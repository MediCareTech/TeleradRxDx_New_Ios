//
//  SmartRxCarePlaneSubVC.m
//  SmartRx
//
//  Created by PaceWisdom on 09/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxCarePlaneSubVC.h"
#import "SmartRxCommonClass.h"
#import "SmartRxCarePlaneDetailsVC.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"
#define kNoCarePlaneAlertTag 7008


@interface SmartRxCarePlaneSubVC ()
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    
}

@end

@implementation SmartRxCarePlaneSubVC

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

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self navigationBackButton];
    self.navigationItem.title=self.strTitle;
   [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];      
    self.arrCareSubPlans=[[NSArray alloc]init];
    self.tblCarePlanSub.hidden=YES;
    self.lblNoCarePlans.hidden=YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    self.dictCarplanIcons=[[NSDictionary alloc]initWithObjectsAndKeys:@"icn_gim.png",@"Exercises",@"icn_lifestyle.png",@"Lifestyle",@"icn_diet.png",@"Diet Nutrition",@"icn_notes.png",@"Notes",@"icn_conditions.png",@"About Condition",@"icn_symptoms.png",@"Signs and Symptoms",@"icn_complications.png",@"Complications",@"icn_sergery.png",@"Surgery Info",@"icn_expect.png",@"What to expect?",@"follow_up.png",@"Follow-ups",@"icn_alarm.png",@"Alarm signs", nil];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForCareSubPlans];
    }
    else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
    }

    refreshControl = [[UIRefreshControl alloc]init];
    [self.tblCarePlanSub addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [self.tblCarePlanSub setTableFooterView:[UIView new]];
    
    // Do any additional setup after loading the view.
}
-(void)refreshTable
{
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForCareSubPlans];
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
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Request
-(void)makeRequestForCareSubPlans
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"sessionid",sectionId,@"opid",self.strOpId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mpostopview"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 10 %@",response);
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            [refreshControl endRefreshing];
            self.arrCareSubPlans=[response objectForKey:@"tabinfo"];
            if ([self.arrCareSubPlans count])
            {
                self.tblCarePlanSub.hidden=NO;
                [self.tblCarePlanSub reloadData];
            }
            else{
                self.tblCarePlanSub.hidden=YES;
                //self.lblNoCarePlans.hidden=NO;
                [self customAlertView:@"" Message:@"No care plans information are available " tag:kNoCarePlaneAlertTag];
            }
            
            
        });
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
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
    return [self.arrCareSubPlans count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"CareSubCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    cell.textLabel.numberOfLines=2;
    cell.textLabel.text=[[self.arrCareSubPlans objectAtIndex:indexPath.row]objectForKey:@"post_care_tab_text"];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image=[UIImage imageNamed:[self.dictCarplanIcons objectForKey:cell.textLabel.text]];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:[[self.arrCareSubPlans objectAtIndex:indexPath.row]objectForKey:@"rectype"],@"type",[[self.arrCareSubPlans objectAtIndex:indexPath.row]objectForKey:@"post_care_tab_text"],@"Title", nil];
    [self performSegueWithIdentifier:@"CarePlanDetailsID" sender:dictTemp];
}

#pragma mark - Alertview Delegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kNoCarePlaneAlertTag && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - prepareForSegue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CarePlanDetailsID"])
    {
        ((SmartRxCarePlaneDetailsVC *)segue.destinationViewController).strRectype=[sender objectForKey:@"type"];
        ((SmartRxCarePlaneDetailsVC *)segue.destinationViewController).strTitle=[sender objectForKey:@"Title"];
        ((SmartRxCarePlaneDetailsVC *)segue.destinationViewController).strOpId=self.strOpId;
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
@end
