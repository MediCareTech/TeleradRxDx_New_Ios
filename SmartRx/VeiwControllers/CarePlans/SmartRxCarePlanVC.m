//
//  SmartRxCarePlanVC.m
//  SmartRx
//
//  Created by PaceWisdom on 09/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxCarePlanVC.h"
#import "SmartRxCommonClass.h"
#import "SmartRxCarePlaneSubVC.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"

#define kNoCarePlaneAlertView 7000

@interface SmartRxCarePlanVC ()
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    NSInteger careIndex;
}

@end

@implementation SmartRxCarePlanVC

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
    btnFaq.tag=1;
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
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Care Plans" controler:self];

    [self navigationBackButton];
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tblCarePlan addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self.tblCarePlan setTableFooterView:[UIView new]];
}
- (void)viewDidAppear:(BOOL)animated
{
    self.arrCarePlans=[[NSMutableArray alloc]init];
    self.tblCarePlan.hidden=YES;
    self.lblNoCarePlans.hidden=YES;    
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForCarePlan];
    }
    else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
    }
}
-(void)refreshTable
{
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForCarePlan];
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
#pragma mark - Action Methods
-(void)faqBtnClicked:(id)sender
{
}
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
#pragma mark - Request
- (void)unsubscribeClicked:(UIButton *)sender
{
    // find the cell that contains the button, this might be one or two levels
    // up depending on how you created the button (one level in code, two in IB, probably)
    UIView *view = sender.superview;
    while (view && ![view isKindOfClass:[UITableViewCell self]]) view = view.superview;
    
    UITableViewCell *cell = (UITableViewCell *)view;
    NSIndexPath *indexPath = [self.tblCarePlan indexPathForCell:cell];
    NSLog(@"cell is in section %d, row %d", indexPath.section, indexPath.row);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to Unsubscribe?" delegate:sender cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = indexPath.row + 100;
    alert.delegate = self;
    [alert show];
}

- (void)makeRequestToUnsubscribeCarePlan:(NSString *)careID
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&careid=%@",@"sessionid",sectionId, careID];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mdcare"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"Care Plan sucess %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[response objectForKey:@"removed"] integerValue] == 1)
                {
                    self.arrCarePlans = [self.arrCarePlans mutableCopy];
                    [self.arrCarePlans removeObjectAtIndex:careIndex];
                }
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                [refreshControl endRefreshing];
                if ([self.arrCarePlans count])
                {
                    self.tblCarePlan.hidden=NO;
                    self.lblNoCarePlans.hidden = YES;
                    [self.tblCarePlan reloadData];
                }
                else{
                    self.tblCarePlan.hidden = YES;
                    self.lblNoCarePlans.text = @"No Care Plans assigned.\n\n\u2022 Care plan provides detailed information and regular text messages to help improve your rehab process after surgery";
                    self.lblNoCarePlans.hidden=NO;
                    //                [self customAlertView:@"" Message:@"No care plans information are available " tag:kNoCarePlaneAlertView];
                }
                
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"" Message:@"Fetching care plans failed due to network issues. Please try again." tag:0];
    }];
}

-(void)makeRequestForCarePlan
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mpostop"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"Care Plan sucess %@",response);
//        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
//        {
//            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
//            smartLogin.loginDelegate=self;
//            [smartLogin makeLoginRequest];
//        }
      //  else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            [refreshControl endRefreshing];
            self.arrCarePlans=[response objectForKey:@"postopdetails"];
            if ([self.arrCarePlans count])
            {
                self.tblCarePlan.hidden=NO;
                self.lblNoCarePlans.hidden = YES;
                [self.tblCarePlan reloadData];
            }
            else{
                self.lblNoCarePlans.text = @"No Care Plans assigned.\n\n\u2022 Care plan provides detailed information and regular text messages to help improve your rehab process after surgery";
                self.lblNoCarePlans.hidden=NO;
//                [self customAlertView:@"" Message:@"No care plans information are available " tag:kNoCarePlaneAlertView];
            }
            
        });
        //}
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"" Message:@"Fetching care plans failed due to network issues. Please try again." tag:0];
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
    return [self.arrCarePlans count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"CareCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    cell.textLabel.numberOfLines=2;
    cell.textLabel.text=[[self.arrCarePlans objectAtIndex:indexPath.row]objectForKey:@"rehabname"];
//    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    UIButton *unsubBtn = [[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width-60, 5.0f, 60.0f, 35.0f)];// [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    unsubBtn.frame = CGRectMake(cell.frame.size.width-50, 0.0f, 25.0f, 25.0f);
    [unsubBtn setImage:[UIImage imageNamed:@"unsubscribe.png"] forState:UIControlStateNormal];
//    unsubBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    unsubBtn.tag = indexPath.row;
    [unsubBtn addTarget:self action:@selector(unsubscribeClicked:) forControlEvents:UIControlEventTouchUpInside];
    if ([[self.arrCarePlans objectAtIndex:indexPath.row]objectForKey:@"wellness_prog_id"] == nil) {
        [cell addSubview:unsubBtn];
    }
    else  if ([[[self.arrCarePlans objectAtIndex:indexPath.row]objectForKey:@"wellness_prog_id"] integerValue] == 0) {
        [cell addSubview:unsubBtn];
    }
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:[[self.arrCarePlans objectAtIndex:indexPath.row]objectForKey:@"postopcareid"],@"careid",[[self.arrCarePlans objectAtIndex:indexPath.row]objectForKey:@"rehabname"],@"Title", nil];
    [self performSegueWithIdentifier:@"CarePlanSubID" sender:dictTemp];

}

#pragma mark - prepareForSegue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CarePlanSubID"])
    {
        ((SmartRxCarePlaneSubVC *)segue.destinationViewController).strOpId=[sender objectForKey:@"careid"];
        ((SmartRxCarePlaneSubVC *)segue.destinationViewController).strTitle=[sender objectForKey:@"Title"];
    }
}
#pragma mark - Aletview Delegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kNoCarePlaneAlertView && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag >= 100 && buttonIndex == 0)
    {
        NSInteger index = alertView.tag - 100;
        careIndex = index;
        [self makeRequestToUnsubscribeCarePlan:[[self.arrCarePlans objectAtIndex:index]objectForKey:@"postopcareid"]];
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
        [self makeRequestForCarePlan];
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
- (IBAction)getCarePlan:(id)sender
{
    [self performSegueWithIdentifier:@"getcarePlan" sender:nil];
}
@end
