//
//  SmartRxRegisterVC.m
//  SmartRx
//
//  Created by PaceWisdom on 30/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxRegisterVC.h"
#import "appConstants.h"
#import "SmartRxLoginViewController.h"
#import "NSString+DateConvertion.h"
#import "SmartRxDashBoardVC.h"
#import <QuartzCore/QuartzCore.h>

#define kNameTxtTag 6000
#define kMobileTxtTag 6001
#define kEmailTxtTag 6002
#define kDOBTxtTag 6003
#define kGenderTxtTag 6004
#define kDoctorTxtTag 6005

#define kRegisteredUserId 1
#define kAlreadyRegistredID -5
#define kInvalidMobileID -3
#define kInvalidNameID -2
#define kSuccessRegisterAlertTag 600


@interface SmartRxRegisterVC ()
{
    MBProgressHUD *HUD;
    UIView *currentView;
    NSInteger  seletedIndexpath;
    NSString *strLoctionId, *strDocId;
    NSString *locationString;
    CGSize viewSize;
}
@end
@implementation SmartRxRegisterVC

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
-(void)numberKeyBoardReturn
{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           //[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(returnWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtMobile.inputAccessoryView = numberToolbar;
}
-(void)returnWithNumberPad
{
    [self.txtEmail becomeFirstResponder];
}
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
    viewSize = [UIScreen mainScreen].bounds.size;
    self.scrolView.contentSize = CGSizeMake(_scrolView.frame.size.width, _btnRegister.frame.origin.y+_btnRegister.frame.size.height+200);

    pickerAction = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    pickerAction.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = pickerAction.bounds;
    [pickerAction addSubview:backgroundView];
//    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeDatePicker:)];
//    [singleTap setNumberOfTapsRequired:1];
//    [pickerAction addGestureRecognizer:singleTap];
    
    self.btnTerms.selected=NO;
    
    self.arrGender=[[NSArray alloc]initWithObjects:@"Male",@"Female", nil];
    self.txtMobile.text=self.strMobilNumber;
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    self.txtMobile.inputAccessoryView = doneToolbar;
}
- (void)doneButton:(id)sender
{
    [self.txtMobile resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request Methods
- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
-(void)makeRequestForUserRegister
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    if([self.txtEmail.text length] > 0)
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        BOOL val = [self validateEmailWithString:self.txtEmail.text];
        if (!val)
        {
            [self customAlertView:@"" Message:@"Please enter a valid E-Mail ID" tag:0];
            return;            
        }
    }
    if([self.txtName.text length] <= 0)
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"" Message:@"Patient Name ID cannot be empty" tag:0];
        return;
    }
    else
    {
        NSString *strGender;
        if ([self.txtGender.text length] > 0)
        {
            if ([self.txtGender.text isEqualToString:@"Male"])
            {
                strGender=@"1";
            }
            else{
                strGender=@"2";
            }
        }
        NSString *bodyText;
        if (strDoctorId)
            bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&mode=2",@"mobile",self.txtMobile.text,@"name",self.txtName.text,@"email",self.txtEmail.text,@"dob",self.txtDOB.text,@"gender",strGender,@"refdoc",strDoctorId,@"location", strLoctionId, @"cid",self.strCID];
        else
            bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&mode=2",@"mobile",self.txtMobile.text,@"name",self.txtName.text,@"email",self.txtEmail.text,@"dob",self.txtDOB.text,@"gender",strGender,@"refdoc",@"",@"location", strLoctionId, @"cid",self.strCID];
        NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mreghims"];
        [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
            NSLog(@"sucess 30 %@",response);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                
                if ([[response objectForKey:@"response"]integerValue] == kRegisteredUserId)
                {
                    [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cid"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtMobile.text forKey:@"MobilNumber"];
                    
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    [self customAlertView:@"" Message:@"Registered successfully" tag:kSuccessRegisterAlertTag];
                }
                else if ([[response objectForKey:@"response"]integerValue] == kAlreadyRegistredID)
                {
                    [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cid"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtMobile.text forKey:@"MobilNumber"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    [self customAlertView:@"Mobile number already registered" Message:@"" tag:kSuccessRegisterAlertTag];
                }
                else if ([[response objectForKey:@"response"]integerValue] == kInvalidMobileID)
                {
                    [self customAlertView:@"" Message:@"phone number is not valid" tag:0];
                }
                else if ([[response objectForKey:@"response"]integerValue] == kInvalidNameID)
                {
                    [self customAlertView:@"" Message:@" Patient name is not valid" tag:0];
                }
            });
        } failureHandler:^(id response) {
            NSLog(@"failure %@",response);
            [HUD hide:YES];
            [HUD removeFromSuperview];
        }];
    }
}

- (void)makeRequestForLocationList
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
        bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlocation"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            [self makeRequestForUserRegister];
        }
        else{
            
            if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
            {
                SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                smartLogin.loginDelegate=self;
                [smartLogin makeLoginRequest];
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    self.view.userInteractionEnabled = YES;
                    
                    if (![[response objectForKey:@"location"] isKindOfClass:[NSArray class]])
                    {
                        [self customAlertView:@"" Message:@"Locations Not available" tag:0];
                    }
                    else{
                        self.arrLocations=[response objectForKey:@"location"];
                        if ([self.arrLocations count])
                        {
                            //[self makeRequestForSpecialities];
                            self.arrLoadCell=self.arrLocations;
                            [self.commonPicker reloadAllComponents];
                            if ([_txtLocation.text length] > 0 && [self.arrLoadCell count])
                            {
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationname ==  %@", _txtLocation.text];
                                NSArray *result = [self.arrLoadCell filteredArrayUsingPredicate: predicate];
                                strLoctionId=[[result objectAtIndex:0]objectForKey:@"locid"];
                                seletedIndexpath=[self.arrLoadCell indexOfObject:result.firstObject];
                                
                            }
                            else
                                seletedIndexpath=0;
                            [self.commonPicker selectRow:seletedIndexpath inComponent:0 animated:NO];
                            [self displayDatePickerView:1];
                        }
                        else{
                            NSLog(@"Not Available");
                        }
                    }
                });
            }
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}

-(void)makeRequestForDoctorsList
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
//    if ([_txtLocation.text length] > 0 && [self.arrLoadCell count])
//    {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationname ==  %@", _txtLocation.text];
//        NSArray *result = [self.arrLocations filteredArrayUsingPredicate: predicate];
//        strLoctionId=[[result objectAtIndex:0]objectForKey:@"locid"];
//    }
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"sessionid",sectionId,@"locid",strLoctionId];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",@"cid",strCid,@"locid",strLoctionId,@"isopen",@"1"];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlocdoc"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 3 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                //                [self.arrLoadTbl removeAllObjects];
                [self.arrSpeclist removeAllObjects];
                self.dictResponse = nil;
                
                self.dictResponse = [response objectForKey:@"docspec"];
                self.arrSpecAndDocResponse = [response objectForKey:@"docspec"];
                self.arrLoadCell = self.arrSpecAndDocResponse;
                NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:self.arrLoadCell];

                
                NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recno" ascending:YES];
                NSArray *arrayNS = [NSArray arrayWithObject:aSortDescriptor];
                arr = [arr sortedArrayUsingDescriptors:arrayNS];

                arr = [arr mutableCopy];
                for (int i=0; i<[arr count]; i++)
                {
                    if (i>0)
                    {
                        if ([[[arr objectAtIndex:i-1] valueForKey:@"recno"] integerValue] == [[[arr objectAtIndex:i] valueForKey:@"recno"] integerValue])
                        {
                            [arr removeObjectAtIndex:i];
                            i--;
                        }
                    }
                }
                
                self.arrLoadCell = arr;
                
                if ([self.dictResponse count])
                {
                    [self.commonPicker reloadAllComponents];
                    if ([_txtDoctor.text length] > 0 && [self.arrLoadCell count])
                    {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dispname  ==  %@", _txtDoctor.text];
                        NSArray *result = [self.arrLoadCell filteredArrayUsingPredicate: predicate];
                        strDocId=[[result objectAtIndex:0]objectForKey:@"recno"];
                        seletedIndexpath=[self.arrLoadCell indexOfObject:result.firstObject];
                        
                    }
                    else
                        seletedIndexpath=0;
                    [self.commonPicker selectRow:seletedIndexpath inComponent:0 animated:NO];
                    [self displayDatePickerView:1];
                }
                else if ([self.txtLocation.text length])
                {
                    self.txtDoctor.text = @"No Doctor(s) available";
                }
                else
                {
                    [self customAlertView:@"" Message:@"Please choose a location to view the Doctor(s) list." tag:0];                    
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occured" Message:@"Try again" tag:0];
    }];
}

-(void)addSpinnerView{
    
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
-(void)homeBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"RegisterToDBID" sender:nil];
    /*for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }*/
}

-(void)loadDatePicker
{
    self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    self.datePickerView.backgroundColor = [UIColor whiteColor];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [self.datePickerView setMaximumDate:[NSDate date]];
    //Setting max date to previous date
    self.datePickerView.datePickerMode = UIDatePickerModeDate;

    NSString *date = self.txtDOB.text;
    if([date length]>0)
    {
        [self.datePickerView setDate:[NSString stringToDate:date]];
    }
    toolbarPicker = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-260, 320, 44)];
    toolbarPicker.barStyle=UIBarStyleBlackOpaque;
    [toolbarPicker sizeToFit];
    NSMutableArray *itemsBar = [[NSMutableArray alloc] init];
    //calls DoneClicked
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    flexSpace.width = 250.0f;
    [itemsBar addObject:flexSpace];
    
    UIBarButtonItem *bbitem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(DoneClicked)];
    [itemsBar addObject:bbitem];

    
    [toolbarPicker setItems:itemsBar animated:YES];
    [pickerAction addSubview:toolbarPicker];
    [pickerAction addSubview:self.datePickerView];
    [self.view addSubview:pickerAction];
    pickerAction.hidden = NO;
}


-(void)DoneClicked
{
    
        NSDate *dateAppointment=self.datePickerView.date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-MM-yyy"];
        NSString *strDate = [dateFormat stringFromDate:dateAppointment];
        NSLog(@"date ==== %@",strDate);
        self.txtDOB.text=strDate;
        self.datePickerView.hidden=YES;

    [self closeDatePicker:nil];
    
}
-(BOOL)closeDatePicker:(id)sender{
    pickerAction.hidden = YES;
    return YES;
}
- (IBAction)cancelButtonClicked:(id)sender
{
    [self removeDatePickerView:nil];
}

- (IBAction)doneButtonClicked:(id)sender
{
    if (currentTextfied.tag == kDoctorTxtTag)
    {
        if (seletedIndexpath != 0)
        {
            self.txtDoctor.text=[[self.arrLoadCell objectAtIndex:seletedIndexpath]objectForKey:@"dispname"];
            strDoctorId=[[self.self.arrLoadCell objectAtIndex:seletedIndexpath]objectForKey:@"recno"];
        }
        else
        {
            self.txtDoctor.text = @"Any Doctor";
            strDoctorId = nil;
        }
    }
    else if (currentTextfied.tag == kGenderTxtTag)
    {
        self.txtGender.text=[self.arrLoadCell objectAtIndex:seletedIndexpath];
    }
    else if (currentTextfied.tag == 50)
    {
        self.txtLocation.text = [[self.self.arrLoadCell objectAtIndex:seletedIndexpath]objectForKey:@"locationname"];
        strLoctionId = [[self.self.arrLoadCell objectAtIndex:seletedIndexpath]objectForKey:@"locid"];
        
    }
    [self removeDatePickerView:nil];
//    self.tblDoctors.hidden=YES;
}

- (IBAction)termsBtnClicked:(id)sender
{
    if ([self.btnTerms isSelected])
    {
        self.btnTerms.selected=NO;
    }
    else{
        self.btnTerms.selected=YES;
    }
}

- (IBAction)hideKeyboard:(id)sender {
    if ([currentTextfied isFirstResponder])
    {
        [currentTextfied resignFirstResponder];
    }
    
//    if (![self.tblDoctors isHidden])
//    {
//        self.tblDoctors.hidden=YES;
//    }
}

- (IBAction)resignKeyboard:(id)sender {
    [currentTextfied resignFirstResponder];
//    if (![self.tblDoctors isHidden])
//    {
//        self.tblDoctors.hidden=YES;
//    }
}

- (IBAction)registerBtnClicked:(id)sender {
    

    if ([self.txtName.text length] <= 0 )
    {
        [self customAlertView:@"Patient name should not be empty" Message:@"" tag:0];
    }
    else if ([self.txtMobile.text length] <= 0)
    {
        [self customAlertView:@"Mobile number should not be empty" Message:@"" tag:0];
    }
    else if ([self.txtGender.text length] <= 0)
    {
        [self customAlertView:@"Gender should not be empty" Message:@"" tag:0];
    }
    else if ([self.txtLocation.text length] <= 0)
    {
        [self customAlertView:@"Select Location" Message:@"" tag:0];
    }
    else if (![self.btnTerms isSelected])
    {
        [self customAlertView:@"" Message:@"Please agree with terms and conditions" tag:0];
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

- (IBAction)cancelBtnClicked:(id)sender
{

}

- (IBAction)backButtonClicked:(id)sender {
}

- (IBAction)termsAndConditionsBtnClicked:(id)sender {
    [self performSegueWithIdentifier:@"TermsID" sender:nil];
}

- (IBAction)dobBtnClicked:(id)sender
{
    [self hideKeyboard:nil];
    currentTextfied=self.txtDOB;
   [self loadDatePicker];
    
}

- (IBAction)genderBtnClicked:(id)sender
{
    [self hideKeyboard:nil];
    currentTextfied=self.txtGender;
    self.arrLoadCell=self.arrGender;
    [self.commonPicker reloadAllComponents];
    if ([self.txtGender.text isEqualToString:@"Male"])
        seletedIndexpath=0;
    else
        seletedIndexpath=1;
    [self.commonPicker selectRow:seletedIndexpath inComponent:0 animated:NO];
//    self.tblDoctors.hidden=NO;
//    [self.tblDoctors reloadData];
    [self displayDatePickerView:1];    
}

- (IBAction)selectDocBtnClicked:(id)sender
{
    [self hideKeyboard:nil];
    currentTextfied=self.txtDoctor;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForDoctorsList];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
        
    }

}

- (IBAction)selectLocationBtnClicked:(id)sender
{
    [self hideKeyboard:nil];
    currentTextfied=self.txtLocation;
    currentTextfied.tag = 50;
    self.txtDoctor.text = nil;
    strDoctorId = nil;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForLocationList];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
        
    }
    
}
#pragma mark - Pickrview datasource/delegate methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.arrLoadCell count];
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (currentTextfied.tag == kDoctorTxtTag)
    {
        if (row == 0)
            return @"Any Doctor";
        else
            return [[self.arrLoadCell objectAtIndex:row]objectForKey:@"dispname"];
    }
    else if (currentTextfied.tag == 50)
    {
       return [[self.arrLoadCell objectAtIndex:row]objectForKey:@"locationname"];
    }
    else{
       return [self.arrLoadCell objectAtIndex:row];
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    seletedIndexpath=row;
}

//#pragma mark -Tableview Delegate methods
//
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [self.arrLoadCell count];
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *cellIdentifier=@"DocListCell";
//    UITableViewCell *cell=(UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    cell.textLabel.textColor=[UIColor whiteColor];
//    if (currentTextfied.tag == kDoctorTxtTag)
//    {
//    cell.textLabel.text=[[self.arrLoadCell objectAtIndex:indexPath.row]objectForKey:@"dispname"];
//    }
//    else{
//        cell.textLabel.text=[self.arrLoadCell objectAtIndex:indexPath.row];
//    }
//    return cell;
//}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (currentTextfied.tag == kDoctorTxtTag)
//    {
//        self.txtDoctor.text=[[self.self.arrLoadCell objectAtIndex:indexPath.row]objectForKey:@"dispname"];
//        strDoctorId=[[self.self.arrLoadCell objectAtIndex:indexPath.row]objectForKey:@"recno"];
//    }
//    else if (currentTextfied.tag == kGenderTxtTag)
//    {
//        self.txtGender.text=[self.self.arrLoadCell objectAtIndex:indexPath.row];
//    }
//     self.tblDoctors.hidden=YES;
//}

#pragma mark - Textfield Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range     replacementString:(NSString *)string
{
    if (textField == self.txtMobile && textField.text.length >= 10 && range.length == 0)
        return NO;
    else
        return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.tag == kNameTxtTag)
    {
        [self.txtMobile becomeFirstResponder];
    }
    else if (textField.tag == kMobileTxtTag)
    {
        [self.txtEmail becomeFirstResponder];
    }
    else if (textField.tag == kEmailTxtTag)
    {
        NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        
        if ([emailTest evaluateWithObject:textField.text] == NO) {
            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
            return NO;
        }
        else
             [self.txtDOB becomeFirstResponder];
    }
    else if (textField.tag == kDOBTxtTag)
    {
        [self.txtDoctor becomeFirstResponder];
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentTextfied=textField;
//    if (![self.tblDoctors isHidden])
//    {
//        self.tblDoctors.hidden=YES;
//        return;
//    }
    if(textField == self.txtEmail)
    {
        [UIView animateWithDuration:0.2 animations:^{
             self.scrolView.contentOffset=CGPointMake(self.scrolView.frame.origin.x, 35);
        }];
       
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.txtEmail)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrolView.contentOffset=CGPointMake(self.scrolView.frame.origin.x, 35);
        }];
        
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
//    if (alertView.tag == kSuccessRegisterAlertTag && buttonIndex == 0)
//    {
//        for (UIViewController *controller in [self.navigationController viewControllers])
//        {
//            if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
//            {
//                [self.navigationController popToViewController:controller animated:YES];
//            }
//        }
//    }
    
    if (alertView.tag == kSuccessRegisterAlertTag && buttonIndex == 0)
    {
     [self performSegueWithIdentifier:@"RegisterToDBID" sender:nil];
    }
}
#pragma mark - date picker view method

- (void)displayDatePickerView:(int)flag
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    currentView = self.pickerView;
    //        [self.pickerDropDown selectRow:seletedIndexpath inComponent:0 animated:YES];
    self.pickerView.hidden = NO;
    self.pickerView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (IBAction)removeDatePickerView:(id)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if (currentView == self.pickerView)
        self.pickerView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height,self.view.frame.size.width, self.view.frame.size.height);

    [UIView commitAnimations];
    //    self.viwDropDownBackground.hidden = YES;
}

@end
