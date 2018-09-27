//
//  SmartRxEditProfileVC.m
//  SmartRx
//
//  Created by PaceWisdom on 26/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxEditProfileVC.h"
#import "UIImageView+ImageConvertion.h"
#import "NSString+DateConvertion.h"
#import "UIKit+AFNetworking.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"

#define kNameTxtTag 8000
#define kEmailTxtTag 8001
#define kMobileTxtTag 8002
#define kGenderTxtTag 8003
#define kDOBTxtTag 8004
#define kDoctroTxtTag 8005
#define kDataSelectTxtTag 8006
#define KSuccessEdit 9000

@interface SmartRxEditProfileVC ()
{
    MBProgressHUD *HUD;
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
    UITextField *currentTextfied;
    NSString *strDoctorId;
    NSString *StrNotify;
    NSString *strSelectData;
    NSString *locationID, *doctorID;
    CGSize viewSize;
    NSMutableArray *profileDetailsFromDB;
    NSString *latitude, *longitude;
}

@end

@implementation SmartRxEditProfileVC

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


#pragma mark -ViewLife Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    
    viewSize=[UIScreen mainScreen].bounds.size;
    
    [self.tblDoctor setTableFooterView:[UIView new]];
    [self navigationBackButton];
    self.btnYes.selected=NO;
    self.btnNo.selected=NO;
    self.arrDoctors=[[NSArray alloc]init];
    self.arrGender=[[NSArray alloc]initWithObjects:@"Male",@"Female", nil];
    self.arrDataSetting=[[NSArray alloc]initWithObjects:@"4",@"8",@"12", nil];
    StrNotify=@"1";
    
    pickerAction = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    pickerAction.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = pickerAction.bounds;
    [pickerAction addSubview:backgroundView];
    //    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeDatePicker:)];
    //    [singleTap setNumberOfTapsRequired:1];
    //    [pickerAction addGestureRecognizer:singleTap];
    
    self.tblDoctor.layer.borderColor=[[UIColor orangeColor]CGColor];
    self.tblDoctor.layer.cornerRadius=10.0f;
    self.tblDoctor.layer.borderWidth=3.0f;
    self.txtEmail.delegate = self;
    [self.txtEmail setReturnKeyType:UIReturnKeyDone];
    
    self.scrolView.contentSize=CGSizeMake(self.scrolView.frame.size.width, self.btnUpdate.frame.origin.y+self.btnUpdate.frame.size.height+220);
    
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestToGetProfile];
    }
    else{
        profileDetailsFromDB = [[NSMutableArray alloc] initWithArray:[[SmartRxDB sharedDBManager] profileDetails]];
        if (profileDetailsFromDB.count) {
            

        if([[profileDetailsFromDB objectAtIndex:0]objectForKey:@"dob"])
        {
            NSDate *dateDOB = [[profileDetailsFromDB objectAtIndex:0]objectForKey:@"dob"];
            NSDateFormatter *format = [[NSDateFormatter alloc]init];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [format setTimeZone:gmt];
            [format setDateFormat:@"dd-mm-yyyy"];
            self.txtDOB.text=[format stringFromDate:dateDOB];
        }
        self.txtName.text=[[profileDetailsFromDB objectAtIndex:0]objectForKey:@"name"];
        self.txtEmail.text=[[profileDetailsFromDB objectAtIndex:0]objectForKey:@"email"];
        self.txtMobile.text=[[profileDetailsFromDB objectAtIndex:0]objectForKey:@"primaryphone"];

        if ([[[profileDetailsFromDB objectAtIndex:0]objectForKey:@"gender"]intValue] == 1)
        {
            self.txtGender.text=@"Male";
        }
        else{
            self.txtGender.text=@"Female";
        }
        strSelectData=[[profileDetailsFromDB objectAtIndex:0]objectForKey:@"mweek"];
        self.txtSettings.text=[NSString stringWithFormat:@"%@ Weeks",strSelectData];
        
        //change
        
        [self.imgProfile  sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/%@",kAdminBaseUrl,[[profileDetailsFromDB objectAtIndex:0]objectForKey:@"profile_pic"]]] placeholderImage:[UIImage imageNamed:@"img_placeholder2.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (!error)
            {
            }
        }];
        strDoctorId = [[profileDetailsFromDB objectAtIndex:0]objectForKey:@"referal_doc"];
        locationID =[[profileDetailsFromDB objectAtIndex:0]objectForKey:@"location"];
        StrNotify=[[profileDetailsFromDB objectAtIndex:0]objectForKey:@"mnotify"];
        if ([StrNotify intValue] == 1)
        {
            self.btnYes.selected=YES;
        }
        else{
            self.btnNo.selected=YES;
        }
        NSMutableArray *arrLocations = [[NSMutableArray alloc] initWithArray:[[SmartRxDB sharedDBManager] fetchLocationsFromDataBase]];
        NSMutableArray *arrDoctors = [[NSMutableArray alloc] initWithArray:[[SmartRxDB sharedDBManager] fetchDoctorsFromDataBase]];
        if ([arrLocations count])
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locid ==  %@", locationID];
            NSArray *result = [arrLocations filteredArrayUsingPredicate: predicate];
            if ([result count] > 0)
            {
                self.labelLocation.text=[[result objectAtIndex:0]objectForKey:@"locationname"];
                
            }
            else
            {
                self.labelLocation.text = @"No location selected";
                self.labelDoctor.text = @"No Doctor(s) available";
            }
            
        }
        else
        {
            self.labelLocation.text = @"No location selected";
            self.labelDoctor.text = @"No Doctor(s) available";
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recno  ==  %@", strDoctorId];
        NSArray *result = [arrDoctors filteredArrayUsingPredicate: predicate];
        if ([result count])
        {
            self.labelDoctor.text=[[result objectAtIndex:0]objectForKey:@"dispname"];
            
        }
        else
        {
            self.labelDoctor.text = @"No Doctor(s) available";
        }

        
        } else{
            [self customAlertView:@"Error" Message:@"Network connection appears to be offline" tag:0];
        }
    }
    //self.txtGender.inputAccessoryView=self.tblDoctor;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -Location delegate method
-(void)tapOnMap:(NSDictionary *)addressDict{
    latitude = addressDict[@"latitude"];
    longitude = addressDict[@"longitude"];
    self.labelLocation.text = addressDict[@"addressString"];
    //[self getAddress:location];
    
}
#pragma mark - Request methods

- (void)makeRequestForUserRegister
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


-(void)makeRequestToGetProfile
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mprofile"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 16 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            
            [[SmartRxDB sharedDBManager] saveUserProfile:[[response objectForKey:@"profie"]objectAtIndex:0]];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                [[NSUserDefaults standardUserDefaults]setObject:[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"email"] forKey:@"emailId"];
                self.txtName.text=[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"name"];
                self.txtEmail.text=[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"email"];
                self.txtMobile.text=[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"primaryphone"];
                
                self.txtDOB.text = [self stringToDateConvertor:[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"dob"]];
                if ([[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"address"] isEqualToString:@""]) {
                    self.labelLocation.text = @"Locate me";
                }else {
                    self.labelLocation.text = [[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"address"] ;

                }
                //self.txtDOB.text=[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"dob"];
                if ([[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"gender"]intValue] == 1)
                {
                    self.txtGender.text=@"Male";
                }
                else  if ([[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"gender"]intValue] == 2){
                    self.txtGender.text=@"Female";
                }
                strSelectData=[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"mweek"];
                self.txtSettings.text=[NSString stringWithFormat:@"%@ Weeks",strSelectData];
                
                //change
                
                [self.imgProfile  sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/%@",kAdminBaseUrl,[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"profile_pic"]]] placeholderImage:[UIImage imageNamed:@"img_placeholder2.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                    if (!error)
                    {
                    }
                }];
                //                NSData *imgData=[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s%@",kBaseProfileImage,[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"profile_pic"]]]];
                //                self.imgProfile.image=[UIImage imageWithData:imgData];//referal_doc
                if ([response[@"profie"][0][@"referal_doc"] isKindOfClass:[NSString class]]) {
                    strDoctorId = [[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"referal_doc"];
                }else {
                    strDoctorId = @"";
                }

                locationID =[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"location"];
                StrNotify=[[[response objectForKey:@"profie"]objectAtIndex:0]objectForKey:@"mnotify"];
                if ([StrNotify intValue] == 1)
                {
                    self.btnYes.selected=YES;
                }
                else{
                    self.btnNo.selected=YES;
                }
                
               // [self makeRequestForLocationList];
                
            });
        }
    } failureHandler:^(id response) {
        
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"The request timed out" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
        
        [self customAlertView:@"Error" Message:@"Loading Profile Details failure" tag:0];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
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
        NSLog(@"sucess locationnn %@",response);
        
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
                
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                
                if (![[response objectForKey:@"location"] isKindOfClass:[NSArray class]])
                {
                    [self customAlertView:@"" Message:@"Locations Not available" tag:0];
                }
                else{
                    NSMutableArray *arrLocations = [[NSMutableArray alloc] initWithArray:[response objectForKey:@"location"]];
                    if ([arrLocations count])
                    {
                        [[SmartRxDB sharedDBManager] saveLocation:arrLocations];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([arrLocations count])
                        {
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locid ==  %@", locationID];
                            NSArray *result = [arrLocations filteredArrayUsingPredicate: predicate];
                            if ([result count] > 0)
                            {
                                self.labelLocation.text=[[result objectAtIndex:0]objectForKey:@"locationname"];
                                [self makeRequestGetDoctors];
                            }
                            else
                            {
                                self.labelLocation.text = @"No location selected";
                                self.labelDoctor.text = @"No Doctor(s) available";
                            }
                            
                        }
                        else
                        {
                            self.labelLocation.text = @"No location selected";
                            self.labelDoctor.text = @"No Doctor(s) available";
                        }
                    });
                }
            }
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
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
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"sessionid",sectionId,@"locid",locationID];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",@"cid",strCid,@"locid",locationID,@"isopen",@"1"];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlocdoc"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 3 %@",response);
        if ([response count] == 0 && [sectionId length] == 0)
        {
            [self makeRequestForUserRegister];
        }
        else{
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            NSMutableArray *responseArr = [[NSMutableArray alloc] initWithArray:[response objectForKey:@"docspec"]];
            [[SmartRxDB sharedDBManager] saveDoctor:responseArr];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([responseArr count])
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recno  ==  %@", strDoctorId];
                    NSArray *result = [responseArr filteredArrayUsingPredicate: predicate];
                    if ([result count])
                    {
                        self.labelDoctor.text=[[result objectAtIndex:0]objectForKey:@"dispname"];
                    }
                    else
                    {
                        self.labelDoctor.text = @"No Doctor(s) available";
                    }
                }
                else{
                    self.labelDoctor.text = @"No Doctor(s) available";
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}

-(void)makeRequestForProfileUpdation
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strSeccionName=[[NSUserDefaults standardUserDefaults]objectForKey:@"SessionName"];
    NSString *strGender=nil;
    if ([self.txtGender.text isEqualToString:@"Male"])
    {
        strGender=@"1";
    }else{
        strGender=@"2";
    }
    NSString *address = @"";
    NSString *latLongStr = @"";
    if (![self.labelLocation.text isEqualToString:@"Locate me"]) {
        address = self.labelLocation.text;
       latLongStr = [NSString stringWithFormat:@"%@,%@",latitude,longitude];

    }
    NSDictionary *dictTemp=[[NSDictionary alloc]initWithObjectsAndKeys:sectionId,@"sessionid",self.txtName.text,@"name",self.txtEmail.text,@"email",self.txtMobile.text,@"mobile",strGender,@"gender",self.txtDOB.text,@"dob",StrNotify,@"mnotify",strSelectData,@"mweek",strSeccionName,@"session_name",address,@"address",latLongStr,@"geotag",strDoctorId,@"refdoc", nil];
    NSLog(@"BODY TEXT = %@",dictTemp);
    [self addSpinnerView];
    [self uploadImage:dictTemp];
    
}
-(void)makeRequestForUdateProfile
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSData *imageData =[UIImageView postImage:self.imgProfile.image];//UIImageJPEGRepresentation(self.imgProfile.image, 1.0);
    
    NSString *strSeccionName=[[NSUserDefaults standardUserDefaults]objectForKey:@"SessionName"];
    
    NSUInteger dataLength = [imageData length];
    NSMutableString *strImgData = [NSMutableString stringWithCapacity:dataLength*2];
    const unsigned char *dataBytes = [imageData bytes];
    for (NSInteger idx = 0; idx < dataLength; ++idx) {
        [strImgData appendFormat:@"%02x", dataBytes[idx]];
    }
    NSString *strGender=nil;
    if ([self.txtGender.text isEqualToString:@"Male"])
    {
        strGender=@"1";
    }else{
        strGender=@"2";
    }
    
    
    NSString *bodyText = [NSString stringWithFormat:@"sessionid=%@&name=%@&email=%@&mobile=%@&gender=%@&dob=%@&mnotify=%@&mweek=%@&session_name=%@&profile_photo=%@",sectionId,self.txtName.text,self.txtEmail.text,self.txtMobile.text,strGender,self.txtDOB.text,StrNotify,strSelectData,strSeccionName,imageData];
    
    
    NSDictionary *dictTemp=[[NSDictionary alloc]initWithObjectsAndKeys:sectionId,@"sessionid",self.txtName.text,@"name",self.txtEmail.text,@"email",self.txtMobile.text,@"mobile",strGender,@"gender",self.txtDOB,@"dob",StrNotify,@"mnotify",strSelectData,@"mweek",strSeccionName,@"session_name", nil];
    NSLog(@"BODY TEXT = %@",dictTemp);
    // [self uploadImage:dictTemp];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"muppro"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText  method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 18 %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.view.userInteractionEnabled = YES;
                
                if ([[response objectForKey:@"dataupdate"]intValue] == 1 && [[response objectForKey:@"authorized"]intValue] == 1 && [[response objectForKey:@"fileupload"]intValue] == 1 && [[response objectForKey:@"result"]intValue] == 1)
                {
                    [self customAlertView:@"" Message:@"Profile updated successfully" tag:KSuccessEdit];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtEmail.text forKey:@"emailId"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtName.text forKey:@"UserName"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                }
                else if ([[response objectForKey:@"dataupdate"]intValue] == 1 && [[response objectForKey:@"authorized"]intValue] == 1 && [[response objectForKey:@"fileupload"]intValue] == 0 && [[response objectForKey:@"result"]intValue] == 1)
                {
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtEmail.text forKey:@"emailId"];
                    [self customAlertView:@"" Message:@"Profile updated successfully" tag:KSuccessEdit];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtName.text forKey:@"UserName"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
                else if ([[response objectForKey:@"added"]intValue] == 0 && [[response objectForKey:@"authorized"]intValue] == 1 && [[response objectForKey:@"fileupload"]intValue] == 0 && [[response objectForKey:@"result"]intValue] == 0)
                {
                    [self customAlertView:@"" Message:@"Adding both data and file is failed" tag:0];
                }
                else if ([[response objectForKey:@"added"]intValue] == 2 && [[response objectForKey:@"authorized"]intValue] == 1 && [[response objectForKey:@"result"]intValue] == 0)
                {
                    [self customAlertView:@"" Message:@"Patient doesn't have credits to ask quastion" tag:0];
                }
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"In posting question" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }];
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark -Action Methods
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)clickOnLocationBtn:(id)sender{
    [self performSegueWithIdentifier:@"mapVC" sender:nil];
}
- (IBAction)imgaePickerBtnClicked:(id)sender
{
    [self showActionSheet:nil];
}

- (IBAction)yesBtnClicked:(id)sender
{
    self.btnYes.selected=YES;
    self.btnNo.selected=NO;
    StrNotify=@"1";
}

- (IBAction)noBtnClicked:(id)sender
{
    self.btnYes.selected=NO;
    self.btnNo.selected=YES;
    StrNotify=@"0";
}
-(void)showActionSheet:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

- (IBAction)updateBtnClicked:(id)sender
{
    if ([self.txtName.text length] <= 0 )
    {
        [self customAlertView:@"Patient name should not be empty" Message:@"" tag:0];
    } else if (self.txtEmail.text.length <= 0){
        [self customAlertView:@"Email should not be empty" Message:@"" tag:0];
    } else if (self.txtDOB.text.length <= 0){
        [self customAlertView:@"Date of birth should not be empty" Message:@"" tag:0];
    }else if (self.txtGender.text.length <= 0){
        [self customAlertView:@"Gender should not be empty" Message:@"" tag:0];
    }


    else
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForProfileUpdation];
            //[self makeRequestForUdateProfile];
        }
        else{
            
            [self customAlertView:@"" Message:@"Network not available" tag:0];
            
        }
    }
}

- (IBAction)genderBtnClicked:(id)sender
{
    [self keyBoardHideBtnClicked:nil];
    currentTextfied=self.txtGender;
    self.arrLoadTbl=self.arrGender;
    [self.tblDoctor reloadData];
    self.tblDoctor.hidden=NO;
    [self.view bringSubviewToFront:self.tblDoctor];
}
- (IBAction)dataBtnClicked:(id)sender
{
    [self keyBoardHideBtnClicked:nil];
    currentTextfied=self.txtSettings;
    self.arrLoadTbl=self.arrDataSetting;
    [self.tblDoctor reloadData];
    self.tblDoctor.hidden=NO;
}

- (IBAction)doctorBtnClicked:(id)sender
{
    [self keyBoardHideBtnClicked:nil];
    currentTextfied=self.txtDoctor;
    self.arrLoadTbl=self.arrDoctors;
    [self.tblDoctor reloadData];
    self.tblDoctor.hidden=NO;
}
- (IBAction)mobileBtnClicked:(id)sender
{
    [self keyBoardHideBtnClicked:nil];
    currentTextfied=self.txtMobile;
    [self customAlertView:@"" Message:@"If you want to change the mobile number, please contact hospital" tag:0];//[self loadDatePicker];
}

- (IBAction)dobBtnClicked:(id)sender
{
    [self keyBoardHideBtnClicked:nil];
    currentTextfied=self.txtDOB;
    [self loadDatePicker];
}
- (IBAction)keyBoardHideBtnClicked:(id)sender
{
    if ([self.txtEmail isFirstResponder])
    {
        [self.txtEmail resignFirstResponder];
    }
    if ([self.txtName isFirstResponder])
    {
        [self.txtName resignFirstResponder];
    }
    if (![self.tblDoctor isHidden])
    {
        self.tblDoctor.hidden=YES;
    }
}

#pragma mark -Textfield delegate method

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldShouldBeginEditing");
    if (textField == self.txtDoctor || textField == self.txtLocation) {
        if (textField == self.txtLocation) {
            [self performSegueWithIdentifier:@"mapVC" sender:nil];
        }
        return NO;
    } else {
        return YES;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentTextfied=textField;
    if (![self.tblDoctor isHidden])
    {
        self.tblDoctor.hidden=YES;
    }
    
    
    if (textField.tag == kEmailTxtTag)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrolView.frame=CGRectMake(self.scrolView.frame.origin.x, self.scrolView.frame.origin.x-20, self.scrolView.frame.size.width, self.scrolView.frame.size.height);
        }];
        
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == kEmailTxtTag)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrolView.frame=CGRectMake(self.scrolView.frame.origin.x, self.scrolView.frame.origin.x+20, self.scrolView.frame.size.width, self.scrolView.frame.size.height);
        }];
        
    }
    [textField resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtName)
    {
        [self.txtEmail becomeFirstResponder];
    }
    else if (textField.tag == kEmailTxtTag)
    {
        NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        
        NSLog(@"text filed text : %@",textField.text);
        if ([emailTest evaluateWithObject:textField.text] == NO && ![textField.text isEqualToString:@""]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        [textField resignFirstResponder];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.tag == kNameTxtTag)
    {
        NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    else
        return YES;
}

#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

-(void)loadDatePicker{
    
    self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    self.datePickerView.backgroundColor = [UIColor whiteColor];
    NSString *date = self.txtDOB.text;
    
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
-(NSString *)stringToDateConvertor:(NSString *)date{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [format setTimeZone:gmt];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *serverDate = [format dateFromString:date];
    [format setDateFormat:@"dd-MMM-yyyy"];
    NSString *dateStr = [format stringFromDate:serverDate];
    return dateStr;
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
    self.txtDOB.text=strDate;
    self.datePickerView.hidden=YES;
    
    [self closeDatePicker:nil];
    
}
-(BOOL)closeDatePicker:(id)sender{
    pickerAction.hidden = YES;
    return YES;
}

#pragma mark - Tableview Delegate Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrLoadTbl count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"ProfileCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (currentTextfied.tag == kDataSelectTxtTag)
    {
        cell.textLabel.text=[NSString stringWithFormat:@"%@ Weeks",[self.arrLoadTbl objectAtIndex:indexPath.row]];
        
    }
    else{
        cell.textLabel.text=[self.arrLoadTbl objectAtIndex:indexPath.row];
    }
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentTextfied.tag == kDoctroTxtTag)
    {
        self.labelDoctor.text=[self.arrLoadTbl objectAtIndex:indexPath.row];
        NSLog(@" value === %@",[self.arrLoadTbl objectAtIndex:indexPath.row]);
        strDoctorId=[[self.dictDocorRefId allKeysForObject:[self.arrLoadTbl objectAtIndex:indexPath.row]]objectAtIndex:0];
        
    }
    else if (currentTextfied.tag == kGenderTxtTag)
    {
        self.txtGender.text=[self.arrLoadTbl objectAtIndex:indexPath.row];
    }
    else if (currentTextfied.tag == kDataSelectTxtTag)
    {
        self.txtSettings.text=[NSString stringWithFormat:@"%@ Weeks",[self.arrLoadTbl objectAtIndex:indexPath.row]];
        strSelectData=[self.arrLoadTbl objectAtIndex:indexPath.row];
    }
    self.tblDoctor.hidden=YES;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == KSuccessEdit && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - Action Sheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        NSLog(@"Camera Clicked");
        [self takePhoto];
        
    } else if (buttonIndex == 1)
    {
        NSLog(@"Gallary Clicked");
        [[SmartRxCommonClass sharedManager] openGallary:self];
    } else if (buttonIndex == 2) {
        NSLog(@"Cancel Clicked");
    }
}
- (void)takePhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}
#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // self.imgProfile.image=info[UIImagePickerControllerEditedImage];
    [self compression:info[UIImagePickerControllerEditedImage]];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
-(void)imageSelected:(UIImage *)image{
    //self.imgProfile.image=image;
    [self compression:image];
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForProfileUpdation];
    }
    else{
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}
-(void)errorSectionId:(id)sender
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
}


//posting profile using afnetworking


-(void) uploadImage:(NSDictionary *)info
{
    
    CGSize newSize = CGSizeMake(100.0f, 100.0f);
    UIGraphicsBeginImageContext(newSize);
    [self.imgProfile.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage=nil;
    if (self.imgProfile.image != nil)
    {
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    
    //    NSData *imgData = UIImageJPEGRepresentation(newImage, 1); //1 it represents the quality of the image.
    //    NSLog(@" final Size of Image(bytes):%lu",(unsigned long)[imgData length]);
    
    
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@kBaseUrl]];
    UIImage *image = newImage;//self.imgProfile.image;
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *strUrl=[NSString stringWithFormat:@"%s/muppro",kBaseUrl];
    
    AFHTTPRequestOperation * op = [manager POST:strUrl parameters:info constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        
        
        [formData appendPartWithFileData:imageData name:@"profile_photo" fileName:@"photo.JPG" mimeType:@"image/JPG"];
        [manager.requestSerializer setTimeoutInterval:30.0];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
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
                
                if ([[responseObject objectForKey:@"dataupdate"]intValue] == 1 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"fileupload"]intValue] == 1 && [[responseObject objectForKey:@"result"]intValue] == 1)
                {
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtEmail.text forKey:@"emailId"];
                    [self customAlertView:@"" Message:@"Profile updated successfully" tag:KSuccessEdit];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtName.text forKey:@"UserName"];
                    [[NSUserDefaults standardUserDefaults]setObject:strDoctorId forKey:@"referal_doc"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.labelDoctor.text forKey:@"refdocname"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                }
                else if ([[responseObject objectForKey:@"dataupdate"]intValue] == 1 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"fileupload"]intValue] == 0 && [[responseObject objectForKey:@"result"]intValue] == 1)
                {
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtEmail.text forKey:@"emailId"];
                    [self customAlertView:@"" Message:@"Profile updated successfully" tag:KSuccessEdit];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtName.text forKey:@"UserName"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
                else if ([[responseObject objectForKey:@"added"]intValue] == 0 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"fileupload"]intValue] == 0 && [[responseObject objectForKey:@"result"]intValue] == 0)
                {
                    [self customAlertView:@"" Message:@"Adding both data and file is failed" tag:0];
                }
                else if ([[responseObject objectForKey:@"added"]intValue] == 2 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"result"]intValue] == 0)
                {
                    [self customAlertView:@"" Message:@"Patient doesn't have credits to ask quastion" tag:0];
                }
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
    
    [self.imgProfile setImage:[UIImage imageWithData:imageData]];
    
    
}
#pragma mark - Storyboard Preapare segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"mapVC"]) {
        SmartRxMapVC *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}

@end
