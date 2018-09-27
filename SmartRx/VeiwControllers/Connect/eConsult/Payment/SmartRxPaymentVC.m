//
//  SmartRxPaymentVC.m
//  SmartRx
//
//  Created by Manju Basha on 07/04/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxPaymentVC.h"
#import "SmartRxDashBoardVC.h"
#import "UIUtility.h"
#import "MerchantConstants.h"
#import "WebViewViewController.h"
#import "SmartRxBookeConsultVC.h"
#import "SmartRxGetCarePlanVC.h"
#import "SmartRxBookServices.h"
#import "SmartRxCartCheckOutController.h"
#import "SmartRxGetManagedCarePlanVC.h"
#import "SmartRxBookAPPointmentVC.h"

#define toErrorDescription(error) [error.userInfo objectForKey:NSLocalizedDescriptionKey]

@interface SmartRxPaymentVC ()
{
    MBProgressHUD *HUD;
    NSString *scheme;
    CGFloat viewWidth, viewHeight;
    UIToolbar* numberToolbar;
    UIView *debitView, *creditView;
    UISegmentedControl *segControl;
    CTSPaymentLayer *paymentLayer;
    CTSContactUpdate *cardContactInfo;
    CTSUserAddress* addressInfo;
    UIScrollView *debitScrollView, *creditScrollView;
    NSString *cardType;
    int kOFFSET_FOR_KEYBOARD;
    NSMutableDictionary *imageDict;
    BOOL keyboardHide;
    NSArray *debitArray;
    NSArray *creditArray;
    CTSPaymentDetailUpdate *cardInfo;
    
}
@end

@implementation SmartRxPaymentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    keyboardHide = YES;
    paymentLayer = [[CTSPaymentLayer alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self navigationBackButton];
    viewWidth = CGRectGetWidth(self.view.frame);
    [self initializeCitrusSdk];
    addressInfo = [[CTSUserAddress alloc] init];
    addressInfo.city = @"city";
    addressInfo.country = @"country";
    addressInfo.state = @"state";
    addressInfo.street1 = @"street1";
    addressInfo.street2 = @"street2";
    addressInfo.zip = @"401209";
    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(doneButton:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    [self.loadButton setTitle:[NSString stringWithFormat:@"Pay Rs: %@",self.costValue] forState:UIControlStateNormal];
    // Tying up the segmented control to a scroll view
    imageDict = [[CTSDataCache sharedCache] fetchCachedDataForKey:BANK_LOGO_KEY];    
    [self requestPaymentModes];    
    // Segmented control with scrolling
    HMSegmentedControl *segmentedControl4 ;
    
    segmentedControl4 = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Debit Card", @"Credit Card"]];
    segmentedControl4.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentedControl4.frame = CGRectMake(0, 0, viewWidth, 45);
    segmentedControl4.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    segmentedControl4.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    segmentedControl4.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl4.verticalDividerEnabled = YES;
    segmentedControl4.verticalDividerColor = [UIColor blackColor];
    segmentedControl4.verticalDividerWidth = 1.5f;
    segmentedControl4.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor],  UITextAttributeFont:[UIFont systemFontOfSize:16]};

    [segmentedControl4 addTarget:self action:@selector(loadUsingCard:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl4];

    kOFFSET_FOR_KEYBOARD = 0.0;
}

-(void)initializeCitrusSdk{
    //sdk initialization
    CTSKeyStore *keyStore = [[CTSKeyStore alloc] init];
    keyStore.signinId = SignInId;
    keyStore.signinSecret = SignInSecretKey;
    keyStore.signUpId = SubscriptionId;
    keyStore.signUpSecret = SubscriptionSecretKey;
    keyStore.vanity = VanityUrl;
    
    [CitrusPaymentSDK initializeWithKeyStore:keyStore environment:CTSEnvSandbox];
    
}


-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    keyboardHide = YES;
    kOFFSET_FOR_KEYBOARD = 0.0;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


-(void)setViewMovedUp:(BOOL)movedUp
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
        
    }
    else
    {
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
        
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark - Action Methods
// You can load/add money as per following way
-(IBAction)loadUsingCard:(id)sender{
    
    segControl = (UISegmentedControl *)sender;
    
    [self.view endEditing:YES];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self resetUI];
//        
//    });

    self.loadButton.hidden = FALSE;
    self.loadButton.userInteractionEnabled = TRUE;
    if (segControl.selectedSegmentIndex==0 || segControl.selectedSegmentIndex==1) {
        
        self.ccddtableView.hidden = FALSE;
        
    }
    else if (segControl.selectedSegmentIndex==2){
        
        self.ccddtableView.hidden = TRUE;
        self.loadButton.userInteractionEnabled = FALSE;
        
    }
}


-(void)keyboardWillHide
{
    keyboardHide=YES;
    NSLog(@"ssss %f",self.view.frame.origin.y);
//    kOFFSET_FOR_KEYBOARD = keyboardOffset;
    if ((self.view.frame.origin.y >= 0) || ((([self.ownerNameTextField isFirstResponder])||([self.emailIDTextField isFirstResponder])) && keyboardHide))
    {
        [self setViewMovedUp:NO];
    }
    else if (self.view.frame.origin.y < 0 && !((([self.emailIDTextField isFirstResponder])||([self.ownerNameTextField isFirstResponder])) && keyboardHide))
    {
        [self setViewMovedUp:YES];
    }
    kOFFSET_FOR_KEYBOARD = 0.0;
}

- (void)checkKoffset
{
    if (kOFFSET_FOR_KEYBOARD > 0)
    {
        [self setViewMovedUp:NO];
    }

}
- (void)adjustViewAndKeyboard
{
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)doneButton:(id)sender
{
    [self.cardNumberTextField resignFirstResponder];
    [self.ownerNameTextField resignFirstResponder];
    [self.expiryDateTextField resignFirstResponder];
    [self.cvvTextField resignFirstResponder];
    [self.emailIDTextField resignFirstResponder];
}

#pragma mark spinner alert & picker
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)keyboardWillShow
{
    keyboardHide = NO;
    
    if([self.ownerNameTextField isFirstResponder])
    {
        if (!keyboardHide)
            [self checkKoffset];
        kOFFSET_FOR_KEYBOARD = 60.0;
    }
    else if([self.emailIDTextField isFirstResponder])
    {
        if (!keyboardHide)
            [self checkKoffset];
        kOFFSET_FOR_KEYBOARD = 120.0;
    } else if ([self.cardNumberTextField isFirstResponder]){
        if (!keyboardHide)
            [self checkKoffset];
        kOFFSET_FOR_KEYBOARD = 0.0;
    }
    
    NSLog(@"ssss %f",self.view.frame.origin.y);
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
    
}

-(IBAction)loadOrPayMoney:(id)sender
{
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if (![networkAvailabilityCheck reachable])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Network not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self.view endEditing:YES];
    // Credit card
    self.indicatorView.hidden = FALSE;
    [self.indicatorView startAnimating];
    NSString *cardNumber = [self.cardNumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    scheme = [CTSUtility fetchCardSchemeForCardNumber:cardNumber];
    //    [switchView setOn:NO animated:YES];
    
    if (self.cardNumberTextField.text == nil || !self.cardNumberTextField.text || ![self.cardNumberTextField.text length])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter a valid card number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if (self.expiryDateTextField.text == nil || ![self.expiryDateTextField.text length])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter a valid expiry date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if ([self.cvvTextField.text length] != 3 && ![scheme isEqualToString:@"MTRO"])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter a valid CVV" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if (self.ownerNameTextField.text == nil || ![self.ownerNameTextField.text length])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter your name " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if (self.emailIDTextField.text == nil || ![self.emailIDTextField.text length])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter your E-Mail ID " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else
    {
        if (segControl.selectedSegmentIndex==0)
        {
            
            if (self.expiryDateTextField.text.length!=0) {
                NSArray* subStrings = [self.expiryDateTextField.text componentsSeparatedByString:@"/"];
                int year = [[subStrings objectAtIndex:1] intValue]+2000;
                NSString *resultantDate = [NSString stringWithFormat:@"%d/%d",[[subStrings objectAtIndex:0] intValue],year];
                if (![CTSUtility validateExpiryDate:resultantDate]){
                    [UIUtility toastMessageOnScreen:@"Expiry date is not valid."];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.indicatorView stopAnimating];
                        self.indicatorView.hidden = TRUE;
                    });
                    return;
                }
            }
        }
        else if (segControl.selectedSegmentIndex==1)
        {
            if (self.expiryDateTextField.text.length!=0) {
                NSArray* subStrings = [self.expiryDateTextField.text componentsSeparatedByString:@"/"];
                int year = [[subStrings objectAtIndex:1] intValue]+2000;
                NSString *resultantDate = [NSString stringWithFormat:@"%d/%d",[[subStrings objectAtIndex:0] intValue],year];
                if (![CTSUtility validateExpiryDate:resultantDate]){
                    [UIUtility toastMessageOnScreen:@"Expiry date is not valid."];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.indicatorView stopAnimating];
                        self.indicatorView.hidden = TRUE;
                    });
                    return;
                }
            }
        }
        
        [self setCardInfo];
        CTSBill *bill = [self getBillFromServer:[self.costValue floatValue]];
        cardContactInfo = [[CTSContactUpdate alloc] init];
        cardContactInfo.firstName = self.ownerNameTextField.text;
        cardContactInfo.lastName = @"";
        cardContactInfo.email = self.emailIDTextField.text;
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"] length] >0)
            cardContactInfo.mobile = [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
        
        [paymentLayer requestDirectChargePayment:cardInfo withContact:cardContactInfo withAddress:addressInfo bill:bill returnViewController:self withCompletionHandler:^(CTSCitrusCashRes *citrusCashResponse, NSError *error) {
            //        [self handlePaymentResponse:cardInfo error:error];
            if(error){
                [UIUtility toastMessageOnScreen:error.localizedDescription];
            }
            else {
                
                //SUCCESSFUL TRANSACTION HANDLING AREA.
                
                if([citrusCashResponse.responseDict valueForKey:@"TxStatus"] != nil && [[citrusCashResponse.responseDict valueForKey:@"TxStatus"] caseInsensitiveCompare:@"SUCCESS"] == NSOrderedSame){
                    [[NSUserDefaults standardUserDefaults] setObject:citrusCashResponse.responseDict forKey:@"paymentResponseDictionary"];
                    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"fromEconsult"])
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"TransactionSuccess"];
                        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"fromEconsult"] boolValue])
                            [[SmartRxBookeConsultVC sharedManagerEconsult] setPaymentResponseDictionary:[citrusCashResponse.responseDict mutableCopy]];
                        else
                            [[SmartRxGetCarePlanVC sharedGetCarePlanVC] setPaymentResponseDictionary:[citrusCashResponse.responseDict mutableCopy]];
                    }
                    else if ([[NSUserDefaults standardUserDefaults]objectForKey:@"fromServices"])
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"TransactionSuccess"];
                        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"fromServices"] boolValue])
                            [[SmartRxBookServices sharedManagerServices] setPaymentResponseDictionary:[citrusCashResponse.responseDict mutableCopy]];
                        
                    }
                    else if ([[NSUserDefaults standardUserDefaults]objectForKey:@"fromCareProgram"])
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"TransactionSuccess"];
                        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"fromCareProgram"] boolValue])
                            [[SmartRxGetManagedCarePlanVC sharedManagerCarePlanProgram] setPaymentResponseDictionary:[citrusCashResponse.responseDict mutableCopy]];
                        
                    }else if ([[NSUserDefaults standardUserDefaults]objectForKey:@"fromAppointment"])
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"TransactionSuccess"];
                        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"fromAppointment"] boolValue])
                            [[SmartRxBookAPPointmentVC sharedManagerAppointment] setPaymentResponseDictionary:[citrusCashResponse.responseDict mutableCopy]];
                        
                    }
                    else if ([[NSUserDefaults standardUserDefaults]objectForKey:@"fromServiceView"])
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"TransactionSuccess"];
                        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"fromServices"] boolValue])
                            [[SmartRxCartCheckOutController sharedManagerBookServices] setPaymentResponseDictionary:[citrusCashResponse.responseDict mutableCopy]];
                        
                    }

                }
                else{
                    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"TransactionSuccess"];

                    
                }
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                //    [self.navigationController popViewControllerAnimated:YES];
                for (UIViewController *controller in [self.navigationController viewControllers])
                {
                    if ([controller isKindOfClass:[SmartRxBookeConsultVC class]] || [controller isKindOfClass:[SmartRxGetCarePlanVC class]] || [controller isKindOfClass:[SmartRxBookServices class]] || [controller isKindOfClass:[SmartRxCartCheckOutController class]] || [controller isKindOfClass:[SmartRxGetManagedCarePlanVC class]] || [controller isKindOfClass:[SmartRxBookAPPointmentVC class]])
                    {
                        [self.navigationController popToViewController:controller animated:YES];
                    }
                    
                }
                

            }
            
        }];

    }
}


- (void) setCardInfo{
    
    CTSPaymentDetailUpdate *tempCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    NSString *cardNumber = [self.cardNumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (segControl.selectedSegmentIndex==0) {
        
        // Update card for card payment.
        CTSElectronicCardUpdate *debitCard = [[CTSElectronicCardUpdate alloc] initDebitCard];
        debitCard.number = cardNumber;
        //        debitCard.expiryDate = [NSString stringWithFormat:@"%@/%@",self.expiryMonthTextField.text , self.expiryYearTextField.text];
        debitCard.expiryDate = self.expiryDateTextField.text;
        debitCard.scheme =  [CTSUtility fetchCardSchemeForCardNumber:debitCard.number];
        debitCard.ownerName = self.ownerNameTextField.text;
        debitCard.cvv = self.cvvTextField.text;
        //        debitCard.name = @"Kotak";
        [tempCardInfo addCard:debitCard];
        
    }
    else if (segControl.selectedSegmentIndex==1) {
        
        // Update card for card payment.
        CTSElectronicCardUpdate *creditCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
        creditCard.number = cardNumber;
        creditCard.expiryDate = self.expiryDateTextField.text;
        creditCard.scheme =  [CTSUtility fetchCardSchemeForCardNumber:creditCard.number];
        creditCard.ownerName = self.ownerNameTextField.text;
        creditCard.cvv = self.cvvTextField.text;
        [tempCardInfo addCard:creditCard];
    }
    
    cardInfo = nil;
    cardInfo = tempCardInfo;
    
}

-(void)requestPaymentModes{
    [paymentLayer requestMerchantPgSettings:VanityUrl withCompletionHandler:^(CTSPgSettings *pgSettings, NSError *error) {
        if(error){
            //handle error
            LogTrace(@"[error localizedDescription] %@ ", [error localizedDescription]);
        }
        else {
            //Vikas
            debitArray = [CTSUtility fetchMappedCardSchemeForSaveCards:[[NSSet setWithArray:pgSettings.debitCard] allObjects] ];
            creditArray = [CTSUtility fetchMappedCardSchemeForSaveCards:[[NSSet setWithArray:pgSettings.creditCard] allObjects] ];
            
            LogTrace(@" pgSettings %@ ", pgSettings);
            for (NSString* val in creditArray) {
                LogTrace(@"CC %@ ", val);
            }
            
            for (NSString* val in debitArray) {
                LogTrace(@"DC %@ ", val);
            }
            
        }
    }];
}

-(void)handlePaymentResponse:(CTSPaymentTransactionRes *)paymentInfo error:(NSError *)error
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    BOOL hasSuccess =
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
     (error == nil))
    ? YES
    : NO;
    if(hasSuccess){
        // Your code to handle success.
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIUtility dismissLoadingAlertView:YES];
            if (hasSuccess && error.code != ServerErrorWithCode) {
                [UIUtility didPresentLoadingAlertView:@"Connecting to the Payment Gateway" withActivity:YES];
                [self loadRedirectUrl:paymentInfo.redirectUrl];
            }else{
                [UIUtility didPresentErrorAlertView:error];
            }
        });
        
    }
    else{
        // Your code to handle error.
        NSString *errorToast;
        if(error== nil){
            errorToast = [NSString stringWithFormat:@" payment failed : %@",paymentInfo.txMsg] ;
        }else{
            errorToast = [NSString stringWithFormat:@" payment failed : %@",toErrorDescription(error)] ;
        }
        [UIUtility toastMessageOnScreen:errorToast];
    }
}

- (void)loadRedirectUrl:(NSString*)redirectURL {
    [self performSegueWithIdentifier:@"webViewSegue" sender:redirectURL];
}
#pragma mark - Storyboard Preapare segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"webViewSegue"]) {
//        WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
//        webViewViewController.redirectURL = redirectURL;
        ((WebViewViewController *)segue.destinationViewController).redirectURL =sender;
        [UIUtility dismissLoadingAlertView:YES];
        
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
#pragma mark - SegmentedControl methods

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
}

- (void)uisegmentedControlChangedValue:(UISegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld", (long)segmentedControl.selectedSegmentIndex);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    if (scrollView == self.scrollView)
//    {
//        CGFloat pageWidth = scrollView.frame.size.width;
//        NSInteger page = scrollView.contentOffset.x / pageWidth;
//        
//        [self.segmentedControl4 setSelectedSegmentIndex:page animated:YES];
//    }
}

#pragma mark - Textfield Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [textField resignFirstResponder];
    
    //return NO or YES, it doesn't matter
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    if (textField == self.debitAmountTextField || textField == self.creditAmountTextField)
//        return NO;
//    else
        return YES;
}


#pragma mark - TextView Delegate Methods

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField.tag == 2000) {
        __block NSString *text = [textField text];
        if ([textField.text isEqualToString:@""] || ( [string isEqualToString:@""] && textField.text.length==1)) {
            self.schemeTypeImageView.image = [CTSUtility getSchmeTypeImage:string];
        }
        
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
            return NO;
        }
        
        text = [text stringByReplacingCharactersInRange:range withString:string];
        text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (text.length>1) {
            self.schemeTypeImageView.image = [CTSUtility getSchmeTypeImage:text];
        }
        NSString *newString = @"";
        while (text.length > 0) {
            NSString *subString = [text substringToIndex:MIN(text.length, 4)];
            newString = [newString stringByAppendingString:subString];
            if (subString.length == 4) {
                newString = [newString stringByAppendingString:@" "];
            }
            text = [text substringFromIndex:MIN(text.length, 4)];
        }
        
        newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
        if (newString.length>1) {
          
            NSString* scheme = [CTSUtility fetchCardSchemeForCardNumber:[newString stringByReplacingOccurrencesOfString:@" " withString:@""]];
        
            if ([scheme isEqualToString:@"MTRO"]) {
                if (newString.length >= 24) {
                    return NO;
                }
            }
            else{
                if (newString.length >= 20) {
                    return NO;
                }
            }
        }
        
        [textField setText:newString];
        return NO;
        
    }
    else if (textField==self.cvvTextField) {
        NSString *currentString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        int length = (int)[currentString length];
        if (length > 4) {
            return NO;
        }
    }
    else if (textField==self.expiryDateTextField) {
        __block NSString *text = [textField text];
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789/"];
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        text = [text stringByReplacingCharactersInRange:range withString:string];
        NSArray* subStrings = [text componentsSeparatedByString:@"/"];
        int month = [[subStrings objectAtIndex:0] intValue];
        if(month > 12){
            NSString *string=@"";
            string = [string stringByAppendingFormat:@"0%@",text];
            text = string;
        }
        text = [text stringByReplacingOccurrencesOfString:@"/" withString:@""];
        if ([string isEqualToString:@""]) {
            return YES;
        }
        
        NSString *newString = @"";
        while (text.length > 0) {
            NSString *subString = [text substringToIndex:MIN(text.length, 2)];
            newString = [newString stringByAppendingString:subString];
            
            
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(containsString:)])
            {
                if (subString.length == 2 && ![newString containsString:@"/"]) {
                    newString = [newString stringByAppendingString:@"/"];
                }
            }
            else
            {
                if (subString.length == 2 && [newString rangeOfString:@"/"].location == NSNotFound) {
                    newString = [newString stringByAppendingString:@"/"];
                }
            }
            
//            if (subString.length == 2 && ![newString containsString:@"/"]) {
//                newString = [newString stringByAppendingString:@"/"];
//            }
            text = [text substringFromIndex:MIN(text.length, 2)];
        }
        newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
        
        if (newString.length >=6) {
            return NO;
        }
        
        [textField setText:newString];
        
        if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
            return NO;
        }
        else{
            return NO;
        }
    }
    
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

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (tableView==self.ccddtableView) {
        
        NSString *simpleTableIdentifier =[NSString stringWithFormat:@"test%d",(int)indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            
        }
        if (indexPath.row==0) {
            self.cardNumberTextField = (UITextField *)[cell.contentView viewWithTag:2000];
            self.cardNumberTextField.delegate = self;
            self.schemeTypeImageView = (UIImageView *)[cell.contentView viewWithTag:2001];
            
        }
        if (indexPath.row==1) {
            
            self.expiryDateTextField = (UITextField *)[cell.contentView viewWithTag:2002];
            self.expiryDateTextField.delegate = self;
            //            self.expiryMonthTextField = (UITextField *)[cell.contentView viewWithTag:2002];
            //            self.expiryMonthTextField.delegate = self;
            //            self.expiryYearTextField = (UITextField *)[cell.contentView viewWithTag:2003];
            //            self.expiryYearTextField.delegate = self;
            self.cvvTextField = (UITextField *)[cell.contentView viewWithTag:2004];
            self.cvvTextField.delegate = self;
        }
        if (indexPath.row==2) {
            self.ownerNameTextField = (UITextField *)[cell.contentView viewWithTag:2006];
            self.ownerNameTextField.delegate = self;
            
        }
        if (indexPath.row==3) {
            self.emailIDTextField = (UITextField *)[cell.contentView viewWithTag:2005];
            
            if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"emailId"] length] > 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"emailId"]!=nil)
                self.emailIDTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"emailId"];
            else
                if ([self.email length] > 0 && self.email != nil)
                    self.emailIDTextField.text = self.email;
            self.emailIDTextField.delegate = self;            
            
        }
        
//        if (indexPath.row==3) {
//            
//            UISwitch *localSwitchView = (UISwitch *)[cell.contentView viewWithTag:2005];
//            [localSwitchView addTarget:self action:@selector(updateSwitchAtIndexPath:)forControlEvents:UIControlEventValueChanged];
//        }
        
        
    }
    return cell;
}




- (CTSBill*)getBillFromServer:(CGFloat) amount{
    // Configure your request here.
    
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:
                                   [NSURL URLWithString:BillUrl]];
    [urlReq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setHTTPBody:[[NSString stringWithFormat:@"amount=%f",amount ] dataUsingEncoding:NSUTF8StringEncoding]];
    NSError* error = nil;
    NSData* signatureData = [NSURLConnection sendSynchronousRequest:urlReq
                                                  returningResponse:nil
                                                              error:&error];
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    dict = [NSJSONSerialization JSONObjectWithData:signatureData options:kNilOptions error:&error];
    NSString* billJson = [[NSString alloc] initWithData:signatureData
                                               encoding:NSUTF8StringEncoding];
    JSONModelError *jsonError;
    CTSBill* sampleBill = [[CTSBill alloc] initWithString:billJson
                                                    error:&jsonError];

    NSLog(@"billJson %@",billJson);
    NSLog(@"signature %@ ", sampleBill);
    return sampleBill;
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
