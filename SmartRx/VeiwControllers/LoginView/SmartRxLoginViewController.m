//
//  SmartRxLoginViewController.m
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxLoginViewController.h"
#import "NSString+MD5.h"
#import "SmartRxCommonClass.h"
#import "NetworkChecking.h"
#import "SmartRxValidRegisterVC.h"
#import "MBProgressHUD.h"
#import "SmartRxDashBoardVC.h"
#define kLoginSuccessAlertTag 345
#define kMobileTxtTag 3000
#define kPassTxtTag 3001
#define kNotRegistred 1600

@interface SmartRxLoginViewController ()
{
    UIActivityIndicatorView *spinner;
    UIToolbar* numberToolbar;
    MBProgressHUD *HUD;
    BOOL enableMobileField;
}

@end

@implementation SmartRxLoginViewController

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

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mobileGreyView.hidden = YES;
    enableMobileField = YES;//LoginID//Lougout
    self.hospitalNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"HosName"];
    self.navigationItem.hidesBackButton = YES;
    [self navigationBackButton];
    self.txtPassword.secureTextEntry=YES;
    
    //[self numberKeyBoardReturn];
    
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //self.mobileGreyView.hidden = NO;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"])
    {
        self.txtMobileNumber.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request methods
- (void)doneButton:(id)sender 
{
    [self.txtPassword resignFirstResponder];
    [self loginClicked:nil];
}
/*-(void)makeRequestForUserRegister
{
    
    [[NSUserDefaults standardUserDefaults]setObject:self.txtMobileNumber.text forKey:@"MobileNumber"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }

    [self addSpinnerView];
    NSString *strCode=[[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",self.txtMobileNumber.text];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"code",strCode]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mregister"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess %@",response);
    
        dispatch_async(dispatch_get_main_queue(), ^{

            [spinner stopAnimating];
            [spinner removeFromSuperview];
            spinner = nil;
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"])
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Not registered user" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.tag=kNotRegistred;
                [alert show];
            }
            else{
            if ([response objectForKey:@"cid"])
            {
                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cidd"];
                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cid"];
                NSString *strFrontDestNum=[[response objectForKey:@"hinfo"]objectForKey:@"frontDeskNo" ];
                
                [[NSUserDefaults standardUserDefaults]setObject:strFrontDestNum forKey:@"EmNumber"];
                
                NSString *strHospName=[[response objectForKey:@"hinfo"]objectForKey:@"hospitalName" ];
                
                [[NSUserDefaults standardUserDefaults]setObject:strHospName forKey:@"HosName"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
                if ([networkAvailabilityCheck reachable])
                {
                    [self makeLoginRequest:[response objectForKey:@"cid"]];
                }
                else{
                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                    alertView=nil;
                }
                
            }
            }
        
        });
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];

}*/
-(void)makeLoginRequest :(NSString *)cid
{
    [[NSUserDefaults standardUserDefaults]setObject:self.txtMobileNumber.text forKey:@"MobileNumber"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSString *strPasword=nil;
    
    if ([self.txtPassword.text length] > 0)
    {
        
        strPasword = self.txtPassword.text;
        //strPasword=[NSString md5:self.txtPassword.text];//@"172603"];
    }
    if (strPasword && [self.txtMobileNumber.text length] > 0)
    {
        
        if (![HUD isHidden]) {
            [HUD hide:YES];
        }
        [self addSpinnerView];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:@"PushToken"];
        NSString *strPushToken = [[[data description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"push token.....:%@",strPushToken);
        NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
        NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",self.txtMobileNumber.text];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"cid",strCid]];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"pass",strPasword]];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"regId",strPushToken]];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"mode",@"2"]];
        NSLog(@"body text......:%@",bodyText);
        
        NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlogin"];
        [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
            
           NSLog(@"sucess 23 %@",response);

            if (response == nil || response == NULL || response == [NSNull null])
            {
                //[self customAlertView:@"Login error" Message:@"Try again" tag:0];
                [HUD hide:YES];
                [HUD removeFromSuperview];
                [self makeLoginRequest:nil];
            }
            else if ([[[response objectAtIndex:0] objectForKey:@"authorized"]integerValue] == 0 && [response[0][@"status"] isEqualToString:@"not_authorized"])
            {
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Not authorized to login." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.tag = 890;
                alert.delegate = self;
                [alert show];
            } else if ([[[response objectAtIndex:0] objectForKey:@"authorized"]integerValue] == 0)
            {
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Invalid mobile or password please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.tag = 890;
                alert.delegate = self;
                [alert show];
            }
            else{
               // [[SmartRxDB sharedDBManager] saveLoginData:[response objectAtIndex:0]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([response[0][@"referal_doc"] isKindOfClass:[NSString class]]) {
                        [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"referal_doc"] forKey:@"referal_doc"];
                    }else {
                        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"referal_doc"];
                    }
                    if ([[response objectAtIndex:0] objectForKey:@"refdocname"] == [NSNull null] || [[[response objectAtIndex:0] objectForKey:@"refdocname"] isEqualToString:@""] ||[[response objectAtIndex:0] objectForKey:@"refdocname"] ==  nil )
                    {
                    }
                    else{
                        
                        [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"refdocname"] forKey:@"refdocname"];
                    }
                    
                    [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0]objectForKey:@"sessionid"] forKey:@"sessionid"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtMobileNumber.text forKey:@"MobileNumber"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtPassword.text forKey:@"Password"];
                    [[NSUserDefaults standardUserDefaults]setObject:cid forKey:@"cid"];
                    [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"dispname"] forKey:@"UserName"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.txtMobileNumber.text forKey:@"MobilNumber"];
                    [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"usertype"] forKey:@"usertype"];
                    [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"profile_pic"] forKey:@"profile_pic"];
                    [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"session_name"] forKey:@"SessionName"];
                    [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"recno"] forKey:@"userid"];
                    [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"agstatus"] forKey:@"agstatus"];
                    NSString *strFrontDestNum=[[response objectAtIndex:0]objectForKey:@"fdeskno"];
                    [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"emailid"] forKey:@"emailId"];
                    
                    if (strFrontDestNum != [NSNull null])
                        [[NSUserDefaults standardUserDefaults]setObject:strFrontDestNum forKey:@"EmNumber"];
                    else
                        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"EmNumber"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [HUD hide:YES];
                        [HUD removeFromSuperview];
                        self.view.userInteractionEnabled = YES;
                        
                        //                    [self.navigationController popViewControllerAnimated:YES];
                        
                        [self performSegueWithIdentifier:@"loginSegue" sender:nil];
                    });
                });
            }
        } failureHandler:^(id response) {
            NSLog(@"failure %@",response);
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Login failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [HUD hide:YES];
            [HUD removeFromSuperview];
        }];
    }
}
-(void)makeRequestForPushNotes
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
   
    NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:@"PushToken"];
    
    NSString *strPushToken = [[[data description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%s",@"sessionid",sectionId,@"ipid",strPushToken,@"appid",kBundleID];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mpuship"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@" responsee ====== %@",response);
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
//        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
//        {
//            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
//            smartLogin.loginDelegate=self;
//            [smartLogin makeLoginRequest];
//        }
//        else{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [HUD hide:YES];
//                [HUD removeFromSuperview];
//                self.view.userInteractionEnabled = YES;
//            });
//        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];

}
-(void)addSpinnerView
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}

#pragma mark - Action method
-(void)retunWithNumberPad
{
    [self.txtPassword becomeFirstResponder];
}
-(void)backBtnClicked:(id)sender
{
    [self.txtMobileNumber resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtMobileNumber resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxValidRegisterVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
    //[self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)loginClicked:(id)sender {
    
    [self hideKeyBoard:nil];
    
    if ([self.txtMobileNumber.text length] == 0)
    {
        [self customAlertView:@"Mobile number should not be empty." Message:@"" tag:0];
    }
    
   else if ([self.txtMobileNumber.text length] < 10 )
    {
        [self customAlertView:@"Mobile number can not be less than 10 digits." Message:@"" tag:0];
    }
    else if([self.txtPassword.text length] == 0)
    {
        [self customAlertView:@"Password should not be empty." Message:@"" tag:0];
    }
    else
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
           // [self makeRequestForUserRegister];
            [self makeLoginRequest:@""];
        }
        else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }
    }
}
- (IBAction)hideKeyBoard:(id)sender {
    [self.txtMobileNumber resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

- (IBAction)registerBtnClicked:(id)sender
{
    
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxValidRegisterVC class]])
        {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"FromLogin"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self.navigationController popToViewController:controller animated:NO];
        }
    }
    
}

- (IBAction)forgotBtnClicked:(id)sender {
}

- (IBAction)continueAsGuest:(id)sender
{
    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
}
#pragma mark - Text filed Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldBeginEditing");
    if (textField == self.txtMobileNumber)
        if (enableMobileField)
            return YES;
    else
        return NO;
    else
        return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.txtMobileNumber)
    {
        [self.txtPassword becomeFirstResponder];
    }
    if (textField.tag == kPassTxtTag)
    {
        [textField resignFirstResponder];
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    textField.inputAccessoryView = doneToolbar;
    if (textField.tag == kPassTxtTag)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.frame=CGRectMake(self.scrollView.frame.origin.x,self.scrollView.frame.origin.y-2*self.txtPassword.frame.size.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        }];
        
    }
    if (textField.tag == kMobileTxtTag)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-numberToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }

}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == kPassTxtTag)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.frame=CGRectMake(self.scrollView.frame.origin.x,self.scrollView.frame.origin.y+2*self.txtPassword.frame.size.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        }];
        
    }
    if (textField.tag == kMobileTxtTag)
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+numberToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        }];
       
    }
}
#pragma mark - Alert View Delgate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   // enableMobileField = NO;
    if (alertView.tag == kLoginSuccessAlertTag && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(alertView.tag == kNotRegistred && buttonIndex == 0)
    {
        [self registerBtnClicked:nil];
    }
    else if (alertView.tag == 890)
    {
        self.mobileGreyView.hidden = YES;
        enableMobileField = YES;
    }
    
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}


@end
