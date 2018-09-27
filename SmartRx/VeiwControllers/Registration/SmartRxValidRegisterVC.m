//
//  SmartRxRegisterValidVC.m
//  SmartRx
//
//  Created by PaceWisdom on 30/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxValidRegisterVC.h"
#import "SmartRxRegisterVC.h"
#import "SmartRxRegisterVC.h"
#import "SmartRxDashBoardVC.h"
#import "UIImageView+WebCache.h"
#import "SmartRxAppDelegate.h"
#import "ALToastView.h"
#import "SmartRxAccountPickerVC.h"
#define kCodeTxtTag 5002
#define kMobileTxtTag 5001
#define kRegistredUserAlertTag 500
#define kLessThan4Inch 560

@interface SmartRxValidRegisterVC ()
{
    MBProgressHUD *HUD;
    UIToolbar* numberToolbar;
    CGSize viewSize;
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
}

@end

@implementation SmartRxValidRegisterVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}//RegisterID

-(void)navigationBackButton
{
    
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_home.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [btnFaq addTarget:self action:@selector(homeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromLogin"])
    {
        self.navigationItem.rightBarButtonItem = rightbutton;
    }
    
}

-(void)numberKeyBoardReturn
{
    
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(retunWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    //self.txtMobile.inputAccessoryView = numberToolbar;
}
-(void)retunWithNumberPad
{
    [self.txtMobile resignFirstResponder];
    //[self validateBtnClicked:nil];
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.txtCode.text = nil;
    self.txtCode.placeholder = @"Code";
    self.navigationItem.hidesBackButton=YES;
    self.txtName.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtMobile.autocorrectionType = UITextAutocorrectionTypeNo;
    viewSize=[[UIScreen mainScreen]bounds].size;
    
    
    pickerAction = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    pickerAction.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = pickerAction.bounds;
    [pickerAction addSubview:backgroundView];
    
    //Adding image on Navigation bar
    if (viewSize.height < kLessThan4Inch)
    {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height+100)];
    }
    //    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"MobileNumber"])
    //    {
    //        self.txtMobile.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobileNumber"];
    //    }
    // Do any additional setup after loading the view.
}
- (void)doneButton:(id)sender
{
    [self.txtMobile resignFirstResponder];
    //    if ([self.closeViewContainer isHidden])
    //        [self validateBtnClicked:nil];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    _isFromLogin=NO;
    [self closeBtnClicked:nil];
    self.txtCode.text = nil;
    self.txtCode.placeholder = @"Code";
    self.txtName.text = nil;
    self.txtName.placeholder = @"Name";
    self.txtMobile.text = nil;
    self.txtMobile.placeholder = @"Mobile Number";
    self.txtDob.text = nil;
    [self navigationBackButton];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    //    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"code" ])
    //    {
    //        self.txtCode.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    //    }
    
}
-(void)viewDidAppear:(BOOL)animatedd
{
    [super viewDidAppear:YES];
    SmartRxAppDelegate *delegate = (SmartRxAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"]) {
        if (delegate.passwordStatus == false) {
            [self performSegueWithIdentifier:@"ValidToDBID" sender:nil];
        }
        
    }
    //
    //    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"Reinstalling"])
    //    {
    //        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"Reinstalling"];
    //        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"] boolValue])//[[NSUserDefaults standardUserDefaults]boolForKey:@"sessionid"]
    //        {
    //             [self performSegueWithIdentifier:@"ValidToDBID" sender:nil];
    //        }
    //
    //    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request Methods

-(void)makeRequestForUserRegister
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",self.txtMobile.text];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"name",self.txtName.text]];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"pclientid",@"1047"]];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"custom",@"1"]];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"dob",self.txtDob.text]];

    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"cid",@"99"]];
    
    if (self.txtCode.text && ![self.closeViewContainer isHidden])
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"code",self.txtCode.text]];
    else
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"code",@"TRxDx"]];
    
    NSLog(@"sucess 23 %@",bodyText);
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mnewreg"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 33 %@",response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            if (self.txtCode.text)
                [[NSUserDefaults standardUserDefaults]setObject:self.txtCode.text forKey:@"code"];
            [[NSUserDefaults standardUserDefaults]setObject:self.txtMobile.text forKey:@"MobilNumber"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                
                [self customAlertView:@"" Message:@"USER TO BE REGISTERED" tag:kRegistredUserAlertTag];
                //                [self performSegueWithIdentifier:@"RegisterID" sender:[response objectForKey:@"cid"]];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [[NSUserDefaults standardUserDefaults]setObject:self.txtName.text forKey:@"UName"];
                [[NSUserDefaults standardUserDefaults]setObject:self.txtMobile.text forKey:@"UserMobile"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                if ([[response objectForKey:@"hinfo"] count] == 1)
                {
                    
                    NSInteger paddedStr = [[NSString stringWithFormat:@"%@",[response objectForKey:@"padded"]] integerValue];
                    if(paddedStr ==1) {
                        
                        [[NSUserDefaults standardUserDefaults]setObject:[[[response objectForKey:@"hinfo"] objectAtIndex:0] objectForKey:@"custid"] forKey:@"cidd"];
                        [[NSUserDefaults standardUserDefaults]setObject:[[[response objectForKey:@"hinfo"] objectAtIndex:0] objectForKey:@"custid" ] forKey:@"cid"];
                        NSString *strHospName=[[[response objectForKey:@"hinfo"] objectAtIndex:0] objectForKey:@"hospitalName"];
                        [[NSUserDefaults standardUserDefaults]setObject:strHospName forKey:@"HosName"];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                        [self customAlertView:@"" Message:@"Congratulations! You are now registered and a password has been sent to your mobile. Please enter the password to continue." tag:100];
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults]setObject:[[[response objectForKey:@"hinfo"] objectAtIndex:0] objectForKey:@"custid"] forKey:@"cidd"];
                        [[NSUserDefaults standardUserDefaults]setObject:[[[response objectForKey:@"hinfo"] objectAtIndex:0] objectForKey:@"custid" ] forKey:@"cid"];
                        NSString *strFrontDestNum=[[[response objectForKey:@"hinfo"] objectAtIndex:0]objectForKey:@"frontDeskNo" ];
                        if (strFrontDestNum != [NSNull null])
                            [[NSUserDefaults standardUserDefaults]setObject:strFrontDestNum forKey:@"EmNumber"];
                        else
                            [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"EmNumber"];
                        
                        NSString *strHospName=[[[response objectForKey:@"hinfo"] objectAtIndex:0] objectForKey:@"hospitalName" ];
                        
                        [[NSUserDefaults standardUserDefaults]setObject:strHospName forKey:@"HosName"];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[[[response objectForKey:@"hinfo"]objectAtIndex:0] objectForKey:@"splash_screen"] forKey:@"splash_screen"];//logo
                        if ([[[response objectForKey:@"hinfo"] objectAtIndex:0] objectForKey:@"mlogo"] && [[[response objectForKey:@"hinfo"] objectAtIndex:0] objectForKey:@"mlogo"] != [NSNull null])
                            [[NSUserDefaults standardUserDefaults] setObject:[[[response objectForKey:@"hinfo"] objectAtIndex:0] objectForKey:@"mlogo"] forKey:@"logo"];
                        else
                            [[NSUserDefaults standardUserDefaults] setObject:[[[response objectForKey:@"hinfo"] objectAtIndex:0] objectForKey:@"logo"] forKey:@"logo"];
                        //             [[NSUserDefaults standardUserDefaults] setObject:[[response objectForKey:@"hinfo"] objectForKey:@"mlogo"] forKey:@"logo"];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                        
                        //change
                        [((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/%@",kAdminBaseUrl,[[[response objectForKey:@"hinfo"] objectAtIndex:0] objectForKey:@"splash_screen"]]] placeholderImage:[UIImage imageNamed:@"splash_iphone5@2x.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                            if (!error) {
                                ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).imgSlpash = nil;
                                ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).imgSlpash = image;
                            }else{
                                [[NSUserDefaults standardUserDefaults] setObject:@"splash_iphone5@2x.png" forKey:@"splash_screen"];
                                ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).imgSlpash = nil;
                            }
                        }];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSegueWithIdentifier:@"loginWithCode" sender:nil];
                        });
                    }
                }
                else if ([[response objectForKey:@"hinfo"] count] > 1)
                {
                    //                    [self customAlertView:@"" Message:@"WE HAVE MORE THAN ONE USER" tag:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self performSegueWithIdentifier:@"accountChoice" sender:[response objectForKey:@"hinfo"]];
                    });
                }
            }
            else if ([[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"Invalid customer code. Please try again." Message:[response objectForKey:@"response"] tag:0];
            }
            
            
            
        });
    } failureHandler:^(id response) {
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Error occured" Message:@"Try again" tag:0];
        
    }];
}
-(void)addSpinnerView
{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

#pragma mark - Action Methods

-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)validateBtnClicked:(id)sender
{
    //    NSLog(@"UDIDDDDDD----->   %@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]);
    [self.txtMobile resignFirstResponder];
    [self.txtCode resignFirstResponder];
    
    if ([self.txtMobile.text length] > 0 && [self.txtName.text length] > 0)
    {
        if ([self.txtMobile.text length] <10)
        {
            //[self customAlertView:@"Phone number can not be less than 10 digits"];
            [self customAlertView:@"" Message:@"Phone number cannot be less than 10 digits" tag:0];
        }else if (self.txtDob.text.length <= 0){
            [self customAlertView:@"Date of birth should not be empty" Message:@"" tag:0];
        }
        else if (![self.closeViewContainer isHidden])
        {
            if (!self.txtCode.text || [self.txtCode.text length] <= 0)
                [self customAlertView:@"" Message:@"Customer code cannot be empty" tag:0];
            else
            {
                NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
                if ([networkAvailabilityCheck reachable])
                {
                    [self makeRequestForUserRegister];
                }
                else{
                    
                    [self customAlertView:@"" Message:@"Network not available" tag:0];
                }
            }
            
        }
        else{
            NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
            if ([networkAvailabilityCheck reachable])
            {
                [self makeRequestForUserRegister];
            }
            else{
                
                [self customAlertView:@"" Message:@"Network not available" tag:0];
            }
        }
    }
    else{
        [self customAlertView:@"" Message:@"Fill all the details" tag:0];
    }
}

- (IBAction)cnacelBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tapToResignKeyBoard:(id)sender
{
    [self.txtMobile resignFirstResponder];
    [self.txtCode resignFirstResponder];
}

- (IBAction)clickHereBtnClicked:(id)sender
{
    if ([self.closeViewContainer isHidden])
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.closeViewContainer.hidden = NO;
            self.nextButton.frame = CGRectMake(self.nextButton.frame.origin.x, self.nextButton.frame.origin.y+self.closeViewContainer.frame.size.height+10, self.nextButton.frame.size.width, self.nextButton.frame.size.height);
            self.mainContainer.frame = CGRectMake(self.mainContainer.frame.origin.x, self.mainContainer.frame.origin.y, self.mainContainer.frame.size.width, self.mainContainer.frame.size.height+self.closeViewContainer.frame.size.height+10);
            self.codeEnterHereContainer.hidden = YES;
        }];
    }
}

- (IBAction)closeBtnClicked:(id)sender
{
    if (![self.closeViewContainer isHidden])
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.codeEnterHereContainer.hidden = NO;
            self.nextButton.frame = CGRectMake(self.nextButton.frame.origin.x, self.nextButton.frame.origin.y-self.closeViewContainer.frame.size.height-10, self.nextButton.frame.size.width, self.nextButton.frame.size.height);
            self.mainContainer.frame = CGRectMake(self.mainContainer.frame.origin.x, self.mainContainer.frame.origin.y, self.mainContainer.frame.size.width, self.mainContainer.frame.size.height-self.closeViewContainer.frame.size.height-10);
            self.closeViewContainer.hidden = YES;
        }];
    }
}

-(void)homeBtnClicked:(id)sender
{
    
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
        {
            _isFromLogin=YES;
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
    if (!_isFromLogin)
    {
        [self performSegueWithIdentifier:@"ValidToDBID" sender:nil];
    }
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
    self.datePickerView.maximumDate = [NSDate date];
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

#pragma mark - Segue Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == kMobileTxtTag)
    {
        UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        doneToolbar.barStyle = UIBarStyleBlackTranslucent;
        doneToolbar.items = [NSArray arrayWithObjects:
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                             nil];
        [doneToolbar sizeToFit];
        textField.inputAccessoryView = doneToolbar;
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-numberToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    if (textField.tag == kCodeTxtTag)
    {
        [self validateBtnClicked:nil];
    }
    
    
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == kMobileTxtTag)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+numberToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    else if (textField.tag == kCodeTxtTag)
    {
        [self.txtMobile resignFirstResponder];
        //[self validateBtnClicked:nil];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.txtMobile)
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 10) ? NO : YES;
    }
    return YES;
}
#pragma mark - Segue Delegate
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"RegisterID"])
    {
        ((SmartRxRegisterVC *)segue.destinationViewController).strCID=sender;
        ((SmartRxRegisterVC *)segue.destinationViewController).strMobilNumber=self.txtMobile.text;
    }
    else if ([segue.identifier isEqualToString:@"accountChoice"])
    {
        ((SmartRxAccountPickerVC *)segue.destinationViewController).responseDict = [[NSMutableArray alloc] init];
        ((SmartRxAccountPickerVC *)segue.destinationViewController).responseDict = sender;
    }
}

#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
#pragma mark -AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kRegistredUserAlertTag && buttonIndex == 0)
    {
        //[self.navigationController popViewControllerAnimated:YES];
        [self performSegueWithIdentifier:@"ValidToDBID" sender:nil];
        
    }
    else if(alertView.tag == 100)
    {
        [self performSegueWithIdentifier:@"loginWithCode" sender:nil];
    }
}
@end
