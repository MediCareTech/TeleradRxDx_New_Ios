//
//  SmartRxAddSymptomsVC.m
//  CareBridge
//
//  Created by Gowtham on 09/10/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import "SmartRxAddDiagnosisVC.h"
#import "SmartRxDashBoardVC.h"

@interface SmartRxAddDiagnosisVC ()
{
    CGSize viewSize;
    NSDictionary *selectedSymptom;
    
}
@property (strong, nonatomic) NSTimer * searchTimer;
@property (strong, nonatomic) NSArray * symptomsList;

@end

@implementation SmartRxAddDiagnosisVC
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
     if (![self.fromViewController isEqualToString:@"registerVc"]) {
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
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Add Diagnosis" controler:self];
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.hidden = YES;
    [self.diagnosisTF addTarget:self
                           action:@selector(textFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
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

}
-(void)textFieldDidChange :(UITextField *)textField{
    
    // if a timer is already active, prevent it from firing
    if (self.searchTimer != nil) {
        [self.searchTimer invalidate];
        self.searchTimer = nil;
    }
    
    // reschedule the search: in 1.0 second, call the searchForKeyword: method on the new textfield content
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                        target: self
                                                      selector: @selector(searchForKeyword:)
                                                      userInfo: self.diagnosisTF.text
                                                       repeats: NO];
    
}


- (void)searchForKeyword:(NSTimer *)timer
{
    // retrieve the keyword from user info
    NSString *keyword = (NSString*)timer.userInfo;
    [self.diagnosisTF resignFirstResponder];
    if (self.diagnosisTF.text.length > 0) {

    [self makeRequestForDiagnosisList];
    }else{
        self.tableView.hidden = YES;
    }
    NSLog(@"searching word:%@",keyword);
    // perform your search (stubbed here using NSLog)
    NSLog(@"Searching for keyword %@",keyword);
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
-(IBAction)clickOnCancelBtn:(id)sender{
    [self backBtnClicked:nil];
}
-(IBAction)clickOnDateBtn:(id)sender{
    [self.diagnosisTF resignFirstResponder];

    [self ChooseDP:@"Date"];
}
-(IBAction)clickOnSaveBtn:(id)sender{
    if (self.diagnosisTF.text.length < 1) {
        [self customAlertView:@"" Message:@"Diagnosis name is required." tag:0];
        
    }  else {
        NSString *diagnosisId = @"";
        if (selectedSymptom != nil) {
            diagnosisId = selectedSymptom[@"id"];
        }
        NSString *startDateStr = @"";
        if (![self.observedDate.text isEqualToString:@"Observed Date"]) {
            startDateStr = self.observedDate.text;
        }
        NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"r_diagnosis",@"record_type",diagnosisId,@"a_diagnosis_id",startDateStr,@"observed_at",self.diagnosisTF.text,@"a_diagnosis_name",userId,@"member_id",@"",@"entry_id", nil];
        
        if ([self.fromViewController isEqualToString:@"registerVc"]) {
            [self.delegate selectedDiagnosis:dict];
            [self.navigationController popViewControllerAnimated:NO];

        } else {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
            [self makeRequestForAddSymptoms:dict];
        else
            [self customAlertView:@"" Message:@"Network not available" tag:0];
        }
    }
}

-(void)ChooseDP:(id)sender{
    //    pickerAction = [[UIActionSheet alloc] initWithTitle:@"Date"
    //                                               delegate:nil
    //                                      cancelButtonTitle:nil
    //                                 destructiveButtonTitle:nil
    //                                      otherButtonTitles:nil];
    
    self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    self.datePickerView.backgroundColor = [UIColor whiteColor];
    //NSString *date = self.observedDate.text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if ([sender isEqualToString:@"Date"])
    {
        //[self.datePickerView setMinimumDate:[NSDate date]];
        [self.datePickerView setMaximumDate:[NSDate date]];

        self.datePickerView.datePickerMode = UIDatePickerModeDate;
    }
    else
    {
        
        
    }
    
    //[self.datePickerView setDate:[NSString stringToDate:date]];
    
    //self.datePickerView.datePickerMode = UIDatePickerModeTime;
    
    // if([date length]>0)
    //{
    //}
    //    //format datePicker mode. in this example time is used
    //    self.datePickerView.datePickerMode = UIDatePickerModeTime;
    //    [dateFormatter setDateFormat:@"h:mm a"];
    //    //calls dateChanged when value of picker is changed
    //    [self.datePickerView addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    
    self.datePickerView.datePickerMode = UIDatePickerModeDate;
    
    toolbarPicker = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-260, 320, 44)];
    toolbarPicker.barStyle=UIBarStyleBlackOpaque;
    [toolbarPicker sizeToFit];
    NSMutableArray *itemsBar = [[NSMutableArray alloc] init];
    //calls DoneClicked
    UIBarButtonItem *bbitem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [itemsBar addObject:bbitem];
    
    [toolbarPicker setItems:itemsBar animated:YES];
    [pickerAction addSubview:toolbarPicker];
    [pickerAction addSubview:self.datePickerView];
    [self.view addSubview:pickerAction];
    pickerAction.hidden = NO;
}
- (void)doneClicked:(id)sender
{
    
    NSDate *dateAppointment=self.datePickerView.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyy"];
    NSString *strDate = [dateFormat stringFromDate:dateAppointment];
    NSLog(@"date ==== %@",strDate);
    
    self.observedDate.text=strDate;
    
    self.datePickerView.hidden=YES;
    [self closeDatePicker:nil];
    
}
-(BOOL)closeDatePicker:(id)sender{
    pickerAction.hidden = YES;
    return YES;
}
#pragma mark - Request Methods
-(void)makeRequestForAddSymptoms:(NSDictionary *)info{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[SmartRxCommonClass sharedManager] addEHR:info successHandler:^(id response) {
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            if ([response[@"result"] integerValue] == 1) {
                [self customAlertView:@"" Message:@"Diagnosis added successfully" tag:999];
            } else {
                [self customAlertView:@"Error" Message:@"EHR updation failed .Please try again later." tag:0];
            }        });
        
    } failureHandler:^(id response) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self customAlertView:@"" Message:@"Network not available" tag:0];

    }];
    
    
}

-(void)makeRequestForDiagnosisList{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *url=[NSString stringWithFormat:@"%s/ehr/archetypes/a_diagnosis/search/%@?count=100",kBaseUrl,self.diagnosisTF.text];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:nil method:@"GET" setHeader:YES  successHandler:^(id response) {
        
        if (response == nil)
        {
            
            //[[SmartRxCommonClass sharedManager] checkExpiryAndLogin:self];
        }  else {
            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                
                self.symptomsList = response;
                if (self.symptomsList.count) {
                    self.tableView.hidden = NO;
                    [self.tableView reloadData];
                } else {
                    self.tableView.hidden = YES;
                    [self.tableView reloadData];
                }
                
            });
        }
        
        
    }failureHandler:^(id response) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        NSError *err = response;
        NSDictionary *inforDict = err.userInfo;
        if (![inforDict[@"NSLocalizedDescription"] isEqualToString:@"unsupported URL"]) {
            [self customAlertView:@"" Message:@"Network not available" tag:0];

        }

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
    return self.symptomsList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.symptomsList[indexPath.row][@"diagnosis_name"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedSymptom = self.symptomsList[indexPath.row];
    self.diagnosisTF.text = self.symptomsList[indexPath.row][@"diagnosis_name"];
    self.tableView.hidden = YES;
    
}
#pragma mark - TextField methods

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
