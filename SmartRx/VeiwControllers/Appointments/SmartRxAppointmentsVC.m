//
//  SmartRxAppointmentsVC.m
//  SmartRx
//
//  Created by PaceWisdom on 12/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxAppointmentsVC.h"
#import "SmartRxCommonClass.h"
#import "AppointmentTableViewCell.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxAppointmentDetailVC.h"
#import "SmartRxBookAPPointmentVC.h"
#import "SmartRxBookAPPointmentVC.h"

#define kNoAppsAlertTag 1600

@interface SmartRxAppointmentsVC ()
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    CGFloat heightLbl;
}

@end

@implementation SmartRxAppointmentsVC

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
    self.navigationItem.title = @"Appointments";

    heightLbl = 0;
    [self navigationBackButton];
    self.arrAppointments=[[NSMutableArray alloc]init];
    self.lblNoApps.hidden=YES;
    self.tblAppointments.hidden=YES;
    self.lblNoApps.hidden=YES;
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tblAppointments addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self.tblAppointments setTableFooterView:[UIView new]];
    // Do any additional setup after loading the view.
}
-(void)refreshTable
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForAppointments];
        }
        else
        {
            [self.arrAppointments removeAllObjects];
            self.arrAppointments = [[[SmartRxDB sharedDBManager] fetchEconAptFromDataBase:1] mutableCopy];
            if ([self.arrAppointments count])
            {
                self.lblNoApps.hidden=YES;
                self.tblAppointments.hidden=NO;
                [refreshControl endRefreshing];
                [self.tblAppointments reloadData];
            }
            else
            {
                self.tblAppointments.hidden=YES;
                self.lblNoApps.hidden=NO;
                //                self.lblNoApps.text = @"\u2022 No appointments to show. Click “ Book New Appointment” button to book new appointment.";
                self.lblNoApps.text = @"\u2022 Book your appointments here and meet the doctor at the hospital.\n\n\u2022 You will receive a confirmation after you book.";
            }

        }
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForAppointments];
        }
        else{
            if (self.arrAppointments.count) {
                [self.arrAppointments removeAllObjects];
            }
            
            self.arrAppointments = [[[SmartRxDB sharedDBManager] fetchEconAptFromDataBase:1] mutableCopy];
            if ([self.arrAppointments count])
            {
                self.lblNoApps.hidden=YES;
                self.tblAppointments.hidden=NO;
                [refreshControl endRefreshing];
                [self.tblAppointments reloadData];
            }
            else
            {
                self.tblAppointments.hidden=YES;
                self.lblNoApps.hidden=NO;
                //                self.lblNoApps.text = @"\u2022 No appointments to show. Click “ Book New Appointment” button to book new appointment.";
                self.lblNoApps.text = @"\u2022 Book your appointments here and meet the doctor at the hospital.\n\n\u2022 You will receive a confirmation after you book.";
            }
        }
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
        {
            self.lblNoApps.hidden=NO;
            //            self.lblNoApps.text = @"\u2022 No appointments to show. Click “ Book New Appointment” button to book new appointment.";
            self.lblNoApps.text = @"\u2022 Book your appointments here and meet the doctor at the hospital.\n\n\u2022 You will receive a confirmation after you book.";
            
        }
        else
        {
            self.lblNoApps.hidden=NO;
            self.lblNoApps.text = @"\u2022 Login to view the appointment List. Click “Book New Appointment” button to book new appointment.";
        }
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
#pragma mark - Action Methods

-(void)backBtnClicked:(id)sender
{
    if (self.fromFindDoctors)
    {
        for (UIViewController *controller in [self.navigationController viewControllers])
        {
            if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(IBAction)clickOnBookNewApponitmentBtn:(id)sender{
    //bookAppController
    //bookAppointmentVc
    [self performSegueWithIdentifier:@"bookAppController" sender:nil];
}
#pragma mark - Request methods
-(void)makeRequestForAppointments
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *type = @"1";
    if (self.scheduleType != nil) {
        type = @"3";
    }
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&type=%@",@"sessionid",sectionId,type];
    if (self.scheduleType != nil) {
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&sc_type=3"]];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mapt"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            self.arrAppointments = [self.arrAppointments mutableCopy];
            if ([self.arrAppointments count])
                [self.arrAppointments removeAllObjects];                
            self.arrAppointments=[response objectForKey:@"app"];
            [[SmartRxDB sharedDBManager] saveEconApt:self.arrAppointments];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.view.userInteractionEnabled = YES;
                if ([self.arrAppointments count])
                {
                    self.lblNoApps.hidden=YES;
                    self.tblAppointments.hidden=NO;
                    [refreshControl endRefreshing];
                    [self.tblAppointments reloadData];
                }
                else
                {
                    self.tblAppointments.hidden=YES;
                    self.lblNoApps.hidden=NO;
//                self.lblNoApps.text = @"\u2022 No appointments to show. Click “ Book New Appointment” button to book new appointment.";
                    self.lblNoApps.text = @"\u2022 Book your appointments here and meet the doctor at the hospital.\n\n\u2022 You will receive a confirmation after you book.";
                }
                [HUD hide:YES];
                [HUD removeFromSuperview];

            });
        }
    } failureHandler:^(id response) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading appointments failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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

#pragma mark - Tableview Delegate/Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrAppointments count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"APPCell";
    AppointmentTableViewCell *cell=(AppointmentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setCellData:[self.arrAppointments copy] row:indexPath.row];
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat estHeight = 100.0;
    NSString *htmlString=[[self.arrAppointments objectAtIndex:indexPath.row] objectForKey:@"reason"];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    if ([[attrStr string] length] > 0)
    {
        NSArray *tempArr = [[attrStr string] componentsSeparatedByString:@"***"];
        
        if ([tempArr count] == 3 && [[tempArr objectAtIndex:2] length])
        {
            [self estimatedHeight:[tempArr objectAtIndex:2]];
            estHeight = estHeight+heightLbl;
        }
        else if ([tempArr count] == 1)
        {
            [self estimatedHeight:[attrStr string]];
            estHeight = estHeight+heightLbl;
        }
    }
    return estHeight;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SmartRxAppointmentDetailVC *controller =[self.storyboard instantiateViewControllerWithIdentifier:@"appointmentDetailVC"];
    controller.dictResponse = [[NSMutableDictionary alloc]init];
    controller.dictResponse = self.arrAppointments[indexPath.row];
    if (self.scheduleType != nil) {
        controller.scheduleType = @"3";
    }
    [self.navigationController pushViewController:controller animated:YES];
    //NSLog(@"uzsgiihoea:%@",self.arrAppointments[indexPath.row]);
}

-(void)estimatedHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, 300,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont systemFontOfSize:15];// [UIFont fontWithName:@"HelveticaNeue" size:15];
    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(300,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    heightLbl=expectedLabelSize.height;
    //[self setLblYPostionAndHeight:expectedLabelSize.height+20];
}
#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kNoAppsAlertTag && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
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
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForAppointments];
    }
    else{
        [self.arrAppointments removeAllObjects];
        self.arrAppointments = [[[SmartRxDB sharedDBManager] fetchEconAptFromDataBase:1] mutableCopy];
        if ([self.arrAppointments count])
        {
            self.lblNoApps.hidden=YES;
            self.tblAppointments.hidden=NO;
            [refreshControl endRefreshing];
            [self.tblAppointments reloadData];
        }
        else
        {
            self.tblAppointments.hidden=YES;
            self.lblNoApps.hidden=NO;
            //                self.lblNoApps.text = @"\u2022 No appointments to show. Click “ Book New Appointment” button to book new appointment.";
            self.lblNoApps.text = @"\u2022 Book your appointments here and meet the doctor at the hospital.\n\n\u2022 You will receive a confirmation after you book.";
        }
//
//        
//        [self customAlertView:@"" Message:@"Network not available" tag:0];
        
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
#pragma mark - prepareForSegue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"bookAppointmentVc"]) {
        SmartRxBookAPPointmentVC *controller = segue.destinationViewController;
        controller.scheduleType = self.scheduleType;
    }
}

@end
