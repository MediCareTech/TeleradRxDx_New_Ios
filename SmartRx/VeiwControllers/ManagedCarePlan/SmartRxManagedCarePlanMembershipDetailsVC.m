//
//  SmartRxManagedCarePlanMembershipDetailsVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 17/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxManagedCarePlanMembershipDetailsVC.h"
#import "MembershipTypeDetailsResponseModel.h"
#import "GetCarePlanDetailsResponseModel.h"
#import "GetManagedCarePlanServiceDetailsCell.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxGetManagedCarePlanServiceDetailsVC.h"

@interface SmartRxManagedCarePlanMembershipDetailsVC ()

@property(nonatomic,strong) NSArray *titlesArray;
@property(nonatomic,strong) NSArray *tableArr;

@end

@implementation SmartRxManagedCarePlanMembershipDetailsVC
-(void)navigationBackButton{
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
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Membership Details" controler:self];
    CareWellnessCategoryItemResponseModel *model = self.membershipDetails[0];
    self.careProgramName.text = model.careProgramName;
    self.titlesArray = [NSArray arrayWithObjects:@"Detailed Assessments",@"Health Coach Follow ups(phone/email/chat/sms)",@"Care plans",@"Care manager assistance",@"Chat with care team",@"Continuous monitoring",@"Weekly & monthly newsletters, Health recipes & Stress busters",@"E-Consult",@"Second Opinion",@"Mini Health Check",@"Diagnostic / Lab Tests",@"", nil];
    [self navigationBackButton];
    [self dataModel];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
-(void)dataModel{
    NSMutableArray *temmpArr = [[NSMutableArray alloc]init];
    for ( CareWellnessCategoryItemResponseModel *model in self.membershipDetails) {

        MembershipTypeDetailsResponseModel *membership = [[MembershipTypeDetailsResponseModel alloc]init];
        if ([model.title containsString:@"Silver"]) {
            membership.membershipType = @"Silver";
            membership.membershipArray= [self createDataModel:@"Silver" memberShip:model];
        } else if ([model.title containsString:@"Gold"]) {
            membership.membershipType = @"Gold";
            
            membership.membershipArray=[self createDataModel:@"Gold" memberShip:model];
        }else if ([model.title containsString:@"Platinum"]) {
            membership.membershipType = @"Platinum";
            membership.membershipArray= [self createDataModel:@"Platinum" memberShip:model];
        }
        else if ([model.title containsString:@"Diamond"]) {

            membership.membershipType = @"Diamond";
            membership.membershipArray= [self createDataModel:@"Diamond" memberShip:model];
        }
        [temmpArr addObject:membership];

    }
    self.tableArr = [temmpArr copy];
    for (MembershipTypeDetailsResponseModel *membershi  in  self.tableArr) {
                NSLog(@"data array.....:%@",membershi.membershipType);
        
            }
    dispatch_async(dispatch_get_main_queue(),^{
        [self.tableView reloadData];
    });
}
-(void)dataSetup{
    NSMutableArray *temmpARr = [[NSMutableArray alloc]init];
    for (MembershipTypesResponseModel  *model in self.selectedCarePlan.membershipArray) {
        NSLog(@"data array.....:%@",model.name);
        MembershipTypeDetailsResponseModel *membership = [[MembershipTypeDetailsResponseModel alloc]init];
        if ([model.name containsString:@"Silver"]) {
            membership.membershipType = @"Silver";
           membership.membershipArray= [self createDataModel:@"Silver" memberShip:model];
        } else if ([model.name containsString:@"Gold"]) {
            membership.membershipType = @"Gold";

            membership.membershipArray=[self createDataModel:@"Gold" memberShip:model];
        }else if ([model.name containsString:@"Platinum"]) {
            membership.membershipType = @"Platinum";
           membership.membershipArray= [self createDataModel:@"Platinum" memberShip:model];
        }
        else if ([model.name containsString:@"Diamond"]) {
            membership.membershipType = @"Diamond";
            membership.membershipArray= [self createDataModel:@"Diamond" memberShip:model];
        }
        [temmpARr addObject:membership];
    }
    self.tableArr = [temmpARr copy];
    
//    for (MembershipTypeDetailsResponseModel *membershi  in  self.tableArr) {
//        NSLog(@"data array.....:%@",membershi.membershipType);
//
//    }
        dispatch_async(dispatch_get_main_queue(),^{
        [self.tableView reloadData];
    });
}
-(NSArray *)createDataModel:(NSString *)type memberShip:(CareWellnessCategoryItemResponseModel *)membershipModel{
    NSMutableArray *tempARr = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < self.titlesArray.count ; i++) {
        GetCarePlanDetailsResponseModel * model = [[GetCarePlanDetailsResponseModel alloc]init];
         if([self.titlesArray[i] isEqualToString:@"Detailed Assessments"]){
            model.CareProgramProperty = @"Detailed Assessments";
            model.quantity = membershipModel.detailedAssessments;
        }else if([self.titlesArray[i] isEqualToString:@"Health Coach Follow ups(phone/email/chat/sms)"]){
            model.CareProgramProperty = @"Health Coach Follow ups(phone/email/chat/sms)";
            model.quantity = membershipModel.healthCoachFollowUps;
        }else if([self.titlesArray[i] isEqualToString:@"Care plans"]){
            model.CareProgramProperty = @"Care plans";
            model.quantity = membershipModel.careplans;
        }else if([self.titlesArray[i] isEqualToString:@"Customised health plan"]){
            model.CareProgramProperty = @"Customised health plan";
            model.quantity = [self getBoolData:membershipModel.customisedHealthPlan];
        }else if([self.titlesArray[i] isEqualToString:@"Care manager assistance"]){
            model.CareProgramProperty = @"Care manager assistance";
            model.quantity = [self getBoolData:membershipModel.careManagerAssistance];
        }else if([self.titlesArray[i] isEqualToString:@"Chat with care team"]){
            model.CareProgramProperty = @"Chat with care team";
            model.quantity = [self getBoolData:membershipModel.ChatWithCareTeam];
        }else if([self.titlesArray[i] isEqualToString:@"Continuous monitoring"]){
            model.CareProgramProperty = @"Continuous monitoring";
            model.quantity = [self getBoolData:membershipModel.continuousMonitoring];
        }else if([self.titlesArray[i] isEqualToString:@"Weekly & monthly newsletters, Health recipes & Stress busters"]){
            model.CareProgramProperty = @"Weekly & monthly newsletters, Health recipes & Stress busters";
            model.quantity = [self getBoolData:membershipModel.newsletters];
        }else if([self.titlesArray[i] isEqualToString:@"E-Consult"]){
            model.CareProgramProperty = @"E-Consult";
            model.quantity = membershipModel.econsults;
        }else if([self.titlesArray[i] isEqualToString:@"Second Opinion"]){
            model.CareProgramProperty = @"Second Opinion";
            model.quantity = membershipModel.secondOpinion;
        }else if([self.titlesArray[i] isEqualToString:@"Mini Health Check"]){
            model.CareProgramProperty = @"Mini Health Check";
            model.quantity = membershipModel.miniHealthCheck;
        }else if([self.titlesArray[i] isEqualToString:@"Diagnostic / Lab Tests"]){
            model.CareProgramProperty = @"Diagnostic / Lab Tests";
            model.quantity = @"Show";
        }else if([self.titlesArray[i] isEqualToString:@""]){
            NSString *priceStr = nil;
            if ([membershipModel.price integerValue] == 0 ) {
                priceStr = @"Free";
            }else {
                priceStr = [NSString stringWithFormat:@"Rs. %@",membershipModel.price];
            }
          

            if ([membershipModel.oldPrice integerValue] > 0 && [membershipModel.oldPrice integerValue] != [membershipModel.price integerValue]) {
                    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %@  %@ /  %@", membershipModel.oldPrice,priceStr,membershipModel.managedCareProgram]];
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                            value:@2
                                            range:NSMakeRange(0, [membershipModel.oldPrice length]+3)];
                model.attributedCareProgram = attributeString;
                model.quantity = [NSString stringWithFormat:@"Rs. %@",membershipModel.price];
                model.CareProgramProperty = attributeString.string;
            }else {
            model.CareProgramProperty = [NSString stringWithFormat:@"%@ /  %@",priceStr,membershipModel.managedCareProgram];
            model.quantity = [NSString stringWithFormat:@"Rs. %@",membershipModel.price];
            }
        }
        [tempARr addObject:model];
    }

    return [tempARr copy];
}
-(NSString *)getBoolData:(NSString *)value{
    NSString *str= @"No";
    if ([value integerValue] == 1) {
        str = @"Yes";
    }
    return str;
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
#pragma mark - Tableview Delegate/Datasource Methods
-(CGFloat)estimatedHeight:(NSString *)strToCalCulateHeight font:(CGFloat)fontSize
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, self.view.frame.size.width-145,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    //    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width-145,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    CGFloat heightLbl=expectedLabelSize.height;
    heightLbl = heightLbl+ 30;
    return heightLbl;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MembershipTypeDetailsResponseModel *model = self.tableArr[indexPath.section];
    NSArray *membershipArr =model.membershipArray;
    GetCarePlanDetailsResponseModel * detailModel = membershipArr[indexPath.row];
    CGFloat height;
    if (indexPath.row == membershipArr.count-1) {
       height = [self estimatedHeight:detailModel.CareProgramProperty font:14];
    }else {
     height = [self estimatedHeight:detailModel.CareProgramProperty font:17];
    }
    
    return height;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableArr.count;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    view.tintColor = [UIColor colorWithRed:26.0/255.0 green:84.0/255.0 blue:82.0/255.0 alpha:1];
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setFont:[UIFont systemFontOfSize:15]];
    header.textLabel.textColor = [UIColor whiteColor];
    header.textLabel.textAlignment = NSTextAlignmentCenter;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MembershipTypeDetailsResponseModel *model = self.tableArr[section];
    return model.membershipType;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MembershipTypeDetailsResponseModel *model = self.tableArr[section];
        return  model.membershipArray.count;
    // return [dashItems count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GetManagedCarePlanServiceDetailsCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell"];
    MembershipTypeDetailsResponseModel *model = self.tableArr[indexPath.section];
    NSArray *membershipArr =model.membershipArray;
    GetCarePlanDetailsResponseModel * detailModel = membershipArr[indexPath.row];
    cell.careProgramProperty.text =detailModel.CareProgramProperty;
    cell.careProgramTotal.text = detailModel.quantity;
    cell.careProgramProperty.numberOfLines = 5;
    
    if (indexPath.row == membershipArr.count-1) {
        UITableViewCell *buyCell =[tableView dequeueReusableCellWithIdentifier:@"buyCell"];
        UILabel *textLbl = [buyCell viewWithTag:100];
        UILabel *buyLabl = [buyCell viewWithTag:101];
        textLbl.font = [UIFont systemFontOfSize:12];
        if (detailModel.attributedCareProgram == nil) {
            textLbl.text = detailModel.CareProgramProperty;
        }else {
            textLbl.attributedText = detailModel.attributedCareProgram;
        }
        buyLabl.text = @"Buy";
        buyLabl.backgroundColor = [UIColor redColor];
        return buyCell;
        
    }
    if(indexPath.row == membershipArr.count-2){
        CareWellnessCategoryItemResponseModel *membershipModel = [self getSelectedMembership:model.membershipType];
        if (membershipModel.serviceDetailsArray.count) {
            cell.careProgramTotal.textColor = [UIColor whiteColor];
            cell.careProgramTotal.backgroundColor = [UIColor redColor];
        }else {
            cell.careProgramTotal.textColor = [UIColor darkGrayColor];
            cell.careProgramTotal.backgroundColor = [UIColor whiteColor];
            cell.careProgramTotal.text= @"-";
        }
       
    }else {
        cell.careProgramTotal.textColor = [UIColor darkGrayColor];
        cell.careProgramTotal.backgroundColor = [UIColor whiteColor];
    }

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MembershipTypeDetailsResponseModel *model = self.tableArr[indexPath.section];
       CareWellnessCategoryItemResponseModel *membershipModel = [self getSelectedMembership:model.membershipType];
    NSArray *membershipArr =model.membershipArray;
    if (membershipArr.count-2 == indexPath.row) {
        
        GetCarePlanDetailsResponseModel * detailModel = membershipArr[indexPath.row];
        //getCareplanServiceDetailsVc
        if (membershipModel.serviceDetailsArray.count && [detailModel.CareProgramProperty isEqualToString:@"Diagnostic / Lab Tests"]) {
            dispatch_async(dispatch_get_main_queue(),^{
                [self performSegueWithIdentifier:@"getCareplanServiceDetails" sender:membershipModel.serviceDetailsArray];
            });
        }
    }else if (membershipArr.count-1 == indexPath.row){
        NSString *mebershipCheck = [[NSUserDefaults standardUserDefaults]objectForKey:@"membership"];
        NSString *mebershipDate = [[NSUserDefaults standardUserDefaults]objectForKey:@"membership_enddate"];
        BOOL expires;
        if (mebershipDate != nil) {
            expires=[self getExpireDate:mebershipDate];
        }
        if ([mebershipCheck integerValue] == 0 || expires == YES) {
            NSLog(@"buy option:%@",membershipModel.packageId);
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate updatePurchaseDetails:membershipModel];
        }else {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:@"Care wellness program cannot be purchased." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
            [controller addAction:okAction];
            [self presentViewController:controller animated:YES completion:nil];
            controller.view.tintColor = [UIColor blueColor];
        }
    }
    
}
-(BOOL)getExpireDate:(NSString *)dateStr{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *date = [formatter dateFromString:dateStr];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date1 = [formatter stringFromDate:date];
    NSDate *date2 = [formatter dateFromString:date1];
    NSComparisonResult result = [date2 compare:[NSDate date]];
    BOOL value ;
    if (result == NSOrderedAscending || result == NSOrderedSame) {
        value = YES;
    }else{
        value = NO;
    }
    return value;
}
-(CareWellnessCategoryItemResponseModel *)getSelectedMembership:(NSString *)selectedType{
    
  CareWellnessCategoryItemResponseModel *selectedModel;
 for ( CareWellnessCategoryItemResponseModel *model in self.membershipDetails) {
        if ([model.title containsString:selectedType]) {
            selectedModel = model;
            return model;
        }
    }
    return selectedModel;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"getCareplanServiceDetails"]) {
        SmartRxGetManagedCarePlanServiceDetailsVC *controller = segue.destinationViewController;
        controller.serviceArray = sender;
    }
}


@end
