//
//  SmartRxAddSymptomsVC.m
//  CareBridge
//
//  Created by Gowtham on 09/10/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import "SmartRxAddFamilyHistoryVC.h"
#import "SmartRxDashBoardVC.h"

@interface SmartRxAddFamilyHistoryVC ()
{
    CGSize viewSize;
    NSDictionary *selectedRelation,*selectedCondition;
    NSString *arrayType;
    UILabel *currentLabel;
    NSString *aliveStr;
}
@property (strong, nonatomic) NSArray * relationshipList;
@property (strong, nonatomic) NSArray * conditionList;

@end

@implementation SmartRxAddFamilyHistoryVC
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ageTF.delegate = self;
    self.ageTF.returnKeyType = UIReturnKeyDone;
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Add Family History" controler:self];
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.hidden = YES;
    arrayType = @"a_relationship";
    aliveStr = @"0";
    viewSize = [UIScreen mainScreen].bounds.size;
    pickerAction = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    pickerAction.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = pickerAction.bounds;
    [pickerAction addSubview:backgroundView];
    
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    UIImageView *pickerBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    pickerBackgroundView.opaque = NO;
    pickerBackgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:pickerBackgroundView];
    [self navigationBackButton];
    [self makeRequestForFamilyHistoryList:@"a_relationship"];
    
    
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
-(IBAction)clickOnAliveBtn:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        self.aliveBtn.selected = NO;
        aliveStr = @"0";
    } else {
        aliveStr = @"1";
        self.aliveBtn.selected = YES;
        
    }
}
-(IBAction)clickOnRelationshipBtn:(id)sender{
    [self.view endEditing:YES];
    self.tableViewType = RelationshiptableView;
    if (self.relationshipList.count) {
        CGFloat y = self.relationshipLbl.frame.origin.y+self.relationshipLbl.frame.size.height+10;
        CGFloat Height = self.view.frame.size.height - y;
        [self setTableViewFrame:y height:Height];
        [self.tableView reloadData];
        self.tableView.hidden = NO;
    }
}
-(IBAction)clickConditionBtn:(id)sender{
    [self.view endEditing:YES];
    self.tableViewType = ConditionTableView;
    if (self.conditionList.count) {
        CGFloat y = self.conditionLbl.frame.origin.y+self.conditionLbl.frame.size.height+10;
        CGFloat Height = self.view.frame.size.height - y;
        [self setTableViewFrame:y height:Height];
        [self.tableView reloadData];
        self.tableView.hidden = NO;
    }
}
-(IBAction)clickOnSaveButton:(id)sender{
    if ([self.relationshipLbl.text isEqualToString:@"Select Relationship"]) {
        [self customAlertView:@"" Message:@"Please Select any relationship ." tag:0];
        
    }else if([self.conditionLbl.text isEqualToString:@"Select Condition"]){
        [self customAlertView:@"" Message:@"Please Select any condition ." tag:0];
    } else {
        NSString *ageStr= @"";
        if (self.ageTF.text != nil) {
            ageStr = self.ageTF.text;
        }
        NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];

        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"r_familyhistory",@"record_type",selectedRelation[@"id"],@"a_relationship_id",selectedCondition[@"id"],@"a_medicalcondition_id",ageStr,@"relationship_age",aliveStr,@"alive",userId,@"member_id",@"",@"entry_id", nil];
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
            [self makeRequestForAddFamily:dict];
        else
            [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
}
-(IBAction)clickOnCancelButton:(id)sender{
    [self backBtnClicked:nil];
}

-(void)setTableViewFrame:(CGFloat)yPosition height:(CGFloat)hight{
    self.tableView.frame = CGRectMake(2, yPosition, self.view.frame.size.width-4, hight);
}

#pragma mark - Request Methods
-(void)makeRequestForAddFamily:(NSDictionary *)info{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [[SmartRxCommonClass sharedManager] addEHR:info successHandler:^(id response) {
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            if ([response[@"result"] integerValue] == 1) {
                [self customAlertView:@"" Message:@"Family history added successfully" tag:999];
            } else {
                [self customAlertView:@"Error" Message:@"EHR updation failed .Please try again later." tag:0];
            }
        });
        
    } failureHandler:^(id response) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self customAlertView:@"" Message:@"Network not available" tag:0];

    }];

}
-(void)makeRequestForFamilyHistoryList:(NSString *)typeStr{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *url=[NSString stringWithFormat:@"%s/ehr/archetypes/%@?count=100",kBaseUrl,typeStr];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:nil method:@"GET" setHeader:YES  successHandler:^(id response) {
        
        if (response == nil)
        {
            
            //[[SmartRxCommonClass sharedManager] checkExpiryAndLogin:self];
        }  else {
            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                if ([arrayType isEqualToString:@"a_relationship"]) {
                    self.relationshipList = response;
                    arrayType = @"a_medicalcondition";
                    [self makeRequestForFamilyHistoryList:@"a_medicalcondition"];
                    
                } else if ([arrayType isEqualToString:@"a_medicalcondition"]) {
                    self.conditionList = response;
                    arrayType = @"a_relationship";
                  }
                
                
            });
        }
        
        
    }failureHandler:^(id response) {
        
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self customAlertView:@"" Message:@"Network not available" tag:0];

    }];
    
    
}
#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [self homeBtnClicked:nil];
    
    
}
-(void)errorSectionId:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [self customAlertView:@"Session expired." Message:@"Login again " tag:0];
}

#pragma mark - TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count= 0;
    if (self.tableViewType == RelationshiptableView) {
        count = self.relationshipList.count;
    } else if (self.tableViewType == ConditionTableView) {
        count = self.conditionList.count;
    }
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (self.tableViewType == RelationshiptableView) {
        cell.textLabel.text = self.relationshipList[indexPath.row][@"relationship_name"];
    } else if (self.tableViewType == ConditionTableView) {
        cell.textLabel.text = self.conditionList[indexPath.row][@"condition_name"];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableViewType == RelationshiptableView) {
        selectedRelation = self.relationshipList[indexPath.row];
        self.relationshipLbl.text = selectedRelation[@"relationship_name"];
        
    } else if (self.tableViewType == ConditionTableView) {
        selectedCondition = self.conditionList[indexPath.row];
        self.conditionLbl.text = selectedCondition[@"condition_name"];

    }
    
    self.tableView.hidden = YES;
    
}
#pragma mark - TextField methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.tableView.hidden = YES;
}// became first responder

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999 )
    {
        //[self homeBtnClicked:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
