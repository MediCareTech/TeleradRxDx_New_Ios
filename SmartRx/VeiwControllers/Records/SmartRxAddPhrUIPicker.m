//
//  SmartRxAddPhr.m
//  SmartRx
//
//  Created by Anil Kumar on 10/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxAddPhrUIPicker.h"
#import "SmartRxDataTVC.h"
#import "SmartRxImageTVC.h"
#import <QuickLook/QuickLook.h>
#import "SmartRxCommonClass.h"
#import "SmartRxCarePlaneSubVC.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"
#import "NSString+DateConvertion.h"

#define kResultScreenWidth 260
#define kBSugarRation 1.0

@interface SmartRxAddPhrUIPicker ()<ShowImageInMainView, QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    CGSize viewSize;
    UIView *viw;
}
@end

@implementation SmartRxAddPhrUIPicker

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
    self.selectedComponentOne = [[self.phrDetailsDictionary objectForKey:@"component0"] floatValue];
    self.selectedComponentTwo = [[self.phrDetailsDictionary objectForKey:@"component1"] integerValue];
    self.selectedComponentThree = [[self.phrDetailsDictionary objectForKey:@"component2"] integerValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    [self addSpinnerView];
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
    self.measureLabel.text = [self.phrDetailsDictionary objectForKey:@"Title"];
    if ([self.navigationItem.title isEqualToString:@"Add Daily Activities"])
        self.levelTextField.placeholder = @"Time Spent";
    else
        self.levelTextField.placeholder = @"Sugar Level";
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    viewSize = [UIScreen mainScreen].bounds.size;
    
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:backgroundView];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    
    self.timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.timePicker.backgroundColor = [UIColor whiteColor];
    
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    self.picker.backgroundColor = [UIColor whiteColor];
    [UIPickerView setAnimationDelegate:self];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    _mmolSelected = NO;
    self.phrID = [[self.phrDetailsDictionary objectForKey:@"phrid"] integerValue];
    self.feetRowCount = 1;
    self.addOrUpdateButtonText =  [self.phrDetailsDictionary objectForKey:@"buttonTextString"];
    [self.addOrUpdatebutton setTitle:self.addOrUpdateButtonText forState:UIControlStateNormal];
    self.numberOfRowsInComponent = (int)[self.phrDetailsDictionary objectForKey:@"numberOfRowsInComponent"];
    self.numberOfComponents = [[self.phrDetailsDictionary objectForKey:@"numberOfComponents"] integerValue];
    self.feetMeasures = [NSMutableArray array];
    _selectedArray = [[NSMutableDictionary alloc] init];
    self.componentOneArray = [[NSMutableArray alloc] initWithArray:[[self.phrDetailsDictionary objectForKey:@"componentOneArray"] objectAtIndex:0]];
    
    if([self.phrDetailsDictionary valueForKey:@"componentTwoArray"])
        self.componentTwoArray = [[NSMutableArray alloc] initWithArray:[[self.phrDetailsDictionary objectForKey:@"componentTwoArray"] objectAtIndex:0]];
    else
        self.componentTwoArray = [NSMutableArray array];
    self.measureTextField.text = [NSString stringWithFormat:@"%@ - %@",[self.componentOneArray objectAtIndex:0],[self.componentTwoArray objectAtIndex:0]];
    
    self.selectedComponentOne = [[self.phrDetailsDictionary objectForKey:@"component0"] floatValue];
    self.selectedComponentTwo = [[self.phrDetailsDictionary objectForKey:@"component1"] integerValue];
    self.selectedComponentThree = [[self.phrDetailsDictionary objectForKey:@"component2"] integerValue];
    if (self.phrID > 0)
        [self prePopulatePickers];
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
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


#pragma mark - Textfield Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if (textField == self.levelTextField)
    {
        [self doneButtonPressed:nil];
        self.transparentImgView.hidden = NO;
        UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        doneToolbar.barStyle = UIBarStyleBlackTranslucent;
        doneToolbar.items = [NSArray arrayWithObjects:
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                             nil];
        [doneToolbar sizeToFit];
        textField.inputAccessoryView = doneToolbar;
    }
    else
    {
        
        [self.measureTextField resignFirstResponder];
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
        [_actionSheet addSubview:self.picker];
        [self.view addSubview:_actionSheet];
        [self.view bringSubviewToFront:_actionSheet];
        _actionSheet.hidden = NO;
        
        self.measureTextField.tag = 1;
    }
    //        self.measureTextField.inputView = self.picker;
    
}
- (void)loadPicker
{
    if (!_pickerToolbar)
    {
        _pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-260, 320, 44)];
        _pickerToolbar.barStyle = UIBarStyleBlackTranslucent; //UIBarStyleBlackOpaque;
        [_pickerToolbar sizeToFit];
    }
    [_actionSheet addSubview:_pickerToolbar];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [barItems addObject:cancelBtn];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    flexSpace.width = 200.0f;
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [barItems addObject:doneBtn];
    
    
    [_pickerToolbar setItems:barItems animated:YES];
    if (self.currentButton == self.timeButton)
    {
        [_actionSheet addSubview:self.timePicker];
    }
    else if (self.currentButton == self.dateButton)
    {
        [_actionSheet addSubview:self.datePicker];
    }
    
    [self.view addSubview:_actionSheet];
    [self.view bringSubviewToFront:_actionSheet];
    _actionSheet.hidden = NO;
    
}
- (void)doneButton:(id)sender
{
    self.transparentImgView.hidden = YES;
    [self.levelTextField resignFirstResponder];
    [self.measureTextField resignFirstResponder];
}
-(void)doneButtonPressed:(id)sender{
    //Do something here here with the value selected using [pickerView date] to get that value
    _actionSheet.hidden = YES;
    
    NSInteger row = [self.picker selectedRowInComponent:0];
    if ([_selectedArray objectForKey:@"unit"] == nil)
    {
        [_selectedArray setObject:[self.componentOneArray objectAtIndex:row] forKey:@"unit"];
    }
    row = [self.picker selectedRowInComponent:1];
    if ([_selectedArray objectForKey:@"unit2"] == nil)
    {
        [_selectedArray setObject:[self.componentTwoArray objectAtIndex:row] forKey:@"unit2"];
    }
    
    self.measureTextField.text = [NSString stringWithFormat:@"%@ - %@",[_selectedArray objectForKey:@"unit"],[_selectedArray objectForKey:@"unit2"]];
    
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
- (IBAction)dateBtnClicked:(id)sender
{
    [self doneButton:nil];
    self.currentButton = nil;
    self.currentButton = self.dateButton;
    [self loadPicker];
}
- (IBAction)timeBtnClicked:(id)sender
{
    [self doneButton:nil];
    self.currentButton = nil;
    self.currentButton = self.timeButton;
    [self loadPicker];
}
-(void)cancelButtonPressed:(id)sender{
    _actionSheet.hidden = YES;
}

#pragma mark Result view methods

-(void)loadResultView:(NSString *)strSugarLevel readingTakenDuring:(NSString *)strReadingTime
{
        viw=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 65)];
        viw.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"transparent.png"]];
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=viw.frame;
        [btn addTarget:self action:@selector(hideResultView:) forControlEvents:UIControlEventTouchUpInside];
        [viw addSubview:btn];
        [self.navigationController.view addSubview:viw];
        _viwResult.hidden=NO;
        if (_mmolSelected)//[strSugarInMl isEqualToString:@"mmol/L"])
        {
            strSugarLevel=[NSString stringWithFormat:@"%d",[strSugarLevel integerValue]*18];
        }
    self.lblBloodSugResult.text = strSugarLevel;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (([strReadingTime isEqualToString:@"Fasting"] && [strSugarLevel intValue] >60 && [strSugarLevel intValue] <= 126)  || (![strReadingTime isEqualToString:@"Fasting"] && [strSugarLevel intValue] >60 && [strSugarLevel intValue] <= 140))
        {
            [UIView animateWithDuration:0.5 animations:^{
                _viwExcellent.frame=CGRectMake(0, 165, _viwExcellent.frame.size.width, _viwExcellent.frame.size.height);
            } completion:^(BOOL finished) {
                _scrolviwResult.contentSize=CGSizeMake(self.view.frame.size.width, _viwExcellent.frame.origin.y+_viwExcellent.frame.size.height+80);
            }];
        }
        else  if (([strReadingTime isEqualToString:@"Fasting"] && [strSugarLevel intValue] >126 && [strSugarLevel intValue] <=250)  || (![strReadingTime isEqualToString:@"Fasting"] && [strSugarLevel intValue] >140 && [strSugarLevel intValue] <= 250))
        {
            [UIView animateWithDuration:0.5 animations:^{
                _viwNeedToImprove.frame=CGRectMake(0, 165, _viwNeedToImprove.frame.size.width, _viwNeedToImprove.frame.size.height);
            } completion:^(BOOL finished) {
                _scrolviwResult.contentSize=CGSizeMake(self.view.frame.size.width, _viwNeedToImprove.frame.origin.y+_viwNeedToImprove.frame.size.height+80);
            }];
        }
        else{
            [UIView animateWithDuration:0.5 animations:^{
                _viwWarning.frame=CGRectMake(0, 165, _viwWarning.frame.size.width, _viwWarning.frame.size.height);
                if ([strSugarLevel intValue] > 250)
                    self.lblWarning.text = @"\u2022Such high blood sugar can lead to complications.\n\n\u2022Consult your doctor to review your medications and dietician for dietary advise";
                else if ([strSugarLevel intValue] <= 60)
                {
                    self.lblWarning.text = @"\u2022Such low blood sugar can lead to complications.\n\n\u2022Consult your doctor to review your medications and dietician for dietary advise";
                }
            } completion:^(BOOL finished) {
                _scrolviwResult.contentSize=CGSizeMake(self.view.frame.size.width, _viwWarning.frame.origin.y+_viwWarning.frame.size.height+100);
            }];
        }
        [UIView animateWithDuration:2.0 animations:^{
            float tcResults=[strSugarLevel floatValue]*kBSugarRation;
            if (tcResults > kResultScreenWidth)
                tcResults=kResultScreenWidth;
            _imgSugrresltIndctor.frame=CGRectMake(tcResults, _imgSugrresltIndctor.frame.origin.y, _imgSugrresltIndctor.frame.size.width, _imgSugrresltIndctor.frame.size.height);
        }];
    });
}

- (IBAction)hideResultView:(id)sender {
    [viw removeFromSuperview];
}
- (IBAction)okBtnClickedToHideResultView:(id)sender {
    [self hideResultView:nil];
    [self updateBackBtnClicked];        
}

#pragma mark - Spinner method
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
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
    }
}

- (void) prePopulatePickers
{
    if ([self.navigationItem.title isEqualToString:@"Add Daily Activities"])
    {
        NSUInteger index = [self.componentOneArray indexOfObject:[self.phrDetailsDictionary objectForKey:@"component1"]];
        self.selectedComponentTwo = index+1;
    }
    if (self.selectedComponentTwo == 2)
    {
        _mmolSelected = YES;
        self.levelTextField.text = [NSString stringWithFormat:@"%.01f",self.selectedComponentOne];
        self.measureTextField.text = [NSString stringWithFormat:@"%@ - %@",[self.componentOneArray objectAtIndex:(self.selectedComponentTwo-1)],[self.componentTwoArray objectAtIndex:(self.selectedComponentThree-1)]];;
    }
    else
    {
        _mmolSelected = NO;
        self.levelTextField.text = [NSString stringWithFormat:@"%.01f",self.selectedComponentOne];
        self.measureTextField.text = [NSString stringWithFormat:@"%@ - %@",[self.componentOneArray objectAtIndex:(self.selectedComponentTwo-1)],[self.componentTwoArray objectAtIndex:(self.selectedComponentThree-1)]];
    }
    [self.picker selectRow:(self.selectedComponentTwo-1) inComponent:0 animated:YES];
    [self.picker selectRow:(self.selectedComponentThree-1) inComponent:1 animated:YES];
    
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return self.numberOfComponents-1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
        return [self.componentOneArray count];
    else
        return [self.componentTwoArray count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    switch (component){
        case 0:
            return 90.0f;
        case 1:
            return 200.0f;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return [self.componentOneArray objectAtIndex:row];
    }
    else
    {
        return [self.componentTwoArray objectAtIndex:row];
    }
    //    else
    //    {
    //        if ([self.navigationItem.title isEqualToString:@"Daily Activities"])
    //            return [NSString stringWithFormat:@"%d", row+1];
    //        else if (!(_mmolSelected))
    //            return [NSString stringWithFormat:@"%d", row+1];
    //        else
    //            return [NSString stringWithFormat:@"%.01f",[[_feetMeasures objectAtIndex:row] floatValue]];
    //    }
}

#pragma mark -
#pragma mark PickerView Delegate

- (NSInteger)selectedRowInComponent:(NSInteger)component
{
    return (int)[self.picker selectedRowInComponent:1];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    if (component == 0)
    {
        if (row == 1)
            _mmolSelected = YES;
        else
            _mmolSelected = NO;
        
        [_selectedArray setObject:[self.componentOneArray objectAtIndex:row] forKey:@"unit"];
        [pickerView reloadComponent:0];
        
    }
    else if (component == 1)
    {
        [_selectedArray setObject:[self.componentTwoArray objectAtIndex:row] forKey:@"unit2"];
    }
    //    else
    //    {
    //        if([_feetMeasures count]>0 && _mmolSelected)
    //            [_selectedArray setObject:[NSString stringWithFormat:@"%.01f",[[_feetMeasures objectAtIndex:row] floatValue]] forKey:@"value"];
    //        else
    //            [_selectedArray setObject:[NSNumber numberWithInt:row+1] forKey:@"value"];
    //    }
}

#pragma mark IBAction Methods

- (IBAction)updateBackBtnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)makeRequestToAddPhrDetails:(id)sender
{
    
    //    if (![HUD isHidden]) {
    //        [HUD hide:YES];
    //    }
    //    [self addSpinnerView];
   
    if ((self.measureTextField.text == nil || [self.measureTextField.text length] <= 0))
    {
        [self customAlertView:@"" Message:[NSString stringWithFormat:@"Please Add %@",[self.phrDetailsDictionary objectForKey:@"Title"]] tag:1];
    }
    else if((self.levelTextField.text == nil || [self.levelTextField.text length] <= 0))
    {
        if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"blood sugar"])
        {
            [self customAlertView:@"" Message:@"Please enter your blood sugar level." tag:1];
        }
        else
        {
            [self customAlertView:@"" Message:@"Please specify the amount of time spent on the activity." tag:1];
        }
    }
    else
    {
        NSString *sessionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
         [_addOrUpdatebutton setEnabled:false];
        
        //        NSDate *today = [NSDate date];
        //        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
        //        [dateFormat setTimeZone:gmt];
        //        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        //        NSString *dateString = [dateFormat stringFromDate:today];
        //        [dateFormat setDateFormat:@"hh:mm a"];
        //        NSString *timeString = [dateFormat stringFromDate:today];
        //        [dateFormat setDateFormat:@"dd-MM-yyyy HH:mm:SS"];
        
        int unitType=0, type=0, checkWith=0;
        if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"blood sugar"])
        {
             _lblUnitsResult.text = @"mg/dl";
            NSArray *string = [self.measureTextField.text componentsSeparatedByString:@"-"];
            [_selectedArray setObject:self.levelTextField.text forKey:@"value"];
            NSString *unit2 =[string objectAtIndex:1];
            if ([string count]>4)
            {
                unit2 = [NSString stringWithFormat:@"%@ %@",[string objectAtIndex:0],[string objectAtIndex:1]];
            }
            type = 2;
            if ([[string objectAtIndex:0] isEqualToString:@"mg/dl "])
            {
                unitType = 1;
                _lblUnitsResult.text = @"mg/dl";
            }
            else
            {
                unitType = 2;
            }
            if ([unit2 isEqualToString:@" Fasting"])
            {
                checkWith = 1;
            }
            else if ([unit2 isEqualToString:@" Post Breakfast"])
            {
                checkWith = 2;
            }
            else if ([unit2 isEqualToString:@" Before Lunch"])
            {
                checkWith = 3;
            }
            else if ([unit2 isEqualToString:@" Post Lunch"])
            {
                checkWith = 4;
            }
            else if ([unit2 isEqualToString:@" Before dinner"])
            {
                checkWith = 5;
            }
            else if ([unit2 isEqualToString:@" Post Dinner"])
            {
                checkWith = 6;
            }
            else if ([unit2 isEqualToString:@" Random"])
            {
                checkWith = 7;
            }
            else if ([unit2 isEqualToString:@" Basal Insulin"])
            {
                checkWith = 8;
            }
            else
            {
                checkWith = 9;
            }
        }
        else if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"daily activities"])
        {
            type = 3;
            if (![_selectedArray count])
            {
                NSArray* foo = [self.measureTextField.text componentsSeparatedByString: @"-"];
                [_selectedArray setObject:self.levelTextField.text forKey:@"value"];
                [_selectedArray setObject:[foo objectAtIndex:0] forKey:@"unit"];
                [_selectedArray setObject:[foo objectAtIndex:1] forKey:@"unit2"];
                
            }
            if ([[_selectedArray objectForKey:@"unit2"] isEqualToString:@"BriskWalk"] || [[_selectedArray objectForKey:@"unit2"] isEqualToString:@" BriskWalk"])
            {
                [_selectedArray setObject:@"BriskWalk" forKey:@"unit2"];
                checkWith = 1;
            }
            else if ([[_selectedArray objectForKey:@"unit2"] isEqualToString:@"Regular Walk"] || [[_selectedArray objectForKey:@"unit2"] isEqualToString:@" Regular Walk"])
            {
                [_selectedArray setObject:@"Regular Walk" forKey:@"unit2"];
                checkWith = 2;
            }
            else if ([[_selectedArray objectForKey:@"unit2"] isEqualToString:@"Jogging"] || [[_selectedArray objectForKey:@"unit2"] isEqualToString:@" Jogging"])
            {
                [_selectedArray setObject:@"Jogging" forKey:@"unit2"];
                checkWith = 3;
            }
            else if ([[_selectedArray objectForKey:@"unit2"] isEqualToString:@"Yoga"] || [[_selectedArray objectForKey:@"unit2"] isEqualToString:@" Yoga"])
            {
                [_selectedArray setObject:@"Yoga" forKey:@"unit2"];
                checkWith = 4;
            }
            else if ([[_selectedArray objectForKey:@"unit2"] isEqualToString:@"Aerobics"] || [[_selectedArray objectForKey:@"unit2"] isEqualToString:@" Aerobics"])
            {
                [_selectedArray setObject:@"Aerobics" forKey:@"unit2"];
                checkWith = 5;
            }
            else if ([[_selectedArray objectForKey:@"unit2"] isEqualToString:@"Swimming"] || [[_selectedArray objectForKey:@"unit2"] isEqualToString:@" Swimming"])
            {
                [_selectedArray setObject:@"Swimming" forKey:@"unit2"];
                checkWith = 6;
            }
            else if ([[_selectedArray objectForKey:@"unit2"] isEqualToString:@"Cycling"] || [[_selectedArray objectForKey:@"unit2"] isEqualToString:@" Cycling"])
            {
                [_selectedArray setObject:@"Cycling" forKey:@"unit2"];
                checkWith = 7;
            }
            else
            {
                [_selectedArray setObject:@"Others" forKey:@"unit2"];
                checkWith = 8;
            }
        }
        
        NSString *bodyText;
        
        if (type == 2) {
            bodyText = [NSString stringWithFormat:@"sessionid=%@&sugar=%@&sugar_check=%d&sugar_unit=%d&tested_date=%@&tested_time=%@&type=%d",sessionId,[_selectedArray objectForKey:@"value"],checkWith,unitType,self.dateTextField.text,self.timeTextField.text,type];
        }
        else if(type == 3)
        {
            bodyText = [NSString stringWithFormat:@"sessionid=%@&daily_activity=%@ min&daily_act_type=%d&tested_date=%@&tested_time=%@&type=%d",sessionId,self.levelTextField.text,checkWith,self.dateTextField.text,self.timeTextField.text,type];
            
            if ([_selectedArray objectForKey:@"unit"]!=nil)
            {
                bodyText = [NSString stringWithFormat:@"sessionid=%@&daily_activity=%@ %@&daily_act_type=%d&tested_date=%@&tested_time=%@&type=%d",sessionId,self.levelTextField.text,[_selectedArray objectForKey:@"unit"],checkWith,self.dateTextField.text,self.timeTextField.text,type];
            }
        }
        
        if(self.phrID > 0)
        {
            bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&phrid=%lu",(unsigned long)self.phrID]];
            
        }
        if (![HUD isHidden]) {
            [HUD hide:YES];
        }
        [self addSpinnerView];
        NSString *urlStr = [NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mphr"];

       // NSString *url=@"https://dev.smartrx.in/api/mphr";
        [[SmartRxCommonClass sharedManager] postOrGetData:urlStr postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
            if (response != nil) {
                
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
                                if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"blood sugar"])
                                {
                                    NSArray *string = [self.measureTextField.text componentsSeparatedByString:@"-"];
                                    [_selectedArray setObject:self.levelTextField.text forKey:@"value"];
                                    [self loadResultView:[_selectedArray objectForKey:@"value"] readingTakenDuring:[string objectAtIndex:1]];
                                }
                                else
                                {
                                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ added successfully",[self.phrDetailsDictionary objectForKey:@"Title"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    [alert show];
                                }
                                break;
                            }
                            case 2:
                            {
                                if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"blood sugar"])
                                {
                                    NSArray *string = [self.measureTextField.text componentsSeparatedByString:@"-"];
                                    [_selectedArray setObject:self.levelTextField.text forKey:@"value"];
                                    [self loadResultView:[_selectedArray objectForKey:@"value"] readingTakenDuring:[string objectAtIndex:1]];
                                }
                                else
                                {
                                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ updated successfully",[self.phrDetailsDictionary objectForKey:@"Title"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    [alert show];
                                }
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
            }
            else {
                [_addOrUpdatebutton setEnabled:true];
                [HUD hide:YES];
                [HUD removeFromSuperview];
                [self customAlertView:@"Error" Message:@"Health record updation failed .Please try again later." tag:1];
            }
        } failureHandler:^(id response) {
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"The request timed out" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [self customAlertView:@"" Message:@"Adding or Updating Personal Health Record failed" tag:0];
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            
        }];
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

#pragma mark
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
