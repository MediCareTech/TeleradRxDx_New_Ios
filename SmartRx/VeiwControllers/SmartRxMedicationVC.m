//
//  SmartRxMedicationVC.m
//  CareBridge
//
//  Created by Gowtham on 09/10/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import "SmartRxMedicationVC.h"
#import "SmartRxDashBoardVC.h"
@interface SmartRxMedicationVC ()
{
    UILabel *currentLabel;
    CGSize viewSize;
    CGFloat height;
    NSString *mStr;
    NSString *noStr;
    NSString *eStr;
    NSString *nStr;
    NSDictionary *selectedDrug;
}
@property (strong, nonatomic) NSTimer * searchTimer;
@property (strong, nonatomic) NSArray * drugNameList;

@end

@implementation SmartRxMedicationVC
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
    self.daysTF.returnKeyType = UIReturnKeyDone;
    self.quantityTF.returnKeyType = UIReturnKeyDone;
    self.drugNameTF.returnKeyType = UIReturnKeyDone;

    //[[SmartRxCommonClass sharedManager] setNavigationTitle:@"Add Medication" controler:self];

    self.navigationItem.title = @"Add Medication";
    [self navigationBackButton];
    mStr = @"0";
    noStr = @"0";
    eStr = @"0";
    nStr = @"0";

    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.hidden = YES;
    [self.drugNameTF addTarget:self
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
                                                      userInfo: self.drugNameTF.text
                                                       repeats: NO];
    
}


- (void)searchForKeyword:(NSTimer *)timer
{
    // retrieve the keyword from user info
    NSString *keyword = (NSString*)timer.userInfo;
    [self.drugNameTF resignFirstResponder];
    if (self.drugNameTF.text.length > 0) {
        [self makeRequestForDrugsList];

    } else{
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
-(IBAction)clickOnStartDateBtn:(id)sender{
    [self.drugNameTF resignFirstResponder];
    [self.quantityTF resignFirstResponder];
    [self.daysTF resignFirstResponder];
    currentLabel = self.startDate;
    self.datePickerView.datePickerMode=UIDatePickerModeDate;
    [self ChooseDP:@"Date"];

}
-(IBAction)clickOnendDateBtn:(id)sender{
    [self.drugNameTF resignFirstResponder];
    [self.quantityTF resignFirstResponder];
    [self.daysTF resignFirstResponder];
    currentLabel = self.endDate;

    self.datePickerView.datePickerMode=UIDatePickerModeDate;
    [self ChooseDP:@""];
}
-(IBAction)clickOnMBtn:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        self.mBtn.selected = NO;
        mStr = @"0";
    } else {
        mStr = @"1";
        self.mBtn.selected = YES;

    }
}
-(IBAction)clickOnNoBtn:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        noStr = @"0";

        self.noBtn.selected = NO;
    } else {
        noStr = @"1";

        self.noBtn.selected = YES;
        
    }
}
-(IBAction)clickOnEBtn:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        eStr = @"0";

        self.eBtn.selected = NO;
    } else {
        eStr = @"1";

        self.eBtn.selected = YES;
        
    }
}
-(IBAction)clickOnNBtn:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        nStr = @"0";

        self.nBtn.selected = NO;
    } else {
        nStr = @"1";

        self.nBtn.selected = YES;
        
    }
}
-(IBAction)clickOnCancelBtn:(id)sender{
    [self backBtnClicked:nil];
}
-(IBAction)clickOnSaveBtn:(id)sender{
    if (self.drugNameTF.text.length < 1) {
        [self customAlertView:@"" Message:@"Drug name is required." tag:0];

    } else {
       
        NSString *patternsStr= [NSString stringWithFormat:@"%@,%@,%@,%@",mStr,noStr,eStr,nStr];
        NSString *startDateStr = @"";
        if (![self.startDate.text isEqualToString:@"Start Date"]) {
            startDateStr = self.startDate.text;
        }
        NSString *endDateStr = @"";
        if (![self.endDate.text isEqualToString:@"End Date"]) {
            endDateStr = self.endDate.text;
        }
        NSString *medicationId = @"";
        if (selectedDrug.count > 0) {
            medicationId = selectedDrug[@"id"];
        }
        NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];

        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:@"r_medication" forKey:@"record_type"];
        [dict setObject:self.drugNameTF.text forKey:@"a_medication_name"];
        [dict setObject:self.quantityTF.text forKey:@"a_medication_dosage"];
        [dict setObject:startDateStr forKey:@"started_at"];
        [dict setObject:endDateStr forKey:@"ended_at"];
        [dict setObject:self.daysTF.text forKey:@"number_of_days"];
        [dict setObject:patternsStr forKey:@"a_medication_consumption_pattern"];
        [dict setObject:medicationId forKey:@"a_medication_id"];
        [dict setObject:userId forKey:@"member_id"];
        [dict setObject:@"" forKey:@"entry_id"];
        if (selectedDrug.count<1) {
            [dict setObject:@"0" forKey:@"a_medication_id"];
        }
        if ([self.fromViewController isEqualToString:@"registerVc"]) {
            [self.delegate selectedMedication:dict];
            [self.navigationController popViewControllerAnimated:NO];
        } else {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
            [self makeRequestForAddMedication:dict];
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
    NSString *date = self.startDate.text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if ([sender isEqualToString:@"Date"])
    {
        //[self.datePickerView setMinimumDate:[NSDate date]];
        self.datePickerView.datePickerMode = UIDatePickerModeDate;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-MM-yyy"];

        if (![self.startDate.text isEqualToString:@"Start Date"]) {
            NSDate *startDate = [dateFormat dateFromString:self.startDate.text];
            self.datePickerView.date = startDate;
        }
    }
    else
    {
        if (![self.startDate.text isEqualToString:@"Start Date"]) {
            [dateFormatter setDateFormat:@"dd-MM-yyyy"];
            NSDate *date = [dateFormatter dateFromString:self.startDate.text];
            if (![self.endDate.text isEqualToString:@"End Date"]) {
                NSDate *startDate = [dateFormatter dateFromString:self.endDate.text];
                self.datePickerView.date = startDate;
            }

            //[self.datePickerView setMinimumDate:date];

        }
        
        //[self.datePickerView setDate:[NSString stringToDate:date]];

        //self.datePickerView.datePickerMode = UIDatePickerModeTime;
    }
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
    if (currentLabel == self.startDate) {

        self.startDate.text=strDate;
        if (![self.daysTF.text isEqualToString:@""]) {
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setDay:[self.daysTF.text intValue]];
            NSDate *newDate = [[NSCalendar currentCalendar]
                               dateByAddingComponents:dateComponents
                               toDate:self.datePickerView.date options:0];
            NSString *endDate = [dateFormat stringFromDate:newDate];
            self.endDate.text=endDate;

            
        }
        
    } else {
        
        self.endDate.text=strDate;

    }
    self.datePickerView.hidden=YES;
    [self closeDatePicker:nil];
    
}
-(BOOL)closeDatePicker:(id)sender{
    pickerAction.hidden = YES;
    return YES;
}
#pragma mark - Request Methods
-(void)makeRequestForAddMedication:(NSDictionary *)info{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[SmartRxCommonClass sharedManager] addEHR:info successHandler:^(id response) {
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            if ([response[@"result"] integerValue] == 1) {
                [self customAlertView:@"" Message:@"Medication added successfully" tag:999];
            } else {
                [self customAlertView:@"Error" Message:@"EHR updation failed .Please try again later." tag:0];
            }
        });
        
    } failureHandler:^(id response) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self customAlertView:@"" Message:@"Network not available" tag:0];

    }];

    
}
-(void)makeRequestForDrugsList{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *url=[NSString stringWithFormat:@"%s/ehr/archetypes/a_medication/search/%@?count=100",kBaseUrl,self.drugNameTF.text];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:nil method:@"GET" setHeader:YES  successHandler:^(id response) {
        
        if (response == nil)
        {
            
            //[[SmartRxCommonClass sharedManager] checkExpiryAndLogin:self];
        }  else {
            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                
                self.drugNameList = response;
                if (self.drugNameList.count) {
                    self.tableView.hidden = NO;
                }else {
                    self.tableView.hidden = YES;
                }
                [self.tableView reloadData];

            });
        }
        
        
    }failureHandler:^(id response) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self customAlertView:@"" Message:@"Network not available" tag:0];

    }];
    

}
#pragma mark - TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.drugNameList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.drugNameList[indexPath.row][@"medication_name"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedDrug = self.drugNameList[indexPath.row];
    self.drugNameTF.text = self.drugNameList[indexPath.row][@"medication_name"];
    self.tableView.hidden = YES;

}
#pragma mark - TextField methods

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.tableView.hidden = YES;
}
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
