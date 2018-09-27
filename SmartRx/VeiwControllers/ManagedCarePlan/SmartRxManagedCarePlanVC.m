//
//  SmartRxManagedCarePlanVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 11/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxManagedCarePlanVC.h"
#import "SmartRxDashBoardVC.h"
#import "AssignedManagedCareplanResponse.h"
#import "AssignedManagedCareplanServiceResponse.h"
#import "AssignedCareplanTableCell.h"
#import "SmartRxManagedCarePlanDetailsVC.h"
#import "ResponseModels.h"

@interface SmartRxManagedCarePlanVC ()
{
    MBProgressHUD *HUD;
    
}
@property(nonatomic,strong) NSArray *assignedCarePlanArray;
@property(nonatomic,strong) NSArray *carePlansArray;
@end

@implementation SmartRxManagedCarePlanVC
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
- (void)viewDidLoad {
    [super viewDidLoad];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Managed Care Program" controler:self];
    self.noAppsLbl.hidden = YES;
    [self.tableView setTableFooterView:[UIView new]];
    [self navigationBackButton];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self makeRequestForAssigendCarePrograms];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Action Methods

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
-(IBAction)clickOnBuyCareProgram:(id)sender{
    [self performSegueWithIdentifier:@"getCareProgramVc" sender:nil];
}
#pragma mark - Request Methods
-(void)makeRequestForAssigendCarePrograms{
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"massinged_wellness_list"];
   
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        if (response == nil)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            //[smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"result......:%@",response);
                //self.assessmentsList=[response objectForKey:@"app"];
                [HUD hide:YES];
                [HUD removeFromSuperview];
                NSArray *carePlans = response[@"assinged_wellness_programs"];
                NSMutableArray *tempArr = [[NSMutableArray alloc]init];
                for (NSDictionary *dict in carePlans) {
                    AssignedManagedCareplanResponse *model = [[AssignedManagedCareplanResponse alloc]init];
                    model.name = dict[@"name"];
                    model.packageName = dict[@"packname"];
                    model.membership = dict[@"membership"];
                    model.patid = dict[@"patid"];
                    model.recno = dict[@"recno"];
                    model.detailedAssessments = dict[@"assess_count"];
                    model.detailedAssessmentsAvailable = dict[@"assess_available"];
                    model.econsults = dict[@"econsults"];
                    model.econsultsAvailable = dict[@"econsults_available"];
                    model.healthCoachFollowUps = dict[@"followup_count"];
                    model.healthCoachFollowUpsAvailable = dict[@"followup_available"];
                    model.careplans = dict[@"careplan_count"];
                    model.careplansAvailable = dict[@"careplan_available"];
                    model.customisedHealthPlan = dict[@"concierge"];
                    model.careManagerAssistance = dict[@"caremanager_assist"];
                    model.ChatWithCareTeam = dict[@"chat_with_careteam"];
                    model.continuousMonitoring = dict[@"continuous_monitioring"];
                    model.newsletters = dict[@"newsletter"];
                    model.secondOpinion = dict[@"second_opinion"];
                    model.secondOpinionAvailable = dict[@"second_opinions_available"];
                    model.miniHealthCheck = dict[@"mini_health_checkup_count"];
                    model.miniHealthCheckAvailable = dict[@"mini_health_checkup_available"];
                    model.expireDate = [self dateConvertor:dict[@"exp_date"]];
                    NSArray *careplanArr = dict[@"postopdetails"];
                    NSMutableArray *careTemp = [[NSMutableArray alloc]init];
                    for (NSDictionary *careDict in careplanArr) {
                        CareWellnessCarePlansResponseModel *care = [[CareWellnessCarePlansResponseModel alloc]init];
                        care.carePlanName = careDict[@"rehabname"];
                        care.careId = careDict[@"postopcareid"];
                        [careTemp addObject:care];
                    }
                    model.carePlansArray = [careTemp copy];
                    NSArray *services = dict[@"service_details"];
                    NSMutableArray *serviceTemp = [[NSMutableArray alloc]init];
                    for (NSDictionary *serviceDict in services) {
                        AssignedManagedCareplanServiceResponse *service = [[AssignedManagedCareplanServiceResponse alloc]init];
                        service.serviceName = serviceDict[@"service_name"];
                        service.serviceTotal = serviceDict[@"quantity"];
                        service.serviceAvailable = serviceDict[@"services_available"];
                        service.serviceId = serviceDict[@"service_id"];
                        [serviceTemp addObject:service];
                    }
                    model.serviceDetailsArray = [serviceTemp copy];
                    [tempArr addObject:model];
                }
                self.assignedCarePlanArray = [tempArr copy];
                if (self.assignedCarePlanArray.count) {
                    self.noAppsLbl.hidden = YES;
                    [self.tableView reloadData];
                }else {
                    self.noAppsLbl.hidden = NO;
                }
            });
        }
    } failureHandler:^(id response) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Network not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 999;
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
}
-(NSString *)dateConvertor:(NSString *)dateStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:dateStr];
    
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    return [formatter stringFromDate:date];
}
-(void)addSpinnerView{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

#pragma mark - Tableview Delegate/Datasource Methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.assignedCarePlanArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AssignedCareplanTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    AssignedManagedCareplanResponse *model = self.assignedCarePlanArray[indexPath.row];
    cell.careProgramNameLbl.text = model.packageName;
    cell.expireDate.text = [NSString stringWithFormat:@"Expiry Date : %@",model.expireDate];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AssignedManagedCareplanResponse *model = self.assignedCarePlanArray[indexPath.row];
    [self performSegueWithIdentifier:@"assignedCareplanDetailsVc" sender:model];
    
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"assignedCareplanDetailsVc"]) {
        SmartRxManagedCarePlanDetailsVC *controller = segue.destinationViewController;
        controller.selectedCarePlan = sender;
    }
}

@end
