//
//  SmartRxBookServices.m
//  SmartRx
//
//   by Manju Basha on 19/10/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxBookServices.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxPaymentVC.h"
#import "SmartRxeServicesVC.h"
#import "NSString+HTML.h"
#define kKeyBoardHeight 276
@interface SmartRxBookServices ()
{
    CGSize viewSize;
    NSString *service_name;
    UIRefreshControl *refreshControl;
    NSMutableArray *arrayOfState;
    MBProgressHUD *HUD;
    NSInteger service_type;
    UIPickerView *picker;
    CGFloat height;
    NSString *campId;
    UIToolbar* numberToolbar;
    NSInteger finalCost, actualCost, ser_auto_camp_count;
    int payOption;
    double discountedCost;
    NSMutableArray *responseArr, *slotArr, *methodArr;
}
@end

@implementation SmartRxBookServices

+ (id)sharedManagerServices {
    static SmartRxBookServices *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    if (!sectionId)
    {
        self.loggedInUserView.frame = CGRectMake(self.loggedInUserView.frame.origin.x, self.guestUserView.frame.origin.y+self.guestUserView.frame.size.height-9, self.loggedInUserView.frame.size.width, self.loggedInUserView.frame.size.height);
        self.loggedInUserView.backgroundColor = [UIColor clearColor];
    }
    else
        self.loggedInUserView.backgroundColor = [UIColor whiteColor];
    campId = @"";
    [self numberKeyBoardReturn];
    self.selectedDates = [[NSMutableArray alloc] init];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.payNow = [[RadioButton alloc] initWithGroupId:@"first group" index:0];
    [self.radioOneView addSubview:self.payNow];
    self.payLater = [[RadioButton alloc] initWithGroupId:@"first group" index:1];
    [self.radioTwoView addSubview:self.payLater];
    [RadioButton addObserverForGroupId:@"first group" observer:self];
    [self.payNow handleButtonTap:0];
    viewSize=[[UIScreen mainScreen]bounds].size;
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:backgroundView];
    
    self.arrServiceType = [[NSMutableArray alloc] initWithArray:@[@"Test / Diagnostics", @"Packages", @"Home Care"]];
    
    [self initializePickers];
    [self createBorderForAllBoxes];
    [self navigationBackButton];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UName"] length] >0)
    {
        self.nameTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"UName"];
        self.phoneTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    }
    
    // Do any additional setup after loading the view.
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
            [self makeRequestToAddServicesWithPayment];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TransactionSuccess"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self customAlertView:@"" Message:@"Sorry we were not able to process the payment. Please try again after sometime." tag:0];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)numberKeyBoardReturn
{
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(hideKeyBoard:)],
                           nil];
    [numberToolbar sizeToFit];
    
    self.nameTextField.inputAccessoryView = numberToolbar;
    self.phoneTextField.inputAccessoryView = numberToolbar;
    self.promoCodeText.inputAccessoryView = numberToolbar;
}
- (void)initCalendar
{
    CKCalendarView *calendar = [[CKCalendarView alloc] initWithStartDay:startMonday];
    self.calendar = calendar;
    calendar.delegate = self;
    calendar.onlyShowCurrentMonth = NO;
    calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    calendar.frame = CGRectMake(0, 0, 320, 320);
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.calendarContainer addSubview:calendar];
    //    [self.view addSubview:self.dateLabel];
    [self.view bringSubviewToFront:self.calendarContainer];
    
}
- (BOOL)dateIsApt:(NSDate *)date
{
    if ([self.selectedDates count])
    {
        for (NSDate *enableDate in self.selectedDates) {
            if ([enableDate isEqualToDate:date]) {
                return YES;
            }
        }
    }
    return NO;
    
}
- (void)initializePickers
{
    self.nameTextField.layer.cornerRadius=0.0f;
    self.nameTextField.layer.masksToBounds = YES;
    self.nameTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.nameTextField.layer.borderWidth= 1.0f;
    
    self.nameTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"name.png"]];
    self.nameTextField.leftView.frame = CGRectMake(self.nameTextField.leftView.frame.origin.x, self.nameTextField.leftView.frame.origin.y, self.nameTextField.leftView.frame.size.width-10, self.nameTextField.leftView.frame.size.height-10);
    
    self.phoneTextField.layer.cornerRadius=0.0f;
    self.phoneTextField.layer.masksToBounds = YES;
    self.phoneTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.phoneTextField.layer.borderWidth= 1.0f;
    
    self.phoneTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mobile.png"]];
    self.phoneTextField.leftView.frame = CGRectMake(self.phoneTextField.leftView.frame.origin.x, self.phoneTextField.leftView.frame.origin.y, self.phoneTextField.leftView.frame.size.width-10, self.phoneTextField.leftView.frame.size.height-10);
    self.serviceTypePicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.serviceTypePicker.delegate = self;
    self.serviceTypePicker.dataSource = self;
    self.serviceTypePicker.backgroundColor = [UIColor whiteColor];
    
    self.packageTypePicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.packageTypePicker.delegate = self;
    self.packageTypePicker.dataSource = self;
    self.packageTypePicker.backgroundColor = [UIColor whiteColor];
    
    self.timePicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.timePicker.delegate = self;
    self.timePicker.dataSource = self;
    self.timePicker.backgroundColor = [UIColor whiteColor];
}
#pragma mark Action Methods
-(void)cancelButtonPressed:(id)sender
{
    _actionSheet.hidden = YES;
}
-(void)doneButtonPressed:(id)sender
{
    if (self.currentButton == self.serviceTypeButton)
    {
        self.serviceTypeLbl.text = [self.arrServiceType objectAtIndex:[self.serviceTypePicker selectedRowInComponent:0]];
        if ([self.serviceTypeLbl.text isEqualToString:@"Test / Diagnostics"])
            service_type = 3;
        else if ([self.serviceTypeLbl.text isEqualToString:@"Packages"])
            service_type = 4;
        else
            service_type = 5;
        self.serviceTypeLbl.textColor = [UIColor blackColor];
        if (self.promoApplyBtn.tag == 999)
        {
            self.promoCodeText.text = nil;
            [self promoApplyBtnClicked:nil];
        }

        [self makeRequestForPackageType];
        
    }
    else if (self.currentButton == self.packageTypeButton)
    {
        service_name = [[self.arrPackageType objectAtIndex:[self.packageTypePicker selectedRowInComponent:0]] objectForKey:@"recno"];
        self.packageTypeLbl.textColor = [UIColor blackColor];
        self.packageTypeLbl.text = [[self.arrPackageType objectAtIndex:[self.packageTypePicker selectedRowInComponent:0]] objectForKey:@"service_name"];
//        NSString *description = [self convertHTML:[[self.arrPackageType objectAtIndex:[self.packageTypePicker selectedRowInComponent:0]] objectForKey:@"description"]];
//        NSString *description = [[[[[self.arrPackageType objectAtIndex:[self.packageTypePicker selectedRowInComponent:0]] objectForKey:@"description"] stringWithNewLinesAsBRs] stringByStrippingTags] stringByDecodingHTMLEntities];
        
        NSString *description = [[[self.arrPackageType objectAtIndex:[self.packageTypePicker selectedRowInComponent:0]] objectForKey:@"description"] stringByReplacingOccurrencesOfString: @"<br>" withString: @"<br/>"];
        description = [[description stringByDecodingHTMLEntities] stringByStrippingTags];
        
        if (self.promoApplyBtn.tag == 999)
        {
            self.promoCodeText.text = nil;
            [self promoApplyBtnClicked:nil];
        }
        if (description != nil && [description length] > 0)
        {
            self.packageDescription.text = description;
            self.packageDescription.textColor = [UIColor blackColor];
        }
        else
        {
            self.packageDescription.text = @"No description given";
            self.packageDescription.textColor = [UIColor lightGrayColor];
        }
        if ([[[self.arrPackageType objectAtIndex:[self.packageTypePicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"] integerValue] > 0)
        {
            self.serviceActualCost.text = [NSString stringWithFormat:@"Rs %@",[[self.arrPackageType objectAtIndex:[self.packageTypePicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"]];
            [self showAllPay];
        }
        else
        {
            self.serviceActualCost.text = @"Free";
            [self hideIfFree];
            [self hidePromo];
        }
        finalCost = [[[self.arrPackageType objectAtIndex:[self.packageTypePicker selectedRowInComponent:0]] objectForKey:@"service_amount"] integerValue];
        if ([[[self.arrPackageType objectAtIndex:[self.packageTypePicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"] integerValue] != [[[self.arrPackageType objectAtIndex:[self.packageTypePicker selectedRowInComponent:0]] objectForKey:@"service_amount"] integerValue])
        {
            [self setAutoDiscountValue:[[[self.arrPackageType objectAtIndex:[self.packageTypePicker selectedRowInComponent:0]] objectForKey:@"aservice_amount"] integerValue]];
        }
        else
        {
            self.serviceDiscountedCost.text = @"";
            finalCost = [[[self.arrPackageType objectAtIndex:[self.packageTypePicker selectedRowInComponent:0]] objectForKey:@"service_amount"] integerValue];
        }
        
    }
    else if (self.currentButton == self.timeButton)
    {
        self.timeLbl.text = [slotArr objectAtIndex:[self.timePicker selectedRowInComponent:0]];
    }
    _actionSheet.hidden = YES;
}
- (IBAction)serviceTypeButtonClicked:(id)sender

{
    self.currentButton = self.serviceTypeButton;
    self.currentButton.tag = 1;
    if ([self.arrServiceType count])
    {
        [self clearTextfieldData:self.serviceTypeLbl];
        [self showPicker];
    }
    else
        [self customAlertView:@"Network Error" Message:@"Not able to fetch the service type please refresh the page and try again." tag:1];
}

- (IBAction)packageTypeButtonClicked:(id)sender
{
    //    autoSelect = NO;
    self.currentButton = self.packageTypeButton;
    if (![self.serviceTypeLbl.text isEqualToString:@"Select Service Type"])
    {
        if([self.arrPackageType count])
        {
            [self clearTextfieldData:self.packageTypeLbl];
            //            calendarApiType = 2;
            //            [self getDoctorsList];
            [self showPicker];
        }
        else
        {
            self.packageTypeLbl.text = @"No Service Available";
            self.packageTypeLbl.textColor = [UIColor blackColor];
            self.packageDescription.text = @"No description available";
            self.packageDescription.textColor = [UIColor blackColor];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select a Service Type" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

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
- (IBAction)dateButtonClicked:(id)sender
{
    if ([self.serviceTypeLbl.text isEqualToString:@"Select Service Type"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select service type" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        //        [self makeRequestForDates];
    }
    else if ([self.packageTypeLbl.text isEqualToString:@"No Service Available"])
    {
        NSString *message = [NSString stringWithFormat:@"No services available for %@. Please select another service type", self.serviceTypeLbl.text];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
        return;
        
    }
    else
    {
        [self makeRequestForDates];
    }
    
}

- (IBAction)timeButtonClicked:(id)sender
{
    if (![self.timeLbl.text isEqualToString: @"No time slots available"])
    {
        self.currentButton = self.timeButton;
        self.currentButton.tag = 3;
        if ([slotArr count])
            [self showPicker];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"No time slots available please select another date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}

- (IBAction)promoApplyBtnClicked:(id)sender
{
    if (self.promoApplyBtn.tag == 666)
    {
        [self.promoCodeText resignFirstResponder];
        if ([self.promoCodeText.text length] > 0 && self.promoCodeText.text != nil)
        {
            NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
            if (!sectionId)
            {
                if ([self.nameTextField.text length] <= 0 )
                {
                    [self customAlertView:@"Please enter your name" Message:@"" tag:0];
                }
                else if ([self.phoneTextField.text length] <= 0)
                {
                    [self customAlertView:@"Please enter your mobile number" Message:@"" tag:0];
                }
                else if ([self.phoneTextField.text length] > 10)
                {
                    [self customAlertView:@"Mobile number cannot be more than 10 digits" Message:@"" tag:0];
                }
                else if ([self.phoneTextField.text length] < 10)
                {
                    [self customAlertView:@"Mobile number can not be less than 10 digits." Message:@"" tag:0];
                }
                else
                {
                    [self makeRequestCheckPromo];
                }
            }
            else
            {
                [self makeRequestCheckPromo];
            }
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
        self.serviceActualCost.text = self.serviceActualCost.text;
        if ([self.serviceDiscountedCost.text isEqualToString:@"Free"])
        {
            self.payNowView.frame = CGRectMake(self.payNowView.frame.origin.x, self.radioOneView.frame.origin.y+self.radioOneView.frame.size.height+10, self.payNowView.frame.size.width, self.payNowView.frame.size.height);
            if (payOption == 2)
                self.noteLbl.hidden = NO;
        }
        
        self.serviceDiscountedCost.text = nil;
        NSArray *arr = [self.serviceActualCost.text componentsSeparatedByString:@" "];
        if ([arr count]  >= 2)
            finalCost = [[arr objectAtIndex:1] integerValue];
        else
            finalCost = 0;
        [self.promoApplyBtn setTitle:@"APPLY" forState:UIControlStateNormal];
        [self.promoApplyBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bg.png"] forState:UIControlStateNormal];
        
    }
}

- (IBAction)hideKeyBoard:(id)sender
{
    [self.nameTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    [self.promoCodeText resignFirstResponder];
}

- (void)hideIfFree
{
    self.radioOneView.hidden = YES;
    self.radioTwoView.hidden = YES;
    self.payNowLabel.hidden = YES;
    self.payLaterLabel.hidden = YES;
    self.noteLbl.hidden = YES;
}

- (void)showAllPay
{
    self.radioOneView.hidden = NO;
    self.radioTwoView.hidden = NO;
    self.payNowLabel.hidden = NO;
    self.payLaterLabel.hidden = NO;
    self.noteLbl.hidden = NO;
    
}
- (void)hidePromo
{
    self.promoApplyBtn.hidden = YES;
    self.promoCodeText.hidden = YES;
    self.closeImage.hidden = YES;
    self.noteLbl.frame = CGRectMake(self.noteLbl.frame.origin.x, self.promoApplyBtn.frame.origin.y, self.noteLbl.frame.size.width, self.noteLbl.frame.size.height);
}

- (void)showPromo
{
    if (ser_auto_camp_count <= 0)
    {
        self.promoApplyBtn.hidden = NO;
        self.promoCodeText.hidden = NO;
        self.closeImage.hidden = NO;
        self.noteLbl.frame = CGRectMake(self.noteLbl.frame.origin.x, self.promoApplyBtn.frame.origin.y+self.promoApplyBtn.frame.size.height+8, self.noteLbl.frame.size.width, self.noteLbl.frame.size.height);
    }
    
}

- (IBAction)servicesBookBtnClicked:(id)sender
{
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    if (!sectionId)
    {
        if ([self.nameTextField.text length] <= 0 )
        {
            [self customAlertView:@"Please enter your name" Message:@"" tag:0];
        }
        else if ([self.phoneTextField.text length] <= 0)
        {
            [self customAlertView:@"Please enter your mobile number" Message:@"" tag:0];
        }
        else if ([self.phoneTextField.text length] > 10)
        {
            [self customAlertView:@"Mobile number cannot be more than 10 digits" Message:@"" tag:0];
        }
        else if ([self.phoneTextField.text length] < 10)
        {
            [self customAlertView:@"Mobile number can not be less than 10 digits." Message:@"" tag:0];
        }
        else if ([self.serviceTypeLbl.text isEqualToString:@"Select Service Type"])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select a Service Type" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [HUD hide:YES];
            [HUD removeFromSuperview];
            return;
        }
        else if ([self.packageTypeLbl.text isEqualToString:@"No Service Available"])
        {
            NSString *message = [NSString stringWithFormat:@"No services available for %@. Please select another service type", self.serviceTypeLbl.text];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [HUD hide:YES];
            [HUD removeFromSuperview];
            return;
            
        }
        else if([self.dateLbl.text isEqualToString: @"Select a date"])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Request you to pick a date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [HUD hide:YES];
            [HUD removeFromSuperview];
            return;
        }
        else if ([self.timeLbl.text isEqualToString: @"No time slots available"])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select available date and time and re-try" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [HUD hide:YES];
            [HUD removeFromSuperview];
            return;
        }
        else
            [self checkAndBook];
    }
    else
    {
        if ([self.serviceTypeLbl.text isEqualToString:@"Select Service Type"])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select a Service Type" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [HUD hide:YES];
            [HUD removeFromSuperview];
            return;
        }
        else if([self.dateLbl.text isEqualToString: @"Select a date"])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Request you to pick a date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [HUD hide:YES];
            [HUD removeFromSuperview];
            return;
        }
        else if ([self.timeLbl.text isEqualToString: @"No time slots available"])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Select available date and time and re-try" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [HUD hide:YES];
            [HUD removeFromSuperview];
            return;
        }
        else
            [self checkAndBook];
    }
    
}

- (void)checkAndBook
{
    if (finalCost == 0 || payOption-1 == 0)
    {
        [self makeRequestToAddService];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"fromServices"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self customAlertView:@"Note" Message:@"You will be taken to the payment gateway to complete the transaction, as you have chosen Pay Now" tag:2];
    }
    
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
#pragma mark - Storyboard Preapare segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"payment"]) {
        ((SmartRxPaymentVC *)segue.destinationViewController).costValue = [NSString stringWithFormat:@"%d", finalCost];
    }else if ([segue.identifier isEqualToString:@"SmartRxDashBoardVC"]){
//        SmartRxDashBoardVC *sMDVC = sMDVC
//        self.navigationController pushViewController:SmartRxDashBoardVC animated:NO];
    }
    
    
}
#pragma mark RadioButton Delegate
-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId{
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    int heightOfScroll=0;
    if (index == 0)
    {
        self.payNowView.hidden = NO;
        self.noteLbl.hidden = NO;
        payOption = 2;
        if (sectionId)
            heightOfScroll = 250;
        else
            heightOfScroll = 300;
    }
    else if (index == 1)
    {
        if (ser_auto_camp_count <= 0)
        {
            self.noteLbl.hidden = YES;
            if (sectionId)
                heightOfScroll = 100;
            else
                heightOfScroll = 200;
        }
        else
        {
            self.payNowView.hidden = YES;
            if (sectionId)
                heightOfScroll = 0;
            else
                heightOfScroll = 100;
        }
        payOption = 1;
        
    }
    [self.scrolView setContentSize:CGSizeMake(self.scrolView.frame.size.width, self.paymentFullView.frame.origin.y+self.paymentFullView.frame.size.height+heightOfScroll)];

}

#pragma mark - TextView Delegate method
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [textView resignFirstResponder];
    return NO;
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

#pragma mark - Textfield Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [textField resignFirstResponder];
    
    //return NO or YES, it doesn't matter
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.promoCodeText)
    {
        height=viewSize.height - (textField.frame.origin.y+textField.frame.size.height);
        height=kKeyBoardHeight-height-50;
        if (height > 0)
        {
            
            [UIView animateWithDuration:0.2 animations:^{
                
                self.scrolView.contentOffset=CGPointMake(self.scrolView.frame.origin.x, height);
            }];
        }
        [self.scrolView setContentSize:CGSizeMake(self.scrolView.frame.size.width, self.scrolView.frame.size.height+300)];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (height > 0)
    {
        [UIView animateWithDuration:0.2 animations:^{
            _scrolView.contentOffset=CGPointMake(0, 0);
        }];
    }
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    if (sectionId)
        [self.scrolView setContentSize:CGSizeMake(self.scrolView.frame.size.width, self.paymentFullView.frame.origin.y+ self.paymentFullView.frame.size.height+250)];
    else
        [self.scrolView setContentSize:CGSizeMake(self.scrolView.frame.size.width, self.paymentFullView.frame.origin.y+ self.paymentFullView.frame.size.height+300)];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.phoneTextField)
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 10) ? NO : YES;
    }
    return YES;
}
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (self.currentButton == self.serviceTypeButton)
    {
        return [self.arrServiceType count];
    }
    else if (self.currentButton == self.packageTypeButton)
    {
        return [self.arrPackageType count];
    }
    else if (self.currentButton == self.timeButton)
    {
        NSLog(@"slot arr count %d", [slotArr count]);
        return [slotArr count];
    }
    
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (self.currentButton==self.serviceTypeButton)
    {
        return [self.arrServiceType objectAtIndex:row];
    }
    else if (self.currentButton==self.packageTypeButton)
    {
        return [[self.arrPackageType objectAtIndex:row] objectForKey:@"service_name"];// objectForKey:@"dispname"];
    }
    else if (self.currentButton==self.timeButton)
    {
        return [slotArr objectAtIndex:row];
    }
    return [NSString stringWithFormat:@"Hey Row %ld", (long)self.currentButton.tag];
}

#pragma mark - other methods
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

- (void)showPicker
{
    [self hideKeyBoard:nil];
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
    
    if (self.currentButton==self.serviceTypeButton)
    {
        [_actionSheet addSubview:self.serviceTypePicker];
        [self.serviceTypePicker reloadAllComponents];
    }
    else if (self.currentButton==self.packageTypeButton)
    {
        [_actionSheet addSubview:self.packageTypePicker];
        [self.packageTypePicker reloadAllComponents];
        if ([self.packageTypeLbl.text isEqualToString:@"No Service Available"])
            [self.packageTypePicker selectRow:0 inComponent:0 animated:NO];
        else
        {
            NSArray *arrayWithPlaces = [self.arrPackageType valueForKey:@"service_name"];
            NSUInteger index = [arrayWithPlaces indexOfObject:self.packageTypeLbl.text];
            [self.packageTypePicker selectRow:index inComponent:0 animated:NO];
        }
        
    }
    else if (self.currentButton == self.timeButton)
    {
        [_actionSheet addSubview:self.timePicker];
        [self.timePicker reloadAllComponents];
    }
    
    [self.view addSubview:_actionSheet];
    [self.view bringSubviewToFront:_actionSheet];
    _actionSheet.hidden = NO;
    
    
}

-(void)clearTextfieldData:(UILabel *)selectedLabel
{
    if (selectedLabel == self.serviceTypeLbl)
    {
//        if(![self.packageTypeLbl.text isEqualToString:@"No Service Available"])
//        {
//            self.packageTypeLbl.text=@"No Service Available";
//            self.packageTypeLbl.textColor = [UIColor lightGrayColor];
//        }
        if(![self.dateLbl.text isEqualToString:@"Select a date"])
        {
            self.dateLbl.text=@"Select a date";
            self.dateLbl.textColor = [UIColor lightGrayColor];
            //            NSDate *today = [NSDate date];
            //            NSDate *end = [NSDate date];
            
        }
        if(![self.timeLbl.text isEqualToString:@"No time slots available"])
        {
            self.timeLbl.text=@"No time slots available";
            self.timeLbl.textColor = [UIColor lightGrayColor];
        }
    }
    else if (selectedLabel == self.packageTypeLbl)
    {
        if(![self.dateLbl.text isEqualToString:@"Select a date"])
        {
            self.dateLbl.text=@"Select a date";
            self.dateLbl.textColor = [UIColor lightGrayColor];
            //            NSDate *today = [NSDate date];
            //            NSDate *end = [NSDate date];
            //
        }
        if(![self.timeLbl.text isEqualToString:@"No time slots available"])
        {
            self.timeLbl.text=@"No time slots available";
            self.timeLbl.textColor = [UIColor lightGrayColor];
        }
    }
}

#pragma mark borderMethod
- (void)createBorderForAllBoxes
{
    
    self.serviceTypeButton.layer.cornerRadius=0.0f;
    self.serviceTypeButton.layer.masksToBounds = YES;
    self.serviceTypeButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.serviceTypeButton.layer.borderWidth= 1.0f;
    
    self.packageTypeButton.layer.cornerRadius=0.0f;
    self.packageTypeButton.layer.masksToBounds = YES;
    self.packageTypeButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.packageTypeButton.layer.borderWidth= 1.0f;
    
    self.dateButton.layer.cornerRadius=0.0f;
    self.dateButton.layer.masksToBounds = YES;
    self.dateButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.dateButton.layer.borderWidth= 1.0f;
    
    self.timeButton.layer.cornerRadius=0.0f;
    self.timeButton.layer.masksToBounds = YES;
    self.timeButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.timeButton.layer.borderWidth= 1.0f;
    
    
    self.packageDescription.layer.cornerRadius=0.0f;
    self.packageDescription.layer.masksToBounds = YES;
    self.packageDescription.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.packageDescription.layer.borderWidth= 1.0f;
    
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

#pragma mark - Request methods

- (void)makeRequestCheckPromo
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&for=3&promocode=%@",@"cid",strCid,@"sessionid",sectionId, self.promoCodeText.text];
    }
    else{
        bodyText=[NSString stringWithFormat:@"name=%@&mobile=%@&%@=%@&%@=%@&for=3&promocode=%@",self.nameTextField.text, self.phoneTextField.text, @"cid",strCid,@"isopen",@"1", self.promoCodeText.text];
    }
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mchkcamp"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"hi sucess 111 %@",response);
        
        if (([response count] == 0 && [sectionId length] == 0))
        {
            //            [self makeRequestForUserRegister];
        }
        else
        {
//            if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
//            {
//                
//            }
//            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    if ([[response objectForKey:@"chkredeem"] integerValue] == )
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    NSString *msg;
                    if ([[response objectForKey:@"chkredeem"] integerValue] == 1)
                    {
                        self.promoApplyBtn.tag = 999;
                        [self.promoApplyBtn setTitle:nil forState:UIControlStateNormal];
                        [self.promoApplyBtn setBackgroundImage:nil forState:UIControlStateNormal];
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Promo code applied. Thank you." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        //                        campId = [[[response objectForKey:@"campaign"] objectAtIndex:0] objectForKey:@"recno"];
                        //                        discount
                        campId = [[[response objectForKey:@"campaign"] objectAtIndex:0] objectForKey:@"recno"];
                        float discountPercent = [[[[response objectForKey:@"campaign"] objectAtIndex:0] objectForKey:@"discount"] floatValue];
                        discountPercent = discountPercent/100;
                        float discount = finalCost * discountPercent;
                        discountedCost = ceilf(finalCost - discount);
                        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %d", finalCost]];
                        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                                value:@2
                                                range:NSMakeRange(0, [attributeString length])];
                        self.serviceActualCost.attributedText = attributeString;
                        finalCost = discountedCost;
                        if (discountedCost > 0)
                            self.serviceDiscountedCost.text = [NSString stringWithFormat:@"Rs %d", (int)discountedCost];
                        else
                        {
                            self.serviceDiscountedCost.text = @"Free";
                            self.payNowView.frame = CGRectMake(self.payNowView.frame.origin.x, self.radioOneView.frame.origin.y-3, self.payNowView.frame.size.width, self.payNowView.frame.size.height);
                            self.noteLbl.hidden = YES;
                        }
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -3)
                    {
                        msg = @"You already used this promo code";
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -4)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"This promo code expired." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -5)
                    {
                        msg = @"Given promo code not sent to this user";
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Name cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -6)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Promo code is invalid. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -7)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable at this location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -8)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable for this visit." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -9)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable for Services." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    
                });
            }
//        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
}


-(void)makeRequestForDates
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText;
    if (sectionId)
        bodyText = [NSString stringWithFormat:@"%@=%@&type=1",@"sessionid",sectionId];
    else
        bodyText = [NSString stringWithFormat:@"isopen=1&type=1&cid=%@",strCid];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mecondt"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        NSLog(@"sucess 1 %@",response);
//        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
//        {
//            //            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
//            //            smartLogin.loginDelegate=self;
//            //            [smartLogin makeLoginRequest];
//            //
//        }
//        else
//        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *type = NSStringFromClass([[response objectForKey:@"econdates"] class]);
                if(![type isEqualToString:@"__NSCFNumber"])
                {
                    NSMutableArray *sample = [[NSMutableArray alloc]initWithArray:[response objectForKey:@"econdates"]];
                    responseArr = [[NSMutableArray alloc]init];
                    //                    self.calendar.hidden = NO;
                    for (int i=0;i<[sample count];i++)
                    {
                        for (int j=0; j<[[sample objectAtIndex:i] count];j++)
                        {
                            NSDate * myDate = [NSDate dateWithTimeIntervalSince1970:[[[sample objectAtIndex:i] objectAtIndex:j] doubleValue]];
                            [self.selectedDates addObject:myDate];
                        }
                    }
                    [self initCalendar];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"No dates available for the selected service." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                
            });
//        }
        
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error loading dates please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}

- (void)makeRequestForSlots
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText;
    if (sectionId)
        bodyText = [NSString stringWithFormat:@"%@=%@&&doa=%@&cid=%@",@"sessionid",sectionId, self.dateLbl.text,    strCid];
    else
        bodyText = [NSString stringWithFormat:@"isopen=1&doa=%@&cid=%@", self.dateLbl.text, strCid];
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mstime"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            //            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            //            smartLogin.loginDelegate=self;
            //            [smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                slotArr = [[NSMutableArray alloc]init];
                slotArr = [response objectForKey:@"stime"];
                if ([slotArr count])
                {
                    self.timeLbl.text = [[response objectForKey:@"stime"] objectAtIndex:0];
                    self.timeLbl.textColor = [UIColor blackColor];
                }
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error loading dates please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}

-(void)makeRequestForPackageType
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    /*sessionid
     service_type
     isopen
     cid*/
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&service_type=%d&%@=%@&%@=%@",@"sessionid",sectionId, service_type, @"cid",strCid,@"isopen",@"1"];
    }
    else{
        bodyText=[NSString stringWithFormat:@"%@=%@&%@=%@&service_type=%d",@"cid",strCid,@"isopen",@"1", service_type];
    }
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"msname"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"hi sucess --- %@",response);
        
        if (([response count] == 0 && [sectionId length] == 0))
        {
            //            [self makeRequestForUserRegister];
        }
        else if([sectionId length] == 0 && [[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            //[self makeRequestForUserRegister];
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
                    self.view.userInteractionEnabled = YES;
                    [refreshControl endRefreshing];
                    self.arrPackageType=[response objectForKey:@"snames"];
                    if([self.arrPackageType count])
                    {
                        service_name = [[self.arrPackageType objectAtIndex:0]objectForKey:@"recno"];
                        self.packageTypeLbl.textColor = [UIColor blackColor];
                        self.packageTypeLbl.text = [[self.arrPackageType objectAtIndex:0]objectForKey:@"service_name"];
//                        NSString *description = [self convertHTML:[[self.arrPackageType objectAtIndex:0]objectForKey:@"description"]];
                        NSString *description = [[[self.arrPackageType objectAtIndex:0] objectForKey:@"description"] stringByReplacingOccurrencesOfString: @"<br>" withString: @"<br/>"];
                        description = [[description stringByDecodingHTMLEntities] stringByStrippingTags];

//                      description = [[description stringByStrippingTags] stringByDecodingHTMLEntities];
//                      [[[[self.arrPackageType objectAtIndex:0] objectForKey:@"description"] stringByDecodingHTMLEntities] stringByStrippingTags];
                        [self convertHTML:description];
                        if (description != nil && [description length] > 0)
                        {
                            self.packageDescription.text = description;
                            self.packageDescription.textColor = [UIColor blackColor];
                        }
                        else
                        {
                            self.packageDescription.text = @"No description given";
                            self.packageDescription.textColor = [UIColor lightGrayColor];
                        }
                        
                        if ([[[self.arrPackageType objectAtIndex:0]objectForKey:@"aservice_amount"] integerValue]>0)
                        {
                            self.serviceActualCost.text = [NSString stringWithFormat:@"Rs %@",[[self.arrPackageType objectAtIndex:0]objectForKey:@"aservice_amount"]];
                            [self showAllPay];
                        }
                        else
                        {
                            self.serviceActualCost.text = @"Free";
                            [self hideIfFree];
                            [self hidePromo];
                        }
                        finalCost = [[[self.arrPackageType objectAtIndex:0]objectForKey:@"service_amount"] integerValue];
                        self.serviceDiscountedCost.text= @"";
                        if ([[[self.arrPackageType objectAtIndex:0]objectForKey:@"aservice_amount"] integerValue] != [[[self.arrPackageType objectAtIndex:0]objectForKey:@"service_amount"] integerValue])
                        {
                            [self setAutoDiscountValue:[[[self.arrPackageType objectAtIndex:0]objectForKey:@"aservice_amount"] integerValue]];
                        }
                        if ([[response objectForKey:@"ser_auto_camp_count"] integerValue] == 1)
                            [self hidePromo];
                        else
                            [self showPromo];
                        self.packageDescription.hidden = NO;
                        self.dateTimeView.frame = CGRectMake(self.dateTimeView.frame.origin.x, self.packageDescription.frame.origin.y+self.packageDescription.frame.size.height+8, self.dateTimeView.frame.size.width, self.dateTimeView.frame.size.height);
                        self.paymentFullView.hidden = NO;
                        self.paymentFullView.frame = CGRectMake(self.paymentFullView.frame.origin.x, self.dateTimeView.frame.origin.y+self.dateTimeView.frame.size.height, self.paymentFullView.frame.size.width, self.paymentFullView.frame.size.height);
                        if (sectionId)
                            [self.scrolView setContentSize:CGSizeMake(self.scrolView.frame.size.width, self.paymentFullView.frame.origin.y+self.paymentFullView.frame.size.height+250)];
                        else
                            [self.scrolView setContentSize:CGSizeMake(self.scrolView.frame.size.width, self.paymentFullView.frame.origin.y+self.paymentFullView.frame.size.height+300)];
                        
                    }
                    else
                    {
                        self.packageTypeLbl.text = @"No Service Available";
                        self.packageDescription.text = @"No description available";
                    }
                    //                    [self getDoctorsList];
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                });
            }
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
}
- (void)makeRequestToAddService
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText;
    //sessionid     isopen     cid service_type  service_name doa toa name mobile email service_price payment_type
    if (sectionId)
        bodyText = [NSString stringWithFormat:@"sessionid=%@&cid=%@&service_type=%d&service_name=%@&doa=%@&toa=%@&service_price=%d&payment_type=%d",sectionId, strCid, service_type, service_name,self.dateLbl.text, self.timeLbl.text, finalCost,payOption-1];
    else
        bodyText = [NSString stringWithFormat:@"isopen=1&cid=%@&service_type=%d&service_name=%@&doa=%@&toa=%@&service_price=%d&payment_type=%d&name=%@&mobile=%@",strCid, service_type, service_name,self.dateLbl.text, self.timeLbl.text, finalCost,payOption-1, self.nameTextField.text, self.phoneTextField.text];
    
    if ([campId length] > 0 && campId != nil)
    {
        NSString *campTemp = [NSString stringWithFormat:@"&campid=%@",campId];
        bodyText = [bodyText stringByAppendingString:campTemp];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"msbook"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            //            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            //            smartLogin.loginDelegate=self;
            //            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[response objectForKey:@"booked"] integerValue] == 1)
                {
                    [self customAlertView:@"" Message:[response objectForKey:@"status_msg"] tag:1];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error booking Service please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    return;
                }
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error booking Service please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
    
}

- (void)makeRequestToAddServicesWithPayment
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText;
    //sessionid     isopen     cid service_type  service_name   name mobile email service_price payment_type
    
    if (sectionId)
        bodyText = [NSString stringWithFormat:@"sessionid=%@&cid=%@&service_type=%d&service_name=%@&doa=%@&toa=%@&service_price=%d&payment_type=%d&payraw=%@&TxId=%@&TxStatus=%@&amount=%@&authIdCode=%@&TxMsg=%@&pgTxnNo=%@&paymentMode=%@",sectionId, strCid, service_type, service_name,self.dateLbl.text, self.timeLbl.text, finalCost,payOption-1, self.paymentResponseDictionary, [self.paymentResponseDictionary objectForKey:@"TxId"],[self.paymentResponseDictionary objectForKey:@"TxStatus"],[self.paymentResponseDictionary objectForKey:@"amount"] ,[self.paymentResponseDictionary objectForKey:@"authIdCode"] ,[self.paymentResponseDictionary objectForKey:@"TxMsg"] ,[self.paymentResponseDictionary objectForKey:@"pgTxnNo"] ,[self.paymentResponseDictionary objectForKey:@"paymentMode"]];
    
    else
        bodyText = [NSString stringWithFormat:@"isopen=1&name=%@&mobile=%@&cid=%@&service_type=%d&service_name=%@&doa=%@&toa=%@&service_price=%d&payment_type=%d&payraw=%@&TxId=%@&TxStatus=%@&amount=%@&authIdCode=%@&TxMsg=%@&pgTxnNo=%@&paymentMode=%@",self.nameTextField.text, self.phoneTextField.text, strCid, service_type, service_name,self.dateLbl.text, self.timeLbl.text, finalCost,payOption-1, self.paymentResponseDictionary, [self.paymentResponseDictionary objectForKey:@"TxId"],[self.paymentResponseDictionary objectForKey:@"TxStatus"],[self.paymentResponseDictionary objectForKey:@"amount"] ,[self.paymentResponseDictionary objectForKey:@"authIdCode"] ,[self.paymentResponseDictionary objectForKey:@"TxMsg"] ,[self.paymentResponseDictionary objectForKey:@"pgTxnNo"] ,[self.paymentResponseDictionary objectForKey:@"paymentMode"]];
    if ([campId length] > 0 && campId != nil)
    {
        NSString *campTemp = [NSString stringWithFormat:@"&campid=%@",campId];
        bodyText = [bodyText stringByAppendingString:campTemp];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"msbook"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            //            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            //            smartLogin.loginDelegate=self;
            //            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[response objectForKey:@"booked"] integerValue] == 1)
                {
                    [self customAlertView:@"" Message:[response objectForKey:@"status_msg"] tag:1];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error booking Service please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    return;
                }
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error booking Service please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
    
}
-(void)setAutoDiscountValue:(NSInteger)costReceived
{
    if(costReceived != 0 && costReceived != finalCost)
    {
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %d", costReceived]];
        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                value:@2
                                range:NSMakeRange(0, [attributeString length])];
        self.serviceActualCost.attributedText = attributeString;
        if (finalCost > 0)
        {
            self.serviceDiscountedCost.text = [NSString stringWithFormat:@"Rs %d", (int)finalCost];
            [self showAllPay];
        }
        else
        {
            self.serviceDiscountedCost.text = @"Free";
            [self hideIfFree];
        }
        
    }
    else if (finalCost == 0)
    {
        self.serviceDiscountedCost.text = @"Free";
        [self hideIfFree];
    }
}


-(NSString *)convertHTML :(NSString *)html {
    
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    html = [html stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    return html;
}

#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
               [self.navigationController popViewControllerAnimated:YES];
    }
    if (alertView.tag == 2 && buttonIndex == 1)
        [self performSegueWithIdentifier:@"payment" sender:nil];
}
#pragma mark - CKCalendarDelegate
- (void)calendar:(CKCalendarView *)calendar configureDateItem:(CKDateItem *)dateItem forDate:(NSDate *)date {
    if ([self dateIsApt:date])
    {
        dateItem.backGroundImg = [UIImage imageNamed:@"dayMarked.png"];
    }
}
- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone systemTimeZone];
    [dateFormat setTimeZone:gmt];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    self.dateLbl.text = [dateFormat stringFromDate:date];
    self.dateLbl.textColor = [UIColor blackColor];
    if ([self dateIsApt:date])
    {
        //        NSLog(@"%@",[self.appointmentDetails objectAtIndex:[self.selectedDates indexOfObject:date]]);
        [self.selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isEqualToDate:date])
             {
                 [self makeRequestForSlots];
                 [self.view sendSubviewToBack:self.calendarContainer];
                 self.calendar.hidden = YES;
             }
         }];
    }
    else
    {
        [self.view sendSubviewToBack:self.calendarContainer];
        self.calendar.hidden = YES;
        self.timeLbl.text = @"No time slots available";
        self.timeLbl.textColor = [UIColor blackColor];        
        [self customAlertView:@"" Message:@"No time slots available. Please select another date." tag:0];
        //ALERT SAYING TIME SLOTS NOT AVAILABLE
    }
    
}

- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    return [date laterDate:self.minimumDate] == date;
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
