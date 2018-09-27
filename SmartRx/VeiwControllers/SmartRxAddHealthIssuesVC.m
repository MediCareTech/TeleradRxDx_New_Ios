//
//  SmartRxAddSymptomsVC.m
//  CareBridge
//
//  Created by Gowtham on 09/10/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import "SmartRxAddHealthIssuesVC.h"
#import "SmartRxDashBoardVC.h"

@interface SmartRxAddHealthIssuesVC ()<UITextFieldDelegate>
{
    CGSize viewSize;
    NSDictionary *selectedHealthIssue;
    UILabel *currentLabel;

    
}
@property (strong, nonatomic) NSTimer * searchTimer;
@property (strong, nonatomic) NSArray * healthIssuesList;

@end

@implementation SmartRxAddHealthIssuesVC
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
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Add Health issue" controler:self];
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.hidden = YES;
    self.healthIssueTF.delegate= self;
    [self.healthIssueTF addTarget:self
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
                                                      userInfo: self.healthIssueTF.text
                                                       repeats: NO];
    
}


- (void)searchForKeyword:(NSTimer *)timer
{
    // retrieve the keyword from user info
    NSString *keyword = (NSString*)timer.userInfo;
    [self.healthIssueTF resignFirstResponder];
    if (self.healthIssueTF.text.length > 0) {
    [self makeRequestForSymptomsList];
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
-(IBAction)clickOnStartDateBtn:(id)sender{
    [self.healthIssueTF resignFirstResponder];
    currentLabel = self.startDateLbl;
    self.datePickerView.datePickerMode=UIDatePickerModeDate;
    [self ChooseDP:@"Date"];
}
-(IBAction)clickOnEndDateBtn:(id)sender{
    [self.view endEditing:YES];
    currentLabel = self.endDateLbl;
    self.datePickerView.datePickerMode=UIDatePickerModeDate;
    [self ChooseDP:@""];
}
-(IBAction)clickOnSaveBtn:(id)sender{
    if (self.healthIssueTF.text.length < 1) {
        [self customAlertView:@"" Message:@"Health issue name is required." tag:0];
        
    }
//    else if ([self.startDateLbl.text isEqualToString:@"Start Date"]) {
//        [self customAlertView:@"" Message:@"Please select start date." tag:0];
//        
//    }
    else {
        NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
        NSString *startDateStr = @"";
        if (![self.startDateLbl.text isEqualToString:@"Start Date"]) {
            startDateStr = self.startDateLbl.text;
        }
        NSString *endDateStr = @"";
        if (![self.endDateLbl.text isEqualToString:@"End Date"]) {
            endDateStr = self.endDateLbl.text;
        }
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"r_healthissue",@"record_type",@"",@"a_healthissue_id",self.healthIssueTF.text,@"a_issue_name",startDateStr,@"started_at",endDateStr,@"ended_at",userId,@"member_id",@"",@"entry_id", nil];
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
            [self makeRequestForAddHealthIssues:dict];
        else
            [self customAlertView:@"" Message:@"Network not available" tag:0];
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
        [self.datePickerView setMaximumDate:[NSDate date]];
        self.datePickerView.datePickerMode = UIDatePickerModeDate;
    }
    else
    {
        
        
        if (![self.startDateLbl.text isEqualToString:@"Start Date"]) {
            [dateFormatter setDateFormat:@"dd-MM-yyyy"];
            NSDate *date = [dateFormatter dateFromString:self.startDateLbl.text];
            
            [self.datePickerView setMaximumDate:[NSDate date]];
            [self.datePickerView setMinimumDate:date];
            
        }
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
    
    if (currentLabel == self.startDateLbl) {
        self.startDateLbl.text=strDate;
    } else {
        self.endDateLbl.text=strDate;
        
    }

    self.datePickerView.hidden=YES;
    [self closeDatePicker:nil];
    
}
-(BOOL)closeDatePicker:(id)sender{
    pickerAction.hidden = YES;
    return YES;
}
#pragma mark - Request Methods
-(void)makeRequestForAddHealthIssues:(NSDictionary *)info{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[SmartRxCommonClass sharedManager] addEHR:info successHandler:^(id response) {
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            if ([response[@"result"] integerValue] == 1) {
                [self customAlertView:@"" Message:@"Health issue added successfully" tag:999];
            } else {
                [self customAlertView:@"Error" Message:@"EHR updation failed .Please try again later." tag:0];
            }        });
        
    } failureHandler:^(id response) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self customAlertView:@"" Message:@"Network not available" tag:0];

    }];
    

}
-(void)makeRequestForSymptomsList{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *url=[NSString stringWithFormat:@"%s/ehr/archetypes/a_healthissue/search/%@?count=100",kBaseUrl,self.healthIssueTF.text];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:nil method:@"GET" setHeader:YES  successHandler:^(id response) {
        
        if (response == nil)
        {
            
            //[[SmartRxCommonClass sharedManager] checkExpiryAndLogin:self];
        }  else {
            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                
                self.healthIssuesList = response;
                if (self.healthIssuesList.count) {
                    self.tableView.hidden = NO;
                    [self.tableView reloadData];
                }else {
                    self.tableView.hidden = YES;
                    [self.tableView reloadData];
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
    return self.healthIssuesList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.healthIssuesList[indexPath.row][@"issue_name"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedHealthIssue = self.healthIssuesList[indexPath.row];
    self.healthIssueTF.text = self.healthIssuesList[indexPath.row][@"issue_name"];
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
