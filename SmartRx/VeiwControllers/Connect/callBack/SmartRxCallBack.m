//
//  SmartRxCallBack.m
//  SmartRx
//
//  Created by Anil Kumar on 23/01/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import "SmartRxCallBack.h"
#import "SmartRxDashBoardVC.h"
#define kKeyBoardHeight 276
#define kBookAppSuccesTag 3005

@interface SmartRxCallBack ()
{
    CGFloat height;
    MBProgressHUD *HUD;    
    BOOL validatioErrorFlag;
    UIToolbar* numberToolbar;
    CGSize viewSize;
    NSInteger  seletedIndexpath;
    NSString *strLoctionId;
    UIView *currentView;
    UIButton *currentButton;
}
@end

@implementation SmartRxCallBack

- (void)viewDidLoad {
    [super viewDidLoad];
    viewSize=[[UIScreen mainScreen]bounds].size;
    self.timeArray = @[@"Morning 10 AM - 12 PM", @"Afternoon 12 PM - 3 PM", @"Evening 3 PM - 6 PM", @"Late Evening 6 PM - 9 PM"];
    self.timeLabel.text = [self.timeArray objectAtIndex:0];
    self.commonPicker.frame = CGRectMake(0, self.view.frame.size.height-self.commonPicker.frame.size.height, self.commonPicker.frame.size.width, self.commonPicker.frame.size.height);
    self.toolBar.frame = CGRectMake(0, self.commonPicker.frame.origin.y-self.toolBar.frame.size.height, self.toolBar.frame.size.width, self.toolBar.frame.size.height);
    [self numberKeyBoardReturn];
    [self createBorderForAllBoxes];
    [self makeRequestForLocationList];
    [self navigationBackButton];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)numberKeyBoardReturn
{
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(hideKeyBoard:)],
                           nil];
    [numberToolbar sizeToFit];
    
    self.reasonTextView.inputAccessoryView = numberToolbar;
    self.nameTextField.inputAccessoryView = numberToolbar;
    self.phoneTextField.inputAccessoryView = numberToolbar;
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
- (IBAction)hideKeyBoard:(id)sender
{
    [self.reasonTextView resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
}
- (IBAction)locationBtnClicked:(id)sender
{
    
}

- (IBAction)timeBtnClicked:(id)sender
{
    
}

-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)cancelButtonClicked:(id)sender
{
    [self removeDatePickerView:nil];
}

- (IBAction)doneButtonClicked:(id)sender
{
    if (currentButton.tag == 100)
    {
        self.timeLabel.text = [self.timeArray objectAtIndex:seletedIndexpath];
    }
    else
    {
        self.locationLabel.text = [[self.arrLoadCell objectAtIndex:seletedIndexpath]objectForKey:@"locationname"];
    }
    [self removeDatePickerView:nil];
}

- (IBAction)timerButtonClicked:(id)sender
{
    if ([self.timeLabel.text length] <= 0)
    {
        seletedIndexpath = 0;
    }
    else
    {
        seletedIndexpath = [self.timeArray indexOfObject:self.timeLabel.text];
    }
    self.timeButton.tag = 100;
    currentButton = self.timeButton;
//    self.arrLoadCell = self.timeArray;
    [self.commonPicker reloadAllComponents];
    [self.commonPicker selectRow:seletedIndexpath inComponent:0 animated:YES];
    [self displayDatePickerView];
}

- (IBAction)locationButtonClicked:(id)sender
{
    if ([self.locationLabel.text length] <= 0)
    {
        seletedIndexpath = 0;
    }
    currentButton = self.locationButton;
    [self makeRequestForLocationList];
}

- (IBAction)callBackBtnClicked:(id)sender
{
    if ([self.nameTextField.text length] <= 0 )
    {
        [self customAlertView:@"Please enter your name" Message:@"" tag:0];
    }
    else if ([self.phoneTextField.text length] <= 0)
    {
        [self customAlertView:@"Please enter your mobile number" Message:@"" tag:0];
    }
    else if ([self.phoneTextField.text length] > 10)
    {
        [self customAlertView:@"Mobile number cannot be more than 10 digits" Message:@"" tag:0];
    }
    else if ([self.phoneTextField.text length] < 10)
    {
        [self customAlertView:@"Mobile number can not be less than 10 digits." Message:@"" tag:0];
    }
    else if ([self.timeLabel.text length] <= 0)
    {
        [self customAlertView:@"Please select a time to call back" Message:@"" tag:0];
    }
    else if ([self.reasonTextView.text length] <= 0)
    {
        [self customAlertView:@"Reason should not be empty" Message:@"" tag:0];
    }
    else
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForCallBack];
        }
        else
        {
            
            [self customAlertView:@"" Message:@"Network not available" tag:0];
        }
    }
}

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark borderMethod
- (void)createBorderForAllBoxes
{
    self.nameTextField.layer.cornerRadius=0.0f;
    self.nameTextField.layer.masksToBounds = YES;
    self.nameTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.nameTextField.layer.borderWidth= 1.0f;
    
    self.nameTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"name.png"]];
    self.nameTextField.leftView.frame = CGRectMake(self.nameTextField.leftView.frame.origin.x, self.nameTextField.leftView.frame.origin.y, self.nameTextField.leftView.frame.size.width-10, self.nameTextField.leftView.frame.size.height-10);
    
    self.phoneTextField.layer.cornerRadius=0.0f;
    self.phoneTextField.layer.masksToBounds = YES;
    self.phoneTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.phoneTextField.layer.borderWidth= 1.0f;
    
    self.phoneTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mobile.png"]];
    self.phoneTextField.leftView.frame = CGRectMake(self.phoneTextField.leftView.frame.origin.x, self.phoneTextField.leftView.frame.origin.y, self.phoneTextField.leftView.frame.size.width-10, self.phoneTextField.leftView.frame.size.height-10);
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UName"] length] >0)
    {
        self.nameTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"UName"];
        self.phoneTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    }
    
    self.timeButton.layer.cornerRadius=0.0f;
    self.timeButton.layer.masksToBounds = YES;
    self.timeButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.timeButton.layer.borderWidth= 1.0f;
    
    self.locationButton.layer.cornerRadius=0.0f;
    self.locationButton.layer.masksToBounds = YES;
    self.locationButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.locationButton.layer.borderWidth= 1.0f;
    
    self.reasonTextView.layer.cornerRadius=0.0f;
    self.reasonTextView.layer.masksToBounds = YES;
    self.reasonTextView.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.reasonTextView.layer.borderWidth= 1.0f;
    
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
                            if ([self.locationLabel.text length] > 0 && [self.arrLoadCell count])
                            {
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationname ==  %@", self.locationLabel.text];
                                NSArray *result = [self.arrLoadCell filteredArrayUsingPredicate: predicate];
                                strLoctionId=[[result objectAtIndex:0]objectForKey:@"locid"];
                                seletedIndexpath=[self.arrLoadCell indexOfObject:result.firstObject];
                                [self displayDatePickerView];
                                [self.commonPicker selectRow:seletedIndexpath inComponent:0 animated:NO];
                            }
                            else
                            {
                                seletedIndexpath=0;
                                self.locationLabel.text = [[self.arrLocations objectAtIndex:0] objectForKey:@"locationname"];
                                [self.commonPicker selectRow:seletedIndexpath inComponent:0 animated:NO];
                            }

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

- (void)makeRequestForCallBack
{

    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strSeccionName=[[NSUserDefaults standardUserDefaults]objectForKey:@"SessionName"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    int indexTime = [self.timeArray indexOfObject:self.timeLabel.text]+1;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationname ==  %@", self.locationLabel.text];
    NSArray *result = [self.arrLoadCell filteredArrayUsingPredicate: predicate];
    strLoctionId=[[result objectAtIndex:0]objectForKey:@"locid"];
    
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%d&%@=%@&%@=%@&%@=%@&%@=%@",@"sessionid",sectionId,@"session_name", strSeccionName, @"tcall", indexTime, @"locid", strLoctionId, @"reason", self.reasonTextView.text, @"name", self.nameTextField.text, @"mobile", self.phoneTextField.text];
    }
    else{
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%d&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@", @"isopen", @"1", @"tcall", indexTime, @"locid", strLoctionId, @"reason", self.reasonTextView.text, @"name", self.nameTextField.text, @"mobile", self.phoneTextField.text, @"cid", strCid];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mcallback"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 6 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                
                if ([[response objectForKey:@"result"]integerValue] == 1)
                {
                    NSString *msg = [NSString stringWithFormat:@"Request sent successfully.\nYou will receive a call back between \n%@", self.timeLabel.text];
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:msg message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        alert.tag=kBookAppSuccesTag;
                        [alert show];
                }
                else if ([[response objectForKey:@"result"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Slot has not free" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
    
    
}
#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kBookAppSuccesTag && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }    
}
#pragma mark - Pickrview datasource/delegate methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (currentButton.tag == 100)
        return [self.timeArray count];
    else
        return [self.arrLoadCell count];
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (currentButton.tag == 100)
    {
        return [self.timeArray objectAtIndex:row];
    }
    else
    {
        return [[self.arrLoadCell objectAtIndex:row]objectForKey:@"locationname"];
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    seletedIndexpath=row;
}


#pragma mark - date picker view method

- (void)displayDatePickerView
{
    [self hideKeyBoard:nil];
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
    self.reasonLabel.hidden=YES;
    height=viewSize.height - (textView.frame.origin.y+textView.frame.size.height);
    height=kKeyBoardHeight-height;
    if (height > 0)
    {
        [UIView animateWithDuration:0.2 animations:^{
            
            self.scrolView.contentOffset=CGPointMake(self.scrolView.frame.origin.x, height);
        }];
        
    }
    
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text length] <=0)
    {
        self.reasonLabel.hidden=NO;
    }
    if (height > 0)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrolView.contentOffset=CGPointMake(0, -60);
        }];
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

#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

@end
