//
//  SmartRxGetManagedCarePlanVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 11/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxGetManagedCarePlanVC.h"
#import "SmartRxDashBoardVC.h"
#import "AssignedManagedCarePlanDetailsCell.h"
#import "GetCarePlanResponseModel.h"
#import "MembershipTypesResponseModel.h"
#import "AssignedManagedCareplanResponse.h"
#import "AssignedManagedCareplanServiceResponse.h"
#import "SmartRxGetManagedCarePlanDetailsVC.h"
#import "SmartRxManagedCarePlanMembershipDetailsVC.h"
#import "SmartRxPaymentVC.h"
#import "MembershipTypesResponseModel.h"
#import "ResponseModels.h"


@interface SmartRxGetManagedCarePlanVC ()<BuyDelegate>
{
    MBProgressHUD *HUD;
    CGSize viewSize;
    GetCarePlanResponseModel *selectedCareProgram;
    CareWellnessCategoryItemResponseModel *selectedMembership;
    NSString *selectedPatient,*campId;
    BOOL promoApplied;
    double discountedCost;
    NSInteger finalCost, actualCost;
}
@property(nonatomic,strong) NSArray *carePlanArr;
@property(nonatomic,strong) NSArray *careWellnessCategory;
@property(nonatomic,strong) NSArray *careWellnessCategoryItems;
@property(nonatomic,strong) NSArray *dependentsArray;
@end

@implementation SmartRxGetManagedCarePlanVC
+ (id)sharedManagerCarePlanProgram {
    static SmartRxGetManagedCarePlanVC *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
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
- (void)viewDidLoad {
    [super viewDidLoad];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Managed Care Program" controler:self];
    promoApplied = NO;
    viewSize=[[UIScreen mainScreen]bounds].size;

    self.noAppsLbl.hidden = YES;
    [self.tableView setTableFooterView:[UIView new]];
    [self.itemsTableView setTableFooterView:[UIView new]];

    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:backgroundView];
    
    [self navigationBackButton];

    [self initializePickers];
    [self makeRequestForCareProgramsList];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"TransactionSuccess"] )
    {
        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"TransactionSuccess"] boolValue])
        {
            self.paymentResponseDictionary = [[NSUserDefaults standardUserDefaults]objectForKey:@"paymentResponseDictionary"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TransactionSuccess"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"payment dict:%@",self.paymentResponseDictionary);
            [self makeRequestForPurchaseCareProgram:NO];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TransactionSuccess"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self customAlertView:@"" Message:@"Sorry we were not able to process the payment. Please try again after sometime to Buy Care Program." tag:0];
        }
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (void)initializePickers
{
    self.dependentsPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.dependentsPickerView.delegate = self;
    self.dependentsPickerView.dataSource = self;
    self.dependentsPickerView.backgroundColor = [UIColor whiteColor];

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
-(IBAction)clickOnYesBtn:(id)sender{
    [self hideConfirmationView];
    if (finalCost == 0) {
        [self makeRequestForPurchaseCareProgram:YES];
    }else {
          [self customAlertView:@"Note" Message:@"You will be taken to the payment gateway to complete the transaction." tag:2];
    }
   
    
    //econsultSpecialityView
}
-(IBAction)clickOnNoBtn:(id)sender{
    NSLog(@"clickOnNoBtn");
    [self hideConfirmationView];
}
-(IBAction)clickOnCloseItemsView:(id)sender{
    [self hideItemsSubView];
}
-(void)cancelButtonPressed:(id)sender
{
    _actionSheet.hidden = YES;
}
-(void)doneButtonPressed:(id)sender
{
    self.userNameTf.text = [[self.dependentsArray objectAtIndex:[self.dependentsPickerView selectedRowInComponent:0]]objectForKey:@"name"];
    selectedPatient =  [[self.dependentsArray objectAtIndex:[self.dependentsPickerView selectedRowInComponent:0]]objectForKey:@"patid"];
    [self.view endEditing:YES];

    _actionSheet.hidden = YES;


}
- (IBAction)promoApplyBtnClicked:(id)sender
{
    if (self.promoApplyBtn.tag == 666)
    {
        [self.promoCodeText resignFirstResponder];
        if ([self.promoCodeText.text length] > 0 && self.promoCodeText.text != nil)
        {
            [self makeRequestCheckPromo];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Enter valid promo code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    else if (self.promoApplyBtn.tag == 999)
    {
        self.promoApplyBtn.tag = 666;
        [self updatePriceDetails:selectedMembership];
//        NSString *cost = self.consultationDiscountedCost.text;
//        self.consultationActualCost.attributedText =nil;
//        self.consultationActualCost.text = cost;
//        self.consultationDiscountedCost.text = nil;
//        NSArray *arr = [self.consultationActualCost.text componentsSeparatedByString:@" "];
//        if ([arr count]  >= 2)
//            finalCost = [[arr objectAtIndex:1] integerValue];
//        else
//            finalCost = 0;
        [self.promoApplyBtn setTitle:@"APPLY" forState:UIControlStateNormal];
        [self.promoApplyBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bg.png"] forState:UIControlStateNormal];
    }
}
#pragma mark - ConfirmationView Methods

-(void)showConfirmationView{
    [UIView animateWithDuration:0.2 animations:^{
        self.confirmationView.frame=CGRectMake(0,  self.confirmationView.frame.origin.y,  self.confirmationView.frame.size.width,  self.confirmationView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}
-(void)hideConfirmationView{
    [UIView animateWithDuration:0.2 animations:^{
        self.confirmationView.frame=CGRectMake(viewSize.width,  self.confirmationView.frame.origin.y,  self.confirmationView.frame.size.width,  self.confirmationView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}
-(void)updatePurchaseDetails:(CareWellnessCategoryItemResponseModel *)membership{
    selectedMembership = membership;
    self.userNameTf.text = self.dependentsArray[0][@"name"];
    selectedPatient = self.dependentsArray[0][@"patid"];
    [self updatePriceDetails:membership];
    [self.view endEditing:YES];
    [self showConfirmationView];
}
-(void)updatePriceDetails:(CareWellnessCategoryItemResponseModel *)membership{
    NSString *priceStr = nil;
    if ([membership.price integerValue] == 0 ) {
        priceStr = @"Free";
        finalCost = 0;
        self.promoApplyBtn.hidden = YES;
        self.promoCodeText.hidden = YES;
        self.yesNoView.frame = CGRectMake(self.yesNoView.frame.origin.x, self.promoCodeText.frame.origin.y, self.yesNoView.frame.size.width, self.yesNoView.frame.size.height);
    }else {
        priceStr = [NSString stringWithFormat:@"Rs. %@",membership.price];
        finalCost = [membership.price integerValue];
        self.promoApplyBtn.hidden = NO;
        self.promoCodeText.hidden = NO;
        self.yesNoView.frame = CGRectMake(self.yesNoView.frame.origin.x, self.promoCodeText.frame.origin.y+self.promoCodeText.frame.size.height+15, self.yesNoView.frame.size.width, self.yesNoView.frame.size.height);
    }
    self.consultationActualCost.text = priceStr;
    
    if ([membership.oldPrice integerValue] > 0 && [membership.oldPrice integerValue] != [membership.price integerValue]) {
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %@ ", membership.oldPrice]];
        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                value:@2
                                range:NSMakeRange(0, [membership.oldPrice length]+3)];
        self.consultationDiscountedCost.hidden = NO;
        self.consultationDiscountedCost.attributedText = attributeString;
        
    }else{
        self.consultationDiscountedCost.hidden = YES;
    }
}
- (void)showPicker
{
    _pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-260, 320, 44)];
    _pickerToolbar.barStyle = UIBarStyleBlackTranslucent; //UIBarStyleBlackOpaque;
    [_pickerToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [barItems addObject:cancelBtn];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    flexSpace.width = 200.0f;
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [barItems addObject:doneBtn];
    
    [_pickerToolbar setItems:barItems animated:YES];
    
    [_actionSheet addSubview:_pickerToolbar];
    
    [_actionSheet addSubview:self.dependentsPickerView];
    [self.dependentsPickerView reloadAllComponents];
   
    [self.view addSubview:_actionSheet];
    [self.view bringSubviewToFront:_actionSheet];
    _actionSheet.hidden = NO;
    
}
#pragma mark spinner alert & picker
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView;
    if (alertTag == 2)
        alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    else
        alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2 && buttonIndex == 1)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"fromCareProgram"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        SmartRxPaymentVC *paymentVc = [self.storyboard instantiateViewControllerWithIdentifier:@"econsultSpecialityView"];
        paymentVc.costValue = [NSString stringWithFormat:@"%ld", (long)finalCost];
        paymentVc.packageResponse = [[NSMutableDictionary alloc]init];
        paymentVc.packageResponse = self.packageResponse;
        [self.navigationController pushViewController:paymentVc animated:YES];
    }else if(alertView.tag == 3){
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - Request Methods
-(void)makeRequestForCareProgramsList{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mget_wellness_category"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        if (response == nil)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            //[smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                NSLog(@"response.......:%@",response);
                self.dependentsArray = response[@"dependents"];
                NSArray *array =response[@"wellness_programs"];
                NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dict in array) {
                    CareWellnessCategoryResponseModel *model = [[CareWellnessCategoryResponseModel alloc]init];
                    model.wellnessProgramName = dict[@"name"];
                    model.recno = dict[@"recno"];
                    [tempArray addObject:model];
                }
                self.careWellnessCategory = [tempArray copy];
                
                if (self.careWellnessCategory.count) {
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
-(void)makeRequestForCategoryItemsList:(NSString *)categoryId{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&category_id=%@",@"sessionid",sectionId,categoryId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mget_wellness_category_items"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        if (response == nil)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            //[smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                NSLog(@"response.......:%@",response);
                NSArray *array =response[@"wellness_programs"];
                NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dict in array) {
                    CareWellnessCategoryItemsResponseModel *model = [[CareWellnessCategoryItemsResponseModel alloc]init];
                    model.wellnessProgramItemName = dict[@"name"];
                    model.uniqueId = dict[@"unique_id"];
                    [tempArray addObject:model];
                }
                self.careWellnessCategoryItems = [tempArray copy];
                
                if (self.careWellnessCategory.count) {
                    [self.itemsTableView reloadData];
                    [self showItemsSubView];
                }else {
                    NSLog(@"failure case");
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
-(void)makeRequestForCategoryItemDetails:(NSString *)uniqueId{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&unique_id=%@",@"sessionid",sectionId,uniqueId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mget_wellness_program"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        if (response == nil)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            //[smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                NSLog(@"response.......:%@",response);
                NSArray *array =response[@"wellness_programs"];
                NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dict in array) {
                    CareWellnessCategoryItemResponseModel *model = [[CareWellnessCategoryItemResponseModel alloc]init];
                    model.name = [self getMembershipType:dict[@"membership_type"]];
                    model.careProgramName = dict[@"name"];
                    model.title = dict[@"title"];
                    model.membershipType = dict[@"membership_type"];
                    model.packageName = dict[@"pack_name"];
                   // model.membership = dict[@"membership"];
                    model.autoCampaign = dict[@"auto_camp"];
                    model.patid = dict[@"patid"];
                    model.recno = dict[@"recno"];
                    model.packageId = dict[@"pack_id"];//pack_id
                    model.managedCareProgram = dict[@"duration_formatted"];
                    model.price = dict[@"price"];
                    model.detailedAssessments = dict[@"assess_count"];
                    model.econsults = dict[@"econsult_count"];
                    model.healthCoachFollowUps = dict[@"followup_count"];
                    model.careplans = dict[@"careplan_count"];
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
                    model.oldPrice = dict[@"old_price"];
                    model.packageType = dict[@"package_type_id"];
                    NSArray *services = dict[@"service_details"];
                    NSMutableArray *serviceTemp = [[NSMutableArray alloc]init];
                    for (NSDictionary *serviceDict in services) {
                        AssignedManagedCareplanServiceResponse *service = [[AssignedManagedCareplanServiceResponse alloc]init];
                        service.serviceName = serviceDict[@"service_name"];
                        service.serviceTotal = serviceDict[@"quantity"];
                        [serviceTemp addObject:service];
                        
                    }
                    model.serviceDetailsArray = [serviceTemp copy];
                    [tempArray addObject:model];
                }
                NSArray *arra = [tempArray copy];
                if (arra.count > 0) {
                    [self performSegueWithIdentifier:@"membershipDetails" sender:arra];

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
-(void)makeRequestForCarePrograms{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mget_wellness_list"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        if (response == nil)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            //[smartLogin makeLoginRequest];
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //self.assessmentsList=[response objectForKey:@"app"];
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                NSLog(@"data......:%@",response);

                self.dependentsArray = response[@"dependents"];
                NSArray *carePlans = response[@"wellness_programs"];
                NSArray *membershipTypesArr = response[@"membershiptypes"];
                NSMutableArray *tempArr = [[NSMutableArray alloc]init];
                for (NSDictionary *tempDict in carePlans) {
                    GetCarePlanResponseModel *getCarePlanModel = [[GetCarePlanResponseModel alloc]init];
                    getCarePlanModel.carePlanName = tempDict[@"name"];
                    getCarePlanModel.recno = tempDict[@"recno"];
                    NSMutableArray *typeTempArr = [[NSMutableArray alloc]init];
                    for (NSDictionary *typesDict in membershipTypesArr) {
                    NSString *renoStr = typesDict[@"recno"];
                    NSDictionary *dict = tempDict[@"types"][renoStr];
                       // NSLog(@"type dict.....:%@",dict);
                    if (dict.count > 0) {
                    MembershipTypesResponseModel *model = [[MembershipTypesResponseModel alloc]init];
                    model.name = [self getMembershipType:dict[@"membership_type"]];
                    model.membershipType = dict[@"membership_type"];
                    model.packageName = dict[@"pack_name"];
                    model.membership = dict[@"membership"];
                    model.autoCampaign = dict[@"auto_camp"];
                    model.patid = dict[@"patid"];
                    model.recno = dict[@"recno"];
                    model.packageId = dict[@"pack_id"];
                    model.managedCareProgram = dict[@"duration_formatted"];
                    model.price = dict[@"price"];
                    model.detailedAssessments = dict[@"assess_count"];
                    model.econsults = dict[@"econsult_count"];
                    model.healthCoachFollowUps = dict[@"followup_count"];
                    model.careplans = dict[@"careplan_count"];
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
                        model.oldPrice = dict[@"old_price"];
                        model.packageType = dict[@"package_type_id"];
                    NSArray *services = dict[@"service_details"];
                    NSMutableArray *serviceTemp = [[NSMutableArray alloc]init];
                    for (NSDictionary *serviceDict in services) {
                        AssignedManagedCareplanServiceResponse *service = [[AssignedManagedCareplanServiceResponse alloc]init];
                        service.serviceName = serviceDict[@"service_name"];
                        service.serviceTotal = serviceDict[@"quantity"];
                        [serviceTemp addObject:service];
                        
                    }
                    model.serviceDetailsArray = [serviceTemp copy];
                    [typeTempArr addObject:model];
                }
                }
                    getCarePlanModel.membershipArray = [typeTempArr copy];
                    [tempArr addObject:getCarePlanModel];
                   
                }
                self.carePlanArr = [tempArr copy];
                if (self.carePlanArr.count) {
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
-(void)makeRequestForPurchaseCareProgram:(BOOL)free{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = nil;
    NSString *promoCode = nil;
    if (promoApplied) {
        if ([selectedMembership.autoCampaign isEqualToString:@""]) {
            promoCode = self.promoCodeText.text;
        }else {
            promoCode = [NSString stringWithFormat:@"%@,%@",selectedMembership.autoCampaign,self.promoCodeText.text];
        }
    }else {
        if ([selectedMembership.autoCampaign isEqualToString:@""]) {
            promoCode = @"";
        }else {
            promoCode = selectedMembership.autoCampaign;
        }
    }
    if (free) {
        bodyText = [NSString stringWithFormat:@"%@=%@&assign_to=%@&packid=%@&campid=%@&amount=0&paymentMode=%@",@"sessionid",sectionId,selectedPatient,selectedMembership.packageId,promoCode,@"2"];
    }else{
    bodyText = [NSString stringWithFormat:@"%@=%@&assign_to=%@&packid=%@&payraw=%@&TxId=%@&TxStatus=%@&amount=%@&authIdCode=%@&TxMsg=%@&pgTxnNo=%@&paymentMode=%@&campid=%@",@"sessionid",sectionId,selectedPatient,selectedMembership.packageId, self.paymentResponseDictionary, [self.paymentResponseDictionary objectForKey:@"TxId"],[self.paymentResponseDictionary objectForKey:@"TxStatus"],[self.paymentResponseDictionary objectForKey:@"amount"] ,[self.paymentResponseDictionary objectForKey:@"authIdCode"] ,[self.paymentResponseDictionary objectForKey:@"TxMsg"] ,[self.paymentResponseDictionary objectForKey:@"pgTxnNo"] ,[self.paymentResponseDictionary objectForKey:@"paymentMode"],promoCode];
}
    NSLog(@"body text......:%@",bodyText);
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"massign_wellness_program"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO successHandler:^(id response) {
        if (response == nil)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            //[smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(),^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            NSLog(@"response.....:%@",response);
            if ([response[@"assigned"] integerValue] == 1) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"membership"];

                [self customAlertView:@"Success" Message:response[@"status_msg"] tag:3];
            }else{
                [self customAlertView:@"Failed" Message:@"Error purchasing care program please try after sometime." tag:0];
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
- (void)makeRequestCheckPromo
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
  
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    NSString *offerFor= @"5";
    NSString *schType = @"";
   
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&for=%@&promocode=%@&pack_type=%@&membership_type=%@",@"cid",strCid,@"sessionid",sectionId, offerFor,self.promoCodeText.text,selectedMembership.packageType,selectedMembership.membershipType];
    }
    else{
        bodyText=[NSString stringWithFormat:@"%@=%@&%@=%@&for=%@&promocode=%@&sc_type=%@",@"cid",strCid,@"isopen",@"1",offerFor, self.promoCodeText.text,schType];
    }
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mchkcamp"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"hi sucessssss %@",response);
        
        if (([response count] == 0 && [sectionId length] == 0))
        {
           // [self makeRequestForUserRegister];
        }
        else
        {
            if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
            {
                SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                smartLogin.loginDelegate=self;
                [smartLogin makeLoginRequest];
                
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    if ([[response objectForKey:@"chkredeem"] integerValue] == )
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    NSString *msg;
                    promoApplied = NO;
                    if ([[response objectForKey:@"chkredeem"] integerValue] == 1)
                    {
                        self.promoApplyBtn.tag = 999;
                        [self.promoApplyBtn setTitle:nil forState:UIControlStateNormal];
                        [self.promoApplyBtn setBackgroundImage:nil forState:UIControlStateNormal];
                        promoApplied = YES;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Promo code applied. Thank you." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        campId = [[[response objectForKey:@"campaign"] objectAtIndex:0] objectForKey:@"recno"];
                        //  discount
                        float discountPercent = [[[[response objectForKey:@"campaign"] objectAtIndex:0] objectForKey:@"discount"] floatValue];
                        discountPercent = discountPercent/100;
                        float discount = finalCost * discountPercent;
                        discountedCost = ceilf(finalCost - discount);
                        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %@", selectedMembership.oldPrice]];
                        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                                value:@2
                                                range:NSMakeRange(0, [attributeString length])];
                        self.consultationDiscountedCost.attributedText = attributeString;
                        finalCost = discountedCost;
                        self.consultationDiscountedCost.hidden = NO;

                        if (discountedCost > 0){
                            self.consultationActualCost.text = [NSString stringWithFormat:@"Rs %d", (int)discountedCost];

                        }
                        else
                        {
                            self.consultationActualCost.text = @"Free";

                        }
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -3)
                    {
                        promoApplied = NO;
                        msg = @"You already used this promo code";
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -4)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"This promo code expired." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -5)
                    {
                        promoApplied = NO;
                        msg = @"Given promo code not sent to this user";
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Name cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -6 || [[response objectForKey:@"chkredeem"] integerValue] == -10)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Promo code is invalid. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -7)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable at this location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -8)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable for this visit." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -9)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable for E-Consults." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    
                });
            }
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
}
-(NSString *)getMembershipType:(NSString *)type{
    NSInteger value = [type integerValue];
    NSLog(@"value......:%ld",(long)value);
    NSString *typeStr = nil;
    
    switch (value) {
        case 1:
            typeStr = @"Silver";
            break;
        case 2:
            typeStr = @"Gold";
            break;
        case 3:
            typeStr = @"Platinum";
            break;
        case 4:
            typeStr = @"Diamond";
           break ;
    }
    NSLog(@"value str......:%@",typeStr);

    return typeStr;
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
-(void)showItemsSubView{
    [UIView animateWithDuration:0.2 animations:^{
        self.itemsSubView.frame = CGRectMake(0,  _itemsSubView.frame.origin.y,  _itemsSubView.frame.size.width,  _itemsSubView.frame.size.height);
    }];
}
-(void)hideItemsSubView{
    [UIView animateWithDuration:0.2 animations:^{
        self.itemsSubView.frame = CGRectMake(viewSize.width,  _itemsSubView.frame.origin.y,  _itemsSubView.frame.size.width,  _itemsSubView.frame.size.height);
    }];
}

#pragma mark - Tableview Delegate/Datasource Methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    if (tableView == self.tableView) {
        count = self.careWellnessCategory.count;
    }else if (tableView == self.itemsTableView){
        count = self.careWellnessCategoryItems.count;
    }

    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (tableView == self.tableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        CareWellnessCategoryResponseModel *model = self.careWellnessCategory[indexPath.row];
        cell.textLabel.text = model.wellnessProgramName;
    }else if (tableView == self.itemsTableView){
        NSLog(@"itemsTableView");
        cell = [tableView dequeueReusableCellWithIdentifier:@"itemsCell"];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        CareWellnessCategoryItemsResponseModel *model = self.careWellnessCategoryItems[indexPath.row];
        cell.textLabel.text = model.wellnessProgramItemName;
    }else {
        NSLog(@"failure");
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tableView) {
        CareWellnessCategoryResponseModel *model = self.careWellnessCategory[indexPath.row];
        [self makeRequestForCategoryItemsList:model.recno];

    }else if (tableView == _itemsTableView){
        NSLog(@"success case");
        CareWellnessCategoryItemsResponseModel *model = self.careWellnessCategoryItems[indexPath.row];

        [self hideItemsSubView];
        [self makeRequestForCategoryItemDetails:model.uniqueId];
    }
//    GetCarePlanResponseModel *model = self.carePlanArr[indexPath.row];
//    selectedCareProgram = model;
////membershipDetails
//    //managedCarPlanDetailVc
//    [self performSegueWithIdentifier:@"membershipDetails" sender:model];
}
#pragma mark - UITextfield Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.userNameTf) {
        [self showPicker];
        return NO;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
//- (void)textFieldDidBeginEditing:(UITextField *)textField{
//
//}
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return self.dependentsArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
   
    return [[self.dependentsArray objectAtIndex:row]objectForKey:@"name"];
    
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"membershipDetails"]) {
        SmartRxManagedCarePlanMembershipDetailsVC *controller = segue.destinationViewController;
        controller.membershipDetails = sender;
        controller.delegate = self;
    }
}

@end
