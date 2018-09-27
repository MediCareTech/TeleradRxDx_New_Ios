//
//  SmartRxBookAPPointmentVC.m
//  SmartRx
//
//  Created by PaceWisdom on 12/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxBookAPPointmentVC.h"
#import "SmartRxAppointmentsVC.h"
#import "SmartRxCommonClass.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"
#import "NSString+DateConvertion.h"
#import <QuartzCore/QuartzCore.h>
#import "UsersResponseModel.h"
#import "SamrtRxCitiesResponseModel.h"
#import "SpecialityResponseModel.h"
#import "DoctorResponseModel.h"
#import "DoctorAddressResponseModel.h"
#import "PatientLocationResponseModel.h"
#import "SmartRxPaymentVC.h"

#define kDoctorsTextfieldTag 3000
#define kDateTextfieldTag 3001
#define kTimeTextfieldTag 3002
#define kLocationTextfieldtag 3003
#define kPatientLocationTextfieldtag 3007
#define kDoctorTextFieldTag 3008
#define kSpecialityTextfiledTag 3004
#define kBookAppSuccesTag 3005
#define kBookAppSuccesTagFindDoctors 3006
#define kKeyBoardHeight 200
#define kNoCreditsAlertTag 8000

@interface SmartRxBookAPPointmentVC ()
{
    UIActivityIndicatorView *spinner;
    NSInteger txtFiledTag;
    NSString *strLoctionId;
    NSString *strSelDocId;
    NSString *strSelctedDate;
    NSString *strRegular;
    NSString *strRegisterCall;
    
    MBProgressHUD *HUD;
    CGSize viewSize;
    CGFloat height;
    NSString *strFrontDeskNum;
    
    NSString *selectedTimeSlot;
    NSString *selectedCityId;
    BOOL patientLocationsAvailable , isBookBtnUp;
    UsersResponseModel *selectedUser;
    SamrtRxCitiesResponseModel *selectedCity;
    SpecialityResponseModel *selectedSpecialty;
    DoctorResponseModel *selectedDoctor;
    DoctorAddressResponseModel *selectedDoctorAddress;
    PatientLocationResponseModel *selectedPatientLocation;
    NSInteger consultationFeeAmount, eCostPrice, eConsultCredits, finalCost, actualCost;
    double discountedCost;
    NSInteger econ_auto_camp_count;
    BOOL autoSelect, promoApplied;
    NSString *campId,*paymentType,*payOption,*mobileNumber,*discountAmount;
    
}
@end

@implementation SmartRxBookAPPointmentVC

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
#pragma mark - View LIfe Cycle
+ (id)sharedManagerAppointment {
    static SmartRxBookAPPointmentVC *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UName"] length] >0)
    {
        self.textName.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"UName"];
        self.textMobile.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    }
    paymentType = @"2";
    discountAmount = @"0";
    self.promoCodeText.delegate = self;
    self.promoCodeText.returnKeyType = UIReturnKeyDone;
    self.textReason.layer.cornerRadius=0.0f;
    self.textReason.layer.masksToBounds = YES;
    self.textReason.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.textReason.layer.borderWidth= 1.0f;
    viewSize=[UIScreen mainScreen].bounds.size;
    self.navigationItem.hidesBackButton=YES;
    pickerAction = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    pickerAction.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = pickerAction.bounds;
    [pickerAction addSubview:backgroundView];
    
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    self.textMobile.inputAccessoryView = doneToolbar;
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UName"] length] >0)
    {
        mobileNumber = [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    }
    [self navigationBackButton];
    [self numberKeyBoardReturn];
    self.arrDoctorsList=[[NSMutableArray alloc]init];
    self.arrLoadTbl=[[NSMutableArray alloc]init];
    self.arrSpeclist=[[NSMutableArray alloc]init];
    self.arrSpecAndDocResponse = [[NSMutableArray alloc]init];
    self.arrAppTime=[[NSMutableArray alloc]init];
    self.dictAppTimes=[[NSDictionary alloc]init];
    self.arrLocations=[[NSArray alloc]init];
    if([self.doctorAppointmentDetails count])
    {
        self.arrSpecAndDocResponse = self.dictResponse;
        self.textLocation.text = [self.doctorAppointmentDetails objectForKey:@"locname"];
        self.textSpeciality.text = [self.doctorAppointmentDetails objectForKey:@"deptname"];
        self.textDoctorName.text = [self.doctorAppointmentDetails objectForKey:@"dispname"];
        strLoctionId = [self.doctorAppointmentDetails objectForKey:@"locid"];
        strSlelectedDocID = [self.doctorAppointmentDetails objectForKey:@"recno"];
        strSpecId = [self.doctorAppointmentDetails objectForKey:@"specid"];
    }
    NSDictionary *size = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:17],UITextAttributeFont, nil];
    self.navigationController.navigationBar.titleTextAttributes = size;
    
    CALayer *layer = self.tblDoctorsList.layer;
    [layer setMasksToBounds:YES];
    [layer setCornerRadius: 4.0];
    [layer setBorderWidth:3.0];
    [layer setBorderColor:[[UIColor colorWithWhite: 0.8 alpha: 1.0] CGColor]];
    //[layer setBorderColor:(__bridge CGColorRef)([UIColor darkTextColor])];
    
    self.scrolView.contentSize=CGSizeMake(self.scrolView.frame.origin.x, self.btnBookApp.frame.origin.y+self.btnBookApp.frame.size.height+self.textName.frame.size.height+self.textMobile.frame.size.height+200);
    self.btnEconsult.selected=NO;
    self.btnRegular.selected=YES;
    
    
    strRegular=@"1";
    
    self.tblDoctorsList.hidden=YES;
    
    
    
    viewSize = [UIScreen mainScreen].bounds.size;
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    UIImageView *pickerBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    pickerBackgroundView.opaque = NO;
    pickerBackgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:pickerBackgroundView];
    [self initializePickers];

    self.closeImage.hidden = YES;
    if (self.scheduleType == nil) {
        self.paymentView.hidden = YES;
        self.btnBookApp.frame = CGRectMake(self.btnBookApp.frame.origin.x, 592, self.btnBookApp.frame.size.width, self.btnBookApp.frame.size.height);
        [self makeRequestForUsersList];

    }else {
        [self makeRequestForPackage];


    }
    
}
-(void)initializePickers{
    self.usersPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.usersPickerView.delegate = self;
    self.usersPickerView.dataSource = self;
    self.usersPickerView.backgroundColor = [UIColor whiteColor];
}
- (void)doneButton:(id)sender
{
    [self.textMobile resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            [self makeRequestBookAppointmentWithPayment];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TransactionSuccess"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self customAlertView:@"" Message:@"Sorry we were not able to process the payment. Please try again after sometime to book the Second Opinion Appointment." tag:0];
        }
    }
    
}
#pragma mark - Request methods
-(void)makeRequestForPackage
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *bodyText=nil;
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    }
    else{
        bodyText=[NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mpack"];//@"mdocs"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 24 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                if ([response[@"credit_setting"] integerValue] == 0) {
                    if ([[response objectForKey:@"sec_app_cost"]integerValue] == 0)
                    {
                        eCostPrice = 0;
                    }
                    else
                    {
                        eConsultCredits = 0;
                        eCostPrice = [[response objectForKey:@"sec_app_cost"]integerValue];
                    }
                    
                }else {
                NSString *secAvailable= nil;
                if ([[response objectForKey:@"second_opinions_available"] isEqual:[NSNull null]]) {
                    secAvailable = @"0";
                }else {
                    secAvailable =[response objectForKey:@"second_opinions_available"];
                }
                if ([secAvailable integerValue] > 0)
                {
                    
                    eConsultCredits = [secAvailable integerValue];

                }
                else
                {
                   
                    if ([[response objectForKey:@"sec_app_cost"]integerValue] == 0)
                    {
                        eCostPrice = 0;

                    }
                    else
                    {
                        eConsultCredits = 0;
                        eCostPrice = [[response objectForKey:@"sec_app_cost"]integerValue];
                    }
                }
                }
                [self makeRequestForUsersList];

            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        dispatch_async(dispatch_get_main_queue(),^{
            [self customAlertView:@"Not able to fetch user credits and other details due to network issues. Please try again" Message:@"Try again" tag:1];
        });
    }];
    
}

-(void)makeRequestForCreatdits
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *bodyText=nil;
    bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mpack"];//@"mdocs"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 2 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"GetDoctor";
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                strFrontDeskNum=[response objectForKey:@"frontdesk"];
                if ([[response objectForKey:@"econsults"]integerValue] > 0)
                {
                    strRegular=@"2";
                    self.btnEconsult.selected=YES;
                    self.btnRegular.selected=NO;
                    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
                    if ([networkAvailabilityCheck reachable])
                    {
                        self.textDoctorName.text=@"";
                        self.textLocation.text=@"";
                        self.textSpeciality.text=@"";
                        self.textTime.text=@"";
                    }
                    else{
                        [self customAlertView:@"" Message:@"Network not available" tag:0];
                    }
                    
                }
                else{
                    
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"No credits available, Please call hospital to buy" delegate:self cancelButtonTitle:@"CALL" otherButtonTitles:@"CANCEL", nil];
                    [alert show];
                    alert.tag=kNoCreditsAlertTag;
                    strRegular=@"1";
                    self.btnEconsult.selected=NO;
                    self.btnRegular.selected=YES;
                    alert=nil;
                    
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}
-(void)makeRequestForUsersList{
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
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mmulti"];
    
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if (response) {
            NSArray *array = response[@"family_members"];
            
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            
            for (NSDictionary *dict in array) {
                UsersResponseModel *model = [[UsersResponseModel alloc]init];
                
                model.patientName = dict[@"dispname"];
                model.patientId = dict[@"recno"];
                [tempArray addObject:model];
            }
            self.usersList = [tempArray copy];
            
//            if (self.usersList) {
//                selectedUser = self.usersList[0];
//                self.textName.text = selectedUser.patientName;
//            }
            
            [self makeRquestForPatientLocations];
        }
    
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        dispatch_async(dispatch_get_main_queue(),^{
            [self customAlertView:@"Some error occur" Message:@"Try again" tag:kBookAppSuccesTag];
        });
        
    }];

    
    
}
-(void)makeRquestForPatientLocations{
    
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
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mylocations"];
    
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if (response) {
            
            NSArray *array = response[@"mylocations"];
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            
        
            for (NSDictionary *dict in array) {
                PatientLocationResponseModel *model = [[PatientLocationResponseModel alloc]init];
                
                model.cityName = dict[@"city"][@"name"];
                model.cityId = dict[@"city"][@"id"];
                if ([dict[@"locality"] isKindOfClass:[NSDictionary class]]) {
                    model.localityName = dict[@"locality"][@"name"];
                    model.localityId = dict[@"locality"][@"id"];
                     model.zoneName = dict[@"locality"][@"zone"][@"name"];
                }
                
                model.addressType = dict[@"type"];
                model.zipcode = dict[@"zipcode"];
                model.address = dict[@"address"];
                model.locationId = dict[@"id"];
               
                [tempArray addObject:model];
                
            }
            NSMutableArray *dummyArray = [[NSMutableArray alloc]init];
            NSMutableArray *temp = [[NSMutableArray alloc]init];
            for (PatientLocationResponseModel *model in tempArray) {
                if (![dummyArray containsObject:model.cityName]) {
                    [dummyArray addObject:model.cityName];
                    [temp addObject:model];
                }
            }
            self.patientLocationsArray = [temp copy];
            if (self.patientLocationsArray.count) {
                patientLocationsAvailable = YES;
                PatientLocationResponseModel *model = self.patientLocationsArray[0];
                selectedCityId = model.cityId;
                self.textLocation.text = model.cityName;
        
            } else {
                self.textLocation.text = @"No locations found";
            }
            [self makeRequestForLocations];
            }
        
        
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        dispatch_async(dispatch_get_main_queue(),^{
            [self customAlertView:@"Some error occur" Message:@"Try again" tag:kBookAppSuccesTag];
        });
        
    }];
    
    
}
-(void)makeRquestForSelectedDoctorLocation{
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    
    NSString *bodyText=nil;
    
        bodyText = [NSString stringWithFormat:@"%@=%@&isopen=1&type=3",@"uid",selectedDoctor.doctorId];
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mylocations"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        if (response) {
            
            NSArray *array = response[@"mylocations"];
            
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            
            for (NSDictionary *dict in array) {
                DoctorAddressResponseModel *model = [[DoctorAddressResponseModel alloc]init];
                
                NSString *address = dict[@"type"];
                
                  address = [address stringByAppendingString:@"-"];
                if (![dict[@"locality"] isEqual:[NSNull null]]) {
                    address = [address stringByAppendingString:dict[@"locality"][@"name"]];
                    address = [address stringByAppendingString:@"-"];

                }
                address = [address stringByAppendingString:dict[@"city"][@"name"]];
                
                model.doctorAddress = address;
                model.doctorLocationId = dict[@"id"];
                
                [tempArray addObject:model];
            }
            self.selectedDoctorAddressArray = [tempArray copy];
            
            if (self.selectedDoctorAddressArray.count) {
                selectedDoctorAddress = self.selectedDoctorAddressArray[0];
                
                self.textDoctorAddress.text = selectedDoctorAddress.doctorAddress;
            }
//            NSArray *array = response[@"mylocations"];
//            
//            if (array.count) {
//                self.textLocation.text = @"";
//            } else {
//                self.textLocation.text = @"No locations found";
//            }
            
        }
        
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
    
}

-(void)makeRequestForDoctorsList{
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    NSString *type = @"1";
    NSString *schType = @"";
    if (self.scheduleType != nil) {
        type = @"3";
        schType = @"1";
    }
    
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&cid=%@&city_id=%@&type=%@&sc_type=%@&splid=%@",@"sessionid",sectionId,strCid,selectedCityId,type,schType,selectedSpecialty.specilatyId];
    }
    else{
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&type=%@&sc_type=%@&splid=%@",@"cid",strCid,@"city_id",strLoctionId,@"isopen",@"1",type,schType,selectedSpecialty.specilatyId];

       // bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    
    NSLog(@"body text.....:%@",bodyText);
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlocdoc"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        
        NSLog(@"sucess 99 %@",response);
        
        if (response) {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.doctorArray = nil;
            NSArray *array = response[@"docspec"];
            
            if (array.count) {
                if (self.scheduleType != nil) {
                    if ([[response objectForKey:@"econ_auto_camp_count"]integerValue] > 0)
                    {
                        NSLog(@"ecoun count...... success");
                        
                        econ_auto_camp_count = [[response objectForKey:@"econ_auto_camp_count"]integerValue];
                        NSLog(@"ecoun count......:%ld",(long)econ_auto_camp_count);
                        [self hidePromo];
                    }
                    else
                    {
                        econ_auto_camp_count = 0;
                        [self showPromo];
                    }
                    self.consultationFeeText.hidden = NO;
                }
                NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dict in array) {
                    DoctorResponseModel *model = [[DoctorResponseModel alloc]init];
                    model.doctorId = dict[@"recno"];
                     model.doctorspecilaty = dict[@"deptname"];
                     model.doctorName = dict[@"dispname"];
                    model.secondopinionAmount = dict[@"second_opinion_amount"];
                    if ([dict[@"second_opinion_amount_app"] isKindOfClass:[NSString class]]) {
                        model.secondopinionAppAmount = dict[@"second_opinion_amount_app"];

                    }else{
                        model.secondopinionAppAmount = @"";

                    }
                    model.serviceAmount = dict[@"service_amount"];
                    model.aServiceAmount = dict[@"aservice_amount"];
                    model.defaultSecondOpinionAmount = dict[@"default_second_opinion_amount"];
                    model.defaultSecondOpinionAppAmount = dict[@"default_second_opinion_amount_app"];
                    model.aSecondopinionAmount = dict[@""];
                    if ([dict[@"asecond_opinion_app_amount"] isKindOfClass:[NSString class]]) {
                        model.aSecondopinionAppAmount = dict[@"asecond_opinion_app_amount"];
                        
                    }else{
                        model.aSecondopinionAppAmount = @"";
                        
                    }
                  //  model.aSecondopinionAppAmount = dict[@"asecond_opinion_app_amount"];

                    [tempArray addObject:model];
                }
                self.doctorArray = [tempArray copy];
                NSLog(@"doctor array......:%@",self.doctorArray);
                if (self.doctorArray.count > 0) {
                    if (![self.textSpeciality.text isEqualToString:@""]) {
                        NSLog(@"speciality name.....:%@",self.textSpeciality.text);
                        [self filterDoctorsList:self.textSpeciality.text];
                    }
                   // [self makeRquestForDoctorSpecialityList];

                } else {
                    self.textSpeciality.text = @"No Speciality available";
                    self.textDoctorName.text = @"No Doctor(s) avialble";
                }
              
            }
            else {

                self.textSpeciality.text = @"No Speciality available";
                self.textDoctorName.text = @"No Doctor(s) avialble";
            }
            
        }
        
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
    
}
-(void)makeRquestForDoctorSpecialityList{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    
    //bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",@"cid",strCid,@"locid",selectedCityId,@"isopen",@"1"];
    
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",@"cid",strCid,@"locid",strLoctionId,@"isopen",@"1"];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mspec"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 3 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"getDocAndSpecilities";//@"GetDoctor";
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                
                NSArray *array = response[@"spec"];
                
                NSMutableArray *tempArray = [[NSMutableArray alloc]init];;
                
                for (NSDictionary *dict  in array) {
                    SpecialityResponseModel *model = [[SpecialityResponseModel alloc]init];
                    
                    model.specialityName = dict[@"deptname"];
                    model.specilatyId = dict[@"recno"];
                    
                    [tempArray addObject:model];
                    
                }
                
                self.specialtiArray = [tempArray copy];
                
                if ([self.specialtiArray count])
                {
                    selectedSpecialty = self.specialtiArray[0];
                    [self makeRequestForDoctorsList];
                   // self.textSpeciality.text = selectedSpecialty.specialityName;
                }
                else{
                    [self customAlertView:@"No Speciality available" Message:@"" tag:0];
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
    
}
- (void)makeRequestForDoctorSpecialities
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
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&cid=%@",@"sessionid",sectionId,@"locid",strLoctionId, strCid];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",@"cid",strCid,@"locid",strLoctionId,@"isopen",@"1"];
    }
    if (self.scheduleType != nil) {
        

        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&type=3&-sc_type=1"]];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlocdoc"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 3 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"getDocAndSpecilities";//@"GetDoctor";
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                NSLog(@"ecoun count1......:%ld",[[response objectForKey:@"econ_auto_camp_count"]integerValue]);

                if (self.scheduleType != nil) {
                    if ([[response objectForKey:@"econ_auto_camp_count"]integerValue] > 0)
                    {
                        NSLog(@"ecoun count...... success");

                        econ_auto_camp_count = [[response objectForKey:@"econ_auto_camp_count"]integerValue];
                        NSLog(@"ecoun count......:%ld",(long)econ_auto_camp_count);
                        [self hidePromo];
                    }
                    else
                    {
                        econ_auto_camp_count = 0;
                        [self showPromo];
                    }
                    self.consultationFeeText.hidden = NO;
                }
                
                self.view.userInteractionEnabled = YES;
                [self.arrLoadTbl removeAllObjects];
                [self.arrSpeclist removeAllObjects];
                self.dictResponse = nil;
                [self.tblDoctorsList reloadData];
                
                self.dictResponse = [response objectForKey:@"docspec"];
                self.arrSpecAndDocResponse = [response objectForKey:@"docspec"];
                NSString *tempString = @"";
                
                for (int i=0; i< [self.dictResponse count]; i++)
                {
                    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                    tempString = [[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"deptname"];
                    [tempDict setObject:tempString forKey:@"speciality"];
                    [tempDict setObject:[[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"specid"] forKey:@"recNo"];
                    [self.arrSpeclist addObject:tempDict];
                    
                }
                NSSet *removeDuplicates = [NSSet setWithArray:self.arrSpeclist];
                self.arrSpeclist = [[removeDuplicates allObjects] mutableCopy];
                
                self.arrSpeclist = [self.arrSpeclist mutableCopy];
                
                if ([self.arrSpeclist count])
                {
                   
                }
                else{
                    [self customAlertView:@"No Speciality available" Message:@"" tag:0];
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
    
    
}


-(void)makeRequestGetDoctors
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    if ([self.dictResponse
         count] == 0 && [sectionId length] == 0)
    {
        strRegisterCall=@"getDocAndSpecilities";//@"GetDoctor";
        [self makeRequestForUserRegister];
        
    }
    else
    {
        [self.arrLoadTbl removeAllObjects];
        [self.arrDoctorsList removeAllObjects];
        [self.tblDoctorsList reloadData];
        NSString *tempString = @"";
        NSString *specialityString = self.textSpeciality.text;
        
        for (int i=0; i< [self.dictResponse count]; i++)
        {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
            tempString = [[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"dispname"];
            if ([[[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"deptname"] isEqualToString:specialityString])
            {
                if ([[[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"enable_appointment"] integerValue] == 1)
                {
                    [tempDict setObject:tempString forKey:@"name"];
                    [tempDict setObject:[[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"recno"] forKey:@"recNo"];
                    [self.arrDoctorsList addObject:tempDict];
                }
            }
        }
        NSSet *removeDuplicates = [NSSet setWithArray:self.arrDoctorsList];
        self.arrDoctorsList = [[removeDuplicates allObjects] mutableCopy];
        if ([self.dictResponse count] && [self.arrDoctorsList count])
        {
            self.textDoctorName.text=[[self.arrDoctorsList objectAtIndex:0]objectForKey:@"name"];
            strSlelectedDocID=[[self.arrDoctorsList objectAtIndex:0]objectForKey:@"recNo"];
            
            self.arrLoadTbl=[self.arrDoctorsList mutableCopy];
            self.tblDoctorsList.hidden=NO;
            [self.tblDoctorsList reloadData];
            [HUD hide:YES];
            [HUD removeFromSuperview];
        }
        else{
            [HUD hide:YES];
            [HUD removeFromSuperview];
            [self customAlertView:@"No doctors available." Message:@"" tag:0];
        }
    }
    
}

-(void)makeRequestForDoctorAvailablity
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    //    self.arrLoadTbl = nil;
    //    [self.arrLoadTbl removeAllObjects];
    //    [self.tblDoctorsList reloadData];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",@"sessionid",sectionId,@"docid",selectedDoctor.doctorId,@"doa", self.textDate.text,@"locid",selectedDoctorAddress.doctorLocationId,@"apptype",@"1"];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",@"cid",strCid,@"docid",selectedDoctor.doctorId,@"doa", self.textDate.text,@"locid",strLoctionId,@"isopen",@"1",@"apptype",strRegular];
    }
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mavail"];
    
    if (self.scheduleType != nil) {
        bodyText = [NSString stringWithFormat:@"%@=%@&sch_type=%@&doa=%@&docid=%@&sc_type=1",@"sessionid",sectionId, @"3", self.textDate.text, selectedDoctor.doctorId];
        url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"meconslot"];
        
        NSLog(@"body text .....:%@",bodyText);

    }
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        
        NSLog(@"sucess 4 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"AvialDoctor";
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                spinner = nil;
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                //self.arrAppTime=[[response objectForKey:@"slots"]allValues];
                if ([response[@"slots"] isKindOfClass:[NSArray class]]) {
                    [self.arrAppTime addObjectsFromArray:[response objectForKey:@"slots"]];
                    if ([self.arrAppTime count])
                    {
                        self.textTime.text = [[response objectForKey:@"slots"] objectAtIndex:0];
                        self.textTime.textColor = [UIColor blackColor];
                    }else{
                        NSLog(@"Not Available");
                        
                        [self customAlertView:@"" Message:@"Slots are not available" tag:0];
                    }
                    
                }else {
                self.dictAppTimes=[response objectForKey:@"slots"];
                if ([self.dictAppTimes count])
                {
                    
                    if ([self.arrAppTime count])
                    {
                        [self.arrAppTime removeAllObjects];
                    }
                    
                    NSMutableArray *arrToSort = [[NSMutableArray alloc] initWithArray:[self.dictAppTimes allKeys]];
                    
                    NSArray *sortedArray = [arrToSort sortedArrayUsingComparator:^(id obj1, id obj2) {
                        NSNumber *num1 = [NSNumber numberWithInt:[obj1 intValue]];
                        NSNumber *num2 = [NSNumber numberWithInt:[obj2 intValue]];
                        return (NSComparisonResult)[num1 compare:num2];
                        NSLog(@"(NSComparisonResult)[num1 compare:num2] %ld",(long)[num1 compare:num2]);
                        
                    }];
                    
                    NSLog(@"sorted array == %@",sortedArray);
                    
                    _arrAppTimeIds=sortedArray;
                    
                    
                    for (int i=0; i<[_arrAppTimeIds count]; i++)
                    {
                        
                        
                        if ([self.dictAppTimes objectForKey:[NSString stringWithFormat:@"%@",[_arrAppTimeIds objectAtIndex:i]]])
                        {
                            [self.arrAppTime addObject:[self.dictAppTimes objectForKey:[NSString stringWithFormat:@"%@",[_arrAppTimeIds objectAtIndex:i]]]];
                        }
                        
                    }
                    
                    self.textTime.text=[self.arrAppTime objectAtIndex:0];
//                    self.arrLoadTbl=[self.arrAppTime mutableCopy];
//                    self.tblDoctorsList.hidden=NO;
//                    [self.tblDoctorsList reloadData];
                }
                else{
                    NSLog(@"Not Available");
                    
                    [self customAlertView:@"" Message:@"Slots are not available" tag:0];
                }
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}

-(void)makeRequestBookAppointmentWithPayment{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *patId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    
        NSLog(@"discounted amount....:%@",discountAmount);
   
    NSString *bodyText=nil;
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"maddecon"];
    
    bodyText = [NSString stringWithFormat:@"%@=%@&econ_date=%@&econ_time=%@&econ_specialty=%@&econ_doctor=%@&econ_method=0&payoption=3&&sc_type=3&econ_method=0&apptype=3&payment_type=%@&econ_fee=%@&payraw=%@&TxId=%@&TxStatus=%@&amount=%@&authIdCode=%@&TxMsg=%@&pgTxnNo=%@&paymentMode=%@&locid=%@",@"sessionid",sectionId, self.textDate.text, self.textTime.text, selectedSpecialty.specilatyId, selectedDoctor.doctorId,paymentType,discountAmount,self.paymentResponseDictionary, [self.paymentResponseDictionary objectForKey:@"TxId"],[self.paymentResponseDictionary objectForKey:@"TxStatus"],[self.paymentResponseDictionary objectForKey:@"amount"] ,[self.paymentResponseDictionary objectForKey:@"authIdCode"] ,[self.paymentResponseDictionary objectForKey:@"TxMsg"] ,[self.paymentResponseDictionary objectForKey:@"pgTxnNo"] ,[self.paymentResponseDictionary objectForKey:@"paymentMode"],selectedDoctorAddress.doctorLocationId];
    
    if ([campId length] > 0 && campId != nil)
    {
        NSString *campTemp = [NSString stringWithFormat:@"&campid=%@",campId];
        bodyText = [bodyText stringByAppendingString:campTemp];
    }
    NSString *campTemp = [NSString stringWithFormat:@"&patient_name=%@&patient_mobile=%@",self.textName.text, mobileNumber];
    bodyText = [bodyText stringByAppendingString:campTemp];
    
    NSLog(@"body text..........:%@",bodyText);

  [self makeRequestBookoAppoinment:bodyText Url:url];


}
-(void)makeRequestBookAppointmentWithOutPayment
{
    
    //sessionid:0b7d3fecdda3a6cf6e8c598cfe20796b
    //docid:221787
    //doa:28-03-2013
    //hosploc:24
    //apttime:8:00 AM
    //reason:Check this out
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *patId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    
    NSLog(@"discounted amount....:%@",discountAmount);

    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"maddapt"];

    if (self.scheduleType != nil) {
        
        url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"maddecon"];
        
        bodyText = [NSString stringWithFormat:@"%@=%@&econ_date=%@&econ_time=%@&econ_specialty=%@&econ_doctor=%@&econ_method=0&payoption=%@&&sc_type=3&econ_method=0&apptype=3&payment_type=%@&econ_fee=%@&locid=%@",@"sessionid",sectionId, self.textDate.text, self.textTime.text, selectedSpecialty.specilatyId, selectedDoctor.doctorId,payOption,paymentType,discountAmount,selectedDoctorAddress.doctorLocationId];
        
    }else{
    
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"name=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&patid=%@",self.textName.text, @"sessionid",sectionId,@"docid",selectedDoctor.doctorId,@"doa",self.textDate.text,@"apttime",self.textTime.text,@"reason",self.textReason.text,@"hosploc",selectedDoctorAddress.doctorLocationId,@"specilty",selectedSpecialty.specilatyId,@"apptype",strRegular,patId];
    }
    else{
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@***%@***%@&%@=%@&%@=%@&%@=%@&%@=%@", @"cid",strCid ,@"docid",strSlelectedDocID,@"doa",self.textDate.text,@"apttime",self.textTime.text,@"reason",self.textName.text, self.textMobile.text,self.textReason.text,@"hosploc",strLoctionId,@"specilty",selectedSpecialty.specilatyId,@"apptype",strRegular,@"isopen",@"1"];
    }
    }
    
    if ([campId length] > 0 && campId != nil)
    {
        NSString *campTemp = [NSString stringWithFormat:@"&campid=%@",campId];
        bodyText = [bodyText stringByAppendingString:campTemp];
    }
    NSString *campTemp = [NSString stringWithFormat:@"&patient_name=%@&patient_mobile=%@",self.textName.text, mobileNumber];
    bodyText = [bodyText stringByAppendingString:campTemp];
            
        //bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&sc_type=1&econ_method=0"]];
        
        NSLog(@"bodytext.....:%@",bodyText);
    [self makeRequestBookoAppoinment:bodyText Url:url];

   
}
-(void)makeRequestBookoAppoinment:(NSString *)bodyText Url:(NSString *)url{
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];

    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 6 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"BookApp";
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                
                if ([[response objectForKey:@"result"]integerValue] == 1)
                {
                    NSString *msg = @"Your appointment has been created. You will receive confirmation soon.";
                    
                    if ([self.doctorAppointmentDetails count] && [[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
                    {
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:msg message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        alert.tag=kBookAppSuccesTagFindDoctors;
                        [alert show];
                    }
                    else
                    {
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Your appointment has been created. You will receive confirmation soon." message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        alert.tag=kBookAppSuccesTag;
                        [alert show];
                    }
                }
                else if ([[response objectForKey:@"result"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"There were some issues booking the appointment. Please try after sometime." message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"There were some issues booking the appointment. Please try after sometime." Message:@"Try again" tag:0];
    }];
}
-(void)makeRequestForLocations
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
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"cities/index"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"location";
            [self makeRequestForUserRegister];
        }
        else{
            
            if (response== nil)
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
                    
                    if (response == nil)
                    {
                        [self customAlertView:@"" Message:@"Locations Not available" tag:0];
                    }
                    else{
                        
                        NSMutableArray *tempAaray = [[NSMutableArray alloc]init];
                        
                        for (NSDictionary *dict in response) {
                            SamrtRxCitiesResponseModel *model = [[SamrtRxCitiesResponseModel alloc]init];
                            
                            model.cityName = dict[@"name"];
                            model.cityId = dict[@"id"];
                            
                            [tempAaray addObject:model];
                            
                        }
                        
                        self.locationsArray = [tempAaray copy];
                        
                        if (self.locationsArray.count) {
                            if (!patientLocationsAvailable) {
                        
                             selectedCity= self.locationsArray[0];
                             //self.tblDoctorsList.hidden=NO;
                            selectedCityId = selectedCity.cityId;
                            [self.tblDoctorsList reloadData];
                                [self makeRquestForDoctorSpecialityList];
                           // [self makeRequestForDoctorsList];
                            } else {
                                [self makeRquestForDoctorSpecialityList];

                               // [self makeRequestForDoctorsList];
                            }
                        }
                        
                        
//                        
//                        self.arrLocations=[response objectForKey:@"location"];
//                        if ([self.arrLocations count])
//                        {
//                            self.textLocation.text=[[self.arrLocations objectAtIndex:0]objectForKey:@"locname"];
//                            strLoctionId=[[self.arrLocations objectAtIndex:0]objectForKey:@"locid"];
//                            //[self makeRequestForSpecialities];
//                            self.arrLoadTbl=[self.arrLocations mutableCopy];
//                            self.tblDoctorsList.hidden=NO;
//                            [self.tblDoctorsList reloadData];
//                        }
//                        else{
//                            NSLog(@"Not Available");
//                        }
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


-(void)makeRequestForUserRegister
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *strMobile=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    NSString *strCode=[[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",strMobile];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"code",strCode]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mregister"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 8 %@",response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            [[NSUserDefaults standardUserDefaults]setObject:strCode forKey:@"code"];
            [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cidd"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [self performSegueWithIdentifier:@"RegisterID" sender:[response objectForKey:@"cid"]];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cid"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                if ([strRegisterCall isEqualToString:@"location"])
                {
                    [self makeRequestForLocations];
                }
                else if ([strRegisterCall isEqualToString:@"getDocAndSpecilities"])
                {
                    [self makeRequestForDoctorSpecialities];
                }
                else if ([strRegisterCall isEqualToString:@"GetDoctor"])
                {
                    [self makeRequestGetDoctors];
                }
                //                else if ([strRegisterCall isEqualToString:@"Specilities"])
                //                {
                //                    [self makeRequestForSpecialities];
                //                }
                else if ([strRegisterCall isEqualToString:@"AvialDoctor"])
                {
                    [self makeRequestForDoctorAvailablity];
                }
                else if ([strRegisterCall isEqualToString:@"BookApp"])
                {
                    [self makeRequestBookAppointmentWithOutPayment];
                }
                
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            
        });
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}

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
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&for=%@&promocode=%@&sc_type=%@",@"cid",strCid,@"sessionid",sectionId, @"4",self.promoCodeText.text,@"1"];
    }
    else{
        bodyText=[NSString stringWithFormat:@"%@=%@&%@=%@&for=%@&promocode=%@&sc_type=%@",@"cid",strCid,@"isopen",@"1",@"4", self.promoCodeText.text,@"1"];
    }
    if (selectedSpecialty != nil) {
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&splid=%@&name=%@",selectedSpecialty.specilatyId,self.textName.text]];
    }
    NSLog(@"body text....:%@",bodyText);
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mchkcamp"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"hi sucessssss %@",response);
        
        if (([response count] == 0 && [sectionId length] == 0))
        {
            [self makeRequestForUserRegister];
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
                    //                    if ([[response objectForKey:@"chkredeem"] integerValue] == )
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    NSString *msg;
                    promoApplied = NO;
                    if ([[response objectForKey:@"chkredeem"] integerValue] == 1)
                    {
                        self.promoApplyBtn.tag = 999;
                        [self.promoApplyBtn setTitle:nil forState:UIControlStateNormal];
                        [self.promoApplyBtn setBackgroundImage:nil forState:UIControlStateNormal];
                        promoApplied = YES;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Promo code applied. Thank you." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        campId = [[[response objectForKey:@"campaign"] objectAtIndex:0] objectForKey:@"recno"];
                        //                        discount
                        float discountPercent = [[[[response objectForKey:@"campaign"] objectAtIndex:0] objectForKey:@"discount"] floatValue];
                        discountPercent = discountPercent/100;
                        float discount = finalCost * discountPercent;
                        discountAmount = [NSString stringWithFormat:@"%f",discount];
                        NSLog(@"discount amount......:%@",discountAmount);
                        discountedCost = ceilf(finalCost - discount);
                        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %d", finalCost]];
                        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                                value:@2
                                                range:NSMakeRange(0, [attributeString length])];
                        self.consultationActualCost.attributedText = attributeString;
                        finalCost = discountedCost;
                        if (discountedCost > 0)
                            self.consultationDiscountedCost.text = [NSString stringWithFormat:@"Rs %d", (int)discountedCost];
                        else
                        {
                            self.consultationDiscountedCost.text = @"Free";
                            [self updateBookAppointmentBtnToUP];

                            self.payChoiceView.hidden = YES;
                            [self hidePromo];


                        }
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -3)
                    {
                        promoApplied = NO;
                        msg = @"You already used this promo code";
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -4)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"This promo code expired." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -5)
                    {
                        promoApplied = NO;
                        msg = @"Given promo code not sent to this user";
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Name cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -6 || [[response objectForKey:@"chkredeem"] integerValue] == 0)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Promo code is invalid. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -7)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable at this location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -8)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable for this visit." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -9)
                    {
                        promoApplied = NO;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable for E-Consults." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    
                });
            }
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
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


#pragma mark - Action methods

-(void)homeBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
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
    [self hideKeyboardBtnClicked:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)donePikerBtnClicked:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        self.viewForPicker.frame=CGRectMake(self.viewForPicker.frame.origin.x, self.viewForPicker.frame.origin.y+self.viewForPicker.frame.size.height, self.viewForPicker.frame.size.width, self.viewForPicker.frame.size.height);
        [self.pickerView reloadAllComponents];
    }];
    [self makeRequestForDoctorAvailablity];
}
-(IBAction)usersButtonClicked:(id)sender{
    if (self.usersList.count) {
       // [self showPicker];
    }
    
}
-(IBAction)chooseCityClicked:(id)sender{
    self.tableArray = self.locationsArray;
    cellTextfield=self.textLocation;
    cellTextfield.tag = kLocationTextfieldtag;
    self.tblDoctorsList.hidden=NO;
    [self.tblDoctorsList reloadData];
}
-(IBAction)clickOnPayNowBtn:(id)sender{
    paymentType = @"1";
    self.payNowImage.image = [UIImage imageNamed:@"filled"];
    self.paylaterImage.image = [UIImage imageNamed:@"empty"];


}
-(IBAction)clickOnPayLaterBtn:(id)sender{
    paymentType = @"2";
    self.payNowImage.image = [UIImage imageNamed:@"empty"];
    self.paylaterImage.image = [UIImage imageNamed:@"filled"];

}
- (IBAction)bookAppoinmentClicked:(id)sender
{
    
    [self hideKeyboardBtnClicked:nil];
    if ([self.textName.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Name cannot be empty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    
//    else if ([self.textLocation.text length] <= 0)
//    {
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Please select a location" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
    else if([self.textSpeciality.text length] <=0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Please select a Speciality" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else if ([self.textDoctorName.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Please select a Doctor" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else if ([self.textTime.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Appointment time required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else if ([self.textDate.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Appointment date required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            if (self.scheduleType != nil) {
               [self checkPackageAndBook];

            }else {

                [self makeRequestBookAppointmentWithOutPayment];
            }
            
        }
        else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }
    }
}

- (IBAction)timeBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    cellTextfield=_textTime;
    //    cellTextfield.tag=kTimeTextfieldTag;
    
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        if (self.arrAppTime.count) {
            self.tableArray = [self.arrAppTime copy];
            self.tblDoctorsList.hidden = NO;
            [self.tblDoctorsList reloadData];

        } else {
            [self customAlertView:@"" Message:@"No Time slots available" tag:0];

        }
                //[self makeRequestForDoctorAvailablity];
    }
    else{
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}
-(void)checkDoctorAvailableTimes
{
    txtFiledTag=kTimeTextfieldTag;
    cellTextfield=self.textTime;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForDoctorAvailablity];
    }
    else{
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
}

- (IBAction)dateBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    if ([self.textDoctorName.text isEqualToString:@"No Doctor(s) aviable"] || self.textDoctorName.text.length < 1 ) {
        NSLog(@"failure");
    } else {
    
    if ([self.textReason isFirstResponder])
    {
        [self.textReason resignFirstResponder];
    }
    
    txtFiledTag=kDateTextfieldTag;
    cellTextfield=self.textDate;
    [self clearTextfieldData:cellTextfield];
    self.datePickerView.datePickerMode=UIDatePickerModeDate;
    [self ChooseDP:@"Date"];
    }
}

- (IBAction)eConsultBtnClicked:(id)sender
{
    
    if (![self.btnEconsult isSelected])
    {
        [self.btnBookApp setTitle:@"Book E-Consult" forState:UIControlStateNormal];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
        {
            NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
            if ([networkAvailabilityCheck reachable])
            {
                [self makeRequestForCreatdits];
            }
            else{
                [self customAlertView:@"" Message:@"Network not available" tag:0];
            }
        }
        else
        {
            [self customAlertView:@"" Message:@"Login required" tag:0];
        }
    }
    
}

- (IBAction)regularBtnClicked:(id)sender
{
    
    if (![self.btnRegular isSelected])
    {
        [self.btnBookApp setTitle:@"Book Appointment" forState:UIControlStateNormal];
        strRegular=@"1";
        self.btnEconsult.selected=NO;
        self.btnRegular.selected=YES;
        
        self.textDoctorName.text=@"";
        self.textLocation.text=@"";
        self.textSpeciality.text=@"";
        self.textTime.text=@"";
        
    }
    
    
}

- (IBAction)selectLocationBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    if (self.patientLocationsArray.count) {
        

    cellTextfield=self.textLocation;
    cellTextfield.tag = kPatientLocationTextfieldtag;
    [self clearTextfieldData:cellTextfield];
    self.tableArray = self.patientLocationsArray;
    
    self.tblDoctorsList.hidden=NO;
    [self.tblDoctorsList reloadData];
    }
//    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
//    if ([networkAvailabilityCheck reachable])
//    {
//       // [self makeRequestForLocations];
//    }
//    else{
//        [self customAlertView:@"" Message:@"Network not available" tag:0];
//    }
//    
}

- (IBAction)selectSpecBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    cellTextfield=self.textSpeciality;
    

    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
           // [self makeRequestForDoctorSpecialities];
        //        [self makeRequestForSpecialities];
        if (![self.textSpeciality.text isEqualToString:@"No Speciality available"]) {
            self.tableArray = self.specialtiArray;
            self.tblDoctorsList.hidden=NO;
            [self.tblDoctorsList reloadData];
        } else {
            [self customAlertView:@"" Message:@"No specialities available" tag:0];
        }
        //[self clearTextfieldData:cellTextfield];
       
    }
    else
    {
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}

- (IBAction)selectDocBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    cellTextfield=self.textDoctorName;
    
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        //[self makeRequestGetDoctors];
        
        
        if (!self.textSpeciality.text) {
            [self customAlertView:@"Please select the speciality" Message:@"" tag:0];
        } else {
            
            if (self.filteredDoctorArray.count && ![self.textDoctorName.text isEqualToString:@"No Doctor(s) avialble"]) {
                [self clearTextfieldData:cellTextfield];
                self.tableArray = self.filteredDoctorArray;
                self.tblDoctorsList.hidden=NO;
                [self.tblDoctorsList reloadData];
                
            } else {
                
                [self customAlertView:@"No doctors available." Message:@"" tag:0];
                

        }
        
        
        }
        
        
    }
    else{
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}
-(IBAction)selectDoctorAddressButton:(id)sender{
    [self hideKeyboardBtnClicked:nil];

    if (self.selectedDoctorAddressArray.count) {
        self.tableArray = self.selectedDoctorAddressArray;
        cellTextfield=self.textDoctorAddress;
        cellTextfield.tag = kDoctorTextFieldTag;
        [self clearTextfieldData:cellTextfield];
        
        self.tblDoctorsList.hidden=NO;
        [self.tblDoctorsList reloadData];

    }
}

- (IBAction)hideKeyboardBtnClicked:(id)sender
{
    if ([self.textReason isFirstResponder])
    {
        [self.textReason resignFirstResponder];
    }
    if ([self.textMobile isFirstResponder])
    {
        [self.textMobile resignFirstResponder];
    }
    if ([self.textName isFirstResponder])
    {
        [self.textName resignFirstResponder];
    }
    
    if (![self.tblDoctorsList isHidden]) {
        self.tblDoctorsList.hidden=YES;
    }
}
- (IBAction)promoApplyBtnClicked:(id)sender
{
    if (self.promoApplyBtn.tag == 666)
    {
        [self.promoCodeText resignFirstResponder];
        if ([self.promoCodeText.text length] > 0 && self.promoCodeText.text != nil)
        {
            [self makeRequestCheckPromo];
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
        NSString *cost = self.consultationActualCost.text;
        self.consultationActualCost.attributedText = nil;
        self.consultationActualCost.text = cost;
        self.consultationDiscountedCost.text = nil;
        NSArray *arr = [self.consultationActualCost.text componentsSeparatedByString:@" "];
        if ([arr count]  >= 2)
            finalCost = [[arr objectAtIndex:1] integerValue];
        else
            finalCost = 0;
        [self.promoApplyBtn setTitle:@"APPLY" forState:UIControlStateNormal];
        [self.promoApplyBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bg.png"] forState:UIControlStateNormal];
    }
}
-(void)ChooseDP:(id)sender{
    //    pickerAction = [[UIActionSheet alloc] initWithTitle:@"Date"
    //                                               delegate:nil
    //                                      cancelButtonTitle:nil
    //                                 destructiveButtonTitle:nil
    //                                      otherButtonTitles:nil];
    
    self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    self.datePickerView.backgroundColor = [UIColor whiteColor];
    NSString *date = self.textDate.text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if ([sender isEqualToString:@"Date"])
    {
        [self.datePickerView setMinimumDate:[NSDate date]];
        self.datePickerView.datePickerMode = UIDatePickerModeDate;
    }
    else
    {
        self.datePickerView.datePickerMode = UIDatePickerModeTime;
    }
    if([date length]>0)
    {
        [self.datePickerView setDate:[NSString stringToDate:date]];
    }
    //    //format datePicker mode. in this example time is used
    //    self.datePickerView.datePickerMode = UIDatePickerModeTime;
    //    [dateFormatter setDateFormat:@"h:mm a"];
    //    //calls dateChanged when value of picker is changed
    //    [self.datePickerView addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
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
- (IBAction)doneClicked:(id)sender
{
    if(txtFiledTag == kDateTextfieldTag)
    {
        NSDate *dateAppointment=self.datePickerView.date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-MM-yyy"];
        NSString *strDate = [dateFormat stringFromDate:dateAppointment];
        self.textDate.text=strDate;
        self.datePickerView.hidden=YES;
        [self makeRequestForDoctorAvailablity];
    }
    else if(txtFiledTag == kTimeTextfieldTag)
    {
        NSDate *dateAppointment=self.datePickerView.date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm a"];
        NSString *strTime = [dateFormat stringFromDate:dateAppointment];
        NSLog(@"time ==== %@",strTime);
        self.textTime.text=strTime;
        self.datePickerView.hidden=YES;
    }
    
    [self closeDatePicker:nil];
    
    //[self checkDoctorAvailableTimes];
    
    
}
-(void)doneButtonPressed:(id)sender{
     selectedUser = [self.usersList objectAtIndex:[self.usersPickerView selectedRowInComponent:0]];
    self.textName.text = selectedUser.patientName;
     _actionSheet.hidden = YES;
}
-(void)cancelButtonPressed:(id)sender{
     _actionSheet.hidden = YES;
}
-(BOOL)closeDatePicker:(id)sender
{
    pickerAction.hidden = YES;
    return YES;
}
- (void)checkPackageAndBook{
    if (eConsultCredits > 0) {
        paymentType = @"";
        payOption = @"1";
        [self makeRequestBookAppointmentWithOutPayment];
    }else {
        if (finalCost == 0)
        {
            payOption = @"2";
            paymentType = @"";
            [self makeRequestBookAppointmentWithOutPayment];
        }
        else
        {
            if ([paymentType isEqualToString:@"2"]) {
                payOption = @"2";
                NSLog(@"we can proceed");
                [self makeRequestBookAppointmentWithOutPayment];
                
            }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"fromEconsult"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self customAlertView:@"Note" Message:@"You will be taken to the payment gateway to complete the transaction, as you do not have credits." tag:2];
            }
        
        }
    }
}
-(void)updateBookAppointmentBtnToUP{
    NSLog(@"updateBookAppointmentBtnToUP");

    if (!isBookBtnUp) {
        NSLog(@"updateBookAppointmentBtnToUP success");

    self.btnBookApp.frame = CGRectMake(self.btnBookApp.frame.origin.x, self.btnBookApp.frame.origin.y-100, self.btnBookApp.frame.size.width,self.btnBookApp.frame.size.height);
        NSLog(@"book btn frame1.....:%@",self.btnBookApp);
     isBookBtnUp = YES;
    }
}
-(void)upadteBookAptBtnToDown{
    NSLog(@"upadteBookAptBtnToDown");

    if (isBookBtnUp) {
        NSLog(@"upadteBookAptBtnToDown success");
        self.btnBookApp.frame = CGRectMake(self.btnBookApp.frame.origin.x, self.btnBookApp.frame.origin.y+100, self.btnBookApp.frame.size.width,self.btnBookApp.frame.size.height);
        NSLog(@"book btn frame.....:%@",self.btnBookApp);
        isBookBtnUp = NO;

    }

}
#pragma mark - TableView Datasource/Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableArray count];
}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *cellIdentifier=@"BookAppCell";
//    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    cell.textLabel.textColor=[UIColor whiteColor];
//    if (cellTextfield.tag == kSpecialityTextfiledTag)
//    {
//        cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"title"];
//    }else if(cellTextfield.tag == kDoctorsTextfieldTag)
//    {
//         cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"dispname"];
//    }
//    else if(cellTextfield.tag == kLocationTextfieldtag)
//    {
//        cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"locname"];
//    }
//    else if(cellTextfield.tag == kTimeTextfieldTag)
//    {
//        cell.textLabel.text=[self.arrLoadTbl objectAtIndex:indexPath.row];
//    }
//
//    return cell;
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"BookAppCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.textColor=[UIColor whiteColor];
    if (cellTextfield == _textSpeciality)//kSpecialityTextfiledTag)
    {
        
        SpecialityResponseModel *model = self.tableArray[indexPath.row];
        cell.textLabel.text = model.specialityName;
        //cell.textLabel.text = [[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"speciality"];
        //        cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"deptname"];
        
    }else if(cellTextfield == _textDoctorName)//kDoctorsTextfieldTag)
    {
        
        DoctorResponseModel *model = self.tableArray[indexPath.row];
        cell.textLabel.text = model.doctorName;
        
        //cell.textLabel.text = [[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"name"];
        //        cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"dispname"];
    }
    else if(cellTextfield == _textLocation && cellTextfield.tag ==kLocationTextfieldtag)//kLocationTextfieldtag)
    {
        SamrtRxCitiesResponseModel *model = self.tableArray[indexPath.row];
        cell.textLabel.text = model.cityName;
        
        //cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"locname"];
    }
    else if(cellTextfield == _textLocation && cellTextfield.tag ==kPatientLocationTextfieldtag)//kLocationTextfieldtag)
    {
        PatientLocationResponseModel *model = self.tableArray[indexPath.row];
        cell.textLabel.text = model.cityName;
        
        //cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"locname"];
    }
    else if(cellTextfield == _textTime)//kTimeTextfieldTag)
    {
        cell.textLabel.text=[self.tableArray objectAtIndex:indexPath.row];
    }
    else if(cellTextfield == _textDoctorAddress)//kTimeTextfieldTag)
    {
        DoctorAddressResponseModel *model = self.selectedDoctorAddressArray[indexPath.row];
        cell.textLabel.text=model.doctorAddress;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cellTextfield.tag == kSpecialityTextfiledTag)
    {
        selectedSpecialty = self.tableArray[indexPath.row];
        self.textSpeciality.text = selectedSpecialty.specialityName;
        selectedDoctor = nil;
        self.textDate.text =nil;
        self.textTime.text = nil;
        [self.arrAppTime removeAllObjects];
        self.payChoiceView.hidden = NO;
        [self showPromo];
        [self upadteBookAptBtnToDown];
        [self makeRequestForDoctorsList];
        //[self filterDoctorsList:selectedSpecialty.specialityName];
        
//        self.textSpeciality.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"speciality"];
//        strSpecId=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"recNo"];
        //[self makeRequestGetDoctors];
    }
    else if(cellTextfield.tag == kDoctorsTextfieldTag)
    {
        selectedDoctor = self.tableArray[indexPath.row];
        self.textDate.text =nil;
        self.textTime.text = nil;
        self.textDoctorAddress.text = nil;
        [self.arrAppTime removeAllObjects];
        self.textDoctorName.text = selectedDoctor.doctorName;
        self.payChoiceView.hidden = NO;
        [self showPromo];
        [self upadteBookAptBtnToDown];
        [self setprices:selectedDoctor];
        [self makeRquestForSelectedDoctorLocation];
//        self.textDoctorName.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"name"];
//        strSlelectedDocID=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"recNo"];
    }
    else if(cellTextfield.tag == kLocationTextfieldtag)
    {
        NSLog(@"location......");
        selectedCity = self.tableArray[indexPath.row];
        self.textSpeciality.text = @"";
        self.textDoctorName.text = @"";
        self.textDoctorAddress.text = nil;
        self.textLocation.text = selectedCity.cityName;
        selectedCityId = selectedCity.cityId;
        [self makeRequestForDoctorsList];
//        
//        self.textLocation.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"locname"];
//        strLoctionId=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"locid"];
        //[self makeRequestForSpecialities];
    }
    else if(cellTextfield.tag == kPatientLocationTextfieldtag)
    {
        
        PatientLocationResponseModel *model = self.tableArray[indexPath.row];
        self.textLocation.text = model.cityName;
        selectedCityId = model.cityId;
        self.textSpeciality.text = nil;
        self.textDoctorName.text = nil;
        [self makeRequestForDoctorsList];
        //
        //        self.textLocation.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"locname"];
        //        strLoctionId=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"locid"];
        //[self makeRequestForSpecialities];
    }
    else if(cellTextfield.tag == kTimeTextfieldTag)
    {
        self.textTime.text=[self.tableArray objectAtIndex:indexPath.row];
    }
    else if(cellTextfield.tag == kDoctorTextFieldTag)//kTimeTextfieldTag)
    {
        selectedDoctorAddress= self.selectedDoctorAddressArray[indexPath.row];
         self.textDoctorAddress.text = selectedDoctorAddress.doctorAddress;
    }
    self.tblDoctorsList.hidden=YES;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section
{
    return 1;
}
-(void)filterDoctorsList:(NSString *)specialty{
    //MATCHES
   // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.doctorspecilaty contains[cd] %@",specialty];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.doctorspecilaty MATCHES[cd] %@",specialty];
    self.filteredDoctorArray = [self.doctorArray filteredArrayUsingPredicate:predicate];
    NSLog(@"filter array.....:%@",self.filteredDoctorArray);
    for (DoctorResponseModel *mod in self.filteredDoctorArray) {
        NSLog(@"speciality....:%@",mod.doctorspecilaty);
    }
    if (self.filteredDoctorArray.count) {
        
        selectedDoctor = self.filteredDoctorArray[0];
        
        self.textDoctorName.text = selectedDoctor.doctorName;
        [self makeRquestForSelectedDoctorLocation];
        [self setprices:selectedDoctor];

        
    } else {
        self.textDoctorName.text = @"No Doctor(s) available";
    }
    
}

-(void)setprices:(DoctorResponseModel *)doctor{
    self.consultationDiscountedCost.text = nil;
    self.consultationActualCost.text = nil;
    self.promoCodeText.text = nil;
    [self.promoApplyBtn setTitle:@"APPLY" forState:UIControlStateNormal];
    self.promoApplyBtn.tag = 666;
    [self.promoApplyBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bg.png"] forState:UIControlStateNormal];
    if (eConsultCredits > 0)
    {
        finalCost = 0;
        self.consultationActualCost.hidden = YES;
        self.consultationDiscountedCost.hidden = YES;
        self.consultationFeeText.hidden = YES;
        self.paymentView.hidden = YES;
         self.btnBookApp.frame = CGRectMake(self.btnBookApp.frame.origin.x, 592, self.btnBookApp.frame.size.width, self.btnBookApp.frame.size.height);
        
    }else {
        NSString *defaultEconsultPrice = @"default_econsult_amount";
        NSString *econsultAmount = @"econsult_amount";
        NSString *econsultAamount = @"aeconsult_amount";
        if (self.scheduleType != nil) {
            defaultEconsultPrice= @"default_second_opinion_amount";
            econsultAmount = @"";
            econsultAamount = @"";
        }
        
        if ([doctor.defaultSecondOpinionAppAmount class] != [NSNull null])
        {
            [self showPromo];
            if([doctor.defaultSecondOpinionAppAmount integerValue])
            {
                if ([doctor.serviceAmount class] != [NSNull null])
                {
                    if ([doctor.serviceAmount integerValue] && eConsultCredits <=0)
                    {
                        self.consultationActualCost.text = [NSString stringWithFormat:@"Rs %@",doctor.serviceAmount];
                        consultationFeeAmount = [doctor.serviceAmount integerValue];
                        finalCost = consultationFeeAmount;
                        [self setAutoDiscountValue:[doctor.aServiceAmount integerValue]];
                        self.consultationActualCost.hidden = NO;
                        self.consultationDiscountedCost.hidden = NO;
                        self.consultationFeeText.hidden = NO;
                        [self showPromo];
                    }
                    else
                    {
                        consultationFeeAmount = 0;
                        finalCost = 0;
                        if ([doctor.aServiceAmount integerValue])
                        {
                            self.consultationDiscountedCost.text = @"Free";
                            self.payChoiceView.hidden = YES;
                            [self updateBookAppointmentBtnToUP];
                            [self setAutoDiscountValue:[doctor.aServiceAmount integerValue]];
                            self.consultationActualCost.hidden = NO;
                            self.consultationDiscountedCost.hidden = NO;
                            self.consultationFeeText.hidden = NO;

                        }
                        else
                        {
                            self.consultationDiscountedCost.hidden = YES;
                            consultationFeeAmount = 0;
                            finalCost = 0;
                            self.consultationActualCost.text = @"Free";
                            self.payChoiceView.hidden = YES;
                            [self updateBookAppointmentBtnToUP];
                            [self hidePromo];
                        }
                    }
                }
                else
                {
                    if ([doctor.aServiceAmount class] != [NSNull null])
                    {
                        if ([doctor.aServiceAmount integerValue] == 0)
                        {
                            self.consultationDiscountedCost.hidden = YES;
                            consultationFeeAmount = 0;
                            finalCost = 0;
                            self.consultationActualCost.text = @"Free";
                            [self updateBookAppointmentBtnToUP];
                            self.payChoiceView.hidden = YES;
                            [self hidePromo];
                        }
                        else
                        {
                            finalCost = 0;
                            [self setAutoDiscountValue:[doctor.aServiceAmount integerValue]];
                        }
                        [self showPromo];
                    }
                    else
                    {
                        self.consultationDiscountedCost.hidden = YES;
                        consultationFeeAmount = 0;
                        finalCost = 0;
                        self.consultationActualCost.text = @"Free";
                        [self updateBookAppointmentBtnToUP];

                        self.payChoiceView.hidden = YES;

                        [self hidePromo];
                        
                    }
                }
                
            }
            else
            {
                if([doctor.secondopinionAppAmount integerValue] && eConsultCredits <=0)
                {
                    self.consultationActualCost.text = [NSString stringWithFormat:@"Rs %@",doctor.secondopinionAppAmount];
                    consultationFeeAmount = [doctor.secondopinionAppAmount integerValue];
                    finalCost = consultationFeeAmount;
                    [self setAutoDiscountValue:[doctor.aSecondopinionAppAmount  integerValue]];
                    self.consultationActualCost.hidden = NO;
                    self.consultationDiscountedCost.hidden = NO;
                    self.consultationFeeText.hidden = NO;
                }
                else
                {
                    if ([doctor.secondopinionAppAmount integerValue] == 0)
                    {
                        consultationFeeAmount = 0;
                        finalCost = 0;
                        self.consultationActualCost.text = [NSString stringWithFormat:@"Rs %@",doctor.aSecondopinionAppAmount];
                        [self setAutoDiscountValue:[doctor.aSecondopinionAppAmount integerValue]];
                        self.consultationActualCost.hidden = NO;
                        self.consultationDiscountedCost.hidden = NO;
                        self.consultationFeeText.hidden = NO;
                    }
                    else
                    {
                        self.consultationActualCost.hidden = NO;
                        self.consultationDiscountedCost.hidden = NO;
                        self.consultationFeeText.hidden = NO;
                        finalCost = 0;
                        [self setAutoDiscountValue:[doctor.aSecondopinionAppAmount integerValue]];
                    }
                }
            }
        }
        else
        {
            self.consultationDiscountedCost.hidden = YES;
            self.consultationActualCost.hidden = NO;
            self.consultationFeeText.hidden = NO;
            consultationFeeAmount = 0;
            finalCost = 0;
            self.consultationActualCost.text = @"Free";
            [self updateBookAppointmentBtnToUP];

            self.payChoiceView.hidden = YES;
            [self hidePromo];
        }
    }
}
-(void)setAutoDiscountValue:(NSInteger)costReceived
{
    if (econ_auto_camp_count > 0)
    {
        if(costReceived != 0 && costReceived != finalCost)
        {
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %d", costReceived]];
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@2
                                    range:NSMakeRange(0, [attributeString length])];
            discountAmount = [NSString stringWithFormat:@"%ld",costReceived - finalCost];
            self.consultationActualCost.attributedText = attributeString;
            if (finalCost > 0)
                self.consultationDiscountedCost.text = [NSString stringWithFormat:@"Rs %d", (int)finalCost];
            else{
                self.consultationDiscountedCost.text = @"Free";
                [self updateBookAppointmentBtnToUP];

                self.payChoiceView.hidden = YES;
                [self hidePromo];

            }
            
        }
        else if (finalCost == 0){
            discountAmount = [NSString stringWithFormat:@"%ld",costReceived - finalCost];
            self.consultationDiscountedCost.text = @"Free";
            [self updateBookAppointmentBtnToUP];

            self.payChoiceView.hidden = YES;
            [self hidePromo];


        }
    }
}
#pragma mark - TextField Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField != self.textMobile || textField != self.textName )
        [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.textMobile || textField == self.textName || textField == self.promoCodeText)
    {
    }
    else
    {
        cellTextfield=textField;
        [self clearTextfieldData:textField];
        [textField resignFirstResponder];
    }
    if (textField.tag == kLocationTextfieldtag)
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForLocations];
        }
        else{
            
            [self customAlertView:@"" Message:@"Network not available" tag:0];
            
        }
    }
    else if (textField.tag == kSpecialityTextfiledTag)
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForDoctorSpecialities];
            //           [self makeRequestForSpecialities];
        }
        else{
            
            [self customAlertView:@"" Message:@"Network not available" tag:0];
            
        }
        
    }
    else if (textField.tag == kDoctorsTextfieldTag)
    {
        if ([self.arrDoctorsList count] > 0)
        {
            
            self.tblDoctorsList.hidden=NO;
            
        }
        else{
            if ([self.textLocation.text length] == 0)
            {
                [self customAlertView:@"Location empty" Message:@"Select location" tag:0];
            }
            else if([self.textSpeciality.text length] == 0)
            {
                [self customAlertView:@"Specialities empty" Message:@"Select specialities" tag:0];
            }
            else
            {
                NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
                if ([networkAvailabilityCheck reachable])
                {
                    [self makeRequestGetDoctors];
                }
                else{
                    
                    [self customAlertView:@"" Message:@"Network not available" tag:0];
                }
                
            }
        }
    }
    else if(textField.tag == kDateTextfieldTag)
    {
        txtFiledTag=kDateTextfieldTag;
        self.datePickerView.datePickerMode=UIDatePickerModeDate;
        [self ChooseDP:@"Date"];
        
    }
    else if(textField.tag == kTimeTextfieldTag)
    {
        txtFiledTag=kTimeTextfieldTag;
        
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForDoctorAvailablity];
        }
        else{
            [self customAlertView:@"" Message:@"Network not available" tag:0];
        }
    }else if (textField == self.promoCodeText){
        [UIView animateWithDuration:0.2 animations:^{
            self.scrolView.frame=CGRectMake(self.scrolView.frame.origin.x, self.scrolView.frame.origin.y-(20+kKeyBoardHeight), self.scrolView.frame.size.width, self.scrolView.frame.size.height);
        }];
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == kDateTextfieldTag)
    {
        //        NSDate *dateAppointment=self.datePickerView.date;
        //        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //        [dateFormat setDateFormat:@"dd MM yyy"];
        //        NSString *strDate = [dateFormat stringFromDate:dateAppointment];
        self.datePickerView.hidden=YES;
    }
    else if (textField.tag == kTimeTextfieldTag)
    {
        //        NSDate *dateAppointment=self.datePickerView.date;
        //        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //        [dateFormat setDateFormat:@"hh:mm a"];
        //        NSString *strTime = [dateFormat stringFromDate:dateAppointment];
        self.datePickerView.hidden=YES;
    }else if(textField == self.promoCodeText){
        [UIView animateWithDuration:0.2 animations:^{
            self.scrolView.frame=CGRectMake(self.scrolView.frame.origin.x, self.scrolView.frame.origin.y+(kKeyBoardHeight+20), self.scrolView.frame.size.width, self.scrolView.frame.size.height);
        }];
    }
}
-(void)clearTextfieldData:(UITextField *)selectedTxtField
{
    if (selectedTxtField.tag == kLocationTextfieldtag)
    {
        self.textDoctorName.text=@"";
        self.textLocation.text=@"";
        self.textSpeciality.text=@"";
        self.textTime.text=@"";
        
    }
    else if (selectedTxtField.tag == kSpecialityTextfiledTag)
    {
        self.textDoctorName.text=@"";
        self.textSpeciality.text=@"";
        self.textTime.text=@"";
        
    }
    else if (selectedTxtField.tag == kDoctorsTextfieldTag)
    {
        self.textDoctorName.text=@"";
        self.textTime.text=@"";
    }
    else if (selectedTxtField.tag == kDateTextfieldTag)
    {
        
        self.textTime.text=@"";
        if ([self.arrAppTime count])
        {
            [self.arrAppTime removeAllObjects];
        }
        
    }
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kBookAppSuccesTag && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (alertView.tag == kNoCreditsAlertTag && buttonIndex == 0)
    {
        [self emgCall];
    }
    if (alertView.tag == kBookAppSuccesTagFindDoctors && buttonIndex == 0)
    {
        [self performSegueWithIdentifier:@"appointmentList" sender:nil];
    }
    if (alertView.tag == 2) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"fromAppointment"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        SmartRxPaymentVC *paymentVc = [self.storyboard instantiateViewControllerWithIdentifier:@"econsultSpecialityView"];
        paymentVc.costValue = [NSString stringWithFormat:@"%ld", (long)finalCost];
        paymentVc.packageResponse = [[NSMutableDictionary alloc]init];
        paymentVc.packageResponse = self.packageResponse;
        [self.navigationController pushViewController:paymentVc animated:YES];
    }
    
    
}
-(void)emgCall
{
    
    NSString *number = [NSString stringWithFormat:@"%@",strFrontDeskNum];
    NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@",number]];
    
    //check  Call Function available only in iphone
    if([[UIApplication sharedApplication] canOpenURL:callUrl])
    {
        [[UIApplication sharedApplication] openURL:callUrl];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ALERT" message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}
#pragma mark - TextView Delegate method

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (![self.tblDoctorsList isHidden])
    {
        self.tblDoctorsList.hidden=YES;
    }
    self.lblTxtView.hidden=YES;
    self.imgTxtViwPecil.hidden=YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.scrolView.frame=CGRectMake(self.scrolView.frame.origin.x, self.scrolView.frame.origin.y-(20+kKeyBoardHeight), self.scrolView.frame.size.width, self.scrolView.frame.size.height);
    }];
    
    //    height=self.scrolView.frame.size.height - (textView.frame.origin.y+textView.frame.size.height);
    //    height=kKeyBoardHeight-height;
    //    [UIView animateWithDuration:0.2 animations:^{
    //
    //        self.scrolView.contentOffset=CGPointMake(self.scrolView.frame.origin.x, self.scrolView.frame.origin.y+height);
    //    }];
    
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.scrolView.frame=CGRectMake(self.scrolView.frame.origin.x, self.scrolView.frame.origin.y+(kKeyBoardHeight+20), self.scrolView.frame.size.width, self.scrolView.frame.size.height);
    }];
    if ([textView.text length] <=0)
    {
        self.lblTxtView.hidden=NO;
        self.imgTxtViwPecil.hidden=NO;
    }
    //    [UIView animateWithDuration:0.2 animations:^{
    //        self.scrolView.contentOffset=CGPointMake(0, 0);
    //    }];
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

-(void)numberKeyBoardReturn
{
    UIToolbar* numberToolbar;
    
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(retunWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.textReason.inputAccessoryView = numberToolbar;
}

-(void)retunWithNumberPad
{
    [self.textReason resignFirstResponder];
}

- (void)showPicker
{
    toolbarPicker = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-260, 320, 44)];
    toolbarPicker.barStyle = UIBarStyleBlackTranslucent; //UIBarStyleBlackOpaque;
    [toolbarPicker sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [barItems addObject:cancelBtn];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    flexSpace.width = 200.0f;
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [barItems addObject:doneBtn];
    
    
    [toolbarPicker setItems:barItems animated:YES];
    
    [self.actionSheet addSubview:toolbarPicker];
    [self.actionSheet addSubview:self.usersPickerView];
    [self.usersPickerView reloadAllComponents];
//    if (self.currentButton==self.locationButton)
//    {
//        [_actionSheet addSubview:self.locationPicker];
//        [self.locationPicker reloadAllComponents];
//    }
//    else if (self.currentButton==self.specialityButton)
//    {
//        [_actionSheet addSubview:self.specialityPicker];
//        [self.specialityPicker reloadAllComponents];
//    }
//    else if (self.currentButton==self.doctorButton)
//    {
//        [_actionSheet addSubview:self.doctorPicker];
//        [self.doctorPicker reloadAllComponents];
//        if ([self.doctorLbl.text isEqualToString:@"Any Doctor"])
//            [self.doctorPicker selectRow:0 inComponent:0 animated:NO];
//        
//    }
//    else if (self.currentButton == self.eConsultMethodBtn)
//    {
//        [_actionSheet addSubview:self.eConsultMethodPicker];
//        [self.eConsultMethodPicker reloadAllComponents];
//    }
//    else if (self.currentButton == self.timeButton)
//    {
//        [_actionSheet addSubview:self.timePicker];
//        [self.timePicker reloadAllComponents];
//    }
//    
    [self.view addSubview:_actionSheet];
    [self.view bringSubviewToFront:_actionSheet];
    _actionSheet.hidden = NO;
    
    
}


- (void)hidePromo
{
    self.promoApplyBtn.hidden = YES;
    self.promoCodeText.hidden = YES;
    self.closeImage.hidden = YES;
    self.payOptionView.frame = CGRectMake(self.payOptionView.frame.origin.x, self.promocodeView.frame.origin.y, self.payOptionView.frame.size.width, self.payOptionView.frame.size.height);
  
  
}

- (void)showPromo
{
    if (econ_auto_camp_count <= 0)
    {
        self.promoApplyBtn.hidden = NO;
        self.promoCodeText.hidden = NO;
        self.closeImage.hidden = NO;
         self.payOptionView.frame = CGRectMake(self.payOptionView.frame.origin.x, self.promocodeView.frame.origin.y+self.promocodeView.frame.size.height+14, self.payOptionView.frame.size.width, self.payOptionView.frame.size.height);
    }
    
}


#pragma mark - Picker View Delegate Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
//    return [self.arrLoadTbl count];
    return self.usersList.count;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (cellTextfield.tag == kSpecialityTextfiledTag)
    {
        return [[self.arrLoadTbl objectAtIndex:row]objectForKey:@"title"];
    }else if(cellTextfield.tag == kDoctorsTextfieldTag)
    {
        return [[self.arrLoadTbl objectAtIndex:row]objectForKey:@"dispname"];
    }
    else
    {
        UsersResponseModel *model = self.usersList[row];
        return model.patientName;
    }
    
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //NSLog(@"selected Component === %@",[[self.arrLoadTbl objectAtIndex:row]objectForKey:@"title"]);
}

#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestBookAppointmentWithOutPayment];
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

#pragma mark - prepareForSegue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((SmartRxAppointmentsVC *)segue.destinationViewController).fromFindDoctors = YES;
}

@end


