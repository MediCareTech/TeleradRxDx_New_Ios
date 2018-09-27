//
//  SmartRxAddBMI.m
//  SmartRx
//
//  Created by Anil Kumar on 16/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxAddBMI.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxDataTVC.h"
#import "SmartRxImageTVC.h"
#import <QuickLook/QuickLook.h>
#import "SmartRxCommonClass.h"
#import "SmartRxCarePlaneSubVC.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"
#import "NSString+DateConvertion.h"
#import "mach/mach.h"

#define kMaxHeightInCms 600
#define kMinHeightFeet 1
#define kMaxHeightFeet 7
#define kIncsForFeet 12
#define kCmsForMeter 100
//#define kFeetsTometers 3.25
#define kFeetsTometers 0.3048

#define kLbToKg 0.453592
//#define kLbToKg 0.453
#define kUnderWeight 18.5
#define kNormalWeight 24.9
#define kOverWeight 29.9
#define kRsltViwYaxis 200
#define kRsltviwWidth 260


@interface SmartRxAddBMI ()<ShowImageInMainView, QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    CGSize viewSize;
    UIView *viw;
    float bmi;
    NSMutableArray *heightUnits, *weightUnits;
}
@end

@implementation SmartRxAddBMI

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
    [dateFormat setTimeZone:gmt];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormat stringFromDate:today];
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString *timeString = [dateFormat stringFromDate:today];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.maximumDate = [NSDate date];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    self.timePicker.maximumDate = [NSDate date];

    if(self.phrID > 0)
    {
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormat dateFromString:[self.phrDetailsDictionary objectForKey:@"checked_date"]];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        self.dateTextField.text = [dateFormat stringFromDate:date];
        self.timeTextField.text = [self.phrDetailsDictionary objectForKey:@"checked_time"];
        date = [dateFormat dateFromString:self.dateTextField.text];
        self.datePicker.date = date;
        [dateFormat setDateFormat:@"HH:mm:ss"];
        date = [dateFormat dateFromString:self.timeTextField.text];
        [dateFormat setDateFormat:@"hh:mm a"];
        NSString *time = [dateFormat stringFromDate:date];
        self.timeTextField.text = time;
        date = [dateFormat dateFromString:time];
        self.timePicker.date = date;
    }
    else
    {
        self.dateTextField.text = dateString;
        self.timeTextField.text = timeString;
    }
    _unitType1=1, _unitType2=1;
    self.weightFirstTime = YES;
    self.heightFirstTime = YES;
    _currentTextField = [[UITextField alloc] init];
    _selectedHeightFirstComponent = [[self.phrDetailsDictionary objectForKey:@"heightComponent0"] floatValue];
    if (_selectedHeightFirstComponent != 0.0)
        self.heightTextField.text = [NSString stringWithFormat:@"%.01f", _selectedHeightFirstComponent];
    else
        self.heightTextField.text = nil;
    _selectedHeightSecondComponent = [[self.phrDetailsDictionary objectForKey:@"heightComponent1"] integerValue];
    heightUnits = [[NSMutableArray alloc]initWithArray:@[@"Cm", @"Ft"]];
    weightUnits = [[NSMutableArray alloc] initWithArray:@[@"Kg", @"Lb"]];
    _selectedWeightFirstComponent = [[self.phrDetailsDictionary objectForKey:@"weightComponent0"] integerValue];
    if (_selectedWeightFirstComponent != 0.0)
        self.weightTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)_selectedWeightFirstComponent];
    else
        self.weightTextField.text = nil;
    

    _selectedWeightSecondComponent = [[self.phrDetailsDictionary objectForKey:@"weightComponent1"] integerValue];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _viwResult.hidden=YES;
//    [self addSpinnerView];
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
    viewSize = [UIScreen mainScreen].bounds.size;
    self.phrID = [[self.phrDetailsDictionary objectForKey:@"phrid"] integerValue];    
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:backgroundView];
    
    self.currentButton = [[UIButton alloc] init];
    self.addOrUpdateButtonText =  [self.phrDetailsDictionary objectForKey:@"buttonTextString"];
    [self.addOrUpdatebutton setTitle:self.addOrUpdateButtonText forState:UIControlStateNormal];
    
    self.heightPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.heightPicker.delegate = self;
    self.heightPicker.dataSource = self;
    self.heightPicker.backgroundColor = [UIColor whiteColor];
    
    self.weightPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.weightPicker.delegate = self;
    self.weightPicker.dataSource = self;
    self.weightPicker.backgroundColor = [UIColor whiteColor];

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.datePicker.backgroundColor = [UIColor whiteColor];

    self.timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.timePicker.backgroundColor = [UIColor whiteColor];
    
    if ([[self.phrDetailsDictionary objectForKey:@"lastHeightValue"] integerValue] > 0)
    {
        NSString *unitString = @"Cm";
        if([[self.phrDetailsDictionary objectForKey:@"lastHeightUnit"] isEqualToString:@"2"])
        {
            unitString = @"Ft";
        }
        [self.heightButton setTitle:unitString forState:UIControlStateNormal];
        if (self.phrID > 0)
             self.heightTextField.text = [NSString stringWithFormat:@"%@ %@",[self.phrDetailsDictionary objectForKey:@"heightComponent0"],unitString];
        else
        {
            self.heightTextField.text = [NSString stringWithFormat:@"%@ %@",[self.phrDetailsDictionary objectForKey:@"lastHeightValue"],unitString];
            
            [self.phrDetailsDictionary setObject:[self.phrDetailsDictionary objectForKey:@"lastHeightValue"] forKey:@"heightComponent0"];
            [self.phrDetailsDictionary setObject:[self.phrDetailsDictionary objectForKey:@"lastHeightUnit"] forKey:@"heightComponent1"];
        }
        NSString *value = [self.phrDetailsDictionary objectForKey:@"heightComponent0"];
        _selectedHeightFirstComponent = [value floatValue];
        _selectedHeightSecondComponent = [[self.phrDetailsDictionary objectForKey:@"heightComponent1"] integerValue];
        _selectedWeightFirstComponent = [[self.phrDetailsDictionary objectForKey:@"weightComponent0"] integerValue];
        _selectedWeightSecondComponent = [[self.phrDetailsDictionary objectForKey:@"weightComponent1"] integerValue];

    }
    
    if (self.phrID > 0)
    {
        NSString *unitString = @"Cm";
        if([[self.phrDetailsDictionary objectForKey:@"heightComponent1"] isEqualToString:@"2"])
        {
            unitString = @"Ft";
        }
        self.heightTextField.text = [NSString stringWithFormat:@"%@",[self.phrDetailsDictionary objectForKey:@"heightComponent0"]];
        [self.heightButton setTitle:unitString forState:UIControlStateNormal];        
    }
    // Do any additional setup after loading the view.
}
#pragma mark - Navigation Item methods
-(void)navigationBackButton
{
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

#pragma mark - Action Methods
- (void)doneButton:(id)sender
{
    [self.heightTextField resignFirstResponder];
    [self.weightTextField resignFirstResponder];
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
-(void)doneButtonPressed:(id)sender
{
    if (self.currentButton==self.heightButton)
    {
        NSString *str = [ heightUnits objectAtIndex:[self.heightPicker selectedRowInComponent:0]];
        [self.heightButton setTitle:str forState:UIControlStateNormal];
    }
    else if (self.currentButton==self.weightButton)
    {
        NSString *str = [ weightUnits objectAtIndex:[self.weightPicker selectedRowInComponent:0]];
        [self.weightButton setTitle:str forState:UIControlStateNormal];
    }
    if(self.currentButton==self.dateButton)
    {
        NSDate *dateAppointment=self.datePicker.date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
        [dateFormat setTimeZone:gmt];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        NSString *strDate = [dateFormat stringFromDate:dateAppointment];
        self.dateTextField.text=strDate;
        dateAppointment = [dateFormat dateFromString:strDate];
        NSDate * today = [NSDate date];
        NSString *str = [dateFormat stringFromDate:today];
        today = [dateFormat dateFromString:str];
        NSComparisonResult result = [today compare:dateAppointment];
        switch (result)
        {
            case NSOrderedDescending:
                self.timePicker.maximumDate = nil;
                NSLog(@"Earlier Date");
                break;
            case NSOrderedSame:
                self.timePicker.maximumDate = [NSDate date];
                NSLog(@"Today/Null Date Passed"); //Not sure why This is case when null/wrong date is passed
                break;
            default:
                NSLog(@"Error Comparing Dates");
                break;
        }
    }
    else if(self.currentButton==self.timeButton)
    {
        NSDate *dateAppointment=self.timePicker.date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
        [dateFormat setTimeZone:gmt];
        [dateFormat setDateFormat:@"hh:mm a"];
        NSString *strTime = [dateFormat stringFromDate:dateAppointment];
        self.timeTextField.text=strTime;
    }
    _actionSheet.hidden = YES;
    
}
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)updateBackBtnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)heightBtnClicked:(id)sender
{
    [self doneButton:nil];
    self.currentButton = self.heightButton;
    [self loadPicker];
}

- (IBAction)weightBtnClicked:(id)sender
{
    [self doneButton:nil];
    self.currentButton = self.weightButton;
    [self loadPicker];
}
- (IBAction)dateBtnClicked:(id)sender
{
    [self doneButton:nil];
    self.currentButton = self.dateButton;
    [self loadPicker];
}
- (IBAction)timeBtnClicked:(id)sender
{
    [self doneButton:nil];
    self.currentButton = self.timeButton;
    [self loadPicker];
}
- (IBAction)hideResultView:(id)sender {
    [viw removeFromSuperview];
    viw=nil;
}
- (IBAction)okBtnClickedToCloseResultView:(id)sender {
    [self hideResultView:nil];
    [self updateBackBtnClicked];    
}
- (void)loadPicker
{
    if (!_pickerToolbar)
    {
        _pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-260, 320, 44)];
        _pickerToolbar.barStyle = UIBarStyleBlackTranslucent; //UIBarStyleBlackOpaque;
        [_pickerToolbar sizeToFit];
    }
    
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
    
    if  (self.currentButton == self.heightButton)
    {
        [_actionSheet addSubview:self.heightPicker];
        [self.heightPicker reloadAllComponents];
    }
    else if (self.currentButton==self.weightButton)
    {
        [_actionSheet addSubview:self.weightPicker];
        [self.heightPicker reloadAllComponents];
    }
    else if (self.currentButton == self.dateButton)
    {
        [_actionSheet addSubview:self.datePicker];
    }
    else if (self.currentButton == self.timeButton)
    {
        [_actionSheet addSubview:self.timePicker];
    }
   
    [self.view addSubview:_actionSheet];
    [self.view bringSubviewToFront:_actionSheet];
    _actionSheet.hidden = NO;
    
    if ([[self.phrDetailsDictionary objectForKey:@"lastHeightValue"] integerValue] > 0)
    {
        if  (self.currentButton == self.heightButton)
            [self.heightPicker selectRow:(_selectedHeightSecondComponent-1) inComponent:0 animated:YES];
        else
            [self.weightPicker selectRow:(_selectedWeightSecondComponent-1) inComponent:0 animated:YES];
    }

}

#pragma mark - Spinner method
-(void)addSpinnerView
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}
#pragma mark - Calculate BMI
-(float)calculateBMI:(NSString *)feetValue units:(NSString *)units weight:(NSString *)weight
{
    float inches=0.0;
    float heightInMeters=0.0;
    
    if ([self.weightButton.currentTitle isEqualToString:@"Lb"] || [self.weightButton.currentTitle isEqualToString:@"lb"])
    {
        //weight=[NSString stringWithFormat:@"%f",[weight floatValue]*kLbToKg];
        weight=[NSString stringWithFormat:@"%f",[weight floatValue]/2.2];
    }
    
    if ([units isEqualToString:@"Ft"] || [units isEqualToString:@"ft"])
    {
        
        heightInMeters = [feetValue floatValue]*kFeetsTometers;
         NSArray *arrFeetsNInches=[feetValue componentsSeparatedByString:@"."];
        if (arrFeetsNInches.count> 1) {
             heightInMeters = [arrFeetsNInches[0] floatValue]*30.48 + [arrFeetsNInches[1] floatValue]*2.54;
        } else {
             heightInMeters = [arrFeetsNInches[0] floatValue]*30.48;
        }
       
        heightInMeters= heightInMeters/kCmsForMeter;

//        NSArray *arrFeetsNInches=[feetValue componentsSeparatedByString:@"."];
//        if ([arrFeetsNInches count] == 2)
//        {
//            inches= [[arrFeetsNInches objectAtIndex:1]floatValue]/kIncsForFeet;
//        }
//        heightInMeters=[[arrFeetsNInches objectAtIndex:0]floatValue]+inches;
//        heightInMeters = heightInMeters/kFeetsTometers;
    }
    else{
        heightInMeters= [feetValue floatValue]/kCmsForMeter;
    }
    float bmii=[weight floatValue]/(heightInMeters*heightInMeters);
    
    return bmii;
}

#pragma mark - Result View
-(void)loadResultView
{
    viw=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 65)];
    viw.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"transparent.png"]];
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=viw.frame;
    [btn addTarget:self action:@selector(hideResultView:) forControlEvents:UIControlEventTouchUpInside];
    [viw addSubview:btn];
    [self.navigationController.view addSubview:viw];
    
    _viwResult.hidden=NO;
    
    _lblBMI.text=[NSString stringWithFormat:@"%.2f",bmi];
    if (bmi <=  kNormalWeight && bmi >= kUnderWeight)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _viwExcellent.frame=CGRectMake(0, kRsltViwYaxis, _viwExcellent.frame.size.width, _viwExcellent.frame.size.height);
        } completion:^(BOOL finished) {
            _scrolViwResult.contentSize=CGSizeMake(_scrolViwResult.contentSize.width, _viwExcellent.frame.origin.y+_viwExcellent.frame.size.height+80);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            if (bmi < kUnderWeight) {
                _lblNeedImprovment.textColor=[UIColor blueColor];
            }
            else if (bmi> kNormalWeight && bmi <= kOverWeight)
                _lblNeedImprovment.textColor=[UIColor colorWithRed:227.f/255.f green:146.f/255.f blue:34.f/255.f alpha:1.0];
            else
                _lblNeedImprovment.textColor=[UIColor redColor];
            
            _viwNeedToImporve.frame=CGRectMake(0, kRsltViwYaxis, _viwNeedToImporve.frame.size.width, _viwNeedToImporve.frame.size.height);
        } completion:^(BOOL finished) {
            _scrolViwResult.contentSize=CGSizeMake(_scrolViwResult.contentSize.width, _viwNeedToImporve.frame.origin.y+_viwNeedToImporve.frame.size.height+80);
        }];
    }
    [UIView animateWithDuration:2.0 animations:^{
        float resultBmi=bmi*6.5;
        if (resultBmi > kRsltviwWidth )
        {
            resultBmi=kRsltviwWidth;
        }
        _imgResultPointer.frame=CGRectMake(resultBmi, _imgResultPointer.frame.origin.y, _imgResultPointer.frame.size.width, _imgResultPointer.frame.size.height);
    }];
}
#pragma mark - Textfield Delegate Methods
#pragma mark - Textfield Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.heightTextField || textField == self.weightTextField)
        return YES;
    else
    {
        [textField resignFirstResponder];
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    textField.inputAccessoryView = doneToolbar;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 6) ? NO : YES;
}

-(void)cancelButtonPressed:(id)sender
{
    _actionSheet.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -Alertview Delegate Method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && alertView.tag == 1)
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }
    
    else if (buttonIndex == 0&& alertView.tag == 0)
    {
        [self updateBackBtnClicked];
        //[self.navigationController popViewControllerAnimated:YES];
    } else if (buttonIndex == 999)
    {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (self.currentButton == self.heightButton)
        return [heightUnits objectAtIndex:row];
    else
        return [weightUnits objectAtIndex:row];
            
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    if (pickerView == self.heightPicker)
    {
        if (component == 1 )
        {
            [self.firstPickerselectedArray setObject:[self.firstPickerComponentOneArray objectAtIndex:row] forKey:@"unit"];
            
            if (row == 0)
            {
                [self.firstPickerselectedArray setObject:[NSNumber numberWithInt:row+1] forKey:@"value"];
                self.heightIsCm = YES;
            }
            else
            {
                if([_feetMeasures count]>0)
                {
                    [self.firstPickerselectedArray setObject:[NSString stringWithFormat:@"%.01f",[[_feetMeasures objectAtIndex:row] floatValue]] forKey:@"value"];
                }
                self.heightIsCm = NO;
            }
            [pickerView reloadComponent:0];
        }
        else if (component == 1)
        {
            [self.firstPickerselectedArray setObject:[self.firstPickerComponentOneArray objectAtIndex:row] forKey:@"unit"];
        }
        else if (component == 0 && !self.heightIsCm)
        {
            [self.firstPickerselectedArray setObject:[NSString stringWithFormat:@"%.01f",[[_feetMeasures objectAtIndex:row] floatValue]] forKey:@"value"];
        }
        else
        {
            [self.firstPickerselectedArray setObject:[NSNumber numberWithInt:row+1] forKey:@"value"];
        }
    }
    else
    {
        if (component == 1)
        {
            [self.secondPickerselectedArray setObject:[self.secondPickerComponentOneArray objectAtIndex:row] forKey:@"unit"];
        }
        else
        {
            [self.secondPickerselectedArray setObject:[NSNumber numberWithInt:row+1] forKey:@"value"];
        }
    }
}


- (IBAction)makeRequestToAddPhrBMIDetails:(id)sender
{
    [self.view endEditing:YES];
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];

    NSString *sessionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
    [dateFormat setTimeZone:gmt];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormat stringFromDate:today];
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString *timeString = [dateFormat stringFromDate:today];
    [dateFormat setDateFormat:@"dd-MM-yyyy HH:mm:SS"];

    
    if ((self.heightTextField.text == nil || [self.heightTextField.text length] <= 0) && (self.weightTextField.text == nil|| [self.weightTextField.text length] <= 0))
    {
        [self customAlertView:@"Error" Message:@"Please Add Height & Weight" tag:1];

    }
    else if (self.heightTextField.text == nil|| [self.heightTextField.text length] <= 0)
    {
        [self customAlertView:@"Error" Message:@"Please Add Height" tag:1];
    }
    else if (self.weightTextField.text == nil|| [self.weightTextField.text length] <= 0)
    {
        [self customAlertView:@"Error" Message:@"Please Add Weight" tag:1];
    }
    else
    {
        if ([self.heightButton.currentTitle isEqualToString:@"Cm"])
        {
            _unitType1 = 1;
        }
        else if([self.heightButton.currentTitle isEqualToString:@"Ft"])
        {
            _unitType1 = 2;
            float heightValue = [self.heightTextField.text floatValue];
            if (heightValue > 13.0) {
                [self customAlertView:@"" Message:@"Please add correct height" tag:1];
                return;
            }
        }
        
        
        if ([self.weightButton.currentTitle isEqualToString:@"Kg"])
        {
            _unitType2 = 1;
        }
        else if([self.weightButton.currentTitle isEqualToString:@"Lb"])
        {
            _unitType2 = 2;
        }
        
        bmi=[self calculateBMI:self.heightTextField.text units:self.heightButton.currentTitle weight:self.weightTextField.text];
        
        NSString *bodyText = [NSString stringWithFormat:@"sessionid=%@&height=%@&height_unit=%d&weight=%@&weight_unit=%d&tested_date=%@&tested_time=%@&type=1",sessionId,self.heightTextField.text,_unitType1,self.weightTextField.text, _unitType2, self.dateTextField.text, self.timeTextField.text];
        
        if(self.phrID > 0)
        {
            bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&phrid=%lu",(unsigned long)self.phrID]];
            
        }
        NSString *urlStr = [NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mphr"];
        //NSString *url=@"https://dev.smartrx.in/api/mphr";
        [[SmartRxCommonClass sharedManager] postOrGetData:urlStr postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
            
            if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
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
                    if ([[response objectForKey:@"result"] integerValue]==1 && [[response objectForKey:@"authorized"] integerValue]==1)
                    {
                        switch ([[response objectForKey:@"opstatus"] integerValue]) {
                            case 1:
                            {
//                                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ added successfully",[self.phrDetailsDictionary objectForKey:@"Title"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                                [alert show];
                                [self loadResultView];
                                break;
                            }
                            case 2:
                            {
//                                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ updated successfully",[self.phrDetailsDictionary objectForKey:@"Title"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                                [alert show];
                                [self loadResultView];                                
                                break;
                            }
                            case 3:
                            {
                                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ adding failed",[self.phrDetailsDictionary objectForKey:@"Title"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
                                [alert show];
                                break;
                            }
                            case 4:
                            {
                                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ updating failed",[self.phrDetailsDictionary objectForKey:@"Title"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
                                [alert show];
                                break;
                            }
                            default:
                                break;
                        }
                    }
                    
                });
            }
        } failureHandler:^(id response) {
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"The request timed out" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [self customAlertView:@"Error" Message:@"Adding or Updating Personal Health Record failed" tag:0];
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            
        }];
    }
}
#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestToAddPhrBMIDetails:nil];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}
#pragma mark - Custom Alert

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
@end
