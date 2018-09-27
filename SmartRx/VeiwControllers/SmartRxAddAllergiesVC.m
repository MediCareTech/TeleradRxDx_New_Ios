//
//  SmartRxAddSymptomsVC.m
//  CareBridge
//
//  Created by Gowtham on 09/10/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import "SmartRxAddAllergiesVC.h"
#import "SmartRxDashBoardVC.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 1;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface SmartRxAddAllergiesVC ()
{
    CGSize viewSize;
    NSDictionary *selectedAllergen,*selectedReaction,*selectedSeverity;
    NSString *arrayType;
    UILabel *currentLabel;
    CGFloat animatedDistance;

}
@property (strong, nonatomic) NSArray * allergenList;
@property (strong, nonatomic) NSArray * reactionList;
@property (strong, nonatomic) NSArray * severityList;

@end

@implementation SmartRxAddAllergiesVC
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
    self.descriptionTF.delegate = self;
    //[[SmartRxCommonClass sharedManager] setNavigationTitle:@"Add Allergy" controler:self];
    self.navigationItem.title = @"Add Allergy";
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.hidden = YES;
    arrayType = @"a_allergen";
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
    [self makeRequestForAllergiesList:@"a_allergen"];

    
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
    [self.view endEditing:YES];
    currentLabel = self.startDate;
    self.datePickerView.datePickerMode=UIDatePickerModeDate;
    [self ChooseDP:@"Date"];
    
}
-(IBAction)clickOnendDateBtn:(id)sender{
    [self.view endEditing:YES];
    currentLabel = self.endDate;
    self.datePickerView.datePickerMode=UIDatePickerModeDate;
    [self ChooseDP:@""];
}
-(IBAction)clickOnAllergenBtn:(id)sender{
    [self.view endEditing:YES];
    self.tableViewType = AllergentableView;
    if (self.allergenList.count) {
        CGFloat y = self.allergenLbl.frame.origin.y+self.allergenLbl.frame.size.height+10;
        CGFloat Height = self.view.frame.size.height - y;
        [self setTableViewFrame:y height:Height];
        [self.tableView reloadData];
        self.tableView.hidden = NO;
    }
}
-(IBAction)clickOnReactionBtn:(id)sender{
    [self.view endEditing:YES];
    self.tableViewType = ReactionTableView;
    if (self.reactionList.count) {
        CGFloat y = self.reactionLbl.frame.origin.y+self.reactionLbl.frame.size.height+10;
        CGFloat Height = self.view.frame.size.height - y;
        [self setTableViewFrame:y height:Height];
        [self.tableView reloadData];
        self.tableView.hidden = NO;
    }
}
-(IBAction)clickOnSeverityBtn:(id)sender{
    [self.view endEditing:YES];

    self.tableViewType = SeverityTableView;
    if (self.severityList.count) {
        CGFloat y = self.severirtyLbl.frame.origin.y+self.severirtyLbl.frame.size.height+10;
        CGFloat Height = self.view.frame.size.height - y;
        [self setTableViewFrame:y height:Height];
        [self.tableView reloadData];
        self.tableView.hidden = NO;
    }
}
-(IBAction)clickOnSaveBtn:(id)sender{
    if ([self.allergenLbl.text isEqualToString:@"Select Allergen"]) {
        [self customAlertView:@"" Message:@"Please Select any allergy ." tag:0];
        
    }else if([self.reactionLbl.text isEqualToString:@"Select Reaction"]){
        [self customAlertView:@"" Message:@"Please Select any reaction ." tag:0];
    }else if([self.severirtyLbl.text isEqualToString:@"Select Severity"]){
        [self customAlertView:@"" Message:@"Please Select any Severity ." tag:0];
    } else  {
        
        NSString *startDateStr = @"";
        if (![self.startDate.text isEqualToString:@"Start Date"]) {
            startDateStr = self.startDate.text;
        }
        NSString *endDateStr = @"";
        if (![self.endDate.text isEqualToString:@"End Date"]) {
            endDateStr = self.endDate.text;
        }
        

        NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"r_allergy",@"record_type",selectedAllergen[@"id"],@"a_allergen_id",selectedReaction[@"id"],@"a_allergy_reaction_id",selectedSeverity[@"id"],@"a_allergy_severity_id",startDateStr,@"started_at",endDateStr,@"ended_at",userId,@"member_id",@"",@"entry_id",self.descriptionTF.text,@"comments", nil];
        if ([self.fromViewController isEqualToString:@"registerVc"]) {
            [self.delegate selectedAllergy:dict];
            [self.navigationController popViewControllerAnimated:NO];

        } else {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
            [self makeRequestForAddAllergy:dict];
        else
            [self customAlertView:@"" Message:@"Network not available" tag:0];
        }
    }
}

-(void)setTableViewFrame:(CGFloat)yPosition height:(CGFloat)hight{
    self.tableView.frame = CGRectMake(2, yPosition, self.view.frame.size.width-4, hight);
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
        
        if (![self.startDate.text isEqualToString:@"Start Date"]) {
            [dateFormatter setDateFormat:@"dd-MM-yyyy"];
            NSDate *date = [dateFormatter dateFromString:self.startDate.text];
            
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
    
    if (currentLabel == self.startDate) {
        self.startDate.text=strDate;
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
-(void)makeRequestForAddAllergy:(NSDictionary *)info{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[SmartRxCommonClass sharedManager] addEHR:info successHandler:^(id response) {
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            if ([response[@"result"] integerValue] == 1) {
                [self customAlertView:@"" Message:@"Allergy added successfully" tag:999];
            } else {
                [self customAlertView:@"Error" Message:@"EHR updation failed .Please try again later." tag:0];
            }        });
        
    } failureHandler:^(id response) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self customAlertView:@"" Message:@"Network not available" tag:0];

    }];
    
}
-(void)makeRequestForAllergiesList:(NSString *)typeStr{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *url=[NSString stringWithFormat:@"%s/ehr/archetypes/%@?count=100",kBaseUrl,typeStr];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:nil method:@"GET" setHeader:YES  successHandler:^(id response) {
        
        if (response == nil)
        {
            
            //[[SmartRxCommonClass sharedManager] checkExpiryAndLogin:self];
            
        }  else {
            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                if ([arrayType isEqualToString:@"a_allergen"]) {
                    self.allergenList = response;
                    arrayType = @"a_allergyreaction";
                    [self makeRequestForAllergiesList:@"a_allergyreaction"];

                } else if ([arrayType isEqualToString:@"a_allergyreaction"]) {
                    self.reactionList = response;
                    arrayType = @"a_allergyseverity";
                    [self makeRequestForAllergiesList:@"a_allergyseverity"];

                    
                }else if ([arrayType isEqualToString:@"a_allergyseverity"]) {
                    self.severityList = response;
                    arrayType = @"a_allergen";
                    
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
    NSInteger count = 0;
    if (self.tableViewType == SeverityTableView) {
        count = self.severityList.count;
    } else if (self.tableViewType == ReactionTableView) {
        count = self.reactionList.count;
    }else if (self.tableViewType == AllergentableView) {
        count = self.allergenList.count;
    }
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (self.tableViewType == SeverityTableView) {
    cell.textLabel.text = self.severityList[indexPath.row][@"allergy_severity_name"];
    } else if (self.tableViewType == ReactionTableView) {
     cell.textLabel.text = self.reactionList[indexPath.row][@"allergy_reaction_name"];
    }else if (self.tableViewType == AllergentableView) {
      cell.textLabel.text = self.allergenList[indexPath.row][@"allergen_name"];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableViewType == SeverityTableView) {
        selectedSeverity = self.severityList[indexPath.row];
      self.severirtyLbl.text = self.severityList[indexPath.row][@"allergy_severity_name"];
    } else if (self.tableViewType == ReactionTableView) {
        selectedReaction = self.reactionList[indexPath.row];
    self.reactionLbl.text = self.reactionList[indexPath.row][@"allergy_reaction_name"];
    }else if (self.tableViewType == AllergentableView) {
        selectedAllergen = self.allergenList[indexPath.row];
        self.allergenLbl.text = self.allergenList[indexPath.row][@"allergen_name"];

    }
   
    self.tableView.hidden = YES;
    
}
#pragma mark - TextField methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 0.5)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];

}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    
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
