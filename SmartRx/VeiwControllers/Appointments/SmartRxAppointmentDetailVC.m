//
//  SmartRxAppointmentDetailVC.m
//  SmartRx
//
//  Created by Gowtham on 12/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxAppointmentDetailVC.h"
#import "NSString+DateConvertion.h"
#import "SmartRxDashBoardVC.h"
#import "UIKit+AFNetworking.h"
#import "AFNetworking.h"
#import <QuickLook/QuickLook.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SmartRxReportImageVC.h"
//#import "SmartRxVideoConference.h"
#import "SmartRxSuggesstionCell.h"
#import "EconsultMedicationResponseModel.h"
#import "EconsultMedicationCell.h"

#define kLessThan4Inch 560


@interface SmartRxAppointmentDetailVC ()<ShowImageInMainView, QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    MBProgressHUD *HUD;
    BOOL imageBeingShowed;
    CGFloat viewWidth, viewHeight;
    CGFloat heightLbl;
    CGSize viewSize;
    CGFloat height;
    UILabel *repLabel;
    UILabel *reqLabel;
    NSMutableArray *sectionTitlesArray;
    NSString *mStr,*noStr,*eStr,*nStr,*foodTime;
    EconsultMedicationResponseModel *selectedMedication;

    
}
@end

@implementation SmartRxAppointmentDetailVC
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
    self.navigationItem.title = @"Appointment Details";
    foodTime = @"";
    nStr = @"0";
    mStr = @"0";
    noStr = @"0";
    eStr = @"0";
    [self navigationBackButton];
    NSLog(@"selected appointment details:%@",self.dictResponse);
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    sectionTitlesArray = [[NSMutableArray alloc] init];
    sectionTitlesArray = [@[@"Reports",@"Patient Notes/Symptoms"] mutableCopy];
    viewSize=[[UIScreen mainScreen]bounds].size;
    viewWidth = CGRectGetWidth(self.view.frame);
    viewHeight = CGRectGetHeight(self.view.frame);
    self.suggestionScroll.pagingEnabled = NO;
    self.symptomsContentLabel.editable = NO;
    self.reportScroll.pagingEnabled = NO;
   
    viewSize=[[UIScreen mainScreen]bounds].size;
    [self.reportContentTable setTableFooterView:[UIView new]];
    [self.requestContentTable setTableFooterView:[UIView new]];
    viewWidth = CGRectGetWidth(self.view.frame);
    viewHeight = CGRectGetHeight(self.view.frame);
    [self.medicationTable setTableFooterView:[UIView new]];

    if (viewSize.height < kLessThan4Inch)
    {
        self.symptomsContentLabel.frame = CGRectMake(self.symptomsContentLabel.frame.origin.x, self.symptomsContentLabel.frame.origin.y, self.symptomsContentLabel.frame.size.width, 190);
        self.familyContentLabel.frame = CGRectMake(self.familyContentLabel.frame.origin.x, self.familyContentLabel.frame.origin.y, self.familyContentLabel.frame.size.width, 190);

    }
    else{
        self.symptomsContentLabel.frame = CGRectMake(self.symptomsContentLabel.frame.origin.x, self.symptomsContentLabel.frame.origin.y, self.symptomsContentLabel.frame.size.width, self.symptomsContentLabel.frame.size.height-50);
        self.familyContentLabel.frame = CGRectMake(self.familyContentLabel.frame.origin.x, self.familyContentLabel.frame.origin.y, self.familyContentLabel.frame.size.width, self.familyContentLabel.frame.size.height-50);

    }
    
    self.familyContentLabel.text = @"No past family history added";

    //    self.connectBtn.hidden = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForReports];
        if (self.scheduleType != nil) {
            [self makeRequestForMedicationAndFamilyHistory];
        }
        //[self makeRequestForRequests];
    }
    else
    {
        NSDictionary *tempDict = [[SmartRxDB sharedDBManager] fetchEconReportFromDataBase:[[self.dictResponse objectForKey:@"conid"] integerValue] type:@"econsult"];
        if ([tempDict count])
        {
            [self processReportResponse:tempDict];
        }
        NSDictionary *tempRequestDict = [[SmartRxDB sharedDBManager] fetchEconRequestFromDataBase:[[self.dictResponse objectForKey:@"conid"] integerValue] type:@"econsult"];
        if ([tempRequestDict count])
        {
            [self processRequestData:tempRequestDict];
        }
    }
    if ([[self.dictResponse objectForKey:@"app_method"] integerValue] == 2)
    {
        self.econsultMethodLbl.text = @"Phone Call";
        //self.phoneOrVideoImg.image = [UIImage imageNamed:@"icn_phone.png"];
        //video_call.png
    }
//    self.updateTextView.layer.cornerRadius=5.0f;
//    self.updateTextView.layer.masksToBounds = YES;
//    self.updateTextView.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
//    self.updateTextView.layer.borderWidth= 0.5f;
    
    if([self.dictResponse objectForKey:@"dispname"] != [NSNull null] && [self.dictResponse objectForKey:@"dispname"] && [[self.dictResponse objectForKey:@"dispname"] length] > 0 )
        self.docName.text=[self.dictResponse objectForKey:@"dispname"];
    
    NSString *strDatTime=[NSString stringWithFormat:@"%@ %@",[self.dictResponse objectForKey:@"appdate"],[self.dictResponse objectForKey:@"apptime"]];
    self.eConsultDateTime.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
    if ([[self.dictResponse objectForKey:@"status"] integerValue] == 1)
    {
        self.statusLbl.text = @"Pending";
        self.statusLbl.textColor = [UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1];
        self.eConsultStatusImage.image = [UIImage imageNamed:@"econsult_pending.png"];
        //self.connectBtn.hidden = YES;
    }
    else if ([[self.dictResponse objectForKey:@"status"] integerValue] == 2)
    {
        self.statusLbl.text = @"Confirmed";
        self.statusLbl.textColor = [UIColor colorWithRed:0.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1];
        self.eConsultStatusImage.image = [UIImage imageNamed:@"econsult_booked.png"];
//        if ([[self.dictResponse objectForKey:@"app_method"] integerValue] == 2)
//           // self.connectBtn.hidden = YES;
//        else
//            //self.connectBtn.hidden = NO;
    }
    else if ([[self.dictResponse objectForKey:@"status"] integerValue] == 3)
    {
        self.statusLbl.text = @"Completed";
        self.statusLbl.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:153.0/255.0 alpha:1];
        self.eConsultStatusImage.image = [UIImage imageNamed:@"econsult_completed.png"];
        //self.connectBtn.hidden = YES;
    }
    else if ([[self.dictResponse objectForKey:@"status"] integerValue] == 4)
    {
        self.statusLbl.text = @"Cancelled";
        self.statusLbl.textColor = [UIColor redColor];
        self.eConsultStatusImage.image = [UIImage imageNamed:@"econsult_completed.png"];
        //self.connectBtn.hidden = YES;
    }
    
    
    
    if (self.scheduleType != nil) {
        [sectionTitlesArray addObject:@"Past / Family History"];
        [sectionTitlesArray addObject:@"Current Medications"];
        
        if ([_dictResponse[@"payment_type"] integerValue] == 2) {
            self.paymentStatus.text = [NSString stringWithFormat:@"Pending (Rs. %@)",self.dictResponse[@"second_opinion_app_discounted_price"]];
            // self.paymentStatus.text = @"Pending";
            self.paymentStatus.textColor = [UIColor redColor];
        }else if ([_dictResponse[@"payment_type"] integerValue] == 1) {
            self.paymentStatus.text = @"Completed";
            self.paymentStatus.textColor = [UIColor colorWithRed:0.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1];
        }
        
    }else {
        self.segmentView.frame = CGRectMake(self.segmentView.frame.origin.x, 171, self.segmentView.frame.size.width, self.segmentView.frame.size.height);
    }
    
    if ([self.dictResponse objectForKey:@"suggestion"]  != [NSNull null] || [self.arrayReportFiles count] || [self.arrayDoctorSuggestionFiles count])
    {
        [sectionTitlesArray addObject:@"Doctor Suggestion"];
        
        if (self.scheduleType == nil) {
            CGRect newFrame = self.suggestionViewEdit.frame;
            newFrame.origin.x = self.view.frame.size.width * 3;
            self.suggestionViewEdit.frame = newFrame;
            self.familyViewEdit.hidden = YES;
        }
        
        self.suggestionContentLabel.text = [self.dictResponse objectForKey:@"suggestion"];
        [self estimatedHeight:[self.dictResponse objectForKey:@"suggestion"]];
        self.suggestionContentLabel.frame = CGRectMake(self.suggestionContentLabel.frame.origin.x, self.suggestionContentLabel.frame.origin.y, self.suggestionViewEdit.frame.size.width-20, heightLbl+self.suggestionContentLabel.frame.size.height);
        [self.suggestionContentLabel sizeToFit];
        [self.suggestionContentLabel setNumberOfLines:0];
        self.suggestionContentTable.frame = CGRectMake(self.suggestionContentTable.frame.origin.x, self.suggestionContentLabel.frame.origin.y + self.suggestionContentLabel.frame.size.height+10, self.suggestionContentTable.frame.size.width, self.suggestionContentTable.frame.size.height);
        if (heightLbl > 350)
        {
            [self.suggestionScroll setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.suggestionScroll.frame.size.height+heightLbl)];
            self.suggestionViewEdit.frame = CGRectMake(self.requestViewEdit.frame.origin.x, self.suggestionViewEdit.frame.origin.y, self.suggestionViewEdit.frame.size.width , self.suggestionViewEdit.frame.size.height+heightLbl);
        }
    }
    if ([self.dictResponse objectForKey:@"symptom"]  != [NSNull null] && [[self.dictResponse objectForKey:@"symptom"] length] > 0)
    {
        [self estimatedHeight:[self.dictResponse objectForKey:@"symptom"]];
        self.symptomsContentLabel.text = [self.dictResponse objectForKey:@"symptom"];
        [self.scrollView addSubview:self.symptomsViewEdit];
    }
    else
    {
        self.symptomsViewEdit.frame = CGRectMake(viewWidth*1, 0, viewWidth, heightLbl+40);
        self.symptomsContentLabel.text = @"No symptoms added";
        [self estimatedHeight:@"No symptoms added"];
    }
    
//    if (self.scheduleType != nil) {
//        [sectionTitlesArray addObject:@"Past / Family History"];
//        [sectionTitlesArray addObject:@"Current Medications"];
//        
//        if ([_dictResponse[@"payment_type"] integerValue] == 2) {
//            self.paymentStatus.text = [NSString stringWithFormat:@"Pending (Rs. %@)",self.dictResponse[@"second_opinion_app_discounted_price"]];
//           // self.paymentStatus.text = @"Pending";
//            self.paymentStatus.textColor = [UIColor redColor];
//        }else if ([_dictResponse[@"payment_type"] integerValue] == 1) {
//            self.paymentStatus.text = @"Completed";
//            self.paymentStatus.textColor = [UIColor colorWithRed:0.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1];
//        }
//        
//    }else {
//        self.segmentView.frame = CGRectMake(self.segmentView.frame.origin.x, 171, self.segmentView.frame.size.width, self.segmentView.frame.size.height);
//    }

    
    [self.symptomsViewEdit addSubview:self.symptomsContentLabel];
    [self.scrollView addSubview:self.symptomsViewEdit];
    [self numberKeyBoardReturn];
    [self makeSegmentView];
//    if ([[self.dictResponse objectForKey:@"status"] integerValue] == 2 && [[self.dictResponse objectForKey:@"app_method"] integerValue] == 1)
//        [self makeRequestToGetToken];

}
-(void)numberKeyBoardReturn
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    self.updateTextView.inputAccessoryView = doneToolbar;
    self.quantityTF.inputAccessoryView = doneToolbar;
    self.doseTF.inputAccessoryView = doneToolbar;

}
- (void)makeSegmentView
{
    // Tying up the segmented control to a scroll view
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 1)];
    topBorder.backgroundColor = [UIColor lightGrayColor];
    
    self.segmentedControl4 = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 1, viewWidth, 40)];
    self.segmentedControl4.sectionTitles = sectionTitlesArray;
    
    self.segmentedControl4.selectedSegmentIndex = 0;
    self.segmentedControl4.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    self.segmentedControl4.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor],  UITextAttributeFont:[UIFont systemFontOfSize:15]};//@{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.segmentedControl4.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:7.0/255.0 green:92.0/255.0 blue:176.0/255.0 alpha:1]};//@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]};
    self.segmentedControl4.borderType = HMSegmentedControlBorderTypeRight;
    self.segmentedControl4.borderWidth = 1.0;
    self.segmentedControl4.borderColor = [UIColor lightGrayColor];
    self.segmentedControl4.selectionIndicatorColor = [UIColor colorWithRed:7.0/255.0 green:92.0/255.0 blue:176.0/255.0 alpha:1];
    self.segmentedControl4.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.segmentedControl4.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl4.tag = 3;
    
    __weak typeof(self) weakSelf = self;
    [self.segmentedControl4 setIndexChangeBlock:^(NSInteger index) {
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(viewWidth * index,  0, viewWidth, 200) animated:YES];
    }];
    
    [self.segmentView addSubview:topBorder];
    [self.segmentView addSubview:self.segmentedControl4];
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self.segmentedControl4.frame.size.height, viewWidth, 1)];
    bottomBorder.backgroundColor = [UIColor lightGrayColor];
    [self.segmentView addSubview:bottomBorder];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 41, viewWidth, 800)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(viewWidth * [self.segmentedControl4.sectionTitles count], 1);
    self.scrollView.delegate = self;
    [self.segmentView addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.reportViewEdit];
    [self.scrollView addSubview:self.symptomsViewEdit];
    //[self.scrollView addSubview:self.requestViewEdit];
    [self.scrollView addSubview:self.suggestionViewEdit];
    [self.scrollView addSubview:self.familyViewEdit];
    [self.scrollView addSubview:self.medicationViewEdit];
    [self.scrollView bringSubviewToFront:self.suggestionScroll];
    
}

- (void)setApperanceForLabel:(UILabel *)label {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    label.backgroundColor = color;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:21.0f];
    label.textAlignment = NSTextAlignmentCenter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Action Methods
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
- (IBAction)bfBtnClicked:(id)sender
{
    self.btnBF.selected=YES;
    self.btnAF.selected=NO;
    foodTime = @"1";
}

- (IBAction)afBtnClicked:(id)sender
{
    self.btnBF.selected=NO;
    self.btnAF.selected=YES;
    foodTime = @"2";

}
-(void)imgaeZooming:(NSString *)sender
{
    imageBeingShowed = YES;
    [self performSegueWithIdentifier:@"imageZooming" sender:sender];
    
}


- (IBAction)cancelBtnClicked:(id)sender
{
    [self.view endEditing:YES];
    [self hideUpdateView];
}
-(IBAction)clickOnAddMedication:(id)sender{
    self.currentView = self.medicationViewEdit;
    [self.saveBtn setTitle:@"Save" forState:UIControlStateNormal];
    [self showMedicationUpdateView];
}
-(IBAction)clickOnMedicationConsumptionBtn:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 100) {
        if (btn.selected) {
            self.mBtn.selected = NO;
            mStr = @"0";
        } else {
            mStr = @"1";
            self.mBtn.selected = YES;
            
        }
    } else if (btn.tag == 101){
        if (btn.selected) {
            noStr = @"0";
            
            self.noBtn.selected = NO;
        } else {
            noStr = @"1";
            self.noBtn.selected = YES;
            
        }
    }else if (btn.tag == 102){
        if (btn.selected) {
            eStr = @"0";
            
            self.eBtn.selected = NO;
        } else {
            eStr = @"1";
            
            self.eBtn.selected = YES;
            
        }
    }else if (btn.tag == 103){
        if (btn.selected) {
            nStr = @"0";
            
            self.nBtn.selected = NO;
        } else {
            nStr = @"1";
            
            self.nBtn.selected = YES;
            
        }
    }
    
}

-(IBAction)clickOnMedicationCancelBtn:(id)sender{
    self.drugNameTF.text = nil;
    self.doseTF.text = nil;
    self.quantityTF.text = nil;
    self.mBtn.selected = NO;
    mStr = @"0";
    self.noBtn.selected = NO;
    noStr = @"0";
    self.eBtn.selected = NO;
    eStr = @"0";
    self.nBtn.selected = NO;
    nStr = @"0";
    self.btnBF.selected = NO;
    self.btnAF.selected = NO;
    [self hideUpdateMedicationView];
}
-(IBAction)clickOnMedicationUpdateBtn:(id)sender{
    [self.view endEditing:YES];
    if (self.drugNameTF.text.length < 1) {
        [self customAlertView:@"" Message:@"Drug name is required." tag:0];
    }
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@&drug_name=%@&drug_dose=%@&quantity=%@&morning=%@&afternoon=%@&night=%@&evening=%@&consumption_time=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"],self.drugNameTF.text,self.doseTF.text,self.quantityTF.text,mStr,noStr,nStr,eStr,foodTime];
    if ([self.saveBtn.titleLabel.text isEqualToString:@"Update"]) {
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&medid=%@",selectedMedication.medicationId]];
    }
    [self makeRequestForAddFamilyhistoryOrMedication:bodyText];
    [self hideUpdateMedicationView];
}
- (IBAction)updateBtnClicked:(id)sender
{
    [self.view endEditing:YES];

    if (self.currentView == self.symptomsViewEdit)
    {
        [self makeRequestToAddSymptoms:self.updateTextView.text];
        [self hideUpdateView];
    }
    else if (self.currentView == self.requestViewEdit)
    {
        [self makeRequestToAddRequest:self.updateTextView.text];
        [self hideUpdateView];
    }else if (self.currentView == self.familyViewEdit)
    {
        NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
        
        NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@&family_history=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"],self.updateTextView.text];
        
        [self makeRequestForAddFamilyhistoryOrMedication:bodyText];
        [self hideUpdateView];
    }
}
-(IBAction)clickOnPastFamilyBtn:(id)sender{
    self.currentView = self.familyViewEdit;
    self.updateTextView.text = nil;
    [self.updateBtn setTitle:@"Update" forState:UIControlStateNormal];
    self.updateViewTitle.text = @"Past Family History";
    self.updateLbl.text = @"Type the past family history";
    self.updateLbl.hidden = YES;
    if (![self.familyContentLabel.text isEqualToString:@"No past family history added"])
        self.updateTextView.text = self.familyContentLabel.text;
    else
        self.updateTextView.text = @"";
    [self.updateTextView becomeFirstResponder];
    [self showUpdateView];
}
- (IBAction)symptomsEditClicked:(id)sender
{
    self.currentView = self.symptomsViewEdit;
    [self.updateBtn setTitle:@"Update" forState:UIControlStateNormal];
    self.updateViewTitle.text = @"Symptoms / Notes";
    self.updateLbl.text = @"Type the symptoms";
    self.updateLbl.hidden = YES;
    if (![self.symptomsContentLabel.text isEqualToString:@"No symptoms added"])
        self.updateTextView.text = self.symptomsContentLabel.text;
    else
        self.updateTextView.text = @"";
    
    [self.updateTextView becomeFirstResponder];
    [self showUpdateView];
}

- (IBAction)requestAddClicked:(id)sender
{
    self.currentView = self.requestViewEdit;
    self.updateTextView.text = nil;
    [self.updateBtn setTitle:@"Send" forState:UIControlStateNormal];
    self.updateViewTitle.text = @"Send Request";
    self.updateLbl.text = @"Type the request message";
    self.updateLbl.hidden = NO;
    [self showUpdateView];
}

- (IBAction)reportsAddClicked:(id)sender
{
    self.currentView = self.reportViewEdit;
    [self.updateBtn setTitle:@"Update" forState:UIControlStateNormal];
    //    self.currentBtn = self.reportBtn;
    [self showActionSheet:nil];
}

-(IBAction)showActionSheet:(id)sender {
    imageBeingShowed = YES;
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}


-(void)estimatedHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, 300,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    //    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(300,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    heightLbl=expectedLabelSize.height;
    //[self setLblYPostionAndHeight:expectedLabelSize.height+20];
}
-(CGFloat)estimatedMedicationHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(8,16, self.view.frame.size.width-35,21)];
    lblHeight.text = strToCalCulateHeight;
    
    //[UIFont fontWithName:@"HelveticaNeue" size:15]
    lblHeight.font =  [UIFont systemFontOfSize:17];
    //    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width-35,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    CGFloat heightLbl=expectedLabelSize.height;
    
    heightLbl = heightLbl+ 24;
    
    return heightLbl;
    
}
- (void)takePhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    
    alertView=nil;
}
#pragma mark - Action Sheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        NSLog(@"Camera Clicked");
        [self takePhoto];
        
    } else if (buttonIndex == 1)
    {
        NSLog(@"Gallery Clicked");
        [[SmartRxCommonClass sharedManager] openGallary:self];
    } else if (buttonIndex == 2) {
        NSLog(@"Cancel Clicked");
    }
}
#pragma mark -Prepare Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"imageZooming"])
    {
        ((SmartRxReportImageVC *)segue.destinationViewController).strImage = sender;
    }
}
#pragma mark - Tableview Delegate/Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.reportContentTable)
        return [self.arrayReportFiles count];
    else if (tableView == self.suggestionContentTable)
        return [self.arrayDoctorSuggestionFiles count];
    else if (tableView == self.medicationTable)
        return [self.medicationArray count];
    else
        return [self.arrayRequestData count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.reportContentTable)
    {
        static NSString *cellIdentifier = @"reportCell";
        SmartRxeConsultReportCell *cellReport = (SmartRxeConsultReportCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cellReport.selectionStyle = UITableViewCellSelectionStyleNone;

        if ([self.arrayReportFiles count])
        {
            cellReport.arrImages = self.arrayReportFiles;
        }
        cellReport.delegateImg = self;
        [cellReport setCellData:[self.arrayReportFiles objectAtIndex:indexPath.row] row:indexPath.row];
        //To customize the separatorLines
        UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cellReport.frame.size.height-1, self.reportContentTable.frame.size.width-1, 1)];
        separatorLine.backgroundColor = [UIColor lightGrayColor];
//        
//        [cellReport setSelectionStyle:UITableViewCellSelectionStyleNone];
//        
//        [cellReport.contentView addSubview:separatorLine];
        
        return cellReport;
    }
    else if (tableView == self.medicationTable){
        EconsultMedicationCell *cellMedication = (EconsultMedicationCell *)[tableView dequeueReusableCellWithIdentifier:@"medicationCell" forIndexPath:indexPath];
        EconsultMedicationResponseModel *model = self.medicationArray[indexPath.row];
        cellMedication.titleLbl.text = model.medicationDetails;
        cellMedication.titleLbl.numberOfLines = 5;
        [cellMedication.titleLbl sizeToFit];

        return cellMedication;
    }
    else if (tableView == self.suggestionContentTable)
    {
        static NSString *cellIdentifier = @"suggestCell";
        SmartRxSuggesstionCell *cellReport = (SmartRxSuggesstionCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cellReport.selectionStyle = UITableViewCellSelectionStyleNone;

        if ([self.arrayDoctorSuggestionFiles count])
        {
            cellReport.arrImages = self.arrayDoctorSuggestionFiles;
        }
        cellReport.delegateImg = self;
        [cellReport setCellData:[self.arrayDoctorSuggestionFiles objectAtIndex:indexPath.row] row:indexPath.row];
        //To customize the separatorLines
        UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cellReport.frame.size.height-1, self.suggestionContentTable.frame.size.width-1, 1)];
        separatorLine.backgroundColor = [UIColor lightGrayColor];
        
        [cellReport setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [cellReport addSubview:separatorLine];
        
        return cellReport;
    }
    else
    {
        static NSString *cellIdentifier = @"requestCell";
        
        SmartRxeConsultRequestCell *cellRequest = (SmartRxeConsultRequestCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cellRequest.selectionStyle = UITableViewCellSelectionStyleNone;

        UIView *separatorLine;
        if (cellRequest == nil)
        {
            cellRequest = [[SmartRxeConsultRequestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            separatorLine = [[UIView alloc] initWithFrame:CGRectZero];
            separatorLine.backgroundColor = [UIColor grayColor];
            separatorLine.tag = 100;
            [cellRequest.contentView addSubview:separatorLine];
        }
        separatorLine = (UIView *)[cellRequest.contentView viewWithTag:100];
        
        separatorLine.frame = CGRectMake(0, cellRequest.frame.size.height-1, cellRequest.frame.size.width, 1);
        
        [cellRequest setCellData:[self.arrayRequestData objectAtIndex:indexPath.row] row:indexPath.row];
        [cellRequest setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cellRequest;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    if (tableView == self.medicationTable) {
        [self.saveBtn setTitle:@"Update" forState:UIControlStateNormal];
        selectedMedication = self.medicationArray[indexPath.row];
        self.currentView = self.medicationViewEdit;
        [self updateMediactionViewDetails:selectedMedication];
        
    }
    //    [self performSegueWithIdentifier:@"eConsultDetails" sender:[self.arr_eConsult objectAtIndex:indexPath.row]];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat estHeight = 44.0;
    if (tableView == self.requestContentTable)
    {
        estHeight = 0.0;
        [self estimatedHeight:[[self.arrayRequestData objectAtIndex:indexPath.row] objectForKey:@"replyMsg"]];
        estHeight = estHeight+heightLbl;
        [self estimatedHeight:[[self.arrayRequestData objectAtIndex:indexPath.row] objectForKey:@"replyTime"]];
        if ([[[self.arrayRequestData objectAtIndex:indexPath.row] objectForKey:@"replyMsg"] length]>40)
            estHeight = estHeight+heightLbl+40;
        else
            estHeight = estHeight+heightLbl+30;
        
    }else if (tableView == self.medicationTable){
        EconsultMedicationResponseModel *model = self.medicationArray[indexPath.row];
        estHeight = [self estimatedMedicationHeight:model.medicationDetails];
    }
    return estHeight;
}

#pragma mark - Image Delegate
-(void)ShowImageInMainView:(NSString *)imagePath{
    [self imgaeZooming:imagePath];
}

-(void)openQlPreview:(NSString *)fileUrl{
    [self openFile:fileUrl];
}
#pragma mark - Qlpreview
-(void)openFile:(NSString *)strFilePath{
    [self addSpinnerView];
    [HUD show:YES];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%s/%@",kBaseUrlLabReport,strFilePath]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *fileComponents = [strFilePath componentsSeparatedByString:@"."];
        _pdfPath = [documentsDirectory stringByAppendingPathComponent:[@"file." stringByAppendingString:fileComponents[1]]];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [data writeToFile:_pdfPath atomically:YES];
        QLPreviewController *previewer = [[QLPreviewController alloc] init];
        [previewer setDataSource:self];
        [previewer setCurrentPreviewItemIndex:0];
        previewer.view.tintColor = [UIColor blueColor];
        
        [[self navigationController] presentViewController:previewer animated:YES completion:^{
            [HUD hide:YES];
            [HUD removeFromSuperview];
        }];
    }];
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:_pdfPath];
}

-(void)previewControllerWillDismiss:(QLPreviewController *)controller{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:_pdfPath error:&error];
    if (success) {
        NSLog(@"deleted file");
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
       if (![scrollView isKindOfClass:[UITableView class]] && [scrollView isPagingEnabled])
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = scrollView.contentOffset.x / pageWidth;
        
        [self.segmentedControl4 setSelectedSegmentIndex:page animated:YES];
    }
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
}

#pragma mark Request Methods

- (void)makeRequestToAddReports
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strSeccionName=[[NSUserDefaults standardUserDefaults]objectForKey:@"SessionName"];
    NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:sectionId,@"sessionid",[self.dictResponse objectForKey:@"conid"],@"econid",strSeccionName,@"session_name" ,@"1",@"apptype", nil];
    [self uploadImage:dictTemp];
}

- (void)makeRequestToAddRequest:(NSString *)requestText
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    if (requestText.length)
    {
        NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
        NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@&message=%@&apptype=1",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"],requestText];
        NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mereqadd"];
        [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
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
                    if ([[response objectForKey:@"addreq"] integerValue] == 1)
                    {
                        if ([self.arrayRequestData count] >= 2)
                            [self.requestContentTable setContentSize:CGSizeMake(self.requestContentTable.contentSize.width, self.requestContentTable.contentSize.height+ 50 - [self tableView:self.requestContentTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] + [self tableView:self.requestContentTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]/2)];
                        [self makeRequestForRequests];
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Error in updating Symptoms please enter again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                        [alert show];
                    }
                    
                });
            }
        } failureHandler:^(id response) {
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Error in updating Symptoms please enter again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            [HUD hide:YES];
            [HUD removeFromSuperview];
            
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Request message cannot be empty." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }
}

- (void)makeRequestToAddSymptoms:(NSString *)symptomText
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    if (symptomText.length)
    {
        NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
        NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@&symptoms=%@&apptype=1",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"],symptomText];
        NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mesubadd"];
        [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
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
                    if ([[response objectForKey:@"symptoms"] integerValue] == 1)
                    {
                        [self estimatedHeight:symptomText];
                        [self.symptomsContentLabel setPagingEnabled:NO];
                        self.symptomsContentLabel.text = symptomText;
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Error in updating Symptoms please enter again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                        [alert show];
                    }
                    
                });
            }
        } failureHandler:^(id response) {
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Error in updating Symptoms please enter again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            [HUD hide:YES];
            [HUD removeFromSuperview];
            
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Symptoms cannot be empty." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }
}
-(void)makeRequestForAddFamilyhistoryOrMedication:(NSString *)info{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"maddsosub"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:info method:@"POST" setHeader:NO successHandler:^(id response) {
        
        
        if (response != nil) {
            dispatch_async(dispatch_get_main_queue(),^{
                
                NSLog(@"success.....:%@",response);
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                if (self.currentView == self.familyViewEdit) {
                    self.familyContentLabel.text = self.updateTextView.text;
                    [self makeRequestForMedicationAndFamilyHistory];
                    
                } else  if (self.currentView == self.medicationViewEdit) {
                    self.drugNameTF.text = nil;
                    self.doseTF.text = nil;
                    self.quantityTF.text = nil;
                    self.mBtn.selected = NO;
                    mStr = @"0";
                    self.noBtn.selected = NO;
                    noStr = @"0";
                    self.eBtn.selected = NO;
                    eStr = @"0";
                    self.nBtn.selected = NO;
                    nStr = @"0";
                    foodTime = @"";
                    self.btnBF.selected = NO;
                    self.btnAF.selected = NO;
                    [self makeRequestForMedicationAndFamilyHistory];
                    //self.familyContentLabel.text = response[@"family_history"];
                }
            });
        }
        
    } failureHandler:^(id response) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading reports failed please load the screen again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
}
-(void)makeRequestForMedicationAndFamilyHistory{
    //EconsultMedicationResponseModel
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mgetsosub"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }else {
            dispatch_async(dispatch_get_main_queue(),^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                NSLog(@"resppnse.....:%@",response);
                NSString *familyStr = response[@"past_family_history"];
                if ([familyStr isKindOfClass:[NSString class]]) {
                    self.familyContentLabel.text = familyStr;
                }
                
                NSArray *medication = response[@"current_medication"];
                NSMutableArray *tempArr = [[NSMutableArray alloc]init];
                for (NSDictionary *dict in medication) {
                    EconsultMedicationResponseModel *model = [[EconsultMedicationResponseModel alloc]init];
                    
                    NSString *medicationStr = dict[@"drug_name"];
                    if (![dict[@"quantity"] isEqualToString:@"0"]) {
                        medicationStr = [medicationStr stringByAppendingString:[NSString stringWithFormat:@" / quantity : %@ ",dict[@"quantity"]]];
                        
                        
                    }
                    else {
                        medicationStr = [medicationStr stringByAppendingString:[NSString stringWithFormat:@" / quantity : 0 "]];
                        
                    }
                    medicationStr = [medicationStr stringByAppendingString:[NSString stringWithFormat:@" / consumption : (%@-%@-%@-%@)",dict[@"morning"],dict[@"afternoon"],dict[@"evening"],dict[@"night"]]];
                    
                    if (![dict[@"drug_dose"] isEqualToString:@""]) {
                        medicationStr = [medicationStr stringByAppendingString:[NSString stringWithFormat:@" / dose : %@ ",dict[@"drug_dose"]]];
                        
                    }
                    
                    if ([dict[@"consumption_time"] integerValue] != 0) {
                        medicationStr = [medicationStr stringByAppendingString:[NSString stringWithFormat:@" / time : %@",[self getConsumptionTime:dict[@"consumption_time"]]]];
                    }
                    NSLog(@"medication str .....:%@",medicationStr);
                    NSLog(@"medication date .....:%@",[self dateConvertor:dict[@"created"]]);
                    
                    model.medicationDetails = medicationStr;
                    model.date = [self dateConvertor:dict[@"created"]];
                    model.drugName = dict[@"drug_name"];
                    model.quantity = dict[@"quantity"];
                    model.dose = dict[@"drug_dose"];
                    model.morning = dict[@"morning"];
                    model.afternoon = dict[@"afternoon"];
                    model.evening = dict[@"evening"];
                    model.night = dict[@"night"];
                    model.medicationId = dict[@"recno"];
                    [tempArr addObject:model];
                }
                self.medicationArray = [tempArr copy];
                [self.medicationTable reloadData];
                
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading medication failed please load the screen again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
    
}
-(NSString *)getConsumptionTime:(NSString *)consumptionTime{
    NSString *tempStr = @"";
    if ([consumptionTime integerValue] == 1) {
        tempStr = @"BF";
    }else  if ([consumptionTime integerValue] == 2) {
        tempStr = @"AF";
    }
    return tempStr;
}
-(NSString *)dateConvertor:(NSString *)dateStr{
    
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    //[format setTimeZone:gmt];
    //[format setDateFormat:@"yyyy-MM-dd'T'HH:mm:SS"];
    [format setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *date = [format dateFromString:dateStr];
    NSLog(@"date.....:%@",date);
    [format setDateFormat:@"dd MMM yyyy"];
    NSString *str = [format stringFromDate:date];
    return str;
    
}
- (void)makeRequestForReports
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"meflist"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"response......:%@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else
        {
            [[SmartRxDB sharedDBManager] saveEconReport:response conid:[[self.dictResponse objectForKey:@"conid"] integerValue] type:@"econsult"];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                [self processReportResponse:response];
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading reports failed please load the screen again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}

- (void)processReportResponse:(NSDictionary *)response
{
   // self.arrayDoctorSuggestionFiles = [response objectForKey:@"dfiles"];
    
    NSArray *tempAarray = [response objectForKey:@"dfiles"];
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in tempAarray) {
        NSArray *imagesArr = [dict[@"content_images"] componentsSeparatedByString:@","];
        if (imagesArr.count>1) {
            for (NSString *imageStr in imagesArr) {
                NSDictionary *dic= [NSDictionary dictionaryWithObjectsAndKeys:imageStr,@"content_images", nil];
                [tempArr addObject:dic];
            }
            
        }else {
            NSDictionary *dic= [NSDictionary dictionaryWithObjectsAndKeys:dict[@"content_images"],@"content_images", nil];
            [tempArr addObject:dic];
        }
    }
    self.arrayDoctorSuggestionFiles = [tempArr copy];
    self.arrayReportFiles = [response objectForKey:@"efiles"];
    if ([self.arrayDoctorSuggestionFiles count])
    {
        if (![sectionTitlesArray containsObject:@"Doctor Suggestion"])
        {
            [sectionTitlesArray addObject:@"Doctor Suggestion"];
            self.suggestionViewEdit.frame = CGRectMake(self.suggestionViewEdit.frame.origin.x, self.suggestionViewEdit.frame.origin.y, self.suggestionViewEdit.frame.size.width, heightLbl+40);
            self.suggestionContentLabel.frame = CGRectMake(self.suggestionContentLabel.frame.origin.x, self.suggestionContentLabel.frame.origin.y, self.suggestionContentLabel.frame.size.width, heightLbl);
            int heightneeded = self.segmentView.frame.size.height - (self.suggestionContentLabel.frame.origin.y + heightLbl);
            self.suggestionContentTable.frame = CGRectMake(0, self.suggestionContentLabel.frame.origin.y + heightLbl + 10, viewWidth, heightneeded-57);
            [self makeSegmentView];
        }
    }
    if ([self.arrayReportFiles count])
    {
        repLabel.hidden = YES;
        self.reportContentTable.hidden = NO;
        [self.reportContentTable reloadData];
        CGFloat tableHeight = 0.0f;
        for (int i = 0; i < [self.arrayReportFiles count]; i ++) {
            tableHeight += [self tableView:self.reportContentTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        self.reportContentTable.frame = CGRectMake(self.reportContentTable.frame.origin.x, self.reportContentTable.frame.origin.y, self.reportContentTable.frame.size.width, tableHeight+5);
        if (tableHeight > self.reportViewEdit.frame.size.height)
        {
            self.reportViewEdit.frame = CGRectMake(self.reportViewEdit.frame.origin.x, self.reportViewEdit.frame.origin.y, self.reportViewEdit.frame.size.width , self.reportViewEdit.frame.size.height+tableHeight);
        }
        [self.reportScroll setContentSize:CGSizeMake(self.scrollView.frame.size.width, tableHeight+300)];
        //                    self.reportViewEdit.frame = CGRectMake(self.reportViewEdit.frame.origin.x, self.reportViewEdit.frame.origin.y, self.reportViewEdit.frame.size.width, self.reportViewEdit.frame.size.height+tableHeight);
    }
    else
    {
        repLabel = [[UILabel alloc] init];
        repLabel.frame = CGRectMake(self.reportContentTable.frame.origin.x, self.reportContentTable.frame.origin.y, self.reportContentTable.frame.size.width, 30);
        repLabel.text = @"No files added";
        repLabel.hidden = NO;
        repLabel.font = [UIFont systemFontOfSize:15];
        [self.reportViewEdit addSubview:repLabel];
        self.reportViewEdit.frame = CGRectMake(self.reportViewEdit.frame.origin.x, self.reportViewEdit.frame.origin.y, self.reportViewEdit.frame.size.width, repLabel.frame.size.height+40);
        
        self.reportContentTable.hidden = YES;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.arrayDoctorSuggestionFiles count])
        {
            if ([self.suggestionContentLabel.text isEqualToString:@"No suggestions added"] || [self.dictResponse objectForKey:@"suggestion"]  == [NSNull null] || [self.dictResponse objectForKey:@"suggestion"] == nil || [[self.dictResponse objectForKey:@"suggestion"] length] == 0)
                self.suggestionContentLabel.hidden = YES;
            else
                self.suggestionContentLabel.hidden = NO;
            self.suggestionContentTable.hidden = NO;
            [self.suggestionContentTable setTableFooterView:[UIView new]];
            [self.suggestionContentTable reloadData];
            self.suggestionViewEdit.frame = CGRectMake(self.suggestionViewEdit.frame.origin.x, self.suggestionViewEdit.frame.origin.y, self.suggestionViewEdit.frame.size.width, self.suggestionViewEdit.frame.size.height + self.suggestionContentTable.frame.size.height+40);
            [self estimatedHeight:self.suggestionContentLabel.text];
            CGFloat tableHeight = 0.0f;
            for (int i = 0; i < [self.arrayDoctorSuggestionFiles count]; i ++) {
                tableHeight += [self tableView:self.suggestionContentTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            if ([self.suggestionContentLabel isHidden])
                self.suggestionContentTable.frame = CGRectMake(self.suggestionContentTable.frame.origin.x, self.suggestionContentLabel.frame.origin.y, self.suggestionContentTable.frame.size.width, tableHeight);
            else
                self.suggestionContentTable.frame = CGRectMake(self.suggestionContentTable.frame.origin.x, self.suggestionContentTable.frame.origin.y, self.suggestionContentTable.frame.size.width, tableHeight);
            
            //                            self.suggestionContentTable.contentSize = CGSizeMake(self.suggestionContentTable.contentSize.width, 30*[self.arrayDoctorSuggestionFiles count]);
            if (tableHeight > self.suggestionViewEdit.frame.size.height)
            {
                self.suggestionViewEdit.frame = CGRectMake(self.suggestionViewEdit.frame.origin.x, self.suggestionViewEdit.frame.origin.y, self.suggestionViewEdit.frame.size.width , self.suggestionViewEdit.frame.size.height+heightLbl+tableHeight);
            }
            [self.suggestionScroll setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.suggestionContentLabel.frame.origin.y+self.suggestionContentLabel.frame.size.height+tableHeight+200)];
            NSLog(@"suggestion tableheight.....:%@",self.suggestionContentTable);
            NSLog(@"suggestion view.....:%@",self.suggestionViewEdit);


            //                        [self.suggestionScroll setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.suggestionScroll.frame.size.height+tableHeight)];
        }
        else
        {
            if ([self.suggestionContentLabel.text length] == 0 || self.suggestionContentLabel.text == nil)
                self.suggestionContentLabel.text = @"No suggestions added";
            
            self.suggestionContentTable.hidden = YES;
        }
        
    });
}
- (void)makeRequestForRequests
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mereqlist"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"The request texts : %@", response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            [[SmartRxDB sharedDBManager] saveEconRequest:response conid:[[self.dictResponse objectForKey:@"conid"] integerValue] type:@"econsult"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                [self processRequestData:response];
            });
        }
    } failureHandler:^(id response) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading request failed please load the screen again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}

-(void)processRequestData:(NSDictionary *)response
{
    self.arrayData = [response objectForKey:@"ecrequest"];
    if ([self.arrayData count])
    {
        self.arrayRequestData = [[NSMutableArray alloc] init];
        int k=0;
        for (int i=0; i<[self.arrayData count]/3; i++)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[self.arrayData objectAtIndex:k] forKey:@"replyMsg"];
            k++;
            
            NSString *str = [NSString stringWithFormat:@"%@\nBy %@", [self.arrayData objectAtIndex:k+1], [self.arrayData objectAtIndex:k]];
            [dict setObject:str forKey:@"replyTime"];
            k += 2;
            [self.arrayRequestData addObject:dict];
        }
        reqLabel.hidden = YES;
        self.requestContentTable.hidden = NO;
       
        [self.requestContentTable reloadData];
        //                    self.requestContentTable.frame = CGRectMake(0, self.requestContentTable.frame.origin.y, viewWidth, self.requestContentTable.frame.size.height-57);
        [self.requestContentTable setContentSize:CGSizeMake(self.requestContentTable.contentSize.width, self.requestContentTable.contentSize.height + [self tableView:self.requestContentTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] + [self tableView:self.requestContentTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]/2)];
        self.requestViewEdit.frame = CGRectMake(self.requestViewEdit.frame.origin.x, self.requestViewEdit.frame.origin.y, self.requestViewEdit.frame.size.width, self.requestContentTable.frame.size.height+40);
        
    }
    else
    {
        reqLabel = [[UILabel alloc] init];
        reqLabel.frame = CGRectMake(self.requestContentTable.frame.origin.x, self.requestContentTable.frame.origin.y, self.requestContentTable.frame.size.width, 30);
        reqLabel.font = [UIFont systemFontOfSize:15];
        reqLabel.text = @"No requests sent";
        reqLabel.hidden = NO;
        [self.requestViewEdit addSubview:reqLabel];
        self.requestViewEdit.frame = CGRectMake(self.requestViewEdit.frame.origin.x, self.requestViewEdit.frame.origin.y, self.requestViewEdit.frame.size.width, reqLabel.frame.size.height+40);
        
        self.requestContentTable.hidden = YES;
    }
    
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - Menu Methods
- (void)showUpdateView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.updateView.frame=CGRectMake(0,  self.updateView.frame.origin.y,  self.updateView.frame.size.width,  self.updateView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}
-(void)hideUpdateView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.updateView.frame=CGRectMake(viewSize.width,  self.updateView.frame.origin.y,  self.updateView.frame.size.width,  self.updateView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}
- (void)showMedicationUpdateView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.updateMedicationView.frame=CGRectMake(0,  self.updateMedicationView.frame.origin.y,  self.updateMedicationView.frame.size.width,  self.updateMedicationView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}
-(void)hideUpdateMedicationView{
    [UIView animateWithDuration:0.2 animations:^{
        self.updateMedicationView.frame=CGRectMake(viewSize.width,  self.updateMedicationView.frame.origin.y,  self.updateMedicationView.frame.size.width,  self.updateMedicationView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

-(void)updateMediactionViewDetails:(EconsultMedicationResponseModel *)model{
    self.drugNameTF.text  = model.drugName;
    if (![model.quantity isEqualToString:@"0"]) {
        self.quantityTF.text = model.quantity;
        
    }
    if (![model.dose isEqualToString:@""]) {
        self.doseTF.text = model.dose;
    }
    if (![model.morning isEqualToString:@"0"]) {
        mStr = @"1";
        self.mBtn.selected = YES;
    }
    
    if (![model.afternoon isEqualToString:@"0"]) {
        noStr = @"1";
        self.noBtn.selected = YES;
    } if (![model.evening isEqualToString:@"0"]) {
        eStr = @"1";
        self.eBtn.selected = YES;
    } if (![model.night isEqualToString:@"0"]) {
        nStr = @"1";
        self.nBtn.selected = YES;
    }
    [self showMedicationUpdateView];

    
}
#pragma mark - Textfield Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [textField resignFirstResponder];
    
    //return NO or YES, it doesn't matter
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.updateTextView)
    {
        if ([textView.text isEqualToString:@"No suggestions added"])
            self.updateTextView.text = nil;
    }
    self.updateLbl.hidden=YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text length] <=0)
    {
        self.updateLbl.hidden=NO;
    }
    
}
- (void)textViewDidChange:(UITextView *)textView {
    
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}

- (void)doneButton:(id)sender {
    [self.quantityTF resignFirstResponder];
    [self.doseTF resignFirstResponder];
    [self.updateTextView resignFirstResponder];
}
#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.imgViwPhoto.image=info[UIImagePickerControllerEditedImage];
    [self compression:info[UIImagePickerControllerEditedImage]];
    [self makeRequestToAddReports];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
-(void)imageSelected:(UIImage *)image{
       // self.imgViwPhoto.image=image;
    [self compression:image];
    [self makeRequestToAddReports];
}

#pragma mark - Image methods
-(void) uploadImage:(NSDictionary *)info
{
    
    CGSize newSize = CGSizeMake(320.0f, 480.0f);
    UIGraphicsBeginImageContext(newSize);
    [self.imgViwPhoto.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage;
    if (self.imgViwPhoto.image != nil)
    {
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    
    UIGraphicsEndImageContext();
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@kBaseUrl]];
    UIImage *image =newImage; //self.imgViwPhoto.image;//[info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *strUrl=[NSString stringWithFormat:@"%s/meconaddfile",kBaseUrl];
    
    AFHTTPRequestOperation *op = [manager POST:strUrl parameters:info constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        
        if ([imageData length] > 0)
        {
            int r = arc4random_uniform(999999999);
            [formData appendPartWithFileData:imageData name:@"patientfile[]" fileName:[NSString stringWithFormat:@"%d.JPG",r] mimeType:@"image/JPG"];
        }
        [manager.requestSerializer setTimeoutInterval:30.0];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        if ([[responseObject objectForKey:@"authorized"]integerValue] == 0 && [[responseObject objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.view.userInteractionEnabled = YES;
                [self makeRequestForReports];
                
            });
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [op start];
}
-(void)compression:(UIImage *)image
{
    //compression of image
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.01f;
    int maxFileSize = 250*1024;
    NSData *imageData = UIImageJPEGRepresentation(image,compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 10.9;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    //display image
    UIImage *img = [UIImage imageWithData:imageData];
    [self.imgViwPhoto setImage:[UIImage imageWithData:imageData]];
    
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
