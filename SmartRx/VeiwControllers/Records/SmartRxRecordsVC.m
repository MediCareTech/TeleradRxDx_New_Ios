//
//  SmartRxRecordsVC.m
//  SmartRx
//
//  Created by PaceWisdom on 08/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxRecordsVC.h"
#import "SmartRxRecordTableCell.h"
#import "SmartRxCommonClass.h"
#import "NetworkChecking.h"
#import "SmartRxReportImageVC.h"
#import "SmartRxDataTVC.h"
#import "SmartRxImageTVC.h"
#import "ReportsResponseModel.h"
#import "UIImageView+WebCache.h"

#import <QuickLook/QuickLook.h>

@interface SmartRxRecordsVC ()<ShowImageInMainView, QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    CGFloat rowHeight;
    BOOL pdfSuccess;
   
}

@end

@implementation SmartRxRecordsVC

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
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_add_report.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [btnFaq addTarget:self action:@selector(addReport:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
    if (!self.arrEstimatedHeight) {
        self.arrEstimatedHeight = [[NSMutableArray alloc] init];
    }
}

#pragma mark - View Life Cell
- (void)viewDidLoad
{
    [super viewDidLoad];
    pdfSuccess = YES;
   //self.navigationController.navigationBarHidden=YES;
    self.navigationItem.hidesBackButton=YES;
    [self.tblRecords setTableFooterView:[UIView new]];
    [self navigationBackButton];
    //[self commonFunction];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];    
    [self commonFunction];
}

- (void)commonFunction
{
    self.btnReports.selected=YES;
    self.btnPHR.selected=NO;
    self.btnOther.selected=NO;
    self.lblNoRecords.hidden=YES;
    self.tblRecords.hidden=YES;
    self.arrRecords=[[NSArray alloc]init];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tblRecords addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.self.dicSerialized = [[NSMutableDictionary alloc] init];
    
    
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForReports];
    }
    else{
        
        [self customAlertView:@"Network not available" Message:@"" tag:0];
        
    }

}

-(void)refreshTable
{
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForReports];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request methods
-(void)makeRequestForReports
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlab"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           
        NSLog(@"sucess 28 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(),^{
                
           
                [refreshControl endRefreshing];
                //self.tblRecords.hidden = NO;
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                NSMutableArray *array = [[NSMutableArray alloc]init];
              //  NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];

                NSArray *tempArr = response[@"report"];
                for (NSDictionary *dict in tempArr) {
                    ReportsResponseModel *model = [[ReportsResponseModel alloc]init];
                    // model.category = [self getCategory:dict[@"category"]];
                    model.category = dict[@"filetype"];;
                    model.date = [self getDate:dict[@"uploaded_date"]];
                    model.reportDescrption = dict[@"description"];
                    model.imagePath = [self getImagePath:dict[@"path"]];
                    model.uploadedBy = [self getUserType:dict[@"usertype"] name:dict[@"dispname"]];
                    [array addObject:model];
                }
                
                self.recordsArray = [array copy];
                if (self.recordsArray.count) {
                   
                   
                       self.tblRecords.hidden = NO;
                       self.lblNoRecords.hidden = YES;
                        [self.tblRecords reloadData];
                

                } else {
                     self.tblRecords.hidden = YES;
                    self.lblNoRecords.hidden = NO;

                }
                //self.arrRecords=[response objectForKey:@"report"];
            });
            
        }
                           });
    }failureHandler:^(id response) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading reports failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}
-(NSString *)getUserType:(NSString *)userType name:(NSString *)dispname{
    NSInteger type = [userType integerValue];
    NSString *typeStr = @"";
    switch (type) {
        case 1:
            typeStr = [NSString stringWithFormat:@"By %@",dispname];
            break;
        case 2:
            typeStr = @"By Doctor";
            break;
        case 4:
            typeStr = @"By Me";
            break;
        case 6:
            typeStr = @"By Care Manager";
            break;
        case 8:
            typeStr = @"By Care Assistant";
            break;
        default:
            break;
    }
    return typeStr;
}
-(NSString *)getCategory:(NSString *)key{
         NSString *tempKey = [NSString stringWithFormat:@"%@",key];
         NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:@"Lab",@"1",@"Radiology",@"2",@"MI",@"3",@"Discharge summary",@"4",@"Prescriptions",@"5",@"Case sheet",@"6",@"Others",@"7",@"Assessment files",@"11",@"HRA Files",@"12", nil];
         return dict[tempKey];
}
-(NSString *)getImagePath:(NSString *)imageStr{
    NSString *imapePath = @"";
    if (imageStr.length > 3) {
        NSMutableString *str = [[NSMutableString alloc]initWithString:imageStr];
        [str deleteCharactersInRange:NSMakeRange(0, 2)];
        imapePath = str;
    }
    
    return imapePath;
}
-(NSString *)getDate:(NSString *)dateStr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    
    return [dateFormatter stringFromDate:date];
}
-(void)makeRequestForPHR
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mgetphr"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 29 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];	
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                self.arrRecords=[response objectForKey:@"report"];
                [self.tblRecords reloadData];
            });
        }
    } failureHandler:^(id response) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading Appointments Failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}


#pragma mark - TableView DataSource/Delegate Methods


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGRect size = [UIScreen mainScreen].bounds;
    
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size.size.width-110 ,21)];
    
    CGSize maximumLabelSize = CGSizeMake(220, 9999);
    
    NSString *htmlString=@"wueioagh uwjeahp u9iehw q u9jega ioj ag  jios;dbisjkdg iosdfjgh jpios;dfhb  siodj;h jiopsd;hbkljsdfjhg jidfbh ";
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    CGSize expectedLabelSize = [[attrStr string] sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    
    if (expectedLabelSize.height > 50) {
        float tempValue = expectedLabelSize.height - 50.0;
        rowHeight = 115.0+tempValue;
        return  rowHeight;
    }
    return 110.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return rowHeight;
    
}
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    int numberOFSections = 0;
//    if (self.recordsArray.count >0 ) {
//        
//        numberOFSections = 1;
//        self.tblRecords.backgroundView = nil;
//        self.tblRecords.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    } else {
//        
//        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(12, 16, self.tblRecords.frame.size.width-28, 80)];
//        label.text = [NSString stringWithFormat:@"\u2022 No Health Records found. \n\u2022 Use (+) icon to add reports"];
//        label.numberOfLines = 5;
//        label.textAlignment = NSTextAlignmentCenter;
//        self.tblRecords.backgroundView = label;
//        self.tblRecords.separatorStyle = UITableViewCellSelectionStyleNone;
//        
//    }
//    return numberOFSections;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return self.recordsArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SmartRxReportsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reportsCell"];
    cell.delagte = self;
    cell.cellId = indexPath;
    ReportsResponseModel *model = self.recordsArray[indexPath.row];
    cell.addedByLabel.text = model.uploadedBy;
    [cell.addedByLabel sizeToFit];
    cell.dateLabel.text = model.date;
    
    cell.reportTypeLabel.text = model.category;
    if ([model.reportDescrption isKindOfClass:[NSString class]]) {
        
    cell.descriptionLabel.text = model.reportDescrption;
    }
    //[cell.descriptionLabel sizeToFit];
    
    NSString *urlStr = [NSString stringWithFormat:@"%s%@",kBaseUrlQAImg,model.imagePath];
 [cell.imageButton setImage:[UIImage imageNamed:@"pdfFile"] forState:UIControlStateNormal];
    NSURL *url = [NSURL URLWithString:urlStr];
    [cell.imageButton.imageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            //[cell.imageButton setImage:[UIImage imageNamed:@"pdf"] forState:UIControlStateNormal];
           [cell.imageButton setImage:[UIImage imageNamed:@"pdfFile"] forState:UIControlStateNormal];
        } else {
            [cell.imageButton setImage:image forState:UIControlStateNormal];
            
        }
    }];
   
    
//    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (data) {
//            UIImage *image = [UIImage imageWithData:data];
//            if (image) {
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    SmartRxReportsListCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
//                    
//                    if (updateCell)
//                        [updateCell.imageButton setImage:image forState:UIControlStateNormal];
//                    
//                    
//                });
//            }
//        }
//    }];
//    [task resume];
    
    return cell;
    
}
-(void)clickOnImageButton:(NSIndexPath *)indexpath{
    
    ReportsResponseModel *model = self.recordsArray[indexpath.row];
   // [self performSegueWithIdentifier:@"zoomImageID" sender:model.imagePath];
//    SmartRxReportImageVC *imageVc = [self.storyboard instantiateViewControllerWithIdentifier:@"imageVC"];
//    
//    imageVc.strImage = model.imagePath;
//    [self presentViewController:imageVc animated:YES completion:nil];
    
    
    NSString *splitString;
    //    [self.strImage rangeOfString:@"patient"].location != NSNotFound
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(containsString:)])
    {
        if ([model.imagePath containsString:@"patient/data/pat_uploaded_files/"])
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([model.imagePath containsString:@"admin/data/servicefiles/"])
            splitString = @"admin/data/servicefiles/";
    }
    else
    {
        if ([model.imagePath rangeOfString:@"patient/data/pat_uploaded_files/"].location != NSNotFound)
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([model.imagePath rangeOfString:@"admin/data/servicefiles/"].location != NSNotFound)
            splitString = @"admin/data/servicefiles/";
        
    }
    NSArray *arrImg = [model.imagePath componentsSeparatedByString:@","];
    
    NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
    // NSArray *arrExtensionType = [[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"content_images"] componentsSeparatedByString:@"."];
    
    NSArray *arrExtensionType = [[arrImg objectAtIndex:0] componentsSeparatedByString:@"."];
    if ([arrExtensionType count] && [arrFileType containsObject:arrExtensionType[([arrExtensionType count]-1)]]) {
        [self openFile:arrImg[0]];
    }else
        [self imgaeZooming:arrImg[0]];
    
    

    
}

#pragma mark - Custom AlertView
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
         [self makeRequestForReports];
    }
    else{
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
}

-(void)errorSectionId:(id)sender
{
    NSLog(@"error");
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    self.view.userInteractionEnabled = YES;
}

#pragma mark - Action Methods
-(void)addReport:(id)sender
{
    [self performSegueWithIdentifier:@"AddReportsID" sender:nil];
}

-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)imgaeZooming:(NSString *)sender
{
    [self performSegueWithIdentifier:@"zoomImageID" sender:sender];
}

- (IBAction)otherBtnClicked:(id)sender
{
    self.btnReports.selected=NO;
    self.btnPHR.selected=NO;
    self.btnOther.selected=YES;
}

- (IBAction)phrBtnClicked:(id)sender
{
    self.btnReports.selected=NO;
    self.btnPHR.selected=YES;
    self.btnOther.selected=NO;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForPHR];
    }
    else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
    }
}

- (IBAction)reportBtnClicked:(id)sender
{
    self.btnReports.selected=YES;
    self.btnPHR.selected=NO;
    self.btnOther.selected=NO;
}

- (IBAction)backButtonClicked:(id)sender {
    self.navigationController.navigationBarHidden=NO;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -Prepare Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"zoomImageID"])
    {
        if (pdfSuccess) {
            ((SmartRxReportImageVC *)segue.destinationViewController).strImage = sender;
        } else {
            ((SmartRxReportImageVC *)segue.destinationViewController).webUrl = sender;
        }
    }
}

#pragma mark - Image Delegate
-(void)ShowImageInMainView:(NSString *)imagePath{
    [self imgaeZooming:imagePath];
}

-(void)openQlPreview:(NSString *)fileUrl{
    [self openFile:fileUrl];
}

#pragma mark - Qlpreview
-(void)openFile:(NSString *)strFilePath{
    [self addSpinnerView];
    [HUD show:YES];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@",kBaseUrlLabReport,strFilePath]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *fileComponents = [strFilePath componentsSeparatedByString:@"."];
        _pdfPath = [documentsDirectory stringByAppendingPathComponent:[@"file." stringByAppendingString:fileComponents[1]]];

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [data writeToFile:_pdfPath atomically:YES];
        BOOL success = [QLPreviewController canPreviewItem:[NSURL URLWithString:_pdfPath]];
        if (success) {
            QLPreviewController *previewer = [[QLPreviewController alloc] init];
            [previewer setDataSource:self];
            [previewer setCurrentPreviewItemIndex:0];
            previewer.view.tintColor = [UIColor blueColor];
            [[self navigationController] presentViewController:previewer animated:YES completion:^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
            }];
        } else {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            pdfSuccess = NO;
            [self imgaeZooming:strFilePath];
            
        }
    }];
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
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
