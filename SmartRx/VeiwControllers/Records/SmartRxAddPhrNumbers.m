//
//  SmartRxAddPhrNumbers.m
//  SmartRx
//
//  Created by Anil Kumar on 12/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxAddPhrNumbers.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxDataTVC.h"
#import "SmartRxImageTVC.h"
#import <QuickLook/QuickLook.h>
#import "SmartRxCommonClass.h"
#import "SmartRxCarePlaneSubVC.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"
#import "NSString+DateConvertion.h"

#define kResultScreenWidth 260
#define kSystlicResultRatio 1.44
#define kDiastolicResultRatio 2.36
#define kSystolicBpWarning 90
#define kSystolicBpExcelent 120
#define kSystolicBpNeedImprove 140
#define kSystolicBpNeedMax  180
#define kDiastolicExcelent  80
#define kDiastolicNeedImprove  90
#define kDiastolicMax  110
#define kReultViewY 200

//#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@interface SmartRxAddPhrNumbers ()<ShowImageInMainView, QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    CGSize viewSize;
    UIView *viw;
}
@end

@implementation SmartRxAddPhrNumbers

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.phrDetailsDictionary objectForKey:@"value"] != nil)
    {
        [self populateValuesToEdit];
    }
    
    self.phrID = [[self.phrDetailsDictionary objectForKey:@"phrid"] integerValue];
    self.addOrUpdateButtonText =  [self.phrDetailsDictionary objectForKey:@"buttonTextString"];
    [self.addOrUpdatebutton setTitle:self.addOrUpdateButtonText forState:UIControlStateNormal];
    self.label1.text = [self.phrDetailsDictionary objectForKey:@"label1"];
    self.unitLabel1.text = [self.phrDetailsDictionary objectForKey:@"unit"];
    if ([[self.phrDetailsDictionary objectForKey:@"numberOfLabels"] integerValue] < 2) {
        [self.label2 setHidden:YES];
        [self.textField2 setHidden:YES];
        [self.unitLabel2 setHidden:YES];
    }
    else
    {
        [self.label2 setHidden:NO];
        [self.textField2 setHidden:NO];
        [self.unitLabel2 setHidden:NO];
        self.label2.text = [self.phrDetailsDictionary objectForKey:@"label2"];
        self.unitLabel2.text = [self.phrDetailsDictionary objectForKey:@"unit"];
    }
    if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"temperature"])
    {
        self.textField1.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    [self addSpinnerView];
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    viewSize = [UIScreen mainScreen].bounds.size;
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
    [dateFormat setTimeZone:gmt];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormat stringFromDate:today];
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString *timeString = [dateFormat stringFromDate:today];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
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
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:backgroundView];
    
    self.currentButton = [[UIButton alloc] init];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    
    self.timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.timePicker.backgroundColor = [UIColor whiteColor];
    
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.maximumDate = [NSDate date];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    self.timePicker.maximumDate = [NSDate date];
}
- (void)populateValuesToEdit
{
    self.textField1.text = [self.phrDetailsDictionary objectForKey:@"value"];
    if ([self.phrDetailsDictionary objectForKey:@"value2"]!=nil)
        self.textField2.text = [self.phrDetailsDictionary objectForKey:@"value2"];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textField1 resignFirstResponder];
    [self.textField2 resignFirstResponder];
}

- (void)doneButton:(id)sender {
    [self.textField1 resignFirstResponder];
    [self.textField2 resignFirstResponder];
    [self.timeTextField resignFirstResponder];
    [self.dateTextField resignFirstResponder];
}
//
//- (void)keyboardDidShow:(NSNotification *)note {
//    // create custom button
////    [self addDoneButtontoKeyboard:note];
//}
//- (void)keyboardWillShow:(NSNotification *)note {
//    // create custom button
////    [self addDoneButtontoKeyboard:note];
//}

- (void)addDoneButtontoKeyboard:(NSNotification *)note
{
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 163, 106, 53);
    doneButton.adjustsImageWhenHighlighted = NO;
    [doneButton setImage:[UIImage imageNamed:@"doneup.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"donedown.png"] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *keyboardView = [[[[[UIApplication sharedApplication] windows] lastObject] subviews] firstObject];
            [doneButton setFrame:CGRectMake(0, keyboardView.frame.size.height - 53, 106, 53)];
            [keyboardView addSubview:doneButton];
            [keyboardView bringSubviewToFront:doneButton];
            
            [UIView animateWithDuration:[[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]-.02
                                  delay:.0
                                options:[[note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]
                             animations:^{
                                 self.view.frame = CGRectOffset(self.view.frame, 0, 0);
                             } completion:nil];
        });
    }else {
        // locate keyboard view
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
            UIView* keyboard;
            for(int i=0; i<[tempWindow.subviews count]; i++) {
                keyboard = [tempWindow.subviews objectAtIndex:i];
                // keyboard view found; add the custom button to it
                if([[keyboard description] hasPrefix:@"UIKeyboard"] == YES)
                    [keyboard addSubview:doneButton];
            }
        });
    }
}


#pragma mark - Textfield methods
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    textField.inputAccessoryView = doneToolbar;
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(keyboardWillShow:)
    //                                                 name:UIKeyboardWillShowNotification
    //                                               object:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"temperature"])
        return (newLength > 5) ? NO : YES;
    else
        return (newLength > 3) ? NO : YES;
}
#pragma mark - Spinner method
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - Result view
-(void)loadResultView
{
    viw=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 65)];
    viw.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"transparent.png"]];
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=viw.frame;
    [btn addTarget:self action:@selector(hideResultView:) forControlEvents:UIControlEventTouchUpInside];
    [viw addSubview:btn];
    [self.navigationController.view addSubview:viw];
    
    _lblSysBpResult.text = self.textField1.text;
    _lblDiastBpResult.text = self.textField2.text;
    
    _viwResult.hidden=NO;
    if (([self.textField1.text intValue] >= kSystolicBpNeedMax  ||  [self.textField2.text intValue] >= kDiastolicMax) )
    {
        [UIView animateWithDuration:0.5 animations:^{
            _viwWarningImprovment.frame=CGRectMake(0, kReultViewY, _viwWarningImprovment.frame.size.width, _viwWarningImprovment.frame.size.height);
        } completion:^(BOOL finished) {
            _scrolViwResult.contentSize=CGSizeMake(self.view.frame.size.width, _viwNeedImprove.frame.origin.y+_viwWarningImprovment.frame.size.height+80);
        }];
    }
    else if ([self.textField1.text intValue] > kSystolicBpNeedImprove ||  [self.textField2.text intValue] > kDiastolicNeedImprove || [self.textField1.text intValue] < kSystolicBpWarning)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _viewWarrning.frame=CGRectMake(0, kReultViewY, _viewWarrning.frame.size.width, _viewWarrning.frame.size.height);
        } completion:^(BOOL finished) {
            _scrolViwResult.contentSize=CGSizeMake(_scrolViwResult.contentSize.width, _viewWarrning.frame.origin.y+_viewWarrning.frame.size.height+80);
        }];
    }
    else if (([self.textField1.text intValue] > kSystolicBpExcelent  &&  [self.textField1.text intValue] < kSystolicBpNeedImprove) || ([self.textField2.text intValue] > kDiastolicExcelent &&  [self.textField2.text intValue] < kDiastolicNeedImprove) )
    {
        [UIView animateWithDuration:0.5 animations:^{
            _viwNeedImprove.frame=CGRectMake(0, kReultViewY, _viwNeedImprove.frame.size.width, _viwNeedImprove.frame.size.height);
        } completion:^(BOOL finished) {
            _scrolViwResult.contentSize=CGSizeMake(_scrolViwResult.contentSize.width, _viwNeedImprove.frame.origin.y+_viwNeedImprove.frame.size.height+80);
        }];
    }
    else{
        [UIView animateWithDuration:0.5 animations:^{
            _viwExcellent.frame=CGRectMake(0, kReultViewY, _viwExcellent.frame.size.width, _viwExcellent.frame.size.height);
        } completion:^(BOOL finished) {
            _scrolViwResult.contentSize=CGSizeMake(_scrolViwResult.contentSize.width, _viwExcellent.frame.origin.y+_viwExcellent.frame.size.height+80);
        }];
    }
    [UIView animateWithDuration:2.0 animations:^{
        float tcResults=[self.textField1.text floatValue]*kSystlicResultRatio;
        if (tcResults > kResultScreenWidth)
            tcResults=kResultScreenWidth;
        _imgSystolicResltIndctor.frame=CGRectMake(tcResults, _imgSystolicResltIndctor.frame.origin.y, _imgSystolicResltIndctor.frame.size.width, _imgSystolicResltIndctor.frame.size.height);
        
        float ldlResults=[self.textField2.text floatValue]*kDiastolicResultRatio;
        if (ldlResults > kResultScreenWidth)
            ldlResults=kResultScreenWidth;
        _imgDiastolicResltIndctor.frame=CGRectMake(ldlResults, _imgDiastolicResltIndctor.frame.origin.y, _imgDiastolicResltIndctor.frame.size.width, _imgDiastolicResltIndctor.frame.size.height);
    }];
}
- (IBAction)hideResultView:(id)sender {
    [viw removeFromSuperview];
}
- (IBAction)okBtnClickedToHideResultView:(id)sender {
    [self hideResultView:nil];
    [self updateBackButtontnClicked:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction Methods
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
-(void)doneButtonPressed:(id)sender
{
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

-(void)cancelButtonPressed:(id)sender
{
    _actionSheet.hidden = YES;
}
- (IBAction)makeRequestToAddPhrNumDetails:(id)sender
{
    BOOL nullTestFlag;
    if ([[self.phrDetailsDictionary objectForKey:@"numberOfLabels"] integerValue] == 2)
    {
        if([self.textField1.text length] <= 0 )
        {
            [self customAlertView:@"Error" Message:[NSString stringWithFormat:@"Please enter %@ value",self.label1.text] tag:1];
            nullTestFlag = YES;
        }
        else if ([self.textField2.text length] <= 0 )
        {
            [self customAlertView:@"Error" Message:[NSString stringWithFormat:@"Please enter %@ value",self.label2.text] tag:1];
            nullTestFlag = YES;
        }
        else
        {
            nullTestFlag = NO;
        }
    }
    else
    {
        if([self.textField1.text length] <= 0 )
        {
            [self customAlertView:@"Error" Message:[NSString stringWithFormat:@"Please enter %@ value",self.label1.text] tag:1];
            nullTestFlag = YES;
        }
        else
        {
            nullTestFlag = NO;
        }
        
    }
    if(!nullTestFlag)
        
    {
        if (![HUD isHidden]) {
            [HUD hide:YES];
        }
        [self addSpinnerView];
        
        NSString *sessionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
        //        NSDate *today = [NSDate date];
        //        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
        //        [dateFormat setTimeZone:gmt];
        //        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        //        NSString *dateString = [dateFormat stringFromDate:today];
        //        [dateFormat setDateFormat:@"hh:mm a"];
        //        NSString *timeString = [dateFormat stringFromDate:today];
        //        [dateFormat setDateFormat:@"dd-MM-yyyy HH:mm:SS"];
        NSString *bodyText;
        
        int type=0;
        
        if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"blood pressure"])
        {
            type = 4;
            bodyText = [NSString stringWithFormat:@"sessionid=%@&sbp=%@&dbp=%@&tested_date=%@&tested_time=%@&type=%d",sessionId,self.textField1.text,self.textField2.text,self.dateTextField.text,self.timeTextField.text,type];
        }
        else if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"pulse"])
        {
            type = 5;
            bodyText = [NSString stringWithFormat:@"sessionid=%@&pulse=%@&tested_date=%@&tested_time=%@&type=%d&entry_type=1",sessionId,self.textField1.text,self.dateTextField.text,self.timeTextField.text,type];
        }
        else if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"temperature"])
        {
            type = 6;
            bodyText = [NSString stringWithFormat:@"sessionid=%@&temp=%@&tested_date=%@&tested_time=%@&type=%d",sessionId,self.textField1.text,self.dateTextField.text,self.timeTextField.text,type];
        }
        if(self.phrID > 0)
        {
            bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&phrid=%lu",(unsigned long)self.phrID]];
            
        }
         NSString *urlStr = [NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mphr"];
        //NSString *url=@"https://dev.smartrx.in/api/mphr";
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
                                if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"blood pressure"])
                                {
                                    [self loadResultView];
                                }
                                else if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"temperature"])
                                {
                                    if ([self.textField1.text floatValue] > 100.0)
                                        [self customAlertView:@"Warning !!!" Message:@"Are you feeling feverish? You should consult your doctor." tag:0];
                                    else
                                    {
                                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ added successfully",[self.phrDetailsDictionary objectForKey:@"Title"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                        [alert show];
                                        
                                    }
                                }
                                else if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"pulse"])
                                {
                                    
                                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ added successfully",[self.phrDetailsDictionary objectForKey:@"Title"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    [alert show];
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
                                if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"blood pressure"])
                                {
                                    [self loadResultView];
                                }
                                else if ([[[self.phrDetailsDictionary objectForKey:@"Title"] lowercaseString] isEqualToString:@"temperature"])
                                {
                                    if ([self.textField1.text floatValue] > 100.0)
                                        [self customAlertView:@"Warning !!!" Message:@"Are you feeling feverish? You should consult your doctor." tag:0];
                                    else
                                    {
                                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ added successfully",[self.phrDetailsDictionary objectForKey:@"Title"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                        [alert show];
                                        
                                    }
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
            } else {
                [HUD hide:YES];
                [HUD removeFromSuperview];
                [self customAlertView:@"Error" Message:@"Health record updation failed .Plaese try again later." tag:1];
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
        [self makeRequestToAddPhrNumDetails:nil];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}
-(void)errorSectionId:(id)sender
{
    NSLog(@"error");
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    self.view.userInteractionEnabled = YES;
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
        [self updateBackButtontnClicked:nil];
        //[self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)updateBackButtontnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
