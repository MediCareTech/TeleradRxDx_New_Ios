//
//  SmartRxeServicesVC.m
//  SmartRx
//
//  Created by Manju Basha on 19/10/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxeServicesVC.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxServicesCell.h"
#import "NSString+DateConvertion.h"
#import "SmartRxServicesDetails.h"
@interface SmartRxeServicesVC ()
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    BOOL infoShown, viewAppeared;
    NSInteger serviceIndex;
    

}
@end

@implementation SmartRxeServicesVC

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
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self navigationBackButton];
    self.arrServices=[[NSMutableArray alloc]init];
    [self.tableServicesList setTableFooterView:[UIView new]];
    // Do any additional setup after loading the view.
}
-(void)refreshTable
{
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
//    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForList];
        }
        else
        {
            NSArray *temp = [[SmartRxDB sharedDBManager] fetchServiceListFromDataBase];
            if ([temp count])
                [self processServicesResponse:temp];
            else
            {
                self.tableServicesList.hidden=YES;
                self.lblNoServ.hidden=NO;
                [self customAlertView:@"" Message:@"Network not available" tag:0];
            }
        }
//    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    viewAppeared = YES;
    if ( serviceIndex >= 1 && [[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
    {
        [self performSegueWithIdentifier:@"eConsultDetails" sender:[self.arrServices objectAtIndex:serviceIndex-1]];
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
            [self makeRequestForList];
        }
        else
        {
            NSArray *temp = [[SmartRxDB sharedDBManager] fetchServiceListFromDataBase];
            if ([temp count])
                [self processServicesResponse:temp];
            else
            {
                self.tableServicesList.hidden=YES;
                self.lblNoServ.hidden=NO;
                [self customAlertView:@"" Message:@"Network not available" tag:0];
            }
        }
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

#pragma mark - Request methods

-(void)makeRequestForList
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mslist"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"Services response : \n %@", response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            [[SmartRxDB sharedDBManager] saveServiceList:[response objectForKey:@"services"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                NSArray *samp = [response objectForKey:@"services"];
                [self processServicesResponse:samp];
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading Services list failed. Please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}

-(void)processServicesResponse:(NSArray *)samp
{
    //    NSMutableArray *samp = [[NSMutableArray alloc]initWithArray:samp];
    NSString *strDatTime, *str;
    [self.arrServices removeAllObjects];
    for (int i=0; i < [samp count]; i++)
    {
        strDatTime=[[samp objectAtIndex:i]objectForKey:@"service_date"];
        str =[NSString timeFormating:strDatTime funcName:@"servicesBooking"];
        if(![str isEqualToString:@"(null) (null)"])
            [self.arrServices addObject:[samp objectAtIndex:i]];
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
        {
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultVideoPush"] == YES)
            {
                if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"pushEconsultID"] isEqualToString:[[samp objectAtIndex:i]objectForKey:@"recno"]])
                {
                    serviceIndex = i+1;
                }
                
            }
        }
        if (serviceIndex > 1)
            break;
    }
    NSLog(@"The econsult index is %d", serviceIndex);
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] != YES)
    {
        if ([self.arrServices count])
        {
            self.lblNoServ.hidden=YES;
            self.tableServicesList.hidden=NO;
            [refreshControl endRefreshing];
            [self.tableServicesList reloadData];
        }
        else
        {
            self.tableServicesList.hidden=YES;
            self.lblNoServ.hidden=NO;
        }
    }
    else
    {
        if (viewAppeared)
            [self performSegueWithIdentifier:@"eConsultDetails" sender:[self.arrServices objectAtIndex:serviceIndex-1]];
    }
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
    return [self.arrServices count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"ServCell";
    SmartRxServicesCell *cell=(SmartRxServicesCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setCellData:[self.arrServices copy] row:indexPath.row];
    
    //To customize the separatorLines
    UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cell.frame.size.height-1, self.tableServicesList.frame.size.width-1, 1)];
    separatorLine.backgroundColor = [UIColor lightGrayColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell addSubview:separatorLine];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"eServiceDetail" sender:[self.arrServices objectAtIndex:indexPath.row]];
    
}
#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //    if (alertView.tag == kNoAppsAlertTag && buttonIndex == 0)
    //    {
    //        [self.navigationController popViewControllerAnimated:YES];
    //    }
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
        [self makeRequestForList];
    }
    else
    {
        NSArray *temp = [[SmartRxDB sharedDBManager] fetchServiceListFromDataBase];
        if ([temp count])
            [self processServicesResponse:temp];
        else
        {
            self.tableServicesList.hidden=YES;
            self.lblNoServ.hidden=NO;
            [self customAlertView:@"" Message:@"Network not available" tag:0];
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
    if ([segue.identifier isEqualToString:@"eServiceDetail"])
    {
        ((SmartRxServicesDetails *)segue.destinationViewController).dictResponse = [[NSMutableDictionary alloc] init];
        ((SmartRxServicesDetails *)segue.destinationViewController).dictResponse = sender;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
- (IBAction)bookEconsultClicked:(id)sender
{
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
        [self performSegueWithIdentifier:@"servicesBooking" sender:nil];
    
}


@end
