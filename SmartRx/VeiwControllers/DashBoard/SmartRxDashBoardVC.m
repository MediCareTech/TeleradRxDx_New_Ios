//
//  SmartRxDashBoardVC.m
//  SmartRx
//
//  Created by PaceWisdom on 08/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxDashBoardVC.h"
#import "SmartRxLoginViewController.h"
#import "SmartRxMessageViewController.h"
#import "UIImageView+WebCache.h"
#import "MenuTableViewCell.h"
#import "SmartRxConnectDBVC.h"
#import "CVCell.h"
#import "SmartRxCallCareTVC.h"
#import "ServiceTypeManager.h"
#import "ProviderServiesHandler.h"
#import "SmartRxTipsDetailVC.h"
#import "ServicesResponseModel.h"
#import "SmartRxCartViewController.h"
#import "SmartRxBookeConsultVC.h"
#import "SmartRxSecondOpinionDBVC.h"
#import "SmartRxBookedServicesController.h"
#import "SmartRxBookServicesController.h"
#import "UserDetails.h"
#import "SmartRxAboutUsVC.h"
#import "SmartRxBookAppoitmentController.h"


#define kLessThan4Inch 560
#define kLogoutAlertTag 800
#define kAlertLogin 1200
#define pwdResetSuccess 700
#define pwdResetFailure 1400
#define aggrementBtnTag 1500
#define kCallCareCellHeight 51
#define fExpied_Token      @"expired_token"

@interface SmartRxDashBoardVC ()
{
    NSString *name, *msgCount;
    NSArray *arrCallCareImages;
    CGSize viewSize;
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    BOOL isLogin;
    NSMutableDictionary *dictResponse;
    UIRefreshControl *refreshControl;
    BOOL bIsMenuSel, bIsResetPwdSel, fromMenu;
    NSString *termsString, *privacyString, *disclaimerString, *password, *resetPassword,*bannerServiceId,*bannerProviderId;
}
@property(nonatomic,strong) NSArray *offersAndTipsArr;
@end

@implementation SmartRxDashBoardVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)checkForAgreement
{
    [self SetNavigationBarItems];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        if (self.acceptAgreement == 0)
        {
            [self.termsOfUseAgreeBtn setTitle:@"AGREE" forState:UIControlStateNormal];
            fromMenu = NO;
            [self makeRequestToGetAggrementData];
        }
        //            [self loadTermsOfUseView];
    }
}
-(void)SetNavigationBarItems
{
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *faqBtnImag = [UIImage imageNamed:@"icon_list.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    
    [btnFaq addTarget:self action:@selector(menuBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
    
}
-(void)logoutBtnClicked:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Logout" message:@"Are you sure? Do you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
        alert.tag=kLogoutAlertTag;
        [alert show];
        alert=nil;
    }
}

#pragma mark -View LIfe Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"fitbitToken.....:%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"fitbitToken"]);
    self.navigationItem.hidesBackButton=YES;
    password = nil;
    resetPassword = nil;
    self.retypePassword.text = nil;
    self.password.text = nil;
    viewSize=[[UIScreen mainScreen]bounds].size;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    dictResponse = [[NSMutableDictionary alloc] init];
    _arrCallCareTeam = [[NSMutableArray alloc] initWithArray:@[@"Emergency",@"Phone Call",]];
    arrCallCareImages=[[NSArray alloc]initWithObjects:@"emergency_new.png",@"phone_CALL.png",@"emergency_message.png", nil];
    /* uncomment this block to use subclassed cells */
    [self.collectionView registerClass:[CVCell class] forCellWithReuseIdentifier:@"cvCell"];
    /* end of subclass-based cells block */
    
    // Configure layout
    //    CGSize viewFrame = [UIScreen mainScreen].bounds.size;
    //    viewFrame.height -= self.collectionView.frame.origin.y;
    //    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    //    [flowLayout setItemSize:CGSizeMake((viewFrame.width/3)-10, (viewFrame.height/2)-10)];
    //    [self.collectionView setCollectionViewLayout:flowLayout];
    
    CGSize viewFrame = [UIScreen mainScreen].bounds.size;
    viewFrame.height = viewFrame.height - (self.collectionView.frame.origin.y + self.btnEmergency.frame.size.height+30);
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake((viewFrame.width/3)-10, viewFrame.height/2)];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x, self.imagePager.frame.origin.y+self.imagePager.frame.size.height+10, self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    //Adding image on Navigation bar
    bIsMenuSel = NO;
    bIsResetPwdSel = NO;
    if (viewSize.height < kLessThan4Inch)
    {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height+self.btnEmergency.frame.origin.y+self.btnEmergency.frame.size.height)];
        
    }
    isLogin=NO;
    _arrMenuImages=[[NSArray alloc]initWithObjects:@"icn_home_DB.png",@"icn_profile.png",@"icn_hospital.png",@"icn_refresh.png",@"key.png",@"icn_logout_menu.png", nil];
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    self.password.inputAccessoryView = doneToolbar;
    self.retypePassword.inputAccessoryView = doneToolbar;
    [_tblCallCareTeam setTableFooterView:[UIView new]];
    
    
    
    
}
- (void)doneButton:(id)sender
{
    [self.password resignFirstResponder];
    [self.retypePassword resignFirstResponder];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    _imagePager.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    _imagePager.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    _imagePager.slideshowTimeInterval = 5.5f;
    _imagePager.slideshowShouldCallScrollToDelegate = YES;
    _imagePager.imageCounterDisabled = YES;
    
    //    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    //    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    //    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    //    NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
    
    self.acceptAgreement = [[[NSUserDefaults standardUserDefaults] objectForKey:@"agstatus"] integerValue];
    [self checkForAgreement];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
        _arrMenu=[[NSArray alloc]initWithObjects:@"Book E-Consult",@"Book Services",@"Book Appointment",@"Assessments",@"Chat",@"My Locations",@"View Profile",@"Settings",@"Change Password",@"Terms of use",@"Logout", nil];
    else
        _arrMenu=[[NSArray alloc]initWithObjects:@"Login",@"Get Care Plan", @"Book E-Consult", @"Book Appointment", @"Book Services", nil];
    bIsMenuSel = NO;
    password = nil;
    resetPassword = nil;
    self.retypePassword.text = nil;
    self.password.text = nil;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"])
            name = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"];
        //            self.lblLoginTitle.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"];
    }
    else
    {
        self.lblLoginTitle.text=@"Login";
        name = @"Login";
    }
    
    //    [self.navigationController.navigationBar setTitleTextAttributes:
    //                    [NSDictionary dictionaryWithObjectsAndKeys:
    //                        [UIFont boldSystemFontOfSize:17],NSFontAttributeName, nil]];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    
    if ( [[NSUserDefaults standardUserDefaults]boolForKey:@"PushNotes"] == YES)
    {
        [self messagesBtnClicked:nil];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"PushNotes"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
    {
        //        [self performSegueWithIdentifier:@"eConsultVC" sender:nil];
        [self performSegueWithIdentifier:@"ConnectID" sender:nil];
    }
    else if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        isLogin=YES;
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForNumberOfMessages];
        }
        else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }
    }
    else
    {
        self.lblAppCount.text=@"0";
        self.lblMsgs.text=@"0";
    }
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logooo"]];
    UIView *myView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 100, 44)];
    imageView.frame = CGRectMake(0, 0, 100, 40);
    [myView addSubview:imageView];
    self.navigationItem.titleView = myView;
    
    // = [NSString stringWithFormat:@"%@\n%@", stringHosName, name];
    
    //logo code
    
    //    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"logo"] length] > 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"logo"] && [[NSUserDefaults standardUserDefaults]objectForKey:@"logo"] != [NSNull null])
    //    {
    //        //logo_DB.png
    //        //smartIcon.png
    //        UIImageView *imgViewIcon=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logooo"]];
    //        //change
    //      [imgViewIcon  sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/%@",kAdminBaseUrl,[[NSUserDefaults standardUserDefaults]objectForKey:@"logo"]]] placeholderImage:[UIImage imageNamed:@"logooo"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
    //          NSString *title, *stringHosName;
    //
    //              UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //              [negativeSpacer setWidth:-5];
    //
    //              imgViewIcon.frame = CGRectMake(0, 0, imgViewIcon.frame.size.width+10, imgViewIcon.frame.size.height);
    //              UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:imgViewIcon];
    //              [item setWidth:imgViewIcon.frame.size.width];
    //              if ([[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"])
    //              {
    //                  stringHosName = [[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
    //              }
    //              else
    //              {
    //                  [[NSUserDefaults standardUserDefaults]setObject:@"Guest" forKey:@"HosName"];
    //                  [[NSUserDefaults standardUserDefaults]synchronize];
    //                  stringHosName=[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
    //              }
    //
    //              title = [NSString stringWithFormat:@"%@\n%@", stringHosName, name];
    //              NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:title];
    //              [attrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize: 15.0f] range:NSMakeRange(0, [title length])];
    //              UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(-20, 0, 220, 44)];
    //              label.numberOfLines =0;
    //              label.textColor = [UIColor whiteColor];
    //              label.attributedText = attrString;
    //              UIBarButtonItem *titleView = [[UIBarButtonItem alloc] initWithCustomView:label];
    //              UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logooo"]];
    //              UIView *myView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 100, 44)];
    //              imageView.frame = CGRectMake(0, 0, 100, 40);
    //              [myView addSubview:imageView];
    //              self.navigationItem.titleView = myView;
    //              //self.navigationItem.leftBarButtonItem = item;
    //              //self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,item, titleView,nil];
    //
    //      }];
    //    }
    //    else
    //    {
    //         NSString *title, *stringHosName;
    //      //smartIcon.png
    //        UIImageView *imgViewIcon=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logooo"]];
    //
    //        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //        [negativeSpacer setWidth:-5];
    //
    //        imgViewIcon.frame = CGRectMake(0, 0, imgViewIcon.frame.size.width+20, imgViewIcon.frame.size.height);
    //
    //        UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:imgViewIcon];
    //
    //        [item setWidth:imgViewIcon.frame.size.width];
    //
    //        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"])
    //        {
    //            stringHosName = [[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
    //        }
    //        else
    //        {
    //            [[NSUserDefaults standardUserDefaults]setObject:@"Guest" forKey:@"HosName"];
    //            [[NSUserDefaults standardUserDefaults]synchronize];
    //            stringHosName=[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
    //        }
    //
    //        title = [NSString stringWithFormat:@"%@\n%@", stringHosName, name];
    //        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:title];
    //        [attrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize: 15.0f] range:NSMakeRange(0, [title length])];
    //        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(-20, 0, 220, 44)];
    //        label.numberOfLines =0;
    //        label.textColor = [UIColor whiteColor];
    //        label.attributedText = attrString;
    //        UIBarButtonItem *titleView = [[UIBarButtonItem alloc] initWithCustomView:label];
    //
    //        //self.navigationItem.leftBarButtonItem = item;
    //        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,item, titleView,nil];
    //    }
    //    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"] && [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"])
    //    {
    ////        [self makeRequestForUserRegister];
    //    }
    //
    
}
-(void)makeRequestForUserRegister
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    
    [self addSpinnerView];
    
    NSString *strMobNum=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    NSString *strCodee=[[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",strMobNum];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"code",strCodee]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mregister"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 13 %@",response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            [[NSUserDefaults standardUserDefaults]setObject:strCodee forKey:@"code"];
            [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cidd"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [self performSegueWithIdentifier:@"RegisterID" sender:[response objectForKey:@"cid"]];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cid"];
                NSString *strFrontDestNum=[[response objectForKey:@"hinfo"]objectForKey:@"frontDeskNo" ];
                
                [[NSUserDefaults standardUserDefaults]setObject:strFrontDestNum forKey:@"EmNumber"];
                
                NSString *strHospName=[[response objectForKey:@"hinfo"]objectForKey:@"hospitalName" ];
                
                [[NSUserDefaults standardUserDefaults]setObject:strHospName forKey:@"HosName"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                //[self customAlertView:@"User already registered" Message:@"Login now" tag:kRegistredUserAlertTag];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            [[NSUserDefaults standardUserDefaults] setObject:[[response objectForKey:@"hinfo"] objectForKey:@"splash_screen"] forKey:@"splash_screen"];//logo
            if ([[response objectForKey:@"hinfo"] objectForKey:@"mlogo"] && [[response objectForKey:@"hinfo"] objectForKey:@"mlogo"] != [NSNull null])
                [[NSUserDefaults standardUserDefaults] setObject:[[response objectForKey:@"hinfo"] objectForKey:@"mlogo"] forKey:@"logo"];
            else
                [[NSUserDefaults standardUserDefaults] setObject:[[response objectForKey:@"hinfo"] objectForKey:@"logo"] forKey:@"logo"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            //[[NSUserDefaults standardUserDefaults]setObject:self.txtMobile.text forKey:@"MobilNumber"];
            
        });
    } failureHandler:^(id response) {
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Error occur" Message:@"Try again" tag:0];
        
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark -Requesting To server
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

-(void)makeRequestForFitbitData:(NSString *)previousTime{
    
    if ([previousTime integerValue] == 0) {
        NSLog(@"time is 0:%@",previousTime);
        previousTime = @"00:00";
    }
    NSLog(@"time is:%@",previousTime);
    
    NSString *urlStr = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/heart/date/%@/1d/5min/time/%@/%ld:%ld.json",[self currentDate],previousTime,[self currentHour],[self currentMinute]];
    
    // NSString *urlStr = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/heart/date/%@/1d/5min.json",[self currentDate]];
    
    NSLog(@"fitbit url......:%@",urlStr);
    NSString *fitbitToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fitbitToken"];
    NSLog(@"fitbit token......:%@",fitbitToken);
    
    SmartRxCommonClass *manager = [SmartRxCommonClass sharedManager];
    //********** Pass your API here and get details in response **********
    
    [manager requestGETFitbitData:urlStr Token:fitbitToken success:^(NSDictionary *responseObject) {
        // ------ response -----
        dispatch_async(dispatch_get_main_queue(),^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            
            NSArray *heartBeatArr = responseObject[@"activities-heart-intraday"][@"dataset"];
            
            NSLog(@"response1............:%@",responseObject);
            
            NSLog(@"heartBeatArr............:%@",heartBeatArr);
            
            if (heartBeatArr.count) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                    [self makeRequestForPushFitbitData:heartBeatArr];
                });
                
            }
            
        });
        
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(),^{
            [HUD hide:YES];
            [HUD removeFromSuperview];
            
            NSLog(@"error............:%@",error.userInfo);
            NSDictionary *userInfo = error.userInfo;
            NSLog(@"error code.....:%ld",(long)error.code);
            if (error.code == 401 && [userInfo[@"errorType"] isEqualToString:fExpied_Token])  {
                NSLog(@"token expired");
                // [self makeRequetForRevokeFitbitToken];
            }
        });
    }];
}
-(void)makeRequestForPushFitbitData:(NSArray *)fitbitInfo{
    
    //    if (![HUD isHidden]) {
    //        [HUD hide:YES];
    //    }
    //    [self addSpinnerView];
    NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"r_statistic",@"record_type",@"8",@"a_statistic_id",userId,@"member_id",@"",@"entry_id",fitbitInfo,@"value",@"2",@"entry_type", nil];
    NSLog(@"fitbit info.....:%@",info);
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"ehr/insbulk"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *bodyText=nil;
    bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSLog(@"bodyText.....:%@",bodyText);
    
    NSMutableData *postData = [[NSMutableData alloc]initWithData:[[NSString stringWithFormat:@"%@",bodyText ] dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
    
    [postData appendData:[[NSString stringWithFormat:@"&data_items="] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:data];
    [request setHTTPBody:postData];
    NSString *cokie = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    
    if (cokie) {
        [request addValue:cokie forHTTPHeaderField:@"Cookie"];
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *  data, NSURLResponse *  response, NSError *  error) {
        if (!error) {
            id responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"responseData.....:%@",responseData);
            
        }else{
            NSLog(@"error.....:%@",error);
        }
    }];
    [dataTask resume];
    
    //    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO successHandler:^(id response) {
    //        NSLog(@"success handler:%@",response);
    //    } failureHandler:^(id response) {
    //        NSLog(@"failure handler");
    //
    //    }];
}
- (void)makeRequestToResetPassword
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"sessionid",sectionId, @"txtpass", self.password.text];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mcpass"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
     {
         NSLog(@"sucess 15 %@",response);
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             if ([[response objectForKey:@"cpstatus"] integerValue] == 1)
             {
                 [self customAlertView:@"" Message:@"Password reset successfully. Please relogin using new password." tag:pwdResetSuccess];
             }
             else{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [spinner stopAnimating];
                     [spinner removeFromSuperview];
                     spinner = nil;
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     [self customAlertView:@"" Message:@"Password reset failed. Please try again." tag:pwdResetSuccess];
                 });
             }
             
         } }failureHandler:^(id response) {
             NSLog(@"failure %@",response);
             [HUD hide:YES];
             [HUD removeFromSuperview];
         }];
}
- (void)makeRequestToGetAggrementData
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"magreeview"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
     {
         NSLog(@"sucess 14 %@",response);
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 if ([[response objectForKey:@"result"]integerValue] == 0)
                 {
                     SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                     smartLogin.loginDelegate=self;
                     [smartLogin makeLoginRequest];
                     [self makeRequestToGetAggrementData];
                 }
                 else
                 {
                     termsString = [response objectForKey:@"tc"];
                     privacyString = [response objectForKey:@"privacy"];
                     disclaimerString = [response objectForKey:@"disc"];
                     [self showTermsOfUse];
                 }
             });
         } }failureHandler:^(id response) {
             NSLog(@"failure %@",response);
             [HUD hide:YES];
             [HUD removeFromSuperview];
         }];
}
- (void)showTermsOfUse
{
    self.navigationItem.rightBarButtonItem = nil;
    self.termOfUseSelectedView.hidden = NO;
    self.privacySelectedView.hidden = YES;
    self.disclaimerSelectedView.hidden = YES;
    [self.webView loadHTMLString:termsString baseURL:nil];
    [self loadTermsOfUseView];
    [HUD hide:YES];
    [HUD removeFromSuperview];
}
- (void)makeRequestForUserAggrement
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"magree"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
     {
         NSLog(@"sucess 16 %@",response);
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 if ([[response objectForKey:@"result"]integerValue] == 0)
                 {
                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error occured. Please re-login to continue" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Logout", nil];
                     alert.tag=kLogoutAlertTag;
                     [alert show];
                     alert=nil;
                 }
                 else
                 {
                     if ([[response objectForKey:@"result"]integerValue] == 0)
                     {
                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error occured. Please re-login to continue" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Logout", nil];
                         alert.tag=kLogoutAlertTag;
                         [alert show];
                         alert=nil;
                     }
                     else
                     {
                         [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"astatus"] forKey:@"agstatus"];
                         [self hideTermsOfUseView];
                         [self SetNavigationBarItems];
                         [HUD hide:YES];
                     }
                 }
             });
         } }failureHandler:^(id response) {
             NSLog(@"failure %@",response);
             [HUD hide:YES];
             [HUD removeFromSuperview];
         }];
    
}
-(void)makeRequestForNumberOfMessages
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    //47a96d653e978354dd447d9e7b68cef6
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mdash"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
     {
         NSLog(@"sucess 17 %@",response);
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             if ([[[response objectAtIndex:0] objectForKey:@"authorized"]integerValue] == 0 && [[[response objectAtIndex:0] objectForKey:@"result"]integerValue] == 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
             {
                 SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                 smartLogin.loginDelegate=self;
                 [smartLogin makeLoginRequest];
                 
             }
             else{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [spinner stopAnimating];
                     [spinner removeFromSuperview];
                     spinner = nil;
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     dictResponse = [response objectAtIndex:0];
                     NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
                     NSString *version = infoDictionary[@"CFBundleShortVersionString"];
                     double appVersion = [version doubleValue];
                     NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
                     NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
                     double serverVersion = [[[response objectAtIndex:0] objectForKey:@"ios_app_version"] doubleValue];
                     if (serverVersion > [[[NSUserDefaults standardUserDefaults] objectForKey:@"versionNumber"] doubleValue])
                     {
                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showUpdateAlert"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                     }
                     
                     if (serverVersion > appVersion && [[[NSUserDefaults standardUserDefaults] objectForKey:@"showUpdateAlert"] boolValue])
                     {
                         [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showUpdateAlert"];
                         [[NSUserDefaults standardUserDefaults] setDouble:serverVersion forKey:@"versionNumber"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Update(s) Available" message:@"There is a new version of Medcall Member available. Would you like to download now or later?" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Now", nil];
                         alert.tag=9909;
                         [alert show];
                         alert=nil;
                         
                     }
                     
                     
                     NSString *quikWeelID = [[response objectAtIndex:0] objectForKey:@"QikwellID"];
                     [UserDetails setQikWellApi:[[response objectAtIndex:0] objectForKey:@"QikwellAppUrl"]];
                     if ([quikWeelID isKindOfClass:[NSString class] ]) {
                         
                         [UserDetails setQikWellId:[[response objectAtIndex:0] objectForKey:@"QikwellID"]];
                     }
                     
                     self.view.userInteractionEnabled = YES;
                     ProviderServiesHandler *handler = [ProviderServiesHandler sharedInstance];
                     handler.providerServicesArr = response[0][@"provider_service_types"];
                     //self.arrMsgs=[response objectForKey:@"msg"];
                     self.lblMsgs.text=[NSString stringWithFormat:@"%@",[[response objectAtIndex:0] objectForKey:@"unreadmsg"]];//[NSString stringWithFormat:@"%d",[self.arrMsgs count]];
                     self.lblAppCount.text=[NSString stringWithFormat:@"%@",[[response objectAtIndex:0] objectForKey:@"aptc"]];
                     msgCount = [NSString stringWithFormat:@"%@",[[response objectAtIndex:0] objectForKey:@"aptc"]];
                     [[NSUserDefaults standardUserDefaults] setObject:[[response objectAtIndex:0] objectForKey:@"lmsg"] forKey:@"strLastMsgId"];
                     if ([response[0][@"membership_type"] isKindOfClass:[NSString class]]) {
                         [[NSUserDefaults standardUserDefaults] setObject:[[response objectAtIndex:0] objectForKey:@"membership_type"] forKey:@"membership"];
                         
                     }else {
                         [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"membership"];
                         
                     }
                     if ([response[0][@"mem_end_date"] isKindOfClass:[NSString class]]) {
                         [[NSUserDefaults standardUserDefaults] setObject:[[response objectAtIndex:0] objectForKey:@"mem_end_date"] forKey:@"membership_enddate"];
                     }
                     [[NSUserDefaults standardUserDefaults] setObject:[[response objectAtIndex:0] objectForKey:@"enabled"] forKey:@"enabledServices"];
                     if ([response[0][@"assess_count"] isKindOfClass:[NSString class]]) {
                         [[NSUserDefaults standardUserDefaults] setObject:[[response objectAtIndex:0] objectForKey:@"assess_count"] forKey:@"assessmentCount"];
                         
                     }else {
                         [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"assessmentCount"];
                     }
                     
                     [[NSUserDefaults standardUserDefaults] setObject:[[response objectAtIndex:0] objectForKey:@"credit_setting"] forKey:@"creditSettings"];
                     
                     NSString *enabledStr = response[0][@"enabled"];
                     NSArray *enableArr = [enabledStr componentsSeparatedByString:@"*"];
                     if ([enableArr containsObject:@"13"]) {
                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SecondOpinionEnable"];
                         _arrMenu=[[NSArray alloc]initWithObjects:@"Book E-Consult",@"Book Services",@"Book Appointment",@"Assessments",@"Chat",@"My Locations",@"View Profile",@"Settings",@"Change Password",@"Terms of use",@"Logout", nil];
                         
                     }else {
                         [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SecondOpinionEnable"];
                         _arrMenu=[[NSArray alloc]initWithObjects:@"Book E-Consult",@"Book Services",@"Book Appointment",@"Assessments",@"Chat",@"My Locations",@"View Profile",@"Settings",@"Change Password",@"Terms of use",@"Logout", nil];
                         
                     }
                     [self.tblMenu reloadData];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     self.numberOfMsgs=[[[response objectAtIndex:0] objectForKey:@"unreadmsg"] integerValue];
                     
                     ServiceTypeManager *manger = [ServiceTypeManager sharedManager];
                     NSArray *arr = response[0][@"provider_service_types"];
                     manger.serviceArray = response[0][@"provider_service_types"];
                     
                     NSArray *offersArr = response[0][@"offers"];
                     NSArray *tipsArr = response[0][@"tips"];
                     
                     NSMutableArray *offersTipsArr = [[NSMutableArray alloc]init];
                     
                     for (NSDictionary *dict in offersArr) {
                         [offersTipsArr addObject:dict];
                     }
                     
                     for (NSDictionary *dict in tipsArr) {
                         [offersTipsArr addObject:dict];
                     }
                     
                     self.offersAndTipsArr = [offersTipsArr copy];
                     NSLog(@"offers array.....:%@",self.offersAndTipsArr);
                     [self.view bringSubviewToFront:self.lblMsgs];
                     [self.view bringSubviewToFront:self.lblAppCount];
                     [self.imagePager reloadData];
                     [self.collectionView reloadData];
                     
                     if ([[NSUserDefaults standardUserDefaults]boolForKey:@"fitbitAccess"]) {
                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                             [self makeRequestForFitbitData:response[0][@"time_stamp"]];
                         });
                     }
                 });
             }
             
         } }failureHandler:^(id response) {
             NSLog(@"failure %@",response);
             [HUD hide:YES];
             [HUD removeFromSuperview];
         }];
}
-(void)makeRequestForServiceDetails:(NSString *)serviceId{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&id=%@",@"sessionid",sectionId,serviceId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrlLabReport,@"provider_services/view"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        
        if (response == nil)
        {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            [self customAlertView:@"" Message:@"Internal server error" tag:0];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                NSDictionary *dict = (NSDictionary *)(response);
                ServicesResponseModel *model = [[ServicesResponseModel alloc]init];
                
                model.serviceName = dict[@"name"];
                model.serviceId = dict[@"user"][@"recno"];
                //model.serviceprice = [NSString stringWithFormat:@"%ld",[dict[@"price"] integerValue]];
                model.serviceprice = [NSString stringWithFormat:@"%ld",[dict[@"original_price"] integerValue]];
                
                model.servicediscountprice = [NSString stringWithFormat:@"%ld",[dict[@"effective_price"] integerValue]];
                
                // model.servicediscountprice = [self discountCalculation:dict[@"discount"]  ActualPrice:model.serviceprice];
                
                model.serviceDescription = dict[@"description"];
                model.providerName = dict[@"user"][@"dispname"];
                model.instructions = dict[@"instructions"];
                model.imagePath = dict[@"user"][@"logo_path"];
                model.isScheduled = YES;
                
                //model.isScheduled = [dict[@"is_scheduled"] boolValue];
                int type = [dict[@"service_type"] intValue];
                
                model.serviceType = [NSString stringWithFormat:@"%d",type];
                model.providerId = [NSString stringWithFormat:@"%ld",[dict[@"id"] integerValue]];
                
                model.providerServiceId = [NSString stringWithFormat:@"%d",[dict[@"user"][@"recno"] integerValue]];
                
                int locationType = [dict[@"home_collection"] intValue];;
                model.serviceLocation  = [NSString stringWithFormat:@"%d",locationType];
                
                SmartRxCartViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"cartViewController"];
                controller.selectedService = model;
                [self.navigationController pushViewController:controller animated:YES];
            });
        }
    }failureHandler:^(id response) {
        
        NSLog(@"failure %@",response);
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Logout" message:@"Logout failed due to network issues. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
}
-(void)makeRequestToLogout
{
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    
    [self addSpinnerView];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlogout"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 15 %@",response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            if ([[[response objectAtIndex:0] objectForKey:@"result"]intValue] == 1)
            {
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"sessionid"];
                //                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"HosName"];
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserName"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [self clearLoginDetailAtLogout];
                //[[SmartRxDB sharedDBManager] clearDatbaseWhenUserLogout];
                [self performSegueWithIdentifier:@"DBLoginID" sender:@"Lougout"];
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Logout" message:@"Logout failed due to network issues. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
                alert=nil;
                
            }
            
        });
    } failureHandler:^(id response) {
        
        NSLog(@"failure %@",response);
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Logout" message:@"Logout failed due to network issues. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}
-(void)clearLoginDetailAtLogout
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"sessionid"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"session_name"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserName"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"hosid"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"gender"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"mtrackertype"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"age"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"recno"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"dispname"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"Password"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"MobileNumber"];
    //    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"MRNumber"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"refdocname"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"KeepMeLogin"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey: @"comorbidits"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"fitbitAccess"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey: @"assessmentCount"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey: @"membership"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey: @"credit_setting"];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

#pragma mark -Action Methods
- (IBAction)connectBtnClicked:(id)sender {
    [self performSegueWithIdentifier:@"ConnectID" sender:nil];
}

- (IBAction)carePlansBtnClicked:(id)sender {
    //getCareplan
    //managedCarePlanVC
    //DBCarePlanID
    //carePlanDashVc
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        [self performSegueWithIdentifier:@"carePlanDashVc" sender:nil];
    }
    // else
    //    {
    //        [self performSegueWithIdentifier:@"getCareplan" sender:nil];
    //    }
    //
}
- (IBAction)appointmentsBtnClicked:(id)sender
{
    
    NSString *emailStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"emailId"];
    if (emailStr.length <= 0) {
        [self customAlertView:@"" Message:@"Please Update the Email and DOB" tag:222];
        //[self performSegueWithIdentifier:@"EditProfileID" sender:nil];
    } else {
        
        if (sender != nil) {
            [self performSegueWithIdentifier:@"consultationList" sender:nil];
            
        }else {
            if ([self getServiceAvailablity:@"14"]) {
                SmartRxBookedServicesController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"servicesController"];
                NSLog(@"servicie controller......:%@",controller);
                [self.navigationController pushViewController:controller animated:YES];            }
            else {
                [self customAlertView:@"" Message:@"This service is not available for you." tag:0];
            }
            
        }
        
    }
    //    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    //    {
    
    //    }
    //    else
    //    {
    //        [self performSegueWithIdentifier:@"bookApt" sender:nil];
    //    }
    
}

- (IBAction)hsBtnClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"HsDashboardId" sender:nil];
    
}

- (IBAction)messagesBtnClicked:(id)sender {
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        [self performSegueWithIdentifier:@"DBMessagesID" sender:nil];
    }
    else
    {
        [self showALertView];
    }
}

- (IBAction)myRecordsBtnClicked:(id)sender {
    NSLog(@"Into records thing.");
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        [self performSegueWithIdentifier:@"MyRecordID" sender:nil];
    }
    else
    {
        [self showALertView];
    }
    
}

- (IBAction)loginBtnClicked:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"])
        [self performSegueWithIdentifier:@"EditProfileID" sender:nil];
    else
        [self performSegueWithIdentifier:@"DBLoginID" sender:@"Login"];
}


- (IBAction)callCareCancelBtnClicked:(id)sender
{
    
    _tblCallCareTeam.delegate=nil;
    _tblCallCareTeam.dataSource=nil;
    _viwCallCareTeam.hidden = YES;
    
}

- (IBAction)emergencyBtnClicked:(id)sender
{
    
    //    [self emgCall];
    
    if ([_arrCallCareTeam count])
        [self loadCallCareTeam];
    else
        [self customAlertView:@"Contact details not provided by the hospital" Message:@"'" tag:0];
    
    //    NSURL *phoneNumberURL = [NSURL URLWithString:@"tel:80001212"];
    //    [[UIApplication sharedApplication] openURL:phoneNumberURL];
}

- (IBAction)profileBtnClicked:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        [self performSegueWithIdentifier:@"EditProfileID" sender:nil];
    }
    else
    {
        [self showALertView];
    }
    
}

- (IBAction)resetPwdClicked:(id)sender
{
    if ([self.password.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter password"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self.retypePassword.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Please retype your password"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self.password.text length] < 6)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Your password should have atleast 6 characters"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self.password.text length] > 12)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Your password should have minimum of 6 and maximum of 12 characters"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if (![self.retypePassword.text isEqualToString:self.password.text])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Password mismatch. Please retype your password"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self makeRequestToResetPassword];
    }
    
}

- (IBAction)resetPwdCancelClicked:(id)sender
{
    password = nil;
    resetPassword = nil;
    self.retypePassword.text = nil;
    self.password.text = nil;
    [self hideResetPasswordView];
}
-(void)emgCall
{
    NSString *phoneNumber=nil;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"EmNumber"])
    {
        phoneNumber=[[NSUserDefaults standardUserDefaults]objectForKey:@"EmNumber"];
    }
    else
        phoneNumber=@"9986589899";
    
    NSString *number = [NSString stringWithFormat:@"%@",phoneNumber];
    NSURL* callUrl=[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",number]];
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

-(IBAction)menuBtnClicked:(id)sender
{
    if (bIsResetPwdSel)
        [self hideResetPasswordView];
    if (!bIsMenuSel)
    {
        [_tblMenu reloadData];
        [self loadMenu];
    }
    else
        [self hideMenu];
}


- (IBAction)termsOfUseBtnClicked:(id)sender
{
    self.termOfUseSelectedView.hidden = NO;
    self.privacySelectedView.hidden = YES;
    self.disclaimerSelectedView.hidden = YES;
    [self.webView loadHTMLString:termsString baseURL:nil];
    
    //    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //    [self.webView loadRequest:request];
}

- (IBAction)privacyBtnClicked:(id)sender
{
    self.termOfUseSelectedView.hidden = YES;
    self.privacySelectedView.hidden = NO;
    self.disclaimerSelectedView.hidden = YES;
    [self.webView loadHTMLString:privacyString baseURL:nil];
}

- (IBAction)disclaimerBtnClicked:(id)sender
{
    self.termOfUseSelectedView.hidden = YES;
    self.privacySelectedView.hidden = YES;
    self.disclaimerSelectedView.hidden = NO;
    [self.webView loadHTMLString:disclaimerString baseURL:nil];
}

- (IBAction)agreeBtnClicked:(id)sender
{
    if (fromMenu)
    {
        [self hideTermsOfUseView];
        [self SetNavigationBarItems];
        [HUD hide:YES];
    }
    else
        
        [self makeRequestForUserAggrement];
}

- (IBAction)hideMenuBtnClicked:(id)sender
{
    [self hideMenu];
}
-(IBAction)clickOnChatButton:(id)sender{
    [self performSegueWithIdentifier:@"chatListVc" sender:nil];
}
#pragma mark -prepare Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DBLoginID"])
    {
        ((SmartRxLoginViewController *)segue.destinationViewController).strIsLogout=sender;
    }
    if ([segue.identifier isEqualToString:@"DBMessagesID"])
    {
        
        ((SmartRxMessageViewController *)segue.destinationViewController).strLastMsgId=[[NSUserDefaults standardUserDefaults] objectForKey:@"strLastMsgId"];
        ((SmartRxMessageViewController *)segue.destinationViewController).numberOfMsgs=self.numberOfMsgs;
    }
    if ([segue.identifier isEqualToString:@"ConnectID"])
    {
        
        ((SmartRxConnectDBVC *)segue.destinationViewController).strQuid=[dictResponse objectForKey:@"lqa"];
        ((SmartRxConnectDBVC *)segue.destinationViewController).numberOfQustns=[[dictResponse objectForKey:@"qa"]integerValue];
    }
    if ([segue.identifier isEqualToString:@"tipsVc"]) {
        SmartRxTipsDetailVC *controller = segue.destinationViewController;
        controller.selectedTip = sender;
    }
    if ([segue.identifier isEqualToString:@"eConsult_book"]) {
        SmartRxBookeConsultVC *controller =segue.destinationViewController;
        //secondOpinionVc
        
    }if ([segue.identifier isEqualToString:@"secondOpinionVc"]) {
        SmartRxSecondOpinionDBVC *controller =segue.destinationViewController;
        controller.fromVc = @"dashBoardVc";
        //secondOpinionVc
        
    } if ([segue.identifier isEqualToString:@"newServicesVC"]) {
        NSLog(@"service id.....:%@",bannerServiceId);
        NSLog(@"provider id.....:%@",bannerProviderId);
        SmartRxBookServicesController *controller = segue.destinationViewController;
        controller.selectedServiceId = bannerServiceId;
        controller.selectedProviderId = bannerProviderId;
    }
    
}
-(void)showALertView
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Login required" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag=kAlertLogin;
    [alert show];
    alert=nil;
}
#pragma mark - Alert View Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kLogoutAlertTag && buttonIndex == 1)
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestToLogout];
        }
        else{
            
            [self customAlertView:@"" Message:@"Network not available" tag:0];
            
        }
        
    }
    else if (alertView.tag == kAlertLogin && buttonIndex == 0)
    {
        [self performSegueWithIdentifier:@"DBLoginID" sender:@"Login"];
    }
    else if (alertView.tag == pwdResetSuccess)
    {
        [self hideResetPasswordView];
        [self makeRequestToLogout];
    } else if (alertView.tag == 222){
        [self performSegueWithIdentifier:@"EditProfileID" sender:nil];
    }
}
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

#pragma mark - Menu Methods
- (void)loadResetPasswordView
{
    [self.view bringSubviewToFront:_viewReset];
    [UIView animateWithDuration:0.2 animations:^{
        _viewReset.frame=CGRectMake(0,  _viewReset.frame.origin.y,  _viewReset.frame.size.width,  _viewReset.frame.size.height);
    } completion:^(BOOL finished) {
        bIsResetPwdSel=YES;
        bIsMenuSel = NO;
    }];
}
-(void)hideResetPasswordView
{
    [UIView animateWithDuration:0.2 animations:^{
        _viewReset.frame=CGRectMake(viewSize.width,  _viewReset.frame.origin.y,  _viewReset.frame.size.width,  _viewReset.frame.size.height);
    } completion:^(BOOL finished) {
        bIsResetPwdSel=NO;
    }];
}


-(void)loadMenu
{
    [self.view bringSubviewToFront:self.viwMenu];
    [UIView animateWithDuration:0.2 animations:^{
        _viwMenu.frame=CGRectMake(0,  _viwMenu.frame.origin.y,  _viwMenu.frame.size.width, self.view.frame.size.height-64);
    } completion:^(BOOL finished) {
        bIsMenuSel=YES;
    }];
}
-(void)hideMenu
{
    [UIView animateWithDuration:0.2 animations:^{
        _viwMenu.frame=CGRectMake(viewSize.width,  _viwMenu.frame.origin.y,  _viwMenu.frame.size.width,  _viwMenu.frame.size.height);
    } completion:^(BOOL finished) {
        bIsMenuSel=NO;
    }];
}
-(void)loadTermsOfUseView
{
    [self.view bringSubviewToFront:_termsOfUseView];
    [UIView animateWithDuration:0.2 animations:^{
        _termsOfUseView.frame=CGRectMake(0,  _termsOfUseView.frame.origin.y,  _termsOfUseView.frame.size.width,  _termsOfUseView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}
-(void)hideTermsOfUseView
{
    [UIView animateWithDuration:0.2 animations:^{
        _termsOfUseView.frame=CGRectMake(viewSize.width,  _termsOfUseView.frame.origin.y,  _termsOfUseView.frame.size.width,  _termsOfUseView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - contact us methods
-(void)loadCallCareTeam
{
    [self.view bringSubviewToFront:_viwCallCareTeam];
    _tblCallCareTeam.delegate=self;
    _tblCallCareTeam.dataSource=self;
    [_tblCallCareTeam reloadData];
    _viwCallCareTeam.hidden=NO;
    
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForNumberOfMessages];
    }
    else{
        ///////////        [self customAlertView:@"" Message:@"Network not available" tag:0];
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
-(void)logoutTheSession{
    [HUD hide:YES];
    [HUD removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark - Collection View Delegate/Datasource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    CVCell *cell = (CVCell *)[cv dequeueReusableCellWithReuseIdentifier:@"cvCell" forIndexPath:indexPath];
    //    NSString *imageToLoad = [NSString stringWithFormat:@"%ld.png", (long)indexPath.row];
    //    cell.backGrndImage.image = [UIImage imageNamed:imageToLoad];
    NSString *imageToLoad = [NSString stringWithFormat:@"%lda.png", (long)indexPath.row];
    cell.tileImg.image = [UIImage imageNamed:imageToLoad];
    cell.msgCount.hidden = YES;
    if (indexPath.row == 0)
    {
        cell.titleLbl.text = @"Messages";
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"] && self.numberOfMsgs > 0)
        {
            cell.msgCount.hidden = NO;
            [cell.msgCount setBackgroundImage:[UIImage imageNamed:@"notification_bubble.png"] forState:UIControlStateNormal];
            [cell.msgCount setTitle:[NSString stringWithFormat:@"%ld",(long)self.numberOfMsgs] forState:    UIControlStateNormal];
            cell.msgCount.titleLabel.font = [UIFont systemFontOfSize:11];
        }
    }
    else if (indexPath.row == 1)
        cell.titleLbl.text = @"Managed Care Program";
    else if (indexPath.row == 2)
        cell.titleLbl.text = @"Services";
    else if (indexPath.row == 3)
        cell.titleLbl.text = @"Records";
    else if (indexPath.row == 4)
        cell.titleLbl.text = @"Connect";
    else if (indexPath.row == 5)
        cell.titleLbl.text = @"Info & Feedback";
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CVCell *cell=(CVCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if([cell.titleLbl.text isEqualToString:@"Messages"])
        [self messagesBtnClicked:nil];
    else if([cell.titleLbl.text isEqualToString:@"Managed Care Program"])//My Records"])
        [self carePlansBtnClicked:nil];
    else if ([cell.titleLbl.text isEqualToString:@"Services"])
        [self appointmentsBtnClicked:@"data"];
    else if ([cell.titleLbl.text isEqualToString:@"Records"])
        [self myRecordsBtnClicked:nil];
    else if ([cell.titleLbl.text isEqualToString:@"Info & Feedback"]){
        SmartRxAboutUsVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"aboutVc"];
        [self.navigationController pushViewController:controller animated:YES];
        //[self hsBtnClicked:nil];
    }
    else if ([cell.titleLbl.text isEqualToString:@"Connect"])
        [self connectBtnClicked:nil];
}



#pragma mark - Tableview Delegate/Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _tblCallCareTeam)
        return [_arrCallCareTeam count];
    else
        return [_arrMenu count];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"MenuCellID";
    static NSString *callCareCellIdentifier=@"CallCareCellID";
    
    if(tableView == _tblCallCareTeam)
    {
        SmartRxCallCareTVC *cell=(SmartRxCallCareTVC *)[tableView dequeueReusableCellWithIdentifier:callCareCellIdentifier];
        cell.lblCallCare.text=[_arrCallCareTeam objectAtIndex:indexPath.row];
        if (indexPath.row <= [arrCallCareImages count]-1)
            cell.imgViwCallCare.image=[UIImage imageNamed:[arrCallCareImages objectAtIndex:indexPath.row]];
        else
            cell.imgViwCallCare.image=[UIImage imageNamed:[arrCallCareImages objectAtIndex:[arrCallCareImages count]-1]];
        
        return cell;
    }
    else
    {
        MenuTableViewCell *cell=(MenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.lblMenu.text=[_arrMenu objectAtIndex:indexPath.row];
        cell.imgViwMenu.image = [UIImage imageNamed:@"menu-arrow.png"];
        cell.lblMenu.font = [UIFont systemFontOfSize:14];
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == _tblCallCareTeam)
    {
        //        SmartRxCallCareTVC *cell=(SmartRxCallCareTVC *)[tableView cellForRowAtIndexPath:indexPath];
        if (indexPath.row==0)
        {
            
            [self performSegueWithIdentifier:@"Emergency" sender:nil];
            
        }
        
        else if (indexPath.row == 1)
            [self emgCall];
        
        else if (indexPath.row == 2)
        {
            [self callCareCancelBtnClicked:nil];
            [self performSegueWithIdentifier:@"dbToEnquiry" sender:nil];
        }
    }
    else
    {
        MenuTableViewCell *cell=(MenuTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [self hideMenu];
        if ([cell.lblMenu.text isEqualToString:@"Home"])
            [self hideMenu];
        else if([cell.lblMenu.text isEqualToString:@"Get Care Plan"])
            [self performSegueWithIdentifier:@"getCareplan" sender:nil];
        else if([cell.lblMenu.text isEqualToString:@"View Profile"])
            [self performSegueWithIdentifier:@"EditProfileID" sender:nil];
        else if([cell.lblMenu.text isEqualToString:@"Hospital Info"])
            [self performSegueWithIdentifier:@"HsDashboardId" sender:nil];
        else if ([cell.lblMenu.text isEqualToString:@"Book Appointment"] ){
            if ([self getServiceAvailablity:@"4"]) {
                
                SmartRxBookAppoitmentController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"bookWebVc"];
                [self.navigationController pushViewController:controller animated:YES];
               // [self performSegueWithIdentifier:@"bookApt" sender:nil];
            }else {
                [self customAlertView:@"" Message:@"This service is not available for you." tag:0];
            }
        }
        else if ([cell.lblMenu.text isEqualToString:@"My Locations"])
            [self performSegueWithIdentifier:@"locationsVC" sender:nil];
        else if ([cell.lblMenu.text isEqualToString:@"Book E-Consult"]){
            if ([self getServiceAvailablity:@"2"]) {
                [self performSegueWithIdentifier:@"eConsult_book" sender:nil];
            }else {
                [self customAlertView:@"" Message:@"This service is not available for you." tag:0];
            }
        }
        else if ([cell.lblMenu.text isEqualToString:@"Assessments"])
            [self performSegueWithIdentifier:@"assessmentsVc" sender:nil];
        else if ([cell.lblMenu.text isEqualToString:@"Book Services"])
            [self appointmentsBtnClicked:nil];
        //[self performSegueWithIdentifier:@"newServicesVC" sender:nil];
        else if ([cell.lblMenu.text isEqualToString:@"Login"])
            [self performSegueWithIdentifier:@"DBLoginID" sender:@"Login"];
        else if ([cell.lblMenu.text isEqualToString:@"Book Second Opinion"]){
            if ([self getServiceAvailablity:@"13"]) {
                [self performSegueWithIdentifier:@"secondOpinionVc" sender:nil];
            }else {
                [self customAlertView:@"" Message:@"This service is not available for you." tag:0];
            }
        }
        else if ([cell.lblMenu.text isEqualToString:@"Chat"])
            [self performSegueWithIdentifier:@"chatListVc" sender:@"nil"];
        else if ([cell.lblMenu.text isEqualToString:@"Settings"])
            [self performSegueWithIdentifier:@"settingsVc" sender:@"nil"];
        else if ([cell.lblMenu.text isEqualToString:@"Terms of use"])
        {
            fromMenu = YES;
            [self.termsOfUseAgreeBtn setTitle:@"OK" forState:UIControlStateNormal];
            if ([termsString length] == 0 || termsString == nil)
                [self makeRequestToGetAggrementData];
            else
                [self showTermsOfUse];
        }
        else if([cell.lblMenu.text isEqualToString:@"Refresh"])
        {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isAppDelegateCalls"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self makeRequestForNumberOfMessages];
        }
        else if([cell.lblMenu.text isEqualToString:@"Change Password"])
        {
            if (!bIsResetPwdSel)
            {
                [self loadResetPasswordView];
            }
            else
                [self hideResetPasswordView];
        }
        if (indexPath.row == [_arrMenu count]-1)
        {
            [self logoutBtnClicked:nil];
        }
    }
}
-(BOOL)getServiceAvailablity:(NSString *)value{
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"enabledServices"];
    NSArray *array = [string componentsSeparatedByString:@"*"];
    if ([array containsObject:value]) {
        return YES;
    }
    return NO;
}
#pragma mark - Textfield Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.password)
    {
        if ([password length] > 0)
        {
            self.password.text = password;
        }
    }
    else if (textField == self.retypePassword)
    {
        if ([resetPassword length] > 0)
        {
            self.retypePassword.text = resetPassword;
        }
    }
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.password)
    {
        password = self.password.text;
    }
    else if (textField == self.retypePassword)
    {
        resetPassword = self.retypePassword.text;
    }
}

#pragma mark - KIImagePager DataSource
- (NSArray *) arrayWithImages:(KIImagePager*)pager
{
    
    NSArray *imageArr = nil;
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    if (self.offersAndTipsArr.count) {
        
        for (NSDictionary *dict in self.offersAndTipsArr) {
            NSString *urlStr = [NSString stringWithFormat:@"%s/%@",kBaseUrlQAImg,dict[@"image"]];
            NSString *escapedString = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            [tempArr addObject:escapedString];
        }
        imageArr = [tempArr copy];
    } else {
        imageArr = @[
                     [UIImage imageNamed:@"go_careplan.png"],
                     [UIImage imageNamed:@"go_econsult.png"],
                     [UIImage imageNamed:@"go_phr.png"]
                     ];
        
    }
    
    return imageArr;
    
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image inPager:(KIImagePager *)pager
{
    return UIViewContentModeRedraw;
}

//- (NSString *) captionForImageAtIndex:(NSUInteger)index inPager:(KIImagePager *)pager
//{
//    return @[
//             @"First screenshot",
//             @"Another screenshot",
//             @"Last one! ;-)"
//             ][index];
//}
//
#pragma mark - KIImagePager Delegate
- (void) imagePager:(KIImagePager *)imagePager didScrollToIndex:(NSUInteger)index
{
    //    NSLog(@"didScrollToIndex %lu", (unsigned long)index);
}

- (void) imagePager:(KIImagePager *)imagePager didSelectImageAtIndex:(NSUInteger)index
{
    
    if (self.offersAndTipsArr.count == 0) {
        
        if(index == 0)
            [self carePlansBtnClicked:nil];
        else if(index == 1)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"bookingFromDashboard"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self performSegueWithIdentifier:@"eConsult_book" sender:nil];
        }
        else if (index == 2)
        {
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
                [self performSegueWithIdentifier:@"dbToPHR" sender:nil];
            else
                [self customAlertView:@"" Message:@"Please login to view your PHR" tag:0];
        }
        //        [self trackersBtnClicked:nil];
    }else {
        
        //        NSDictionary *dict = self.offersAndTipsArr[index];
        //        if ([dict[@"service_id"] isKindOfClass:[NSString class]]) {
        //            bannerServiceId = dict[@"service_id"];
        //        }
        //        if ([dict[@"provider_id"] isKindOfClass:[NSString class]]) {
        //            bannerProviderId = dict[@"provider_id"];
        //        }
        //        if ([dict[@"type"] integerValue] == 2) {
        //            [self performSegueWithIdentifier:@"tipsVc" sender:dict];
        //        }else if ([dict[@"type"] integerValue] == 1){
        //            if ([dict[@"feature_type"] integerValue] == 1 && [dict[@"service_type"] integerValue] == 0) {
        //                [self performSegueWithIdentifier:@"newServicesVC" sender:nil];
        //
        //                NSLog(@"selected service vc");
        //            } else if ([dict[@"feature_type"] integerValue] == 1 && [dict[@"service_type"] integerValue] > 0 ) {
        //
        //                bannerServiceId = dict[@"service_id"];
        //                bannerProviderId = dict[@"provider_id"];
        //                [self performSegueWithIdentifier:@"newServicesVC" sender:nil];
        //            }else if ([dict[@"feature_type"] integerValue] == 2 && [dict[@"service_type"] integerValue] == -1) {
        //                [self performSegueWithIdentifier:@"eConsult_book" sender:nil];
        //            } else if ([dict[@"feature_type"] integerValue] == 2 && [dict[@"service_type"] integerValue] != -1) {
        //                [self performSegueWithIdentifier:@"eConsult_book" sender:dict[@"service_type"]];
        //            }
        //
        //        }
        //
    }
    NSLog(@"didSelectImageAtIndex %lu", (unsigned long)index);
}

@end
