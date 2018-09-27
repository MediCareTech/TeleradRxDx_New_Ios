//
//  SmartRxeConsultDetailsVC.m
//  SmartRx
//
//  Created by Anil Kumar on 19/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import "SmartRxeConsultDetailsVC.h"
#import "NSString+DateConvertion.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxeConsultReportCell.h"
#import "SmartRxeConsultRequestCell.h"
#import "UIKit+AFNetworking.h"
#import "AFNetworking.h"
#import <QuickLook/QuickLook.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SmartRxReportImageVC.h"
//#import "SmartRxVideoConference.h"
#import "SmartRxSuggesstionCell.h"
#import "EconsultMedicationCell.h"
#import "EconsultMedicationResponseModel.h"

@import Firebase;


#define fExpied_Token      @"expired_token"

#define kLessThan4Inch 560

NSString *kApiKey = @"45095882";
NSString *kSessionId = @"";
// Replace with your generated token
NSString *kToken = @"";
BOOL streamCreatedFlag;
#define APP_IN_FULL_SCREEN @"appInFullScreenMode"
#define PUBLISHER_BAR_HEIGHT 50.0f
#define SUBSCRIBER_BAR_HEIGHT 44.0f
#define ARCHIVE_BAR_HEIGHT 35.0f
#define PUBLISHER_ARCHIVE_CONTAINER_HEIGHT 85.0f
#define PUBLISHER_PREVIEW_HEIGHT 87.0f
#define PUBLISHER_PREVIEW_WIDTH 113.0f
#define OVERLAY_HIDE_TIME 7.0f

#define fInvalid_Client    @"invalid_client"
#define fExpied_Token      @"expired_token"
#define fInvalid_Token     @"invalid_token"
#define fInvalid_Request   @"invalid_request"
#define FitbitNotification @"FitbitAthozired"

@interface SmartRxeConsultDetailsVC ()<ShowImageInMainView, QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    MBProgressHUD *HUD;
    BOOL pdfSuccess;
    BOOL sessionDidConnect, imageBeingShowed;
    CGFloat viewWidth, viewHeight;
    CGFloat heightLbl;
    CGSize viewSize;
    CGFloat height;
    UILabel *repLabel;
    UILabel *reqLabel;
    NSString *token;
    NSMutableArray *sectionTitlesArray;
    OTStream *streamReceived;
    UILocalNotification *notification;
    AVAudioPlayer *audioPlayer;
    UIAlertView *incomingAlert, *endAlert;
    NSString *mStr,*noStr,*eStr,*nStr,*foodTime;
    EconsultMedicationResponseModel *selectedMedication;
   
}
@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation SmartRxeConsultDetailsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"frame.....:%@",self.medicationViewEdit);
    sessionDidConnect = NO;
    imageBeingShowed = NO;
    self.heartBeatView.hidden = YES;
    foodTime = @"";
    nStr = @"0";
    mStr = @"0";
    noStr = @"0";
    eStr = @"0";

    self.connectBtn.tag = 10;
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"InEconsult"];
    [self navigationBackButton];
    
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    sectionTitlesArray = [[NSMutableArray alloc] init];
    sectionTitlesArray = [@[@"Reports",@"Patient Notes/Symptoms", @"Requests"] mutableCopy];

    viewSize=[[UIScreen mainScreen]bounds].size;
    viewWidth = CGRectGetWidth(self.view.frame);
    viewHeight = CGRectGetHeight(self.view.frame);
    self.suggestionScroll.pagingEnabled = NO;
    self.symptomsContentLabel.editable = NO;
    self.reportScroll.pagingEnabled = NO;
    streamCreatedFlag = NO;
    self.videoConsultView.hidden = YES;
    streamReceived = nil;
    self.connectBtn.layer.cornerRadius = 10; // this value vary as per your desire
    self.connectBtn.clipsToBounds = YES;
    // initialize constants
    allStreams = [[NSMutableDictionary alloc] init];
    allSubscribers = [[NSMutableDictionary alloc] init];
    allConnectionsIds = [[NSMutableArray alloc] init];
    backgroundConnectedStreams = [[NSMutableArray alloc] init];
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
    
    self.onlineStatusImage.image = [UIImage imageNamed:@"offline.png"];
//    self.connectBtn.hidden = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForReports];
        [self makeRequestForRequests];
        if (self.scheduleType != nil) {
        [self makeRequestForMedicationAndFamilyHistory];
        }
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
        self.phoneOrVideoImg.image = [UIImage imageNamed:@"icn_phone.png"];
        //video_call.png
    }
    self.updateTextView.layer.cornerRadius=5.0f;
    self.updateTextView.layer.masksToBounds = YES;
    self.updateTextView.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.updateTextView.layer.borderWidth= 0.5f;
    
    if([self.dictResponse objectForKey:@"dispname"] != [NSNull null] && [self.dictResponse objectForKey:@"dispname"] && [[self.dictResponse objectForKey:@"dispname"] length] > 0 )
        self.docName.text=[self.dictResponse objectForKey:@"dispname"];
    
    NSString *strDatTime=[NSString stringWithFormat:@"%@ %@",[self.dictResponse objectForKey:@"appdate"],[self.dictResponse objectForKey:@"apptime"]];
    self.eConsultDateTime.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
    if ([[self.dictResponse objectForKey:@"status"] integerValue] == 1)
    {
        self.statusLbl.text = @"Pending";
        self.statusLbl.textColor = [UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1];
        self.eConsultStatusImage.image = [UIImage imageNamed:@"econsult_pending.png"];
        self.connectBtn.hidden = YES;
    }
    else if ([[self.dictResponse objectForKey:@"status"] integerValue] == 2)
    {
        self.statusLbl.text = @"Confirmed";
        self.statusLbl.textColor = [UIColor colorWithRed:0.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1];
        self.eConsultStatusImage.image = [UIImage imageNamed:@"econsult_booked.png"];
        if ([[self.dictResponse objectForKey:@"app_method"] integerValue] == 2)
            self.connectBtn.hidden = YES;
        else
            self.connectBtn.hidden = NO;
    }
    else if ([[self.dictResponse objectForKey:@"status"] integerValue] == 3)
    {
        self.statusLbl.text = @"Completed";
        self.statusLbl.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:153.0/255.0 alpha:1];
        self.eConsultStatusImage.image = [UIImage imageNamed:@"econsult_completed.png"];
        self.connectBtn.hidden = YES;
    }
    else if ([[self.dictResponse objectForKey:@"status"] integerValue] == 4)
    {
        self.statusLbl.text = @"Cancelled";
        self.statusLbl.textColor = [UIColor redColor];
        self.eConsultStatusImage.image = [UIImage imageNamed:@"econsult_completed.png"];
        self.connectBtn.hidden = YES;
    }
    else if ([[self.dictResponse objectForKey:@"status"] integerValue] == 5)
    {
        self.statusLbl.text = @"Payment requested";
        self.statusLbl.textColor = [UIColor redColor];
        self.eConsultStatusImage.image = [UIImage imageNamed:@"econsult_completed.png"];
        self.connectBtn.hidden = YES;
    }
    
    if (self.scheduleType != nil) {
        [sectionTitlesArray addObject:@"Past / Family History"];
        [sectionTitlesArray addObject:@"Current Medications"];
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
            self.suggestionViewEdit.frame = CGRectMake(self.suggestionViewEdit.frame.origin.x, self.suggestionViewEdit.frame.origin.y, self.suggestionViewEdit.frame.size.width , self.suggestionViewEdit.frame.size.height+heightLbl);
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
    
    
  
    
    [self.symptomsViewEdit addSubview:self.symptomsContentLabel];
    [self.scrollView addSubview:self.symptomsViewEdit];
    [self numberKeyBoardReturn];
    [self makeSegmentView];
    if ([[self.dictResponse objectForKey:@"status"] integerValue] == 2 && [[self.dictResponse objectForKey:@"app_method"] integerValue] == 1)
        [self makeRequestToGetToken];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"fitbitAccess"]) {
        NSLog(@"fitbitAccess");
        NSURL  *url = [[NSBundle mainBundle] URLForResource:@"hbeat" withExtension:@"gif"];
        FLAnimatedImage *heartImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
        self.heartBeatImageView.animatedImage = heartImage;
        //[self makeRequetForRevokeFitbitToken];
        [self makeRequestForFitbitData];
    }else {
        self.heartBeatView.hidden = YES;
    }

    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"View appearing");
    imageBeingShowed = NO;
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!imageBeingShowed)
    {
        UIButton *btn = [[UIButton alloc]init];
        btn.tag = 3080;
        //    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self endCallAction:btn];
        //    }
    }
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
    [self.scrollView addSubview:self.requestViewEdit];
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
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
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
-(void)homeBtnClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"InEconsult"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultPush"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultVideoPush"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
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
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"InEconsult"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultPush"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultVideoPush"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if ([self.arrayReportFiles count])
        {
            cellReport.arrImages = self.arrayReportFiles;
        }
        cellReport.delegateImg = self;
        [cellReport setCellData:[self.arrayReportFiles objectAtIndex:indexPath.row] row:indexPath.row];
        //To customize the separatorLines
        UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cellReport.frame.size.height-1, self.reportContentTable.frame.size.width-1, 1)];
        separatorLine.backgroundColor = [UIColor lightGrayColor];
        cellReport.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cellReport;
    }
    else if (tableView == self.medicationTable){
        EconsultMedicationCell *cellMedication = (EconsultMedicationCell *)[tableView dequeueReusableCellWithIdentifier:@"medicationCell" forIndexPath:indexPath];
        EconsultMedicationResponseModel *model = self.medicationArray[indexPath.row];
        cellMedication.titleLbl.text = model.medicationDetails;
        
        cellMedication.titleLbl.numberOfLines = 5;
        //[cellMedication.textLabel sizeToFit];
        
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    CGFloat estHeight = 35.0;
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
        
    } else if (tableView == self.medicationTable){
        EconsultMedicationResponseModel *model = self.medicationArray[indexPath.row];
        estHeight = [self estimatedMedicationHeight:model.medicationDetails];
    }
    return estHeight;
}

#pragma mark - AlertView Delegate Methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1200)
    {
        [audioPlayer stop];
        if (buttonIndex == 0)
        {
            [self connectBtnClicked:nil];
        }
    }
    if (alertView.tag == 1400 && buttonIndex == 1)
    {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultPush"];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultVideoPush"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        self.onlineStatusImage.image = [UIImage imageNamed:@"offline.png"];
//        self.connectBtn.hidden = YES;
        [self hideVideoView];
        if (_session && _session.sessionConnectionStatus ==
            OTSessionConnectionStatusConnected)
        {
            // disconnect session
            NSLog(@"disconnecting....");
            [_session disconnect:nil];
            _session = nil;
            //        return;
        }
        //    else
        //    {
        //all other cases just go back to home screen.
        if([self.navigationController.viewControllers indexOfObject:self] !=
           NSNotFound)
        {
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"InEconsult"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        //    }
    }
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
          dispatch_async(dispatch_get_main_queue(),^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *fileComponents = [strFilePath componentsSeparatedByString:@"."];
        _pdfPath = [documentsDirectory stringByAppendingPathComponent:[@"file." stringByAppendingString:fileComponents[1]]];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [data writeToFile:_pdfPath atomically:YES];
        BOOL success = [QLPreviewController canPreviewItem:[NSURL URLWithString:_pdfPath]];
        if (success) {
            QLPreviewController *previewer = [[QLPreviewController alloc] init];
            [previewer setDataSource:self];
            [previewer setCurrentPreviewItemIndex:0];
            [[self navigationController] presentViewController:previewer animated:YES completion:^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
            }];
        } else {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            pdfSuccess = NO;
            [self imgaeZooming:strFilePath];
        }
        });

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
    if (scrollView == self.videoContainerView)
    {
        int currentPage = (int)(self.videoContainerView.contentOffset.x /
                                self.videoContainerView.frame.size.width);
        
        if (currentPage < [allConnectionsIds count]) {
            // show current scrolled subscriber
            NSString *connectionId = [allConnectionsIds objectAtIndex:currentPage];
            NSLog(@"show as current subscriber %@",connectionId);
            [self showAsCurrentSubscriber:[allSubscribers
                                           objectForKey:connectionId]];
        }
        [self resetArrowsStates];
    }
    if (![scrollView isKindOfClass:[UITableView class]] && [scrollView isPagingEnabled])
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = scrollView.contentOffset.x / pageWidth;
        
        [self.segmentedControl4 setSelectedSegmentIndex:page animated:YES];
    }
}

#pragma mark -Prepare Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"zoomImageID"])
    {
        if (pdfSuccess) {
            ((SmartRxReportImageVC *)segue.destinationViewController).strImage = sender;
        } else {
            ((SmartRxReportImageVC *)segue.destinationViewController).webUrl = sender;
        }
    }
    if ([segue.identifier isEqualToString:@"openTok"])
    {
        //        ((SmartRxVideoConference *)segue.destinationViewController).token = token;
        //        ((SmartRxVideoConference *)segue.destinationViewController).sessionId = [self.dictResponse objectForKey:@"vsession"];
    }
}


#pragma mark - Action Methods
-(IBAction)clickOnRefreshButton:(id)sender{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    [self makeRequestForFitbitData];
}
-(void) showVideoView
{
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0)
            if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]])
                [(UIAlertView *)[subviews objectAtIndex:0] dismissWithClickedButtonIndex:[(UIAlertView *)[subviews objectAtIndex:0] cancelButtonIndex] animated:NO];
    }
    [HUD hide:YES];
    [HUD removeFromSuperview];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [UIView animateWithDuration:0.2 animations:^{
        self.videoConsultView.frame=CGRectMake(self.videoConsultView.frame.origin.x, 0 ,  self.videoConsultView.frame.size.width,  self.videoConsultView.frame.size.height);
    } completion:^(BOOL finished) {
        self.videoConsultView.hidden = NO;
    }];
}
-(void) hideVideoView
{
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIView animateWithDuration:0.2 animations:^{
        self.videoConsultView.frame=CGRectMake(self.videoConsultView.frame.origin.x, viewSize.height,  self.videoConsultView.frame.size.width,  self.videoConsultView.frame.size.height);
    } completion:^(BOOL finished) {
        self.videoConsultView.hidden = YES;
    }];
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
    [self performSegueWithIdentifier:@"zoomImageID" sender:sender];
}
- (IBAction)videoPauseBtnClicked:(id)sender
{
    [self hideVideoView];
    self.connectBtn.userInteractionEnabled = YES;
    [self.connectBtn setTitle:@"Resume" forState:UIControlStateNormal];
}

- (IBAction)connectBtnClicked:(id)sender
{
    self.connectBtn.userInteractionEnabled = NO;
    self.connectBtn.tag = 9696;
    if (!sessionDidConnect && !_session)
        [self setupSession];
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultVideoPush"] == YES)
    {
        [self makeRequestToPushEconsultNotification];
    }
    if ([self.connectBtn.currentTitle isEqualToString:@"Resume"])
    {
        [self.connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
        [self showVideoView];
    }
    else
    {
        NSLog(@"INTO ELSE");
        if (![HUD isHidden]) {
            [HUD hide:YES];
        }
        [self addSpinnerView];
        // [self performSegueWithIdentifier:@"openTok" sender:sender];
        [self.view sendSubviewToBack:self.videoContainerView];
        self.endCallButton.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.endCallButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        // Default no full screen
        [self.topOverlayView.layer setValue:[NSNumber numberWithBool:NO]
                                     forKey:APP_IN_FULL_SCREEN];
        self.audioPubUnpubButton.autoresizingMask  =
        UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        
        
        // Add right side border to camera toggle button
        CALayer *rightBorder = [CALayer layer];
        rightBorder.borderColor = [UIColor whiteColor].CGColor;
        rightBorder.borderWidth = 1;
        rightBorder.frame =
        CGRectMake(-1,
                   -1,
                   CGRectGetWidth(self.cameraToggleButton.frame),
                   CGRectGetHeight(self.cameraToggleButton.frame) + 2);
        self.cameraToggleButton.clipsToBounds = YES;
        [self.cameraToggleButton.layer addSublayer:rightBorder];
        
        // Left side border to audio publish/unpublish button
        CALayer *leftBorder = [CALayer layer];
        leftBorder.borderColor = [UIColor whiteColor].CGColor;
        leftBorder.borderWidth = 1;
        leftBorder.frame =
        CGRectMake(-1,
                   -1,
                   CGRectGetWidth(self.audioPubUnpubButton.frame) + 5,
                   CGRectGetHeight(self.audioPubUnpubButton.frame) + 2);
        [self.audioPubUnpubButton.layer addSublayer:leftBorder];
        
        // configure video container view
        self.videoContainerView.scrollEnabled = YES;
        self.videoContainerView.pagingEnabled = YES;
        self.videoContainerView.delegate = self;
        self.videoContainerView.showsHorizontalScrollIndicator = NO;
        self.videoContainerView.showsVerticalScrollIndicator = YES;
        self.videoContainerView.bounces = NO;
        self.videoContainerView.alwaysBounceHorizontal = NO;
        
        // set up look of the page
        //    [self.navigationController setNavigationBarHidden:NO];
        
        self.navigationItem.hidesBackButton = YES;
        
        // listen to taps around the screen, and hide/show overlay views
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(viewTapped:)];
        tgr.delegate = self;
        tgr.cancelsTouchesInView = NO;
        [self.videoConsultView addGestureRecognizer:tgr];
        
        UITapGestureRecognizer *leftArrowTapGesture = [[UITapGestureRecognizer alloc]
                                                       initWithTarget:self
                                                       action:@selector(handleArrowTap:)];
        leftArrowTapGesture.delegate = self;
        leftArrowTapGesture.cancelsTouchesInView = NO;
        [self.leftArrowImgView addGestureRecognizer:leftArrowTapGesture];
        
        UITapGestureRecognizer *rightArrowTapGesture = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(handleArrowTap:)];
        rightArrowTapGesture.delegate = self;
        
        rightArrowTapGesture.cancelsTouchesInView = NO;
        
        [self.rightArrowImgView addGestureRecognizer:rightArrowTapGesture];
        
        [self resetArrowsStates];
        
        self.archiveOverlay.hidden = YES;
        
        self.title = self.rid;
        
        [self.endCallButton sendActionsForControlEvents:UIControlEventTouchDown];
        
        // application background/foreground monitoring for publish/subscribe video
        // toggling
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(enteringBackgroundMode:)
         name:UIApplicationWillResignActiveNotification
         object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(leavingBackgroundMode:)
         name:UIApplicationDidBecomeActiveNotification
         object:nil];
        
        [self showVideoView];
        if (streamReceived)
            [self createSubscriber:streamReceived];
        if (sessionDidConnect && _session)
            [self setupPublisher];
    }
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
    
    if (self.drugNameTF.text.length < 1) {
        [self customAlertView:@"" Message:@"Drug name is required." tag:0];
    }
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@&drug_name=%@&drug_dose=%@&quantity=%@&morning=%@&afternoon=%@&night=%@&evening=%@&consumption_time=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"],self.drugNameTF.text,self.doseTF.text,self.quantityTF.text,mStr,noStr,nStr,eStr,foodTime];
    if ([self.saveBtn.titleLabel.text isEqualToString:@"Update"]) {
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&medid=%@",selectedMedication.medicationId]];
    }
    NSLog(@"body text.....:%@",bodyText);
    [self makeRequestForAddFamilyhistoryOrMedication:bodyText];
    [self hideUpdateMedicationView];
    
}
- (IBAction)cancelBtnClicked:(id)sender
{
    [self.view endEditing:YES];

    [self hideUpdateView];
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
    } else if (self.currentView == self.familyViewEdit)
    {
        NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];

        NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@&family_history=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"],self.updateTextView.text];

        [self makeRequestForAddFamilyhistoryOrMedication:bodyText];
        [self hideUpdateView];
    }
}

- (IBAction)symptomsEditClicked:(id)sender
{
    self.currentView = self.symptomsViewEdit;
    [self.updateBtn setTitle:@"Update" forState:UIControlStateNormal];
    self.updateViewTitle.text = @"Symptoms / Notes";
    self.updateLbl.hidden = YES;
    if (![self.symptomsContentLabel.text isEqualToString:@"No symptoms added"])
        self.updateTextView.text = self.symptomsContentLabel.text;
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
-(IBAction)clickOnPastFamilyBtn:(id)sender{
    self.currentView = self.familyViewEdit;
    self.updateTextView.text = nil;
    [self.updateBtn setTitle:@"Update" forState:UIControlStateNormal];
    self.updateViewTitle.text = @"Past Family History";
    self.updateLbl.text = @"Type the past family history";
    self.updateLbl.hidden = YES;
    if (![self.familyContentLabel.text isEqualToString:@"No symptoms added"])
        self.updateTextView.text = self.familyContentLabel.text;
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
//#pragma mark UIAlertView Delegate
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (buttonIndex == 0)
//    {
//        UITextField * alertTextField = [alertView textFieldAtIndex:0];
//        NSLog(@"alerttextfiled - %@",alertTextField.text);
//        if (self.currentBtn == self.symptomsBtn)
//        {
//            [self makeRequestToAddSymptoms:alertTextField.text];
//        }
//    }
//    // do whatever you want to do with this UITextField.
//}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
}
#pragma mark  - Getting Time

- (NSInteger)currentMinute
{
    // In practice, these calls can be combined
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:now];
    
    return [components minute];
}
- (NSInteger)currentHour
{
    // In practice, these calls can be combined
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour fromDate:now];
    
    return [components hour];
}
-(NSString *)currentDate{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}
-(double)creatingTimeStamp:(NSString *)time{
    
    NSArray *timeArr = [time componentsSeparatedByString:@":"];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[NSDate date]];
    [components setHour:[timeArr[0] integerValue]];
    [components setMinute:[timeArr[1] integerValue]];
    [components setSecond:[timeArr[2] integerValue]];

    NSDate *todayAt6PM = [calendar dateFromComponents:components];
    ;
    NSLog(@"date components.....:%.f",[todayAt6PM timeIntervalSince1970]);
    return [todayAt6PM timeIntervalSince1970];
}
#pragma mark - Request Methods

-(void)makeRequestForFitbitData{
    
    NSLog(@"makeRequestForFitbitData");
    NSString *url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/heart/date/2018-04-05/1d/1sec/time/17:11/18:12.json"];
    NSLog(@"hour......:%ld",(long)[self currentHour]);
    NSLog(@"minute......:%ld",(long)[self currentMinute]);
    NSLog(@"current date.....:%@",[self currentDate]);
    
    NSString *urlStr = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/heart/date/%@/1d/1sec/time/%ld:%ld/%ld:%ld.json",[self currentDate],[self currentHour]-1,[self currentMinute]-1,[self currentHour],[self currentMinute]];
    
    NSLog(@"fitbit url......:%@",urlStr);
    NSString *fitbitToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fitbitToken"];
    NSLog(@"fitbit token......:%@",fitbitToken);
    NSString *fitbitRefreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"refreshToken"];
    NSLog(@"fitbitAuthentication1:%@",fitbitRefreshToken);
    SmartRxCommonClass *manager = [SmartRxCommonClass sharedManager];
    //********** Pass your API here and get details in response **********
    
    [manager requestGETFitbitData:urlStr Token:fitbitToken success:^(NSDictionary *responseObject) {
        // ------ response -----
        dispatch_async(dispatch_get_main_queue(),^{
            
        [HUD hide:YES];
        [HUD removeFromSuperview];
        self.heartBeatView.hidden = NO;

        NSArray *heartBeatArr = responseObject[@"activities-heart-intraday"][@"dataset"];
            if(heartBeatArr.count > 1){
        NSLog(@"response1............:%@",responseObject);

        NSLog(@"response............:%@",heartBeatArr[heartBeatArr.count-1]);
        NSDictionary *heart = heartBeatArr[heartBeatArr.count-1];
        double timeStamp = [self creatingTimeStamp:heart[@"time"]];
        NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
        NSString *timeSta = [NSString stringWithFormat:@"%.f",timeStamp];
            NSLog(@"time stampe.....:%@",timeSta);
        self.heartBeatLbl.text = [NSString stringWithFormat:@"%@",heart[@"value"]];
        self.ref = [[FIRDatabase database] reference];
        [[[self.ref child:@"heart"] child:userId] setValue:@{@"heartbeat": heart[@"value"],@"timeStamp":timeSta}];
        }
        });
        
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(),^{
            [HUD hide:YES];
            [HUD removeFromSuperview];
        self.heartBeatView.hidden = YES;

        NSLog(@"error............:%@",error.userInfo);
        NSDictionary *userInfo = error.userInfo;
        NSLog(@"error code.....:%ld",(long)error.code);
        if (error.code == 401 && [userInfo[@"errorType"] isEqualToString:fExpied_Token])  {
            NSLog(@"token expired");
                [self makeRequetForRevokeFitbitToken];
        }
        });
    }];
}
-(NSString *)base64String:(NSString *)string {
    // Create NSData object
    NSData *nsdata = [string dataUsingEncoding:NSUTF8StringEncoding];
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    return base64Encoded;
}
-(void)makeRequetForRevokeFitbitToken{
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *base64 = [self base64String:[NSString stringWithFormat:@"%@:%@",@"229VW2",@"1d7fd7674cc93c43208ab27d1cecb831"]];
    NSLog(@"base64......:%@",base64);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.fitbit.com/oauth2/token"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];

    [request setValue:[NSString stringWithFormat:@"Basic %@",base64]  forHTTPHeaderField:@"Authorization"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod:@"POST"];
    NSString *fitbitToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fitbitToken"];
//fitbitAuthanticationCode
    NSString *fitbitRefreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fitbitAuthentication"];
    NSLog(@"fitbitAuthentication:%@",fitbitRefreshToken);
    NSString *fitbitRefreshToken1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"fitbitAuthanticationCode"];
    NSLog(@"fitbitAuthentication1:%@",fitbitRefreshToken1);
    NSDictionary *param = @{@"grant_type":@"refresh_token",@"refresh_token":fitbitRefreshToken1,@"expires_in":@"31536000"};

    NSString *postBody = [NSString stringWithFormat:@"grant_type=%@&refresh_token=%@&expires_in=%@&,",@"refresh_token",fitbitRefreshToken1,@"31536000"];
    NSData *postStringData = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    
    request.HTTPBody = postStringData;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *  data, NSURLResponse *  response, NSError *  error) {
        if (!error) {
            id responseObject =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"fitbit.....:%@",responseObject);
        }else {
            
            dispatch_async(dispatch_get_main_queue(),^{
                NSLog(@"fitbit access toke revoke error");
            
            UIAlertController *controller =[UIAlertController alertControllerWithTitle:@"Error" message:@"Network not available" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [controller addAction:okAction];
            [self presentViewController:controller animated:YES completion:nil];
                });

        }
    }];
    [dataTask resume];
    

}
- (void)makeRequestToPushEconsultNotification
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&econid=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"appid"]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"minit"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else
        {
            NSLog(@"response ... %@", response);
        }
    } failureHandler:^(id response) {
        
    }];

}

- (void)makeRequestToGetToken
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"metoken"];
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
                token = [response objectForKey:@"etoken"];
                NSLog(@"Here is my token %@", token);
                self.token = token;
                self.sessionId = [self.dictResponse objectForKey:@"vsession"];
                kToken = self.token;
                kSessionId = self.sessionId;
                if (!sessionDidConnect && !_session)
                    [self setupSession];
            });
        }
    } failureHandler:^(id response) {
        
        
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Error in updating Symptoms please enter again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        //        [alert show];
        //        [HUD hide:YES];
        //        [HUD removeFromSuperview];
        
    }];
}

- (void)makeRequestToAddReports
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strSeccionName=[[NSUserDefaults standardUserDefaults]objectForKey:@"SessionName"];
    NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:sectionId,@"sessionid",[self.dictResponse objectForKey:@"conid"],@"econid",strSeccionName,@"session_name",@"2",@"apptype", nil];
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
        NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@&message=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"],requestText];
        //mereqadd
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
        NSString *conType = @"1";
        if (self.scheduleType != nil) {
            conType = @"3";
        }
        NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
        NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@&symptoms=%@&con_type=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"conid"],symptomText,conType];
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
                self.btnBF.selected = NO;
                self.btnAF.selected = NO;
                [self makeRequestForMedicationAndFamilyHistory];
                //self.familyContentLabel.text = response[@"family_history"];
            }
            });
        }
       
    } failureHandler:^(id response) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Updating" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
        NSLog(@"resppnse.....:%@",response);

        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }else {
            dispatch_async(dispatch_get_main_queue(),^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
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
                        medicationStr = [medicationStr stringByAppendingString:[NSString stringWithFormat:@" - quantity : %@ ",dict[@"quantity"]]];
                        
                        
                    }else {
                        medicationStr = [medicationStr stringByAppendingString:[NSString stringWithFormat:@" - quantity : 0 "]];

                    }
                    medicationStr = [medicationStr stringByAppendingString:[NSString stringWithFormat:@" - consumption : (%@-%@-%@-%@)",dict[@"morning"],dict[@"afternoon"],dict[@"evening"],dict[@"night"]]];

                    
                    if (![dict[@"drug_dose"] isEqualToString:@""]) {
                        medicationStr = [medicationStr stringByAppendingString:[NSString stringWithFormat:@" - dose : %@ ",dict[@"drug_dose"]]];

                    }

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
            //        self.suggestionViewEdit.frame = CGRectMake(self.suggestionViewEdit.frame.origin.x, self.suggestionViewEdit.frame.origin.y, self.suggestionViewEdit.frame.size.width, heightLbl+40);
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
        
       // self.reportContentTable.frame = CGRectMake(self.reportContentTable.frame.origin.x, self.reportContentTable.frame.origin.y, self.reportContentTable.frame.size.width, tableHeight+20);
        if (tableHeight > self.reportViewEdit.frame.size.height)
        {
           // self.reportViewEdit.frame = CGRectMake(self.reportViewEdit.frame.origin.x, self.reportViewEdit.frame.origin.y, self.reportViewEdit.frame.size.width , self.reportViewEdit.frame.size.height+tableHeight);
        }
        //[self.reportScroll setContentSize:CGSizeMake(self.scrollView.frame.size.width, tableHeight+300)];
        
        
        
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
       // self.reportViewEdit.frame = CGRectMake(self.reportViewEdit.frame.origin.x, self.reportViewEdit.frame.origin.y, self.reportViewEdit.frame.size.width, repLabel.frame.size.height+40);
        
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
    //    self.imgViwPhoto.image=image;
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
    
    AFHTTPRequestOperation * op = [manager POST:strUrl parameters:info constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
#pragma mark - openTok methods

- (void)subscriberVideoDisableWarning:(OTSubscriberKit*)subscriber    // callback - when video drops due to poor internet
{
    NSLog(@"subscriberVideoDisableWarning");
    [self videoDisabled:@"midCongestion.png"];
}

- (void)subscriberVideoDisableWarningLifted:(OTSubscriberKit*)subscriber   // callback - when the video dropped due to poor internet comes back
{
    NSLog(@"subscriberVideoDisableWarningLifted");
    [self videoEnabled];
}

- (void)subscriberVideoDisabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason   // callback to disable video due to poor internet
{
    [self videoDisabled:@"highCongestion.png"];
    NSLog(@"Video is disabled for the subscriber. Reason: %d", reason);
    //    if (reason == OTSubscriberVideoEventQualityChanged)
    //    [self showAlert:@"Video is disabled for the subscriber."];
}
- (void)subscriberVideoEnabled:(OTSubscriberKit*)subscriber reason:(OTSubscriberVideoEventReason)reason // callback - enable video when internet becomes good
{
    NSLog(@"Video is enabled for the subscriber. Reason: %d", reason);
    //    [self show Alert:@"Video is enabled for the subscriber."];
}
- (void)enteringBackgroundMode:(NSNotification*)notification
{
    NSLog(@"enteringBackgroundMode");
    _publisher.publishVideo = NO;
    _currentSubscriber.subscribeToVideo = NO;
}
- (void)leavingBackgroundMode:(NSNotification*)notification
{
    NSLog(@"leavingBackgroundMode");
    _publisher.publishVideo = YES;
    _currentSubscriber.subscribeToVideo = YES;
    //now subscribe to any background connected streams
    for (OTStream *stream in backgroundConnectedStreams)
    {
        // create subscriber
        OTSubscriber *subscriber = [[OTSubscriber alloc]
                                    initWithStream:stream delegate:self];
        // subscribe now
        OTError *error = nil;
        [_session subscribe:subscriber error:&error];
        if (error)
        {
            [self showAlert:[error localizedDescription]];
        }
    }
    [backgroundConnectedStreams removeAllObjects];
}
- (void)viewTapped:(UITapGestureRecognizer *)tgr
{
    BOOL isInFullScreen = [[[self topOverlayView].layer
                            valueForKey:APP_IN_FULL_SCREEN] boolValue];
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    
    if (isInFullScreen) {
        
        [self.topOverlayView.layer setValue:[NSNumber numberWithBool:NO]
                                     forKey:APP_IN_FULL_SCREEN];
        
        // Show/Adjust top, bottom, archive, publisher and video container
        // views according to the orientation
        if (orientation == UIInterfaceOrientationPortrait ||
            orientation == UIInterfaceOrientationPortraitUpsideDown) {
            
            
            [UIView animateWithDuration:0.5 animations:^{
                
                CGRect frame = _currentSubscriber.view.frame;
                frame.size.height =
                self.videoContainerView.frame.size.height;
                _currentSubscriber.view.frame = frame;
                
                frame = self.topOverlayView.frame;
                frame.origin.y += frame.size.height;
                self.topOverlayView.frame = frame;
                
                frame = self.archiveOverlay.superview.frame;
                frame.origin.y -= frame.size.height;
                self.archiveOverlay.superview.frame = frame;
                
                [_publisher.view setFrame:
                 CGRectMake(8,
                            self.view.frame.size.height -
                            (PUBLISHER_BAR_HEIGHT +
                             (self.archiveOverlay.hidden ? 0 :
                              ARCHIVE_BAR_HEIGHT)
                             + 8 + PUBLISHER_PREVIEW_HEIGHT),
                            PUBLISHER_PREVIEW_WIDTH,
                            PUBLISHER_PREVIEW_HEIGHT)];
            } completion:^(BOOL finished) {
                
            }];
        }
        else
        {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                CGRect frame = _currentSubscriber.view.frame;
                frame.size.width =
                self.videoContainerView.frame.size.width;
                _currentSubscriber.view.frame = frame;
                
                frame = self.topOverlayView.frame;
                frame.origin.y += frame.size.height;
                self.topOverlayView.frame = frame;
                
                frame = self.bottomOverlayView.frame;
                if (orientation == UIInterfaceOrientationLandscapeRight) {
                    frame.origin.x -= frame.size.width;
                } else {
                    frame.origin.x += frame.size.width;
                }
                
                self.bottomOverlayView.frame = frame;
                
                frame = self.archiveOverlay.frame;
                frame.origin.y -= frame.size.height;
                self.archiveOverlay.frame = frame;
                
                if (orientation == UIInterfaceOrientationLandscapeRight) {
                    [_publisher.view setFrame:
                     CGRectMake(8,
                                self.view.frame.size.height -
                                ((self.archiveOverlay.hidden ? 0 :
                                  ARCHIVE_BAR_HEIGHT) + 8 +
                                 PUBLISHER_PREVIEW_HEIGHT),
                                PUBLISHER_PREVIEW_WIDTH,
                                PUBLISHER_PREVIEW_HEIGHT)];
                    
                    self.rightArrowImgView.frame =
                    CGRectMake(self.videoContainerView.frame.size.width - 40 -
                               10 - PUBLISHER_BAR_HEIGHT,
                               self.videoContainerView.frame.size.height/2 - 20,
                               40,
                               40);
                    
                    
                } else {
                    [_publisher.view setFrame:
                     CGRectMake(PUBLISHER_BAR_HEIGHT + 8,
                                self.view.frame.size.height -
                                ((self.archiveOverlay.hidden ? 0 :
                                  ARCHIVE_BAR_HEIGHT) + 8 +
                                 PUBLISHER_PREVIEW_HEIGHT),
                                PUBLISHER_PREVIEW_WIDTH,
                                PUBLISHER_PREVIEW_HEIGHT)];
                    
                    self.leftArrowImgView.frame =
                    CGRectMake(10 + PUBLISHER_BAR_HEIGHT,
                               self.videoContainerView.frame.size.height/2 - 20,
                               40,
                               40);
                    
                }
            } completion:^(BOOL finished) {
                
                
            }];
        }
        
        // start overlay hide timer
        self.overlayTimer =
        [NSTimer scheduledTimerWithTimeInterval:OVERLAY_HIDE_TIME
                                         target:self
                                       selector:@selector(overlayTimerAction)
                                       userInfo:nil
                                        repeats:NO];
    }
    else
    {
        [self.topOverlayView.layer setValue:[NSNumber numberWithBool:YES]
                                     forKey:APP_IN_FULL_SCREEN];
        
        // invalidate timer so that it wont hide again
        [self.overlayTimer invalidate];
        
        
        // Hide/Adjust top, bottom, archive, publisher and video container
        // views according to the orientation
        if (orientation == UIInterfaceOrientationPortrait ||
            orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                CGRect frame = _currentSubscriber.view.frame;
                // User really tapped (not from willAnimateToration...)
                if (tgr)
                {
                    frame.size.height =
                    self.videoContainerView.frame.size.height;
                    _currentSubscriber.view.frame = frame;
                }
                
                frame = self.topOverlayView.frame;
                frame.origin.y -= frame.size.height;
                self.topOverlayView.frame = frame;
                
                frame = self.archiveOverlay.superview.frame;
                frame.origin.y += frame.size.height;
                self.archiveOverlay.superview.frame = frame;
                
                
                [_publisher.view setFrame:
                 CGRectMake(8,
                            self.view.frame.size.height -
                            (8 + PUBLISHER_PREVIEW_HEIGHT),
                            PUBLISHER_PREVIEW_WIDTH,
                            PUBLISHER_PREVIEW_HEIGHT)];
            } completion:^(BOOL finished) {
            }];
            
        }
        else
        {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                CGRect frame = _currentSubscriber.view.frame;
                frame.size.width =
                self.videoContainerView.frame.size.width;
                _currentSubscriber.view.frame = frame;
                
                frame = self.topOverlayView.frame;
                frame.origin.y -= frame.size.height;
                self.topOverlayView.frame = frame;
                
                frame = self.bottomOverlayView.frame;
                if (orientation == UIInterfaceOrientationLandscapeRight) {
                    frame.origin.x += frame.size.width;
                    
                    self.rightArrowImgView.frame =
                    CGRectMake(self.videoContainerView.frame.size.width - 40 - 10,
                               self.videoContainerView.frame.size.height/2 - 20,
                               40,
                               40);
                    
                } else {
                    frame.origin.x -= frame.size.width;
                    
                    self.leftArrowImgView.frame =
                    CGRectMake(10 ,
                               self.videoContainerView.frame.size.height/2 - 20,
                               40,
                               40);
                    
                }
                
                self.bottomOverlayView.frame = frame;
                
                frame = self.archiveOverlay.frame;
                frame.origin.y += frame.size.height;
                self.archiveOverlay.frame = frame;
                
                
                [_publisher.view setFrame:
                 CGRectMake(8,
                            self.view.frame.size.height -
                            (8 + PUBLISHER_PREVIEW_HEIGHT),
                            PUBLISHER_PREVIEW_WIDTH,
                            PUBLISHER_PREVIEW_HEIGHT)];
            } completion:^(BOOL finished) {
            }];
        }
    }
    
    // no need to arrange subscribers when it comes from willRotate
    if (tgr)
    {
        [self reArrangeSubscribers];
    }
    
    [self resetArrowsStates];
}
- (void)overlayTimerAction
{
    BOOL isInFullScreen =   [[[self topOverlayView].layer
                              valueForKey:APP_IN_FULL_SCREEN] boolValue];
    
    // if any button is in highlighted state, we ignore hide action
    if (!self.cameraToggleButton.highlighted &&
        !self.audioPubUnpubButton.highlighted &&
        !self.audioPubUnpubButton.highlighted) {
        // Hide views
        if (!isInFullScreen) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self viewTapped:[[self.videoConsultView gestureRecognizers]
                                  objectAtIndex:0]];
            });
            
            //[[[self.view gestureRecognizers] objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
            
        }
    } else {
        // start the timer again for next time
        self.overlayTimer =
        [NSTimer scheduledTimerWithTimeInterval:OVERLAY_HIDE_TIME
                                         target:self
                                       selector:@selector(overlayTimerAction)
                                       userInfo:nil
                                        repeats:NO];
    }
}
- (void)willAnimateRotationToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:
     toInterfaceOrientation duration:duration];
    
    BOOL isInFullScreen =   [[[self topOverlayView].layer
                              valueForKey:APP_IN_FULL_SCREEN] boolValue];
    
    // hide overlay views adjust positions based on orietnation and then
    // hide them again
    if (isInFullScreen) {
        // hide all bars to before rotate
        self.topOverlayView.hidden = YES;
        self.bottomOverlayView.hidden = YES;
    }
    
    int connectionsCount = [allConnectionsIds count];
    UIInterfaceOrientation orientation = toInterfaceOrientation;
    
    // adjust overlay views
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        [self.videoContainerView setFrame:
         CGRectMake(0,
                    0,
                    self.view.frame.size.width,
                    self.view.frame.size.height)];
        
        [_publisher.view setFrame:
         CGRectMake(8,
                    self.view.frame.size.height -
                    (isInFullScreen ? PUBLISHER_PREVIEW_HEIGHT + 8 :
                     (PUBLISHER_BAR_HEIGHT +
                      (self.archiveOverlay.hidden ? 0 :
                       ARCHIVE_BAR_HEIGHT) + 8 +
                      PUBLISHER_PREVIEW_HEIGHT)),
                    PUBLISHER_PREVIEW_WIDTH,
                    PUBLISHER_PREVIEW_HEIGHT)];
        
        
        UIView *containerView = self.archiveOverlay.superview;
        containerView.frame =
        CGRectMake(0,
                   self.view.frame.size.height -
                   PUBLISHER_ARCHIVE_CONTAINER_HEIGHT,
                   self.view.frame.size.width,
                   PUBLISHER_ARCHIVE_CONTAINER_HEIGHT);
        
        [self.bottomOverlayView removeFromSuperview];
        [containerView addSubview:self.bottomOverlayView];
        
        self.bottomOverlayView.frame =
        CGRectMake(0,
                   containerView.frame.size.height - PUBLISHER_BAR_HEIGHT,
                   containerView.frame.size.width,
                   PUBLISHER_BAR_HEIGHT);
        
        // Archiving overlay
        self.archiveOverlay.frame =
        CGRectMake(0,
                   0,
                   self.view.frame.size.width,
                   ARCHIVE_BAR_HEIGHT);
        
        self.topOverlayView.frame =
        CGRectMake(0,
                   0,
                   self.view.frame.size.width,
                   self.topOverlayView.frame.size.height);
        
        // Camera button
        self.cameraToggleButton.frame =
        CGRectMake(0, 0, 64, PUBLISHER_BAR_HEIGHT);
        
        //adjust border layer
        CALayer *borderLayer = nil;
        
        if ([[self.cameraToggleButton.layer sublayers] count] > 1)
        {
            borderLayer =[[self.cameraToggleButton.layer sublayers]
                          objectAtIndex:1];
        }
        else
        {
            borderLayer =[[self.cameraToggleButton.layer sublayers]
                          objectAtIndex:0];
        }
        
        borderLayer.frame =
        CGRectMake(-1,
                   -1,
                   CGRectGetWidth(_cameraToggleButton.frame),
                   CGRectGetHeight(_cameraToggleButton.frame) + 2);
        
        // adjust call button
        self.endCallButton.frame =
        CGRectMake(65,
                   0,
                   133,
                   PUBLISHER_BAR_HEIGHT);
        if ([[self.endCallButton.layer sublayers] count] > 1)
        {
            borderLayer = [[self.endCallButton.layer sublayers]
                           objectAtIndex:1];
        }
        else
        {
            borderLayer = [[self.endCallButton.layer sublayers]
                           objectAtIndex:0];
        }
        borderLayer.frame =
        CGRectMake(-1,
                   -1,
                   CGRectGetWidth(self.endCallButton.frame),
                   CGRectGetHeight(self.endCallButton.frame) + 2);
        // adjust videoPauseButton button
        self.videoPauseButton.frame =
        CGRectMake(self.bottomOverlayView.frame.size.width - 64 -56,
                   0,
                   56,
                   PUBLISHER_BAR_HEIGHT);
        if ([[self.videoPauseButton.layer sublayers] count] > 1)
        {
            borderLayer = [[self.videoPauseButton.layer sublayers]
                           objectAtIndex:1];
        }
        else
        {
            borderLayer = [[self.videoPauseButton.layer sublayers]
                           objectAtIndex:0];
        }
        borderLayer.frame =
        CGRectMake(-1,
                   -1,
                   CGRectGetWidth(self.videoPauseButton.frame),
                   CGRectGetHeight(self.videoPauseButton.frame) + 2);
        
        //        borderLayer.frame =
        //        CGRectMake(-1,
        //                   -1,
        //                   CGRectGetWidth(self.videoPauseButton.frame),
        //                   CGRectGetHeight(self.videoPauseButton.frame) + 2);
        //        if ([[self.videoPauseButton.layer sublayers] count] > 1)
        //        {
        //            borderLayer = [[self.videoPauseButton.layer sublayers]
        //                           objectAtIndex:1];
        //        }
        //        else
        //        {
        //            borderLayer = [[self.videoPauseButton.layer sublayers]
        //                           objectAtIndex:0];
        //        }
        
        // Mic button
        self.audioPubUnpubButton.frame =
        CGRectMake(self.bottomOverlayView.frame.size.width - 64,
                   0,
                   64,
                   PUBLISHER_BAR_HEIGHT);
        //        borderLayer.frame =
        //        CGRectMake(-1,
        //                   -1,
        //                   CGRectGetWidth(self.audioPubUnpubButton.frame),
        //                   CGRectGetHeight(self.audioPubUnpubButton.frame) + 2);
        
        if ([[self.audioPubUnpubButton.layer sublayers] count] > 1)
        {
            borderLayer = [[self.audioPubUnpubButton.layer sublayers]
                           objectAtIndex:1];
        }
        else
        {
            borderLayer = [[self.audioPubUnpubButton.layer sublayers]
                           objectAtIndex:0];
        }
        
        borderLayer.frame =
        CGRectMake(-1,
                   -1,
                   CGRectGetWidth(_audioPubUnpubButton.frame) + 5,
                   CGRectGetHeight(_audioPubUnpubButton.frame) + 2);
        
        self.leftArrowImgView.frame =
        CGRectMake(10,
                   self.videoContainerView.frame.size.height/2 - 20,
                   40,
                   40);
        
        self.rightArrowImgView.frame =
        CGRectMake(self.videoContainerView.frame.size.width - 40 - 10,
                   self.videoContainerView.frame.size.height/2 - 20,
                   40,
                   40);
        
        [self.videoContainerView setContentSize:
         CGSizeMake(self.videoContainerView.frame.size.width * (connectionsCount ),
                    self.videoContainerView.frame.size.height)];
    }
    else if (orientation == UIInterfaceOrientationLandscapeLeft ||
             orientation == UIInterfaceOrientationLandscapeRight) {
        
        
        if (orientation == UIInterfaceOrientationLandscapeRight) {
            
            [self.videoContainerView setFrame:
             CGRectMake(0,
                        0,
                        self.view.frame.size.width,
                        self.view.frame.size.height)];
            
            [_publisher.view setFrame:
             CGRectMake(8,
                        self.view.frame.size.height -
                        ((self.archiveOverlay.hidden ? 0 : ARCHIVE_BAR_HEIGHT)
                         + 8 + PUBLISHER_PREVIEW_HEIGHT),
                        PUBLISHER_PREVIEW_WIDTH,
                        PUBLISHER_PREVIEW_HEIGHT)];
            
            UIView *containerView = self.archiveOverlay.superview;
            containerView.frame =
            CGRectMake(0,
                       self.view.frame.size.height - ARCHIVE_BAR_HEIGHT,
                       self.view.frame.size.width - PUBLISHER_BAR_HEIGHT,
                       ARCHIVE_BAR_HEIGHT);
            
            // Archiving overlay
            self.archiveOverlay.frame =
            CGRectMake(0,
                       containerView.frame.size.height - ARCHIVE_BAR_HEIGHT,
                       containerView.frame.size.width ,
                       ARCHIVE_BAR_HEIGHT);
            
            [self.bottomOverlayView removeFromSuperview];
            [self.videoConsultView addSubview:self.bottomOverlayView];
            
            self.bottomOverlayView.frame =
            CGRectMake(self.view.frame.size.width - PUBLISHER_BAR_HEIGHT,
                       0,
                       PUBLISHER_BAR_HEIGHT,
                       self.view.frame.size.height);
            
            // Top overlay
            self.topOverlayView.frame =
            CGRectMake(0,
                       0,
                       self.view.frame.size.width - PUBLISHER_BAR_HEIGHT,
                       self.topOverlayView.frame.size.height);
            
            self.leftArrowImgView.frame =
            CGRectMake(10,
                       self.videoContainerView.frame.size.height/2 - 20,
                       40,
                       40);
            
            self.rightArrowImgView.frame =
            CGRectMake(self.view.frame.size.width - 40 - 10 -
                       PUBLISHER_BAR_HEIGHT,
                       self.videoContainerView.frame.size.height/2 - 20,
                       40,
                       40);
            
            
            
        }
        else
        {
            [self.videoContainerView setFrame:
             CGRectMake(0,
                        0,
                        self.view.frame.size.width ,
                        self.view.frame.size.height)];
            
            [_publisher.view setFrame:
             CGRectMake(8 + PUBLISHER_BAR_HEIGHT,
                        self.view.frame.size.height -
                        ((self.archiveOverlay.hidden ? 0 : ARCHIVE_BAR_HEIGHT)
                         + 8 + PUBLISHER_PREVIEW_HEIGHT),
                        PUBLISHER_PREVIEW_WIDTH,
                        PUBLISHER_PREVIEW_HEIGHT)];
            
            
            UIView *containerView = self.archiveOverlay.superview;
            containerView.frame =
            CGRectMake(PUBLISHER_BAR_HEIGHT,
                       self.view.frame.size.height - ARCHIVE_BAR_HEIGHT,
                       self.view.frame.size.width - PUBLISHER_BAR_HEIGHT,
                       ARCHIVE_BAR_HEIGHT);
            
            [self.bottomOverlayView removeFromSuperview];
            [self.videoConsultView addSubview:self.bottomOverlayView];
            
            self.bottomOverlayView.frame =
            CGRectMake(0,
                       0,
                       PUBLISHER_BAR_HEIGHT,
                       self.view.frame.size.height);
            
            // Archiving overlay
            self.archiveOverlay.frame =
            CGRectMake(0,
                       containerView.frame.size.height - ARCHIVE_BAR_HEIGHT,
                       containerView.frame.size.width ,
                       ARCHIVE_BAR_HEIGHT);
            
            self.topOverlayView.frame =
            CGRectMake(PUBLISHER_BAR_HEIGHT,
                       0,
                       self.view.frame.size.width - PUBLISHER_BAR_HEIGHT,
                       self.topOverlayView.frame.size.height);
            
            self.leftArrowImgView.frame =
            CGRectMake(10 + PUBLISHER_BAR_HEIGHT,
                       self.videoContainerView.frame.size.height/2 - 20,
                       40,
                       40);
            
            self.rightArrowImgView.frame =
            CGRectMake(self.view.frame.size.width - 40 - 10 ,
                       self.videoContainerView.frame.size.height/2 - 20,
                       40,
                       40);
            
        }
        
        // Mic button
        CGRect frame =  self.audioPubUnpubButton.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        frame.size.width = PUBLISHER_BAR_HEIGHT;
        frame.size.height = 90;
        
        self.audioPubUnpubButton.frame = frame;
        
        // vertical border
        frame.origin.x = -1;
        frame.origin.y = -1;
        frame.size.width = 55;
        CALayer *borderLayer = [[self.audioPubUnpubButton.layer sublayers]
                                objectAtIndex:1];
        borderLayer.frame = frame;
        
        // Camera button
        frame =  self.cameraToggleButton.frame;
        frame.origin.x = 0;
        frame.origin.y = self.bottomOverlayView.frame.size.height - 100;
        frame.size.width = PUBLISHER_BAR_HEIGHT;
        frame.size.height = 64;
        
        self.cameraToggleButton.frame = frame;
        
        frame.origin.x = -1;
        frame.origin.y = 0;
        frame.size.height = 64;
        frame.size.width = 55;
        
        borderLayer = [[self.cameraToggleButton.layer sublayers]
                       objectAtIndex:1];
        borderLayer.frame =
        CGRectMake(0,
                   1,
                   CGRectGetWidth(self.cameraToggleButton.frame) ,
                   1
                   );
        
        // call button
        frame =  self.endCallButton.frame;
        frame.origin.x = 0;
        frame.origin.y = (self.bottomOverlayView.frame.size.height / 2) -
        (100 / 2);
        frame.size.width = PUBLISHER_BAR_HEIGHT;
        frame.size.height = 100;
        
        self.endCallButton.frame = frame;
        
        
        // videopause button
        frame =  self.videoPauseButton.frame;
        frame.origin.x = 0;
        frame.origin.y = self.bottomOverlayView.frame.size.height - 100;
        frame.size.width = PUBLISHER_BAR_HEIGHT;
        frame.size.height = 54;
        
        self.videoPauseButton.frame = frame;
        
        frame.origin.x = -1;
        frame.origin.y = 0;
        frame.size.height = 54;
        frame.size.width = PUBLISHER_BAR_HEIGHT;
        
        borderLayer = [[self.videoPauseButton.layer sublayers]
                       objectAtIndex:1];
        borderLayer.frame =
        CGRectMake(0,
                   1,
                   CGRectGetWidth(self.videoPauseButton.frame) ,
                   1
                   );
        
        
        [self.videoContainerView setContentSize:
         CGSizeMake(self.videoContainerView.frame.size.width * connectionsCount,
                    self.videoContainerView.frame.size.height)];
    }
    
    if (isInFullScreen) {
        
        // call viewTapped to hide the views out of the screen.
        [[self topOverlayView].layer setValue:[NSNumber numberWithBool:NO]
                                       forKey:APP_IN_FULL_SCREEN];
        [self viewTapped:nil];
        [[self topOverlayView].layer setValue:[NSNumber numberWithBool:YES]
                                       forKey:APP_IN_FULL_SCREEN];
        
        self.topOverlayView.hidden = NO;
        self.bottomOverlayView.hidden = NO;
    }
    
    // re arrange subscribers
    [self reArrangeSubscribers];
    
    UIView *leftBorder = [[UIView alloc] initWithFrame:CGRectMake(self.endCallButton.frame.size.width-1, 0, 1.5, self.endCallButton.frame.size.height)];
    leftBorder.backgroundColor = [UIColor colorWithRed:(216.0/255.0) green:(215.0/255.0) blue:(215.0/255.0) alpha:1.0];// [UIColor lightGrayColor];
    [self.endCallButton addSubview:leftBorder];
    // set video container offset to current subscriber
    [self.videoContainerView setContentOffset:
     CGPointMake(_currentSubscriber.view.tag *
                 self.videoContainerView.frame.size.width, 0)
                                     animated:YES];
}
- (void)showAsCurrentSubscriber:(OTSubscriber *)subscriber
{
    // scroll view tapping bug
    if(subscriber == _currentSubscriber)
        return;
    
    // unsubscribe currently running video
    _currentSubscriber.subscribeToVideo = NO;
    
    // update as current subscriber
    _currentSubscriber = subscriber;
    self.userNameLabel.text = _currentSubscriber.stream.name;
    
    // subscribe to new subscriber
    _currentSubscriber.subscribeToVideo = YES;
    
    self.audioSubUnsubButton.selected = !_currentSubscriber.subscribeToAudio;
}
- (void)setupSession
{
    //setup one time session
    if (_session) {
        _session = nil;
    }
    
    _session = [[OTSession alloc] initWithApiKey:kApiKey
                                       sessionId:[self.dictResponse objectForKey:@"vsession"]
                                        delegate:self];
    [_session connectWithToken:token error:nil];
    
    //    [self setupPublisher];
        NSLog(@"Setup session");
}
- (void)setupPublisher
{
    NSLog(@"Setup publisher");
    // create one time publisher and style publisher
    //_publisher = [[OTPublisher alloc] initWithDelegate:self];
    
    _publisherSettings = [[OTPublisherSettings alloc]init];
    _publisherSettings.cameraResolution = OTCameraCaptureResolutionHigh;
    _publisher = [[OTPublisher alloc] initWithDelegate:self settings:_publisherSettings];
    // set name of the publisher
    //    [_publisher setName:self.publisherName];
    
    [self willAnimateRotationToInterfaceOrientation:
     [[UIApplication sharedApplication] statusBarOrientation] duration:1.0];
    
    [self.videoConsultView addSubview:_publisher.view];
    
    // add pan gesture to publisher
    UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handlePan:)];
    [_publisher.view addGestureRecognizer:pgr];
    pgr.delegate = self;
    _publisher.view.userInteractionEnabled = YES;
    
    OTError *error;
    [_session publish:_publisher error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:_publisher.view];
    CGRect recognizerFrame = recognizer.view.frame;
    recognizerFrame.origin.x += translation.x;
    recognizerFrame.origin.y += translation.y;
    
    
    if (CGRectContainsRect(self.view.bounds, recognizerFrame)) {
        recognizer.view.frame = recognizerFrame;
    }
    else {
        if (recognizerFrame.origin.y < self.view.bounds.origin.y) {
            recognizerFrame.origin.y = 0;
        }
        else if (recognizerFrame.origin.y + recognizerFrame.size.height > self.view.bounds.size.height) {
            recognizerFrame.origin.y = self.view.bounds.size.height - recognizerFrame.size.height;
        }
        
        if (recognizerFrame.origin.x < self.view.bounds.origin.x) {
            recognizerFrame.origin.x = 0;
        }
        else if (recognizerFrame.origin.x + recognizerFrame.size.width > self.view.bounds.size.width) {
            recognizerFrame.origin.x = self.view.bounds.size.width - recognizerFrame.size.width;
        }
    }
    [recognizer setTranslation:CGPointMake(0, 0) inView:_publisher.view];
}
- (void)handleArrowTap:(UIPanGestureRecognizer *)recognizer
{
    CGPoint touchPoint = [recognizer locationInView:self.leftArrowImgView];
    if ([self.leftArrowImgView pointInside:touchPoint withEvent:nil])
    {
        
        int currentPage = (int)(self.videoContainerView.contentOffset.x /
                                self.videoContainerView.frame.size.width) ;
        
        OTSubscriber *nextSubscriber = [allSubscribers objectForKey:
                                        [allConnectionsIds objectAtIndex:currentPage - 1]];
        
        [self showAsCurrentSubscriber:nextSubscriber];
        
        [self.videoContainerView setContentOffset:
         CGPointMake(_currentSubscriber.view.frame.origin.x, 0) animated:YES];
        
        
    } else {
        
        int currentPage = (int)(self.videoContainerView.contentOffset.x /
                                self.videoContainerView.frame.size.width) ;
        
        OTSubscriber *nextSubscriber = [allSubscribers objectForKey:
                                        [allConnectionsIds objectAtIndex:currentPage + 1]];
        
        [self showAsCurrentSubscriber:nextSubscriber];
        
        [self.videoContainerView setContentOffset:
         CGPointMake(_currentSubscriber.view.frame.origin.x, 0) animated:YES];
        
    }
    
    [self resetArrowsStates];
}
- (void)resetArrowsStates
{
    self.leftArrowImgView.hidden = YES;
    self.rightArrowImgView.hidden = YES;
    
    BOOL isInFullScreen = [[[self topOverlayView].layer
                            valueForKey:APP_IN_FULL_SCREEN] boolValue];
    
    if (isInFullScreen || !_currentSubscriber ||
        (_currentSubscriber.view.tag == 0 && [allConnectionsIds count] <= 1))
    {
        return;
    }
    
    if (_currentSubscriber.view.tag == 0 && [allConnectionsIds count] > 1)
    {
        self.rightArrowImgView.hidden = NO;
    } else if (_currentSubscriber.view.tag == [allConnectionsIds count] - 1 &&
               [allConnectionsIds count] > 1)
    {
        self.leftArrowImgView.hidden = NO;
    } else
    {
        self.leftArrowImgView.hidden = NO;
        self.rightArrowImgView.hidden = NO;
    }
}
#pragma mark - OpenTok Session
- (void)session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"connectionDestroyed: %@", connection);
    self.onlineStatusImage.image = [UIImage imageNamed:@"offline.png"];
//    self.connectBtn.hidden = YES;
    [self hideVideoView];
    [endAlert dismissWithClickedButtonIndex:0 animated:YES];
    endAlert = nil;
    
    if (streamCreatedFlag)
    {
        streamCreatedFlag = NO;
        if (_session && _session.sessionConnectionStatus ==
            OTSessionConnectionStatusConnected)
        {
            // disconnect session
            NSLog(@"disconnecting....");
            [_session disconnect:nil];
            //        return;
        }
        if([self.navigationController.viewControllers indexOfObject:self] != NSNotFound)
        {
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"InEconsult"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
- (void)session:(OTSession *)session
connectionCreated:(OTConnection *)connection  // Callback as soon as both users connect to the session or openTok room
{
    NSLog(@"addConnection: %@", connection);
    self. onlineStatusImage.image = [UIImage imageNamed:@"online.png"];
//    self.connectBtn.hidden = NO;
//    self.connectBtn.userInteractionEnabled = YES;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultVideoPush"] == YES)
    {
        [self connectBtnClicked:nil];
    }
    
}
- (void)sessionDidConnect:(OTSession *)session //Callback - as soon as the session gets connected successfully
{
    sessionDidConnect = YES;
    NSLog(@"sessionDidConnect %@", session.sessionId);
    //Forces the application to not let the iPhone go to sleep.
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    // now publish
    [self.spinningWheel stopAnimating];
    if (self.connectBtn.tag == 9696)
        [self setupPublisher];
}
- (void)reArrangeSubscribers
{
    NSLog(@"reArrangeSubscribers");
    CGFloat containerWidth = CGRectGetWidth(self.videoContainerView.bounds);
    CGFloat containerHeight = CGRectGetHeight(self.videoContainerView.bounds);
    int count = [allConnectionsIds count];
    
    // arrange all subscribers horizontally one by one.
    for (int i = 0; i < [allConnectionsIds count]; i++)
    {
        OTSubscriber *subscriber = [allSubscribers
                                    valueForKey:[allConnectionsIds
                                                 objectAtIndex:i]];
        subscriber.view.tag = i;
        [subscriber.view setFrame:
         CGRectMake(i * CGRectGetWidth(self.videoContainerView.bounds),
                    0,
                    containerWidth,
                    containerHeight)];
        [self.videoContainerView addSubview:subscriber.view];
    }
    
    [self.videoContainerView setContentSize:
     CGSizeMake(self.videoContainerView.frame.size.width * (count ),
                self.videoContainerView.frame.size.height - 18)];
    [self.videoContainerView setContentOffset:
     CGPointMake(_currentSubscriber.view.frame.origin.x, 0) animated:YES];
}
- (void)sessionDidDisconnect:(OTSession *)session  //Callback - as soon as the session gets disconnected successfully
{
    sessionDidConnect = NO;
    NSLog(@"sessionDidDisconnect");
    self. onlineStatusImage.image = [UIImage imageNamed:@"offline.png"];
//    self.connectBtn.hidden = YES;
    // remove all subscriber views fro  m video container
    for (int i = 0; i < [allConnectionsIds count]; i++)
    {
        OTSubscriber *subscriber = [allSubscribers valueForKey:
                                    [allConnectionsIds objectAtIndex:i]];
        [subscriber.view removeFromSuperview];
    }
    
    [_publisher.view removeFromSuperview];
    
    [allSubscribers removeAllObjects];
    [allConnectionsIds removeAllObjects];
    [allStreams removeAllObjects];
    _currentSubscriber = NULL;
    
    _publisher = nil;
    
    if (self.archiveStatusImgView.isAnimating)
    {
        [self stopArchiveAnimation];
    }
    //    [self hide ]
    //    if([self.navigationController.viewControllers indexOfObject:self] !=
    //       NSNotFound)
    //    {
    //        [self dismissViewControllerAnimated:YES completion:^{
    //
    //        }];
    //
    //    }
    
    //Allows the iPhone to go to sleep if there is not touch activity.
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}
- (void)    session:(OTSession *)session
    streamDestroyed:(OTStream *)stream   //Callback - as soon as the incoming video stream stops coming
{
    NSLog(@"streamDestroyed %@", stream.connection.connectionId);
    if (streamReceived)
        streamReceived = nil;
    // unsubscribe first
    OTSubscriber *subscriber = [allSubscribers objectForKey:
                                stream.connection.connectionId];
    
    //    OTError *error = nil;
    //	[_session unsubscribe:subscriber error:&error];
    //    if (error)
    //    {
    //        [self showAlert:[error localizedDescription]];
    //    }
    
    // remove from superview
    [subscriber.view removeFromSuperview];
    if (incomingAlert)
    {
        [audioPlayer stop];
        [incomingAlert dismissWithClickedButtonIndex:1 animated:YES];
        incomingAlert = nil;
        [endAlert dismissWithClickedButtonIndex:0 animated:YES];
        endAlert = nil;
        
    }
    
    [allSubscribers removeObjectForKey:stream.connection.connectionId];
    [allConnectionsIds removeObject:stream.connection.connectionId];
    
    _currentSubscriber = nil;
    [self reArrangeSubscribers];
    
    // show first subscriber
    if ([allConnectionsIds count] > 0) {
        NSString *firstConnection = [allConnectionsIds objectAtIndex:0];
        [self showAsCurrentSubscriber:[allSubscribers
                                       objectForKey:firstConnection]];
    }
    [self resetArrowsStates];
}
- (void)createSubscriber:(OTStream *)stream  // This is the method to initate the subscriber for audio and video
{
    
    if ([[UIApplication sharedApplication] applicationState] ==
        UIApplicationStateBackground ||
        [[UIApplication sharedApplication] applicationState] ==
        UIApplicationStateInactive)
    {
        [backgroundConnectedStreams addObject:stream];
    } else
    {
        // create subscriber
        OTSubscriber *subscriber = [[OTSubscriber alloc]
                                    initWithStream:stream delegate:self];
        
        // subscribe now
        OTError *error = nil;
        [_session subscribe:subscriber error:&error];
        if (error)
        {
            [self showAlert:[error localizedDescription]];
        }
    }
}
- (void)subscriberDidConnectToStream:(OTSubscriberKit *)subscriber  //Callback - as soon as the stream gets connected successfully
{
    NSLog(@"subscriberDidConnectToStream %@", subscriber.stream.name);
    streamCreatedFlag = YES;
    // create subscriber
    OTSubscriber *sub = (OTSubscriber *)subscriber;
    [allSubscribers setObject:subscriber forKey:sub.stream.connection.connectionId];
    [allConnectionsIds addObject:sub.stream.connection.connectionId];
    
    // set subscriber position and size
    CGFloat containerWidth = CGRectGetWidth(self.videoContainerView.bounds);
    CGFloat containerHeight = CGRectGetHeight(self.videoContainerView.bounds);
    int count = [allConnectionsIds count] - 1;
    [sub.view setFrame:
     CGRectMake(count *
                CGRectGetWidth(self.videoContainerView.bounds),
                0,
                containerWidth,
                containerHeight)];
    
    sub.view.tag = count;
    
    // add to video container view
    [self.videoContainerView insertSubview:sub.view
                              belowSubview:_publisher.view];
    
    
    // default subscribe video to the first subscriber only
    if (!_currentSubscriber) {
        [self showAsCurrentSubscriber:(OTSubscriber *)subscriber];
    } else {
        subscriber.subscribeToVideo = NO;
    }
    
    // set scrollview content width based on number of subscribers connected.
    [self.videoContainerView setContentSize:
     CGSizeMake(self.videoContainerView.frame.size.width * (count + 1),
                self.videoContainerView.frame.size.height - 18)];
    
    [allStreams setObject:sub.stream forKey:sub.stream.connection.connectionId];
    
    [self resetArrowsStates];
}
- (void)  session:(OTSession *)mySession
    streamCreated:(OTStream *)stream  //Callback - as soon as the incoming video stream is received
{
    // create remote subscriber
    //    streamCreatedFlag = YES;
    streamReceived = stream;
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultVideoPush"] == YES)
    {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultPush"];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultVideoPush"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self createSubscriber:stream];
    }
    else if ([self.videoConsultView isHidden] && [self.connectBtn.currentTitle isEqualToString:@"Connect"])
    {
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource: @"Xylophone" withExtension: @"mp3"] error:&error];
        audioPlayer.delegate = self;
        if (error)  {
            NSLog(@"Error creating audio player: %@", [error userInfo]);
        }
        else
        {
            audioPlayer.numberOfLoops = 10;
            [audioPlayer play];
        }
        incomingAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Incoming call from %@",stream.name ] delegate:self cancelButtonTitle:@"ACCEPT" otherButtonTitles:@"REJECT", nil];
        incomingAlert.delegate = self;
        incomingAlert.tag = 1200;
        [incomingAlert show];
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
        {
            notification = [[UILocalNotification alloc] init];
            notification.fireDate = [NSDate date];
            notification.soundName = @"Xylophone.mp3";
            notification.alertBody = [NSString stringWithFormat:@"Incoming call from %@",stream.name ];
            //            NSDictionary *customInfo =[NSDictionary dictionaryWithObject:[[notifDetails objectAtIndex:0] objectForKey:@"id"] forKey:@"yourKey"];
            //            notification.userInfo = customInfo;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
    else
    {
        [self createSubscriber:stream];
    }
}
- (void)session:(OTSession *)session didFailWithError:(OTError *)error   //Callback - session connection error
{
    NSLog(@"sessionDidFail");
    [self showAlert:
     [NSString stringWithFormat:@"There was an error connecting to session %@",
      error.localizedDescription]];
    [self endCallAction:nil];
}
- (void)publisher:(OTPublisher *)publisher didFailWithError:(OTError *)error //Callback - publishing audio/video fails
{
    NSLog(@"publisher didFailWithError %@", error);
    [self showAlert:[NSString stringWithFormat:
                     @"There was an error publishing."]];
    [self endCallAction:nil];
}
- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error //Callback - connecting to subscribers fails
{
    NSLog(@"subscriber could not connect to stream");
}
#pragma mark - Helper Methods
- (IBAction)endCallAction:(UIButton *)button    // end the opentok call
{
    if (button.tag == 3080)
    {
        self.onlineStatusImage.image = [UIImage imageNamed:@"offline.png"];
//        self.connectBtn.hidden = YES;
        [self hideVideoView];
        if (_session && _session.sessionConnectionStatus ==
            OTSessionConnectionStatusConnected)
        {
            // disconnect session
            NSLog(@"disconnecting....");
            [_session disconnect:nil];
            _session = nil;
            //        return;
        }
        //    else
        //    {
        //all other cases just go back to home screen.
        if([self.navigationController.viewControllers indexOfObject:self] !=
           NSNotFound)
        {
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"InEconsult"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (button != nil)
    {
        endAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to disconnect?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        endAlert.delegate = self;
        endAlert.tag = 1400;
        [endAlert show];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultPush"];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultVideoPush"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        self.onlineStatusImage.image = [UIImage imageNamed:@"offline.png"];
//        self.connectBtn.hidden = YES;
        [self hideVideoView];
        if (_session && _session.sessionConnectionStatus ==
            OTSessionConnectionStatusConnected)
        {
            // disconnect session
            NSLog(@"disconnecting....");
            [_session disconnect:nil];
            _session = nil;
            //        return;
        }
        //    else
        //    {
        //all other cases just go back to home screen.
        if([self.navigationController.viewControllers indexOfObject:self] !=
           NSNotFound)
        {
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"InEconsult"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController popViewControllerAnimated:YES];
        }
        //    }
    }
}
- (void)showAlert:(NSString *)string
{
    // show alertview on main UI
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Message from video session"
                              message:string
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    });
}
#pragma mark - Other Interactions
- (IBAction)toggleAudioSubscribe:(id)sender   // Audio unmute or mute receiving audio
{
    if (_currentSubscriber.subscribeToAudio == YES) {
        _currentSubscriber.subscribeToAudio = NO;
        self.audioSubUnsubButton.selected = YES;
    } else {
        _currentSubscriber.subscribeToAudio = YES;
        self.audioSubUnsubButton.selected = NO;
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
}
- (IBAction)toggleCameraPosition:(id)sender   // switch from front camera to back camera
{
    if (_publisher.cameraPosition == AVCaptureDevicePositionBack) {
        _publisher.cameraPosition = AVCaptureDevicePositionFront;
        self.cameraToggleButton.selected = NO;
        self.cameraToggleButton.highlighted = NO;
    } else if (_publisher.cameraPosition == AVCaptureDevicePositionFront) {
        _publisher.cameraPosition = AVCaptureDevicePositionBack;
        self.cameraToggleButton.selected = YES;
        self.cameraToggleButton.highlighted = YES;
    }
}
- (IBAction)toggleAudioPublish:(id)sender   // Callback - mute or unmute mic.
{
    if (_publisher.publishAudio == YES) {
        _publisher.publishAudio = NO;
        self.audioPubUnpubButton.selected = YES;
    } else {
        _publisher.publishAudio = YES;
        self.audioPubUnpubButton.selected = NO;
    }
}

- (void)videoDisabled:(NSString *)imgName // UI when video drops due to poor internet connection
{
    
    if (self.archiveOverlay.hidden)
    {
        self.archiveOverlay.hidden = NO;
        CGRect frame = _publisher.view.frame;
        frame.origin.y -= ARCHIVE_BAR_HEIGHT;
        _publisher.view.frame = frame;
    }
    BOOL isInFullScreen = [[[self topOverlayView].layer valueForKey:APP_IN_FULL_SCREEN] boolValue];
    
    //show UI if it is in full screen
    if (isInFullScreen)
    {
        [self viewTapped:[self.videoConsultView.gestureRecognizers objectAtIndex:0]];
    }
    
    
    // set animation images
    self.archiveStatusLbl.text = @"";
    UIImage *imageOne = [UIImage imageNamed:imgName];
//    UIImage *imageTwo = [UIImage imageNamed:@"audioOnlyInactive.png"];
    NSArray *imagesArray =
    [NSArray arrayWithObjects:imageOne, nil];
    self.archiveStatusImgView.animationImages = imagesArray;
    self.archiveStatusImgView.animationDuration = 1.0f;
    self.archiveStatusImgView.animationRepeatCount = 0;
    [self.archiveStatusImgView startAnimating];
    
}
- (void)videoEnabled
{
    [self.archiveStatusImgView stopAnimating];
    self.archiveOverlay.hidden = NO;
    self.archiveStatusLbl.text = @"";
    self.archiveStatusImgView.image =
    [UIImage imageNamed:@"archiving-off-15.png"];
}

- (void)startArchiveAnimation
{
    
    if (self.archiveOverlay.hidden)
    {
        self.archiveOverlay.hidden = NO;
        CGRect frame = _publisher.view.frame;
        frame.origin.y -= ARCHIVE_BAR_HEIGHT;
        _publisher.view.frame = frame;
    }
    BOOL isInFullScreen = [[[self topOverlayView].layer valueForKey:APP_IN_FULL_SCREEN] boolValue];
    
    //show UI if it is in full screen
    if (isInFullScreen)
    {
        [self viewTapped:[self.videoConsultView.gestureRecognizers objectAtIndex:0]];
    }
    
    
    // set animation images
    self.archiveStatusLbl.text = @"Archiving call";
    UIImage *imageOne = [UIImage imageNamed:@"archiving_on-10.png"];
    UIImage *imageTwo = [UIImage imageNamed:@"archiving_pulse-Small.png"];
    NSArray *imagesArray =
    [NSArray arrayWithObjects:imageOne, imageTwo, nil];
    self.archiveStatusImgView.animationImages = imagesArray;
    self.archiveStatusImgView.animationDuration = 1.0f;
    self.archiveStatusImgView.animationRepeatCount = 0;
    [self.archiveStatusImgView startAnimating];
    
}
- (void)stopArchiveAnimation
{
    [self.archiveStatusImgView stopAnimating];
    self.archiveStatusLbl.text = @"Archiving off";
    self.archiveStatusImgView.image =
    [UIImage imageNamed:@"archiving-off-15.png"];
}
- (void)     session:(OTSession*)session
archiveStartedWithId:(NSString*)archiveId
                name:(NSString*)name
{
    [self startArchiveAnimation];
}
- (void)     session:(OTSession*)session
archiveStoppedWithId:(NSString*)archiveId
{
    NSLog(@"stopping session archiving");
    [self stopArchiveAnimation];
    
}
//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}
@end
