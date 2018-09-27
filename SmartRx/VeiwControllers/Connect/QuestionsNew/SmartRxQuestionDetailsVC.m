//
//  SmartRxQuestionDetailsVC.m
//  SmartRx
//
//  Created by PaceWisdom on 04/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxQuestionDetailsVC.h"
#import "SmartRxPostDetaisVC.h"
#import "SmartRxDashBoardVC.h"
#import "NSString+DateConvertion.h"
#import "QuestionDetailsTVC.h"
#import "AnswerDetailsTVC.h"
#import "SmartRxImageTVC.h"
#import "SmartRxReportImageVC.h"
#import <QuickLook/QuickLook.h>

#define kDesLblStrartPoint 45
#define kAnsLblStartPoint 40

@interface SmartRxQuestionDetailsVC ()<ShowImageInMainView, QLPreviewControllerDataSource, QLPreviewControllerDelegate>{
    MBProgressHUD *HUD;
    CGFloat heightLbl;
    CGFloat heightAnswerLabl;
}

@end

@implementation SmartRxQuestionDetailsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)navigationBackButton
{
    self.navigationItem.hidesBackButton=YES;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"icn_back.png"];
    [backBtn setImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(-40, -2, 100, 40);
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    backButtonView.bounds = CGRectOffset(backButtonView.bounds, 0, -7);
    [backButtonView addSubview:backBtn];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_home.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [btnFaq addTarget:self action:@selector(homeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
}

#pragma mark - Custom AlertView
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
    //[self estimatedHeight];
    self.arrAnswers=[[NSArray alloc]init];
    self.dictQuestionsMaster=[[NSDictionary alloc]init];
    self.lblTitle.text=[self.dictQuestionDetails objectForKey:@"title"];
    self.lblTime.text=[NSString timeFormating:[self.dictQuestionDetails objectForKey:@"time"] funcName:@"questiondetails"];
//    if ([[self.dictQuestionDetails objectForKey:@"Answred"]integerValue] == 1)
//    {
//        self.imgView.image=[UIImage imageNamed:@"icn_click.png"];
//        self.btnPostDetails.hidden=YES;
//    }
//    else if ([[self.dictQuestionDetails objectForKey:@"askrfeed"]integerValue] == 2)
//    {
//        self.navigationItem.title=@"Feedback details";
//        [self.imgView setImage:[UIImage imageNamed:@"icn_chat_bubble.png"]];
//    }
//    else{
//        [self.imgView setImage:[UIImage imageNamed:@"icn_bubble.png"]];
//    }
    
    self.dicSerialized = [[NSMutableDictionary alloc] init];
    
    NSDictionary *size = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Arial" size:16.0],NSFontAttributeName, nil];
    
    self.navigationController.navigationBar.titleTextAttributes = size;
    
    if ([[self.dictQuestionDetails objectForKey:@"askrfeed"]integerValue] == 2)
    {
        self.navigationItem.title=@"Feedback Details";
    }
    else{
        self.navigationItem.title=@"Q & A Details";
    }
    
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"QuestionReply"] == YES)//Question has replyed request server for new answer
    {
        [self requestforQueDetails];
    }
    else{ // Answers already in database
        id response =[[SmartRxDB sharedDBManager] fetchQuestionDetaisFromDataBase:self.dictQuestionDetails];
        self.dictQuestionsMaster=[response valueForKey:@"master"];
        self.arrAnswers=[response valueForKey:@"answers"];
        NSArray *array = [self.arrAnswers valueForKey:@"repid"];
        
        if ([[self.dictQuestionDetails objectForKey:@"lans"]integerValue] == 0 && response )
        {
            
            self.questionImages = nil;
            self.questionImages = [[NSArray alloc] initWithArray:[(NSString *)self.dictQuestionsMaster[@"flocation"] componentsSeparatedByString:@"***"]];
            [self serilaizeDataFromApi:nil];
            [self.tblQusAns reloadData];
        }
        else{
            
            if ([[self.dictQuestionDetails objectForKey:@"lans"]integerValue] != 0 && [array containsObject:[self.dictQuestionDetails objectForKey:@"lans"]])
            {
                self.questionImages = nil;
                self.questionImages = [[NSArray alloc] initWithArray:[(NSString *)self.dictQuestionsMaster[@"flocation"] componentsSeparatedByString:@"***"]];
                [self serilaizeDataFromApi:nil];
                [self.tblQusAns reloadData];
            }
            
            else
            {
                NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
                if ([networkAvailabilityCheck reachable])
                    [self makeRequestForViewQuestions];
                else
                    [self requestforQueDetails];
            }
        }
    }
}

-(void)requestforQueDetails
{
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
        [self makeRequestForViewQuestions];
    else
    {
        id response =[[SmartRxDB sharedDBManager] fetchQuestionDetaisFromDataBase:_dictQuestionDetails];
        self.dictQuestionsMaster=[response valueForKey:@"master"];
        self.arrAnswers=[response valueForKey:@"answers"]; //arrTemp;
        self.questionImages = nil;
        self.questionImages = [[NSArray alloc] initWithArray:[(NSString *)self.dictQuestionsMaster[@"flocation"] componentsSeparatedByString:@"***"]];
        [self serilaizeDataFromApi:nil];
        [self.tblQusAns reloadData];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Request method
-(void)makeRequestForViewQuestions
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"sessionid",sectionId,@"qid",[self.dictQuestionDetails objectForKey:@"qid"]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mviewqa"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 26 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            self.dictQuestionsMaster=[response objectForKey:@"master"];
            self.arrAnswers=[response objectForKey:@"answers"];
            self.questionImages = nil;
            self.questionImages = [[NSArray alloc] initWithArray:[(NSString *)self.dictQuestionsMaster[@"flocation"] componentsSeparatedByString:@"***"]];
            [self serilaizeDataFromApi:response];
            [[SmartRxDB sharedDBManager] saveQuestionDetaislInDataBase:self.dictQuestionDetails master:self.dictQuestionsMaster answers:self.arrAnswers];
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"QuestionReply"];
            [[NSUserDefaults standardUserDefaults]synchronize];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                [self.tblQusAns reloadData];
                self.view.userInteractionEnabled = YES;
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}

-(void)serilaizeDataFromApi:(id)response{
    NSMutableArray *arrUnquieId = [[NSMutableArray alloc] initWithCapacity:[response[@"answers"] count]];
    for (NSDictionary *dicInResponse  in [response objectForKey:@"answers"]) {
        BOOL present = YES;
        if (![arrUnquieId containsObject:[dicInResponse objectForKey:@"repid"]]) {
            [arrUnquieId addObject:[dicInResponse objectForKey:@"repid"]];
            present = NO;
        }
        if (present) {
            NSMutableDictionary *deSerialized = [self.dicSerialized objectForKey:[dicInResponse objectForKey:@"repid"]];
            NSMutableArray *arrImage = [[NSMutableArray alloc] init];
            [arrImage addObjectsFromArray:deSerialized[@"images"]];
            [arrImage addObject:[dicInResponse objectForKey:@"flocation"]];
            [deSerialized setObject:arrImage forKey:@"images"];
            
            [self.dicSerialized setValue:deSerialized forKey:[dicInResponse objectForKey:@"repid"]];
        }else{
            NSMutableDictionary *dicCreate;
            if (!dicInResponse[@"flocation"] || ![dicInResponse[@"flocation"] isEqualToString:@""]) {
                dicCreate = [NSMutableDictionary dictionaryWithObjectsAndKeys:dicInResponse[@"sentmsg"],@"sentmsg", dicInResponse[@"senton"], @"senton", dicInResponse[@"dispname"], @"dispname", [NSMutableArray arrayWithObject:dicInResponse[@"flocation"]], @"images", nil];
            }else{
                dicCreate = [NSMutableDictionary dictionaryWithObjectsAndKeys:dicInResponse[@"sentmsg"],@"sentmsg", dicInResponse[@"senton"], @"senton", dicInResponse[@"dispname"], @"dispname", nil];
            }
            if(dicInResponse[@"iscompleted"])
            {
                [dicCreate setObject:dicInResponse[@"iscompleted"] forKey:@"iscompleted"];
            }
            [self.dicSerialized setObject:dicCreate forKey:[dicInResponse objectForKey:@"repid"]];
        }

    }
    NSLog(@"***************%@",self.dicSerialized );
    self.arrRecordId = nil;
    NSMutableArray *arrToSort = [[NSMutableArray alloc] initWithArray:[self.dicSerialized allKeys]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [arrToSort sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    self.arrRecordId = [[NSArray alloc] initWithArray:arrToSort];
}

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
    
}

#pragma mark - Action Methods

-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)postDetailsBtnClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"postDetailsID" sender:nil];
}

-(void)homeBtnClicked:(id)sender
{
    
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

#pragma mark - Calculating Label Height

-(void)setLblYPostionAndHeight:(CGFloat )height{
    self.lblDescription.frame = CGRectMake(10, 49, 300, height);
    self.lblDescription.text=[self.dictQuestionDetails objectForKey:@"des"];
    
    self.imgDivider.frame=CGRectMake(self.imgDivider.frame.origin.x, self.lblDescription.frame.origin.y+self.lblDescription.frame.size.height,  self.imgDivider.frame.size.width, self.imgDivider.frame.size.height);
    self.btnPostDetails.frame=CGRectMake(self.btnPostDetails.frame.origin.x, self.imgDivider.frame.origin.y+self.imgDivider.frame.size.height+20,  self.btnPostDetails.frame.size.width, self.btnPostDetails.frame.size.height);
    
}

-(void)estimatedHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, 300,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    CGSize maximumLabelSize = CGSizeMake(300,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    heightLbl=expectedLabelSize.height;
    //[self setLblYPostionAndHeight:expectedLabelSize.height+20];
}

#pragma mark - Prepare segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"postDetailsID"])
    {
        ((SmartRxPostDetaisVC *)segue.destinationViewController).dictMsgDetails=self.dictQuestionDetails;
        if ([self.arrAnswers count])
        {
            ((SmartRxPostDetaisVC *)segue.destinationViewController).strRating=[[self.arrAnswers objectAtIndex:[self.arrAnswers count]-1]objectForKey:@"rating"];
        }
    }else if ([segue.identifier isEqualToString:@"zoomImageID"]){
        ((SmartRxReportImageVC *)segue.destinationViewController).strImage=sender;
    }
}

-(void)doctorPatientInfoHide
{
    if ([[self.dictQuestionDetails objectForKey:@"Answred"]integerValue] == 0)
    {
        self.lblDocReply.hidden=YES;
        self.lblDocReplyTime.hidden=YES;
        self.lblHspSays.hidden=YES;
        self.imgViwDoctorReply.hidden=YES;
        
        self.lblPatientName.hidden=YES;
        self.lblPatientReply.hidden=YES;
        self.lblPatientReplyTime.hidden=YES;
        self.imgViwReplyDivider.hidden=YES;
    }
    else if ([[self.dictQuestionDetails objectForKey:@"Answred"]integerValue] == 1)
    {
        self.lblDocReply.hidden=YES;
        self.lblDocReplyTime.hidden=YES;
        self.lblHspSays.hidden=YES;
        self.imgViwDoctorReply.hidden=YES;
        self.lblPatientName.frame=CGRectMake(self.lblPatientName.frame.origin.x, self.lblDescription.frame.origin.y+self.lblDescription.frame.size.height+20,self.lblPatientName.frame.size.width ,self.lblPatientName.frame.size.height);
        self.lblDocReply.frame=CGRectMake(self.lblDocReply.frame.origin.x, self.lblPatientName.frame.origin.y+self.lblDescription.frame.size.height+20,self.lblDocReply.frame.size.width ,self.lblDocReply.frame.size.height);
        
    }
}

#pragma mark - Tableview Delegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrRecordId count] + 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSArray *arrImages = [(NSString *)self.dictQuestionsMaster[@"flocation"] componentsSeparatedByString:@"***"];
        if (!arrImages || [arrImages count] == 0 || [self.dictQuestionsMaster[@"flocation"] isEqualToString:@""]) {
            return 1;
        }else if ([arrImages count] < 3) {
            return 2;
        }
        return ([arrImages count]/3) + 1;
    }else if (section != 0){
        
        if(!self.dicSerialized[self.arrRecordId[section-1]][@"images"] || ([self.dicSerialized[self.arrRecordId[section-1]][@"images"] count] == 0)){
            return 1;
        }else if ([self.dicSerialized[self.arrRecordId[section-1]][@"images"] count] < 3) {
            return 2;
        }
        return (([self.dicSerialized[self.arrRecordId[section-1]][@"images"] count])/3)+1;
    }
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifierQue=@"QuestionDetailsCell";
    static NSString *cellIdentifierAns=@"AnswerDetailsCell";
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            QuestionDetailsTVC *cell=(QuestionDetailsTVC *)[tableView dequeueReusableCellWithIdentifier:cellIdentifierQue forIndexPath:indexPath];
            [cell setQuestionData:self.dictQuestionDetails height:heightLbl];
            return cell;
        }else{
            static NSString *cellIdentifier=@"imagesCell";
            SmartRxImageTVC *cell=(SmartRxImageTVC *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            [cell setImageToData:self.questionImages startCount:indexPath.row -1 imgType:YES];
            cell.delegateImg = self;
            return cell;
        }
    }
    else{
        if (indexPath.row == 0) {
            AnswerDetailsTVC *cell=(AnswerDetailsTVC *)[tableView dequeueReusableCellWithIdentifier:cellIdentifierAns forIndexPath:indexPath];
            NSLog(@"The values sent are  : %@",self.dicSerialized[self.arrRecordId[indexPath.section-1]]);
            [cell setAnswerData:self.dicSerialized[self.arrRecordId[indexPath.section-1]] row:indexPath.section lblHeight:heightLbl];
            return cell;
        }else{
            static NSString *cellIdentifier=@"imagesCell";
            SmartRxImageTVC *cell=(SmartRxImageTVC *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            [cell setImageToData:self.dicSerialized[self.arrRecordId[indexPath.section-1]][@"images"] startCount:indexPath.row -1 imgType:YES];
            cell.delegateImg = self;
            return cell;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat estHeight = 0.0;
    if (indexPath.section == 0)
    {
        if (indexPath.row) {
            return 60.f;
        }
        
        NSString *htmlString=[self.dictQuestionDetails objectForKey:@"des"];
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [self estimatedHeight:[self.dictQuestionDetails objectForKey:@"title"]];
        estHeight = estHeight+heightLbl;        
        [self estimatedHeight:[attrStr string]];
        estHeight = estHeight+heightLbl+60;
        
    }
    else
    {
        if (indexPath.row == 0) {
            NSLog(@"%@",[self.dicSerialized[self.arrRecordId[indexPath.section - 1]] objectForKey:@"sentmsg"]);
            
            NSString *htmlString=[self.dicSerialized[self.arrRecordId[indexPath.section - 1]] objectForKey:@"sentmsg"];
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            [self estimatedHeight:[self.dictQuestionDetails objectForKey:@"dispname"]];
            estHeight = estHeight+heightLbl;
            [self estimatedHeight:[attrStr string]];//[self.dicSerialized[self.arrRecordId[indexPath.section - 1]] objectForKey:@"sentmsg"]];
            estHeight=heightLbl+60;//heightLbl+kAnsLblStartPoint+20;
        }
        else{
            return 60.f;
        }
    }
    return estHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == [self.arrRecordId count] && [[self.dictQuestionDetails objectForKey:@"Answred"]integerValue] != 1)
    {
        return 0;
    }
    return 1.f;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView;
    if (section == [self.arrRecordId count]) {
            
        if(footerView == nil) {
            //allocate the view if it doesn't exist yet
            footerView  = [[UIView alloc] init];
            //we would like to show a gloosy red button, so get the image first
            UIImage *image = [[UIImage imageNamed:@"bg_register.png"]
                              stretchableImageWithLeftCapWidth:8 topCapHeight:8];
            
            //create the button
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setBackgroundImage:image forState:UIControlStateNormal];
            
            //the button should be as big as a table view cell
            
            [button setFrame:CGRectMake(90, 0, 140, 40)];
            
            //set title, font size and font color
            [button setTitle:@"Post Reply" forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            //set action of the button
            [button addTarget:self action:@selector(postDetailsBtnClicked:)
             forControlEvents:UIControlEventTouchUpInside];
            
            //add the button to the view
            
            footerView.backgroundColor = [UIColor whiteColor];
            
            if ([[self.dictQuestionDetails objectForKey:@"Answred"]integerValue] != 1)
            {
                [self.footerButtonView setHidden:NO];
//                [footerView addSubview:button];
            }
            else
            {
                [self.footerButtonView setHidden:YES];
                UIView *footerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
                footerLineView.backgroundColor = [UIColor blueColor];
                [footerView addSubview:footerLineView];
                self.questIsAnswered = [[UILabel alloc] initWithFrame:CGRectMake(170, footerView.frame.origin.y+10, 150, 25)];
                self.questIsAnswered.text = @"Question is Answered.";
                self.questIsAnswered.textColor = [UIColor grayColor];
                self.questIsAnswered.font = [UIFont systemFontOfSize:14.0f];
                [footerView addSubview:self.questIsAnswered];
//                footerView.clipsToBounds = YES;
            }

        }
        
        //return the view for the footer

        tableView.tableFooterView.frame = CGRectMake(0,0, 320, 40);
        tableView.tableFooterView = footerView;
        tableView.contentSize = CGSizeMake(tableView.contentSize.width, tableView.contentSize.height+40);
//        return nil;
        return footerView;
    }else{
        if(footerView == nil) {
            footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
            footerView.backgroundColor = [UIColor blueColor];
            footerView.clipsToBounds = YES;
            
       }
//        tableView.tableFooterView = footerView;
//        return nil;
        return footerView;
    }
    return nil;
}

#pragma mark - Image Delegate
-(void)ShowImageInMainView:(NSString *)imagePath{
    [self performSegueWithIdentifier:@"zoomImageID" sender:imagePath];
}

-(void)openQlPreview:(NSString *)fileUrl{
    [self openFile:fileUrl];
}
    
#pragma mark - Qlpreview
    -(void)openFile:(NSString *)strFilePath{
        [self addSpinnerView];
        [HUD show:YES];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@",kBaseUrlQAImg,strFilePath]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSArray *fileComponents = [strFilePath componentsSeparatedByString:@"."];
            _pdfPath = [documentsDirectory stringByAppendingPathComponent:[@"file." stringByAppendingString:fileComponents[1]]];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [data writeToFile:_pdfPath atomically:YES];
            QLPreviewController *previewer = [[QLPreviewController alloc] init];
            
            [previewer setDataSource:self];
            
            [previewer setCurrentPreviewItemIndex:0];
            
            [[self navigationController] presentViewController:previewer animated:YES completion:^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
            }];
        }];
    }
    
    - (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller{
        return 1;
    }
    
    - (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
        return [NSURL fileURLWithPath:_pdfPath];
    }
    
    -(void)previewControllerWillDismiss:(QLPreviewController *)controller{
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL success = [fileManager removeItemAtPath:_pdfPath error:&error];
        if (success) {
            NSLog(@"deleted file");
        }
        else
        {
            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        }
    }
    
    @end
