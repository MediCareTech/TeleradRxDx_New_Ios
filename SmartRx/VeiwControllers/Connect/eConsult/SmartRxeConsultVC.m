//
//  SmartRxeConsultVC.m
//  SmartRx
//
//  Created by Anil Kumar on 11/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import "SmartRxeConsultVC.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxeConsultCell.h"
#import "SmartRxeConsultDetailsVC.h"
#import "NSString+DateConvertion.h"
#import "SmartRxBookeConsultVC.h"

#define kNoAppsAlertTag 1600
#define htmlData @"<html><body><b>We request you to follow these guidelines for smooth conduct of your E-Consult</b> <ul style=\"padding:6px;margin:6px;\"><li>Enter your symptoms, problems, concerns prior to the start of the E-Consult<br/><br/><li>Attach any lab reports, pictures that could be helpful for the consultation<br/><br/><li>Login 5 mins prior and ensure there is sufficient light in the location you are sitting<br/><br/><li>E-Consult is typically limited to 15 mins and could be extended with mutual consent <br/><br/><li>Note that there is no obligation for the doctor to prescribe medication always<br/><br/><li>If you are not satisfied with the consultation, send us a message and we will review your feedback and refund your money</ul></body></html>"

@interface SmartRxeConsultVC ()
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    BOOL infoShown, viewAppeared;
    NSInteger econsultIndex;
}
@end

@implementation SmartRxeConsultVC
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
    UIImage *faqBtnImag = [UIImage imageNamed:@"info_consult.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [btnFaq addTarget:self action:@selector(homeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
    
}
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.infoWebView loadHTMLString:htmlData baseURL:nil];
    [self navigationBackButton];
    self.arr_eConsult=[[NSMutableArray alloc]init];
    self.lblNoApps.hidden=YES;
    self.tableConsult.hidden=YES;
    //[self makeRequestForAppointments];
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableConsult addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self.tableConsult setTableFooterView:[UIView new]];
    // Do any additional setup after loading the view.
}
-(void)refreshTable
{
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
//    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForeConsult];
        }
        else{
            NSMutableArray *response = [[[SmartRxDB sharedDBManager] fetchEconAptFromDataBase:2] mutableCopy];
           // NSMutableArray *response;
            if ([response count])
            {
                NSMutableArray *samp = [[NSMutableArray alloc]initWithArray:response];
                NSString *strDatTime, *str;
                [self.arr_eConsult removeAllObjects];
                for (int i=0; i < [samp count]; i++)
                {
                    strDatTime=[NSString stringWithFormat:@"%@ %@",[[response objectAtIndex:i]objectForKey:@"appdate"],[[response objectAtIndex:i]objectForKey:@"apptime"]];
                    str =[NSString timeFormating:strDatTime funcName:@"appointment"];
                    if(![str isEqualToString:@"(null) (null)"])
                        [self.arr_eConsult addObject:[response objectAtIndex:i]];
                }
            }
        }
//    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    viewAppeared = YES;
    if ( econsultIndex >= 1 && [[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
    {
        [self performSegueWithIdentifier:@"eConsultDetails" sender:[self.arr_eConsult objectAtIndex:econsultIndex-1]];
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    viewAppeared = NO;
    infoShown = NO;
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
//    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForeConsult];
        }
        else{
            NSMutableArray *response = [[[SmartRxDB sharedDBManager] fetchEconAptFromDataBase:2] mutableCopy];
            if ([response count])
            {
                NSMutableArray *samp = [[NSMutableArray alloc]initWithArray:response];
                NSString *strDatTime, *str;
                [self.arr_eConsult removeAllObjects];
                for (int i=0; i < [samp count]; i++)
                {
                    strDatTime=[NSString stringWithFormat:@"%@ %@",[[response objectAtIndex:i]objectForKey:@"appdate"],[[response objectAtIndex:i]objectForKey:@"apptime"]];
                    str =[NSString timeFormating:strDatTime funcName:@"appointment"];
                    if(![str isEqualToString:@"(null) (null)"])
                        [self.arr_eConsult addObject:[response objectAtIndex:i]];
                    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
                    {
                        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultVideoPush"] == YES)
                        {
                            if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"pushEconsultID"] isEqualToString:[[response objectAtIndex:i]objectForKey:@"appid"]])
                            {
                                econsultIndex = i+1;
                            }
                            
                        }
                        else
                        {
                            if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"pushEconsultID"] isEqualToString:[[response objectAtIndex:i]objectForKey:@"conid"]])
                            {
                                econsultIndex = i+1;
                            }
                        }
                    }
                    if (econsultIndex > 1)
                        break;
                }
                NSLog(@"The econsult index is %d", econsultIndex);
                if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] != YES)
                {
                    if ([self.arr_eConsult count])
                    {
                        self.lblNoApps.hidden=YES;
                        self.bookeConsultView.hidden = NO;
                        self.tableConsult.hidden=NO;
                        [refreshControl endRefreshing];
                        [self.tableConsult reloadData];
                    }
                    else
                    {
                        self.tableConsult.hidden=YES;
                        self.bookeConsultView.hidden = NO;
                        self.lblNoApps.hidden=NO;
                        //\n\n\u2022
                        self.lblNoApps.text = @"\u2022 E-Consults are ideal for feedback on your health queries, follow-ups and second opinions.\n\n\u2022 Book an E-Consult today - It works via video conference or phone call";
                    }
                }
                else
                {
                    if (viewAppeared)
                        [self performSegueWithIdentifier:@"eConsultDetails" sender:[self.arr_eConsult objectAtIndex:econsultIndex-1]];
                }
                
            }
            
        }
//    }
//    else
//    {
//        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
//        {
//            self.bookeConsultView.hidden = NO;
//            self.lblNoApps.hidden=NO;
//            self.lblNoApps.text = @"\u2022 E-Consults are ideal for feedback on your health queries, follow-ups and second opinions.\n\n\u2022 Book an E-Consult today - It works via video conference or phone call";
//        }
//        else
//        {
//            self.bookeConsultView.hidden = YES;
//            self.lblNoApps.hidden=NO;
//            self.lblNoApps.text = @"\u2022 E-Consults are ideal for feedback on your health queries, follow-ups and second opinions.\n\n\u2022 Book an E-Consult today - It works via video conference or phone call\n\n\u2022 Login to view the E-Consult List.";
//        }
//    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
#pragma mark - Action Methods

-(void)backBtnClicked:(id)sender
{
    if (self.fromFindDoctorsORDashboard)
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
-(void)homeBtnClicked:(UIButton *)sender
{
    if (!infoShown) {
        
        [UIView animateWithDuration:0.5 animations:^{
            _viwInfo.hidden=NO;
            
        } completion:^(BOOL finished) {
            infoShown = YES;
        }];
    }
    else{
        [UIView animateWithDuration:0.5 animations:^{
            _viwInfo.hidden=YES;
        } completion:^(BOOL finished) {
            _viwInfo.hidden=YES;
            infoShown = NO;
        }];
    }
}
- (IBAction)okayInfoClicked:(UIButton *)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        _viwInfo.hidden=YES;
    } completion:^(BOOL finished) {
        infoShown = NO;
    }];
    
}

#pragma mark - Request methods
-(void)makeRequestForeConsult
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *type = @"2";
    if (self.scheduleType != nil) {
        type = @"3";
    }
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];

    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&type=%@",@"sessionid",sectionId,type];
    if (self.scheduleType != nil) {
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&sc_type=1"]];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mapt"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
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
            NSMutableArray *samp = [[NSMutableArray alloc]initWithArray:[response objectForKey:@"app"]];
                NSLog(@"samp count:%lu",(unsigned long)samp.count);
            NSString *strDatTime, *str;
            [self.arr_eConsult removeAllObjects];
            for (int i=0; i < [samp count]; i++)
            {
                strDatTime=[NSString stringWithFormat:@"%@ %@",[[[response objectForKey:@"app"] objectAtIndex:i]objectForKey:@"appdate"],[[[response objectForKey:@"app"] objectAtIndex:i]objectForKey:@"apptime"]];
                str =[NSString timeFormating:strDatTime funcName:@"appointment"];
                if(![str isEqualToString:@"(null) (null)"])
                    [self.arr_eConsult addObject:[[response objectForKey:@"app"] objectAtIndex:i]];
                if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
                {
                    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultVideoPush"] == YES)
                    {
                        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"pushEconsultID"] isEqualToString:[[[response objectForKey:@"app"] objectAtIndex:i]objectForKey:@"appid"]])
                        {
                            econsultIndex = i+1;
                        }
                        
                    }
                    else
                    {
                        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"pushEconsultID"] isEqualToString:[[[response objectForKey:@"app"] objectAtIndex:i]objectForKey:@"conid"]])
                        {
                            econsultIndex = i+1;
                        }
                    }
                }
                if (econsultIndex > 1)
                    break;
            }
            if ([self.arr_eConsult count])
            {
                //[[SmartRxDB sharedDBManager] saveEconApt:self.arr_eConsult];
            }
            NSLog(@"The econsult index is %ld", (long)econsultIndex);
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] != YES)
            {
                if ([self.arr_eConsult count])
                {
                    self.lblNoApps.hidden=YES;
                    self.bookeConsultView.hidden = NO;
                    self.tableConsult.hidden=NO;
                    [refreshControl endRefreshing];
                    [self.tableConsult reloadData];
                }
                else
                {
                    self.tableConsult.hidden=YES;
                    self.bookeConsultView.hidden = NO;
                    self.lblNoApps.hidden=NO;
                    //\n\n\u2022
                    self.lblNoApps.text = @"\u2022 E-Consults are ideal for feedback on your health queries, follow-ups and second opinions.\n\n\u2022 Book an E-Consult today - It works via video conference or phone call";
                }
            }
            else
            {
                if (viewAppeared)
                    [self performSegueWithIdentifier:@"eConsultDetails" sender:[self.arr_eConsult objectAtIndex:econsultIndex-1]];
            }
            
                        });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading E-Consult list failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
    return [self.arr_eConsult count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"APPCell";
    SmartRxeConsultCell *cell=(SmartRxeConsultCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setCellData:[self.arr_eConsult copy] row:indexPath.row];
    
    //To customize the separatorLines
    UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cell.frame.size.height-1, self.tableConsult.frame.size.width-1, 1)];
    separatorLine.backgroundColor = [UIColor lightGrayColor];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell addSubview:separatorLine];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"shikgouieahy:%@",[self.arr_eConsult objectAtIndex:indexPath.row]);
    [self performSegueWithIdentifier:@"eConsultDetails" sender:[self.arr_eConsult objectAtIndex:indexPath.row]];
    
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
        [self makeRequestForeConsult];
    }
    else{
        
        NSMutableArray *response = [[[SmartRxDB sharedDBManager] fetchEconAptFromDataBase:2] mutableCopy];
        if ([response count])
        {
            NSMutableArray *samp = [[NSMutableArray alloc]initWithArray:response];
            NSString *strDatTime, *str;
            [self.arr_eConsult removeAllObjects];
            for (int i=0; i < [samp count]; i++)
            {
                strDatTime=[NSString stringWithFormat:@"%@ %@",[[response objectAtIndex:i]objectForKey:@"appdate"],[[response objectAtIndex:i]objectForKey:@"apptime"]];
                str =[NSString timeFormating:strDatTime funcName:@"appointment"];
                if(![str isEqualToString:@"(null) (null)"])
                    [self.arr_eConsult addObject:[response objectAtIndex:i]];
                if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
                {
                    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultVideoPush"] == YES)
                    {
                        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"pushEconsultID"] isEqualToString:[[response objectAtIndex:i]objectForKey:@"appid"]])
                        {
                            econsultIndex = i+1;
                        }
                        
                    }
                    else
                    {
                        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"pushEconsultID"] isEqualToString:[[response objectAtIndex:i]objectForKey:@"conid"]])
                        {
                            econsultIndex = i+1;
                        }
                    }
                }
                if (econsultIndex > 1)
                    break;
            }
            NSLog(@"The econsult index is %d", econsultIndex);
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] != YES)
            {
                if ([self.arr_eConsult count])
                {
                    self.lblNoApps.hidden=YES;
                    self.bookeConsultView.hidden = NO;
                    self.tableConsult.hidden=NO;
                    [refreshControl endRefreshing];
                    [self.tableConsult reloadData];
                }
                else
                {
                    self.tableConsult.hidden=YES;
                    self.bookeConsultView.hidden = NO;
                    self.lblNoApps.hidden=NO;
                    //\n\n\u2022
                    self.lblNoApps.text = @"\u2022 E-Consults are ideal for feedback on your health queries, follow-ups and second opinions.\n\n\u2022 Book an E-Consult today - It works via video conference or phone call";
                }
            }
            else
            {
                if (viewAppeared)
                    [self performSegueWithIdentifier:@"eConsultDetails" sender:[self.arr_eConsult objectAtIndex:econsultIndex-1]];
            }
            
        }
        
        
        
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


#pragma mark - TableView Storyboard Preapare segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"eConsultDetails"])
    {
        ((SmartRxeConsultDetailsVC *)segue.destinationViewController).dictResponse = [[NSMutableDictionary alloc] init];
        ((SmartRxeConsultDetailsVC *)segue.destinationViewController).dictResponse = sender;
        if (self.scheduleType != nil) {
            ((SmartRxeConsultDetailsVC *)segue.destinationViewController).scheduleType = @"3";
        }

    } else if([segue.identifier isEqualToString:@"calendar"]){
        SmartRxBookeConsultVC *controller = segue.destinationViewController;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
- (IBAction)bookEconsultClicked:(id)sender
{
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
        [self performSegueWithIdentifier:@"calendar" sender:nil];
    
}
@end


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

