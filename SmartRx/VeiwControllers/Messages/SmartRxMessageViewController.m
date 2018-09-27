//
//  SmartRxMessageViewController.m
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxMessageViewController.h"
#import "SmartRxMessageDetailsVC.h"
#import "SmartRxCommonClass.h"
#import "NetworkChecking.h"
#import "SmartRxCarePlaneDetailsVC.h"
#import "SmartRxBookServicesController.h"

#define kIntalMsgRow 3
#define kNoMsgsAlertTag 1600

@interface SmartRxMessageViewController ()
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    CGSize viewSize;
    BOOL isMoreSelected;
    UIRefreshControl *refreshControl;
    BOOL isRefreshClicked;
    NSInteger selectedIndex;
}

@end

@implementation SmartRxMessageViewController

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
    
}
#pragma mark - View Life Cycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self navigationBackButton];
    viewSize=[UIScreen mainScreen].bounds.size;
    self.dstMsgDetails=[[NSMutableDictionary alloc]init];
    self.arrMsgDetails=[[NSArray alloc]init];
    self.tblMessages.hidden=YES;
    self.btnMoreMsgs.hidden=YES;
    self.lblmsgs.text = @"No messages to show.\n\u2022 You can get regular advice, tips and alert messages related to your health condition\n\u2022 Ask your doctor or hospital to subscribe for Messages";
    self.lblmsgs.hidden=YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForMessages];
    }
    else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
    }
    
    isMoreSelected=NO;
    isRefreshClicked=NO;
    
    
    
	refreshControl = [[UIRefreshControl alloc]init];
    [self.tblMessages addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self.tblMessages setTableFooterView:[UIView new]];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fromMsgDetails"] boolValue])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"fromMsgDetails"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self refreshTable];
        self.fromDetails = NO;
    }
    
  //  self.arrMsgDetails = [[SmartRxDB sharedDBManager] fetchMessagesFromDataBase];
    NSArray *array = [self.arrMsgDetails valueForKey:@"recno"];
    if ([self.arrMsgDetails count] == self.numberOfMsgs && [array containsObject:self.strLastMsgId])
    {
        self.tblMessages.hidden=NO;
        [self.tblMessages reloadData];
    }
    else{
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
            [self makeRequestForMessages];
        else
        {
              self.lblmsgs.hidden=NO;
//            _arrMsgDetails=[[SmartRxDB sharedDBManager] fetchMessagesFromDataBase];
//            if ([self.arrMsgDetails count])
//            {
//                self.tblMessages.hidden=NO;
//                [self.tblMessages reloadData];
//            }
//            else{
//                self.lblmsgs.hidden=NO;
//            }
        }
    }
}

-(void)refreshTable
{
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        isRefreshClicked=YES;
        [self makeRequestForMessages];
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
#pragma mark - swipeDelegate methods
-(void)swipeCellRightDoneBtnClicked:(UITableViewCell *)sender
{
    NSLog(@"swipeCellRightDoneBtnClicked");
    NSIndexPath *path=[self.tblMessages indexPathForCell:sender];
    selectedIndex=path.row;
//    if (![[[_arrMsgDetails objectAtIndex:selectedIndex]objectForKey:@"status"] isEqualToString:@"2"])
//    {
////            [self loadTrackers:path];
//    }
    if([[[_arrMsgDetails objectAtIndex:path.row] objectForKey:@"postop_rectype"]integerValue] > 0)
    {
        [self makeRequestToUpdateMsgStatus:[[self.arrMsgDetails objectAtIndex:selectedIndex]objectForKey:@"recno"]statusVal:2];        
        NSDictionary *dicttemp=[NSDictionary dictionaryWithObjectsAndKeys:[[_arrMsgDetails objectAtIndex:selectedIndex]objectForKey:@"postop_rectype"],@"postop_rectype",[[_arrMsgDetails objectAtIndex:selectedIndex]objectForKey:@"postopid"],@"postopid",[[_arrMsgDetails objectAtIndex:selectedIndex]objectForKey:@"recno"],@"recno",[[_arrMsgDetails objectAtIndex:selectedIndex]objectForKey:@"status"],@"status", nil];
        [self performSegueWithIdentifier:@"MsgToCarePlanID" sender:dicttemp];
        
    }
    else
    {
        //TODO
        if([[[self.arrMsgDetails objectAtIndex:selectedIndex] objectForKey:@"dcw_type"]integerValue] == 1)
        {
            NSLog(@"swipeCellRightDoneBtnClicked dcw_type");
            //serviceListVc
            SmartRxBookServicesController *controller= [self.storyboard instantiateViewControllerWithIdentifier:@"serviceListVc"];
            [self.navigationController pushViewController:controller animated:YES];
           // [self performSegueWithIdentifier:@"servFromMsg" sender:nil];
        }
        else if ([[[self.arrMsgDetails objectAtIndex:selectedIndex] objectForKey:@"dcw_type"]integerValue] == 2)
        {
            [self performSegueWithIdentifier:@"econFromMsg" sender:nil];
        }
        else if ([[[self.arrMsgDetails objectAtIndex:selectedIndex]objectForKey:@"status"] integerValue] >= 1)
        {
            [self makeRequestToUpdateMsgStatus:[[self.arrMsgDetails objectAtIndex:selectedIndex]objectForKey:@"recno"]statusVal:2];
        }
        //        [self deleteTracker];
    }
    
//    NSIndexPath *path=[self.tblMessages indexPathForCell:sender];
//    selectedIndex=path.row;
//    if (![[[_arrMsgDetails objectAtIndex:selectedIndex]objectForKey:@"status"] isEqualToString:@"2"])
//    {
//        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
//        if ([networkAvailabilityCheck reachable])
//            [self makeRequestToupdateMessage:@"2"];
//        else
//            [self customAlertView:@"" Message:@"Network not available" tag:0];
//        [[SmartRxDatabase shareManager] updateObjectInCoreData:[[_arrMsgDetails objectAtIndex:selectedIndex]objectForKey:@"recno"] value:@"2"];
//        _arrMsgDetails=[[SmartRxDatabase shareManager] fetchMessagesFromDataBase];
//        [_tblMessages reloadData];
//    }
}
-(void)swipeCellRightUpdateBtnClicked:(UITableViewCell *)sender
{
    NSIndexPath *path=[self.tblMessages indexPathForCell:sender];
    selectedIndex=path.row;
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"This message will be deleted" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    alertView.tag = 2020;
    [alertView show];
}



#pragma mark - Action Methods
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)moreMsgBtnClicked:(id)sender
{
    if ([self.arrMsgDetails count] > 3)
    {
        isMoreSelected=YES;
        self.btnMoreMsgs.hidden=YES;
        self.tblMessages.frame=CGRectMake(self.tblMessages.frame.origin.x, self.tblMessages.frame.origin.y, self.tblMessages.frame.size.width, viewSize.height-20);
        [self.tblMessages reloadData];
    }
    else{
        self.btnMoreMsgs.hidden=YES;
        [self customAlertView:@"No more messages" Message:@"" tag:0];
    }
}

#pragma mark - Custom Methods

-(NSString *)convertHTML :(NSString *)html {
    
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}
-(void)makeRequestForMessages
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mmsg"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 24 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            self.arrMsgDetails=[response objectForKey:@"msg"];
            if ([self.arrMsgDetails count])
            {
                [[SmartRxDB sharedDBManager] saveMessages:_arrMsgDetails];
            }
        dispatch_async(dispatch_get_main_queue(), ^{            
            if ([self.arrMsgDetails count])
            {
                self.tblMessages.hidden=NO;
                [refreshControl endRefreshing];
                if (!isRefreshClicked) {
                   // self.btnMoreMsgs.hidden=NO;
                }
                
                [self.tblMessages reloadData];
            }
            else
            {
                self.tblMessages.hidden = YES;
                self.lblmsgs.hidden=NO;
            }
            
        });
            
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}
- (void)makeRequestToUpdateMsgStatus:(NSString *)msgID statusVal:(int)status
{
//    if (![HUD isHidden]) {
//        [HUD hide:YES];
//    }
//    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"sessionid=%@&msgid=%@&status=%d",sectionId,msgID,status];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mupmsgstatus"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 24 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else
        {
            [self makeRequestForMessages];
        }
        
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
    }];

}
-(void)addSpinnerView
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}

#pragma mark - TableView DataSource/Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.arrMsgDetails count])
    {
        
        if (isMoreSelected)
        {
            return [self.arrMsgDetails count];
        }
        else{
            if ([self.arrMsgDetails count] < 4)
            {
                self.btnMoreMsgs.hidden=YES;
                return [self.arrMsgDetails count];
            }
            else{
                self.btnMoreMsgs.hidden=NO;
                return kIntalMsgRow;
            }
        }
    }
    else{
        return 0;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"messageCell";
    SmartRxMessageTVC *cell=(SmartRxMessageTVC *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self.dstMsgDetails setObject:[[self.arrMsgDetails objectAtIndex:indexPath.row]objectForKey:@"updateddate"] forKey:@"Time"];
    NSString *alerttxt=[NSString stringWithFormat:@"%@", [[self.arrMsgDetails objectAtIndex:indexPath.row]objectForKey:@"alerttxt"]];
    [self.dstMsgDetails setObject:@"Care Message" forKey:@"Name"];
    [self.dstMsgDetails setObject:[[self.arrMsgDetails objectAtIndex:indexPath.row]objectForKey:@"operation"] forKey:@"operation"];
    [self.dstMsgDetails setObject:[self convertHTML:alerttxt] forKey:@"Msg"];
    [(SmartRxMessageTVC *)cell setmessageInfo:[self.arrMsgDetails objectAtIndex:indexPath.row]];
    cell.swipeCellDelegate=self;    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[self.arrMsgDetails objectAtIndex:indexPath.row]objectForKey:@"status"] integerValue] == 1)
        [self makeRequestToUpdateMsgStatus:[[self.arrMsgDetails objectAtIndex:indexPath.row]objectForKey:@"recno"]statusVal:3];
    
    
    NSString *alerttxt=[NSString stringWithFormat:@"%@", [[self.arrMsgDetails objectAtIndex:indexPath.row]objectForKey:@"alerttxt"]];
    
    SmartRxMessageTVC *cell=(SmartRxMessageTVC *)[tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    NSString *strTitle=cell.lblSenderName.text;
    UIImage *imgMessages=cell.imgViewMessages.image;
    
     NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:[self convertHTML:alerttxt],@"msg",[[self.arrMsgDetails objectAtIndex:indexPath.row]objectForKey:@"updateddate"],@"time",strTitle,@"title",imgMessages,@"images", nil];
    [self performSegueWithIdentifier:@"MessageDetails" sender:[self.arrMsgDetails objectAtIndex:indexPath.row]];
}
#pragma mark - TableView Storyboard Preapare segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MessageDetails"]) {
        
        ((SmartRxMessageDetailsVC *)segue.destinationViewController).dictMsgDetails = [[NSDictionary alloc] initWithDictionary:sender];
    }
    else if ([segue.identifier isEqualToString:@"MsgToCarePlanID"])
    {
        ((SmartRxCarePlaneDetailsVC *)segue.destinationViewController).strRectype=[sender objectForKey:@"postop_rectype"];
        ((SmartRxCarePlaneDetailsVC *)segue.destinationViewController).strTitle=[sender objectForKey:@"title"];
        ((SmartRxCarePlaneDetailsVC *)segue.destinationViewController).strOpId=[sender objectForKey:@"postopid"];
        
//        if (![[sender objectForKey:@"status"] isEqualToString:@"2"])
//        {
//            ((SmartRxCarePlaneDetailsVC *)segue.destinationViewController).strQid=[sender objectForKey:@"recno"];
//        }
    }
}
#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kNoMsgsAlertTag && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == 2020 && buttonIndex == 1)
    {
        [self makeRequestToUpdateMsgStatus:[[self.arrMsgDetails objectAtIndex:selectedIndex]objectForKey:@"recno"]statusVal:-1];
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForMessages];
        }
        else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }

    }
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
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForMessages];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
}
-(void)errorSectionId:(id)sender
{
    self.view.userInteractionEnabled = YES;
}


@end
