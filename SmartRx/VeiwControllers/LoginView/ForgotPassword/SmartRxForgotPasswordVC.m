
//
//  SmartRxForgotPasswordVC.m
//  SmartRx
//
//  Created by PaceWisdom on 21/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxForgotPasswordVC.h"
#import "SmartRxDashBoardVC.h"

#define kSuccessAlertTag 345

@interface SmartRxForgotPasswordVC ()
{
    CGSize viewSize;
    MBProgressHUD *HUD;
    UIToolbar* numberToolbar;
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
}

@end

@implementation SmartRxForgotPasswordVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    
}
-(void)numberKeyBoardReturn
{
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           //[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"return" style:UIBarButtonItemStyleDone target:self action:@selector(returnWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtMobileNum.inputAccessoryView = numberToolbar;
}
-(void)returnWithNumberPad
{
    [self.txtMobileNum resignFirstResponder];
}
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    self.txtMobileNum.inputAccessoryView = doneToolbar;
    //[self numberKeyBoardReturn];
   // [self numberKeyBoardReturn];
    
    
    viewSize=[[UIScreen mainScreen]bounds].size;
    
    
    pickerAction = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    pickerAction.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = pickerAction.bounds;
    [pickerAction addSubview:backgroundView];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"])
    {
        self.txtMobileNum.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    }
    
    // Do any additional setup after loading the view.
}
- (void)doneButton:(id)sender
{
    [self.txtMobileNum  resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Request Method
-(void)makeRequestToGetPassword
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&dob=%@",@"cid",strCid,@"mobile",self.txtMobileNum.text,self.txtDob.text];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mreset"];

    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        
        NSLog(@"sucess 22 %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        if ([[[response objectAtIndex:0]objectForKey:@"res_code"]integerValue] == 1)
            
        {
            [[NSUserDefaults standardUserDefaults]setObject:self.txtMobileNum.text forKey:@"MobileNumber"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Your password has been sent to your mobile. Please enter the password to continue" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag=kSuccessAlertTag;
            [alert show];
            
        }
        else{
            //@"Mobile number you entered is not registered."
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:response[0][@"msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    
    } failureHandler:^(id response) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Resending password failed. Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
#pragma mark - Action Methods

- (IBAction)sendPasswordBtnClicked:(id)sender
{
    [self.txtMobileNum resignFirstResponder];
    if ([self.txtMobileNum.text length]> 9)
    {
        if (self.txtDob.text.length <= 0){
            [self customAlertView:@"Date of birth should not be empty" Message:@"" tag:0];
        }else {
        
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestToGetPassword];
        }
        else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }
        }
    }
    else if([self.txtMobileNum.text length] == 0)
            {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Mobile number can not be empty" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;

    }
    else if([self.txtMobileNum.text length] < 10)
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Mobile number can not be less than 10 digits." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
    }
    
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
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)hideKeyBoard:(id)sender
{
    [self.txtMobileNum resignFirstResponder];
}
-(IBAction)clickOnDobBtn:(id)sender{
    [self.view endEditing:YES];
    //currentTextfied=self.txtDOB;
    [self loadDatePicker];
}
-(void)loadDatePicker{
    
    self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    self.datePickerView.backgroundColor = [UIColor whiteColor];
    NSString *date = self.txtDob.text;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    self.datePickerView.datePickerMode = UIDatePickerModeDate;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    NSDate *maxDate = [gregorian dateByAddingComponents:comps toDate:currentDate  options:0];
    self.datePickerView.maximumDate = maxDate;
    if([date length]>0)
    {
        [self.datePickerView setDate:[self dateConvertor:date]];
    }
    toolbarPicker = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-260, 320, 44)];
    toolbarPicker.barStyle=UIBarStyleBlackOpaque;
    [toolbarPicker sizeToFit];
    NSMutableArray *itemsBar = [[NSMutableArray alloc] init];
    //calls DoneClicked
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [itemsBar addObject:doneBtn];
    
    //    UIBarButtonItem *bbitem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(DoneClicked:)];
    //    [ addObject:bbitem];
    
    [toolbarPicker setItems:itemsBar animated:YES];
    [pickerAction addSubview:toolbarPicker];
    [pickerAction addSubview:self.datePickerView];
    [self.view addSubview:pickerAction];
    pickerAction.hidden = NO;
}
-(NSDate *)dateConvertor:(NSString *)dateStr{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [format setTimeZone:gmt];
    [format setDateFormat:@"dd-MMM-yyyy"];
    NSDate *serverDate = [format dateFromString:dateStr];
    [format setDateFormat:@"dd-MM-yyyy"];
    NSString *temp = [format stringFromDate:serverDate];
    NSDate *originalDate = [format dateFromString:temp];
    return originalDate;
}
- (void)doneClicked:(id)sender
{
    NSDate *dateAppointment=self.datePickerView.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MMM-yyy"];
    NSString *strDate = [dateFormat stringFromDate:dateAppointment];
    NSLog(@"date ==== %@",strDate);
    self.txtDob.text=strDate;
    self.datePickerView.hidden=YES;
    
    [self closeDatePicker:nil];
    
}
-(BOOL)closeDatePicker:(id)sender{
    pickerAction.hidden = YES;
    return YES;
}
#pragma mark - Text field delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-numberToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+numberToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - Alert Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kSuccessAlertTag && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [HUD hide:YES];
    [HUD removeFromSuperview];

    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestToGetPassword];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
}
-(void)errorSectionId:(id)sender
{
    [HUD hide:YES];
    [HUD removeFromSuperview];

    self.view.userInteractionEnabled = YES;
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

@end
