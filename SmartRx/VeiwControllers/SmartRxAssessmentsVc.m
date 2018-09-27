//
//  SmartRxAssessmentsVc.m
//  SmartRx
//
//  Created by Gowtham on 23/01/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxAssessmentsVc.h"
#import "SmartRxDashBoardVC.h"
#import "AssessmentsResponseModel.h"
#import "SmartRxAssessmentQuestionsVc.h"
#import "SmartRxAddPhrUIPicker.h"
#import "SmartRxAddPhrNumbers.h"
#import "SmartRxAddBMI.h"

@interface SmartRxAssessmentsVc ()
{
    MBProgressHUD *HUD;

}
@property(nonatomic,strong) NSArray *assessmentsList;
@end

@implementation SmartRxAssessmentsVc
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
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Assessments" controler:self];

    [self.tableView setTableFooterView:[UIView new]];
    [self navigationBackButton];
    [self makeRequestForAssessments];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Action Methods
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
#pragma mark - Request Methods
-(void)makeRequestForAssessments{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mgetassessment"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 1 %@",response);
        if (response == nil)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            //[smartLogin makeLoginRequest];
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //self.assessmentsList=[response objectForKey:@"app"];
                NSArray *assessments = response[@"patient_trackers"];
                NSMutableArray *tempArr = [[NSMutableArray alloc]init];
                if ([assessments isKindOfClass:[NSArray class]]) {
                
                for (NSDictionary *dict in assessments) {
                    AssessmentsResponseModel *model = [[AssessmentsResponseModel alloc]init];
                    model.trackerName = dict[@"tracker"];
                    model.trackerId = dict[@"trackerid"];
                    model.monitorType = dict[@"monitor_type"];
                    model.assessmentType = dict[@"is_general_assessment"];
                    [tempArr addObject:model];
                    
                }
                }
                self.assessmentsList= [tempArr copy];
                if (self.assessmentsList.count) {
                    self.tableView.hidden = NO;
                    self.noAppsLbl.hidden = YES;
                    [self.tableView reloadData];
                }else {
                    self.tableView.hidden = YES;
                    self.noAppsLbl.hidden = NO;
                }
                [HUD hide:YES];
                [HUD removeFromSuperview];
                
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
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999 )
    {
        //[self homeBtnClicked:nil];
        [self backBtnClicked:nil];
    }
}
#pragma mark - Tableview Delegate/Datasource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.assessmentsList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    AssessmentsResponseModel *model = self.assessmentsList[indexPath.row];
    cell.textLabel.text = model.trackerName;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AssessmentsResponseModel *model = self.assessmentsList[indexPath.row];
    if ([model.assessmentType integerValue] == 1) {
    NSString *assessCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"assessmentCount"];
    NSString *creditSettings = [[NSUserDefaults standardUserDefaults] objectForKey:@"creditSettings"];
    if ([creditSettings integerValue] == 0) {
        [self showAlert:@"Credits are not available to do assessments."];
    }else if([assessCount integerValue] < 1){
        [self showAlert:@"Credits are not available to do assessments."];
    }else{
        [self assessmentCheck:model];
    }
    }else{
        [self assessmentCheck:model];
    }
    
}
-(void)assessmentCheck:(AssessmentsResponseModel *)model{
    if ([model.monitorType integerValue] == 1) {
        [self performSegueWithIdentifier:@"assessmentQuestionsVc" sender:model];
    }else {
        [self moveToPhrController:[model.trackerId integerValue]];
    }
}
-(void)moveToPhrController:(NSInteger)trackerType{
    
    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
    [dictTemp setObject:@"" forKey:@"phrid"];
    if (trackerType == 4) {
        [dictTemp setObject:@"Blood Sugar" forKey:@"Title"];
        [dictTemp setObject:@"3" forKey:@"numberOfComponents"];
        [dictTemp setObject:@"599" forKey:@"numberOfRowsInComponent"];
        [dictTemp setObject:@"NO" forKey:@"heightIsSelected"];
        NSMutableArray *componentOneArray = [NSMutableArray arrayWithObject:@[@"mg/dl", @"mmol/L"]];
        [dictTemp setObject:componentOneArray forKey:@"componentOneArray"];
        NSMutableArray *componentTwoArray = [NSMutableArray arrayWithObject:@[@"Fasting",@"Post Breakfast",@"Before Lunch",@"Post Lunch",@"Before dinner",@"Post Dinner",@"Random",@"Insulin",@"Basal Insulin"]];
        [dictTemp setObject:componentTwoArray forKey:@"componentTwoArray"];
        [dictTemp setObject:@"YES" forKey:@"pickerUINeeded"];
        [dictTemp setObject:@"blood_sugar" forKey:@"testString"];
        [dictTemp setObject:@"2" forKey:@"type"];

    }else if (trackerType == 3) {
        [dictTemp setObject:@"" forKey:@"Title"];
        [dictTemp setObject:@"3" forKey:@"numberOfComponents"];
        [dictTemp setObject:@"4" forKey:@"numberOfRowsInComponent"];
        [dictTemp setObject:@"NO" forKey:@"heightIsSelected"];
        NSMutableArray *componentOneArray = [NSMutableArray arrayWithObject:@[@"min", @"hour"]];
        [dictTemp setObject:componentOneArray forKey:@"componentOneArray"];
        NSMutableArray *componentTwoArray = [NSMutableArray arrayWithObject:@[@"BriskWalk",@"Regular Walk",@"Jogging",@"Yoga",@"Aerobics",@"Swimming",@"Cycling",@"Others"]];
        [dictTemp setObject:componentTwoArray forKey:@"componentTwoArray"];
        [dictTemp setObject:@"YES" forKey:@"pickerUINeeded"];
        [dictTemp setObject:@"daily_activity" forKey:@"testString"];
        [dictTemp setObject:@"3" forKey:@"type"];
        
    }else if (trackerType == 1) {
        [dictTemp setObject:@"Blood Pressure" forKey:@"Title"];
        [dictTemp setObject:@"2" forKey:@"numberOfLabels"];
        [dictTemp setObject:@"Systolic (BP)" forKey:@"label1"];
        [dictTemp setObject:@"Diastolic (BP)" forKey:@"label2"];
        [dictTemp setObject:@"mm/hg" forKey:@"unit"];
        [dictTemp setObject:@"NO" forKey:@"pickerUINeeded"];
        [dictTemp setObject:@"bp_disambiguation" forKey:@"testString"];
        [dictTemp setObject:@"4" forKey:@"type"];
        
    }else if (trackerType == 47) {
        [dictTemp setObject:@"Pulse" forKey:@"Title"];
        [dictTemp setObject:@"1" forKey:@"numberOfLabels"];
        [dictTemp setObject:@"Pulse" forKey:@"label1"];
        [dictTemp setObject:@"BPM" forKey:@"unit"];
        [dictTemp setObject:@"NO" forKey:@"pickerUINeeded"];
        [dictTemp setObject:@"pulse" forKey:@"testString"];
        [dictTemp setObject:@"5" forKey:@"type"];
        
    }else if (trackerType == 17) {
        
        [dictTemp setObject:@"Temperature" forKey:@"Title"];
        [dictTemp setObject:@"1" forKey:@"numberOfLabels"];
        [dictTemp setObject:@"Temperature" forKey:@"label1"];
        [dictTemp setObject:@"°F" forKey:@"unit"];
        [dictTemp setObject:@"NO" forKey:@"pickerUINeeded"];
        [dictTemp setObject:@"temperature" forKey:@"testString"];
        [dictTemp setObject:@"6" forKey:@"type"];
        
    }else if (trackerType == 2) {
        [dictTemp setObject:@"BMI" forKey:@"Title"];
        [dictTemp setObject:@"2" forKey:@"firstPickerNoOfComponents"];
        [dictTemp setObject:@"2" forKey:@"secondPickerNoOfComponents"];
        [dictTemp setObject:@"599" forKey:@"firstPickerNumberOfRowsInComponent"];
        [dictTemp setObject:@"599" forKey:@"secondPickerNumberOfRowsInComponent"];
        [dictTemp setObject:@"YES" forKey:@"heightIsSelected"];
        NSMutableArray *firstPickerComponentOneArray = [NSMutableArray arrayWithObject:@[@"Cm", @"Ft"]];
        [dictTemp setObject:firstPickerComponentOneArray forKey:@"firstPickerComponentOneArray"];
        NSMutableArray *secondPickerComponentOneArray = [NSMutableArray arrayWithObject:@[@"Kg", @"Lb"]];
        [dictTemp setObject:secondPickerComponentOneArray forKey:@"secondPickerComponentOneArray"];
        [dictTemp setObject:@"YES" forKey:@"pickerUINeeded"];
        [dictTemp setObject:@"bmi" forKey:@"testString"];
        [dictTemp setObject:@"7" forKey:@"type"];
        
    }
    [dictTemp setObject:@"Add" forKey:@"buttonTextString"];

    if (trackerType == 2) {
        SmartRxAddBMI *addBmi = [self.storyboard instantiateViewControllerWithIdentifier:@"addBMI"];
        addBmi.navigationItem.title = @"BMI";
        addBmi.phrDetailsDictionary = [NSMutableDictionary alloc];
        addBmi.phrDetailsDictionary = dictTemp;
        [self.navigationController pushViewController:addBmi animated:YES];

    }else if(trackerType == 4){
        SmartRxAddPhrUIPicker *addPhrPicker = [self.storyboard instantiateViewControllerWithIdentifier:@"addPhrUIPicker"];
        addPhrPicker.navigationItem.title = [NSString stringWithFormat:@"Add %@",[dictTemp objectForKey:@"Title"]];
       addPhrPicker.phrDetailsDictionary = [NSMutableDictionary alloc];
        addPhrPicker.phrDetailsDictionary = dictTemp;
        [self.navigationController pushViewController:addPhrPicker animated:YES];
        
    }else if(trackerType == 1 || trackerType == 17 || trackerType == 47){
        SmartRxAddPhrNumbers *addPhrNumber = [self.storyboard instantiateViewControllerWithIdentifier:@"addPhrNumbers"];
        addPhrNumber.navigationItem.title = [NSString stringWithFormat:@"Add %@",[dictTemp objectForKey:@"Title"]];
        addPhrNumber.phrDetailsDictionary = [NSMutableDictionary alloc];
        addPhrNumber.phrDetailsDictionary = dictTemp;
        [self.navigationController pushViewController:addPhrNumber animated:YES];


    }else {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];

    }
    
}
-(void)showAlert:(NSString *)message{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error!" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:okAction];
    [self presentViewController:controller animated:YES completion:nil];
    controller.view.tintColor = [UIColor blueColor];
}
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"assessmentQuestionsVc"]) {
        SmartRxAssessmentQuestionsVc *controller = segue.destinationViewController;
        controller.selectedAssessment = sender;
    }
}


@end
