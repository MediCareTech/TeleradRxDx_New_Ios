//
//  SmartRxGetCarePlanVC.m
//  SmartRx
//
//  Created by Manju Basha on 25/05/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxGetCarePlanVC.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxPaymentVC.h"
#define kLessThan4Inch 560
@interface SmartRxGetCarePlanVC ()
{
    MBProgressHUD *HUD;
    NSMutableArray *topTenPlanArray, *searchArray;
    BOOL isTopTen;
    NSInteger finalCost, careID, actualCost;
    double discountedCost;
    CGSize viewSize;
    int cp_auto_camp_count;
    UIToolbar *numberToolbar;
    NSString *campId;
}
@end

@implementation SmartRxGetCarePlanVC
+ (id)sharedGetCarePlanVC {
    static SmartRxGetCarePlanVC *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Get Care Plan" controler:self];

    [self navigationBackButton];
    campId = @"";
    viewSize=[[UIScreen mainScreen]bounds].size;
    if (viewSize.height < kLessThan4Inch)
    {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height+100)];
    }
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                           nil];
    [numberToolbar sizeToFit];
    self.userNameText.inputAccessoryView = numberToolbar;
    self.userMobileText.inputAccessoryView = numberToolbar;
    self.userEmailText.inputAccessoryView = numberToolbar;
    self.userNameText.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"name.png"]];
    self.userNameText.leftView.frame = CGRectMake(self.userNameText.leftView.frame.origin.x, self.userNameText.leftView.frame.origin.y, self.userNameText.leftView.frame.size.width-10, self.userNameText.leftView.frame.size.height-10);
    
    self.userMobileText.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mobile.png"]];
    self.userMobileText.leftView.frame = CGRectMake(self.userMobileText.leftView.frame.origin.x, self.userMobileText.leftView.frame.origin.y, self.userMobileText.leftView.frame.size.width-10, self.userMobileText.leftView.frame.size.height-10);
    
    self.userEmailText.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icn_email.png"]];
    self.userEmailText.leftView.frame = CGRectMake(self.userEmailText.leftView.frame.origin.x, self.userEmailText.leftView.frame.origin.y, self.userEmailText.leftView.frame.size.width-10, self.userEmailText.leftView.frame.size.height-5);
    
    
    isTopTen = NO;
    topTenPlanArray = [[NSMutableArray alloc] init];
    searchArray = [[NSMutableArray alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"fromEconsult"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"] length] >0)
        {
            self.userNameText.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"];
            self.userMobileText.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
            self.userEmailText.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"emailId"];
        }
    }
    else
    {
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UName"] length] >0)
        {
            self.userNameText.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"UName"];
            self.userMobileText.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserMobile"];
        }
    }
    
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.careplanTableView.hidden = YES;
    [self.careplanTableView setTableFooterView:[UIView new]];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"TransactionSuccess"] )
    {
        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"TransactionSuccess"] boolValue])
        {
            self.paymentResponseDictionary = [[NSUserDefaults standardUserDefaults]objectForKey:@"paymentResponseDictionary"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TransactionSuccess"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self makeRequestToBuyCarePlan];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TransactionSuccess"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self customAlertView:@"" Message:@"Sorry we were not able to process the payment. Please try again after sometime." tag:0];
        }
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


-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (alertView.tag == 2)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - Storyboard Preapare segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"carePayment"]) {
        ((SmartRxPaymentVC *)segue.destinationViewController).costValue = [NSString stringWithFormat:@"%d", finalCost];
        ((SmartRxPaymentVC *)segue.destinationViewController).packageResponse = [[NSMutableDictionary alloc]init];
        ((SmartRxPaymentVC *)segue.destinationViewController).email = self.userEmailText.text;
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark Action Methods 
-(void)homeBtnClicked:(id)sender
{
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i=0;i<[viewControllers count];i++){
        id obj=[viewControllers objectAtIndex:i];
        if([obj isKindOfClass:[SmartRxDashBoardVC class]]){
            [[self navigationController] popToViewController:obj animated:YES];
            return;
        }
    }
//    for (UIViewController *controller in self.navigationController.viewControllers)
//    {
//        if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
//        {
//            [self.navigationController popToViewController:controller animated:YES];
//        }
//    }
}
- (IBAction)topcarePlansClicked:(id)sender
{
    [self.promoCodeText resignFirstResponder];
    [self.searchField resignFirstResponder];
    isTopTen = YES;
    self.userDetailView.hidden = YES;
    self.NextBtnView.hidden = YES;
    self.promoApplyBtn.tag = 666;
    self.carePlanActualCost.text = nil;
    self.carePlanDiscountedCost.text = nil;
    self.promoCodeText.text = nil;
    finalCost = 0;
    [self.promoApplyBtn setTitle:@"APPLY" forState:UIControlStateNormal];
    [self.promoApplyBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bg.png"] forState:UIControlStateNormal];
    
    [self makeRequestToGetTopTen];
}
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
        self.carePlanActualCost.text = self.carePlanActualCost.text;
        self.carePlanDiscountedCost.text = nil;
        NSArray *arr = [self.carePlanActualCost.text componentsSeparatedByString:@" "];
        finalCost = [[arr objectAtIndex:1] integerValue];
        [self.promoApplyBtn setTitle:@"APPLY" forState:UIControlStateNormal];
        [self.promoApplyBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bg.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)nextButtonClicked:(id)sender
{
    if (self.searchField.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please select care plan to continue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if (![self.userNameText.text length] || self.userNameText.text == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Name cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if ((![self.userMobileText.text length] || self.userMobileText.text == nil))
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Mobile number cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
        
    }
    else if ([self.userMobileText.text length] < 10)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Mobile number cannot be less than 10 digits." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if ((![self.userEmailText.text length] || self.userEmailText.text == nil))
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"E-Mail ID cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
        
    }
    else if ([self.userEmailText.text length]>0)
    {
        NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        
        NSLog(@"text filed text : %@",self.userEmailText.text);
        if ([emailTest evaluateWithObject:self.userEmailText.text] == NO && ![self.userEmailText.text isEqualToString:@""]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        else
        {
            if (finalCost > 0)
                [self performSegueWithIdentifier:@"carePayment" sender:nil];
            else
                [self makeRequestToBuyCarePlan];
        }
    }
    else
    {
        if (finalCost > 0)
            [self performSegueWithIdentifier:@"carePayment" sender:nil];
        else
            [self makeRequestToBuyCarePlan];
    }
}
- (void)hidePromo
{
    self.promoApplyBtn.hidden = YES;
    self.promoCodeText.hidden = YES;
    self.closeImage.hidden = YES;
    self.carePlanCostText.frame = CGRectMake(self.carePlanCostText.frame.origin.x, self.promoCodeText.frame.origin.y, self.carePlanCostText.frame.size.width, self.carePlanCostText.frame.size.height);
    self.carePlanActualCost.frame = CGRectMake(self.carePlanActualCost.frame.origin.x, self.promoCodeText.frame.origin.y, self.carePlanActualCost.frame.size.width, self.carePlanActualCost.frame.size.height);
    self.carePlanDiscountedCost.frame = CGRectMake(self.carePlanDiscountedCost.frame.origin.x, self.promoCodeText.frame.origin.y, self.carePlanDiscountedCost.frame.size.width, self.carePlanDiscountedCost.frame.size.height);
}

- (void)showPromo
{
    if (cp_auto_camp_count <= 0)
    {
        self.promoApplyBtn.hidden = NO;
        self.promoCodeText.hidden = NO;
        self.closeImage.hidden = NO;
        self.carePlanCostText.frame = CGRectMake(self.carePlanCostText.frame.origin.x, self.promoCodeText.frame.origin.y + self.promoCodeText.frame.size.height + 9, self.carePlanCostText.frame.size.width, self.carePlanCostText.frame.size.height);
        self.carePlanActualCost.frame = CGRectMake(self.carePlanActualCost.frame.origin.x, self.promoCodeText.frame.origin.y + self.promoCodeText.frame.size.height + 9, self.carePlanActualCost.frame.size.width, self.carePlanActualCost.frame.size.height);
        self.carePlanDiscountedCost.frame = CGRectMake(self.carePlanDiscountedCost.frame.origin.x, self.promoCodeText.frame.origin.y + self.promoCodeText.frame.size.height + 9, self.carePlanDiscountedCost.frame.size.width, self.carePlanDiscountedCost.frame.size.height);
    }
    
}
#pragma mark Request methods
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
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&for=2&promocode=%@",@"cid",strCid,@"sessionid",sectionId, self.promoCodeText.text];
    }
    else{
        bodyText=[NSString stringWithFormat:@"%@=%@&%@=%@&for=2&promocode=%@",@"cid",strCid,@"isopen",@"1", self.promoCodeText.text];
    }
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mchkcamp"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"hi sucess %@",response);
        
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
                    if ([[response objectForKey:@"chkredeem"] integerValue] == 1)
                    {
                        self.promoApplyBtn.tag = 999;
                        [self.promoApplyBtn setTitle:nil forState:UIControlStateNormal];
                        [self.promoApplyBtn setBackgroundImage:nil forState:UIControlStateNormal];
                        
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Promo code applied. Thank you." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        campId = [[[response objectForKey:@"campaign"] objectAtIndex:0] objectForKey:@"recno"];
                        
                        //                        discount
                        float discountPercent = [[[[response objectForKey:@"campaign"] objectAtIndex:0] objectForKey:@"discount"] floatValue];
                        discountPercent = discountPercent/100;
                        float discount = actualCost * discountPercent;
                        discountedCost = ceilf(actualCost - discount);
                        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %ld", (long)actualCost]];
                        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                                value:@2
                                                range:NSMakeRange(0, [attributeString length])];
                        self.carePlanActualCost.attributedText = attributeString;
                        finalCost = discountedCost;
                        if (discountedCost > 0)
                            self.carePlanDiscountedCost.text = [NSString stringWithFormat:@"Rs %d", (int)discountedCost];
                        else
                            self.carePlanDiscountedCost.text = @"Free";
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -3)
                    {
                        msg = @"You already used this promo code";                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -4)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"This promo code expired." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -5)
                    {
                        msg = @"Given promo code not sent to this user";
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Name cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -6)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Promo code is invalid. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -7)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable at this location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -8)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable for this visit." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else if([[response objectForKey:@"chkredeem"] integerValue] == -9)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Given promo code is not applicable for Care Plan(s)." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Promo code is invalid. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

- (void)makeRequestToBuyCarePlan
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText, *payType;
    if (finalCost > 0)
        payType = @"2"; //PAYMENT
    else
        payType = @"1"; //FREE
    
    if ([sectionId length]>0)
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&patient_name=%@&patient_mobile=%@&patient_email=%@&careid=%d&paytype=%@&payraw=%@&TxId=%@&TxStatus=%@&amount=%@&authIdCode=%@&TxMsg=%@&pgTxnNo=%@&paymentMode=%@",@"sessionid",sectionId,@"cid",strCid, self.userNameText.text,self.userMobileText.text,self.userEmailText.text, careID, payType,self.paymentResponseDictionary, [self.paymentResponseDictionary objectForKey:@"TxId"], [self.paymentResponseDictionary objectForKey:@"TxStatus"] ,[self.paymentResponseDictionary objectForKey:@"amount"],[self.paymentResponseDictionary objectForKey:@"authIdCode"] ,[self.paymentResponseDictionary objectForKey:@"TxMsg"] ,[self.paymentResponseDictionary objectForKey:@"pgTxnNo"] ,[self.paymentResponseDictionary objectForKey:@"paymentMode"]];
    else
        bodyText = [NSString stringWithFormat:@"isopen=1&%@=%@&patient_name=%@&patient_mobile=%@&patient_email=%@&careid=%d&paytype=%@&payraw=%@&TxId=%@&TxStatus=%@&amount=%@&authIdCode=%@&TxMsg=%@&pgTxnNo=%@&paymentMode=%@",@"cid",strCid, self.userNameText.text,self.userMobileText.text,self.userEmailText.text, careID, payType,self.paymentResponseDictionary, [self.paymentResponseDictionary objectForKey:@"TxId"], [self.paymentResponseDictionary objectForKey:@"TxStatus"] ,[self.paymentResponseDictionary objectForKey:@"amount"],[self.paymentResponseDictionary objectForKey:@"authIdCode"] ,[self.paymentResponseDictionary objectForKey:@"TxMsg"] ,[self.paymentResponseDictionary objectForKey:@"pgTxnNo"] ,[self.paymentResponseDictionary objectForKey:@"paymentMode"]];
    
    if ([campId length] > 0 && campId != nil)
    {
        NSString *campTemp = [NSString stringWithFormat:@"&campid=%@",campId];
        bodyText = [bodyText stringByAppendingString:campTemp];
    }
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"maddpatwithcare"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"Care Plan sucess %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[response objectForKey:@"status"] integerValue] == 1)
                {
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    if([[response objectForKey:@"pattype"] integerValue] == 2)
                        [self customAlertView:@"" Message:@"Thank you. Selected care plan has been successfully assigned to you." tag:2];
                    else
                        [self customAlertView:@"" Message:@"Thank you. Selected care plan has been successfully assigned to you." tag:1];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Selected care plan already assigned to you. Please select someother care plan" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    return;
                }
                
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"" Message:@"Buying care plan failed due to network issues. Please try again." tag:0];
    }];
    
}

- (void)makeRequestToGetTopTen
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&mode=1&%@=%@&%@=%@",@"sessionid",sectionId,@"cid",strCid,@"isopen",@"1"];
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mcare"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"Care Plan sucess %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userDetailView.hidden = YES;
                self.NextBtnView.hidden = YES;
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                if ([[response objectForKey:@"cp_auto_camp_count"]integerValue] > 0)
                {
                    cp_auto_camp_count = [[response objectForKey:@"cp_auto_camp_count"]integerValue];
                    [self hidePromo];
                }
                else
                {
                    cp_auto_camp_count = 0;
                    self.promoApplyBtn.hidden = NO;
                    self.promoCodeText.hidden = NO;
                    self.closeImage.hidden = NO;
                }
                topTenPlanArray = [[response objectForKey:@"template"] mutableCopy];
                finalCost = [[response objectForKey:@"cost"] integerValue];
                actualCost = [[response objectForKey:@"acost"] integerValue];
                discountedCost = [[response objectForKey:@"cost"] integerValue];
                self.topTenCarePlanBtn.hidden = YES;
                self.careplanTableView.hidden = NO;
                self.topTenCarePlanBtn.hidden = YES;
                self.noMatchLabel.hidden = YES;
                self.orLabel.hidden = YES;
                self.topOrLabel.hidden = YES;
                self.searchField.text = nil;
                 [self.careplanTableView reloadData];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                     [self.careplanTableView reloadData];
//                });
              
//                if ([topTenPlanArray count] > 7)
//                {
//                    self.careplanTableView.frame = CGRectMake(self.careplanTableView.frame.origin.x, self.careplanTableView.frame.origin.y, self.careplanTableView.frame.size.width, self.self.careplanTableView.contentSize.height + (([topTenPlanArray count]-7)*44));
//                    //                    [self.careplanTableView setContentSize:CGSizeMake(self.careplanTableView.contentSize.width, self.careplanTableView.contentSize.height + (([topTenPlanArray count]-7)*44))];
//                    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + (([topTenPlanArray count]-7)*44))];
//                    
//                    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height+ 50 + (([topTenPlanArray count]-7)*44));
//                }
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"" Message:@"Fetching top ten care plans failed due to network issues. Please try again." tag:0];
    }];
}

- (void)makeRequestToSearchCarePlan:(NSString *)string
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText = [NSString stringWithFormat:@"mode=2&search=%@&%@=%@&%@=%@",string,@"cid",strCid,@"isopen",@"1"];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mcare"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"Care Plan sucess %@",response);
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
                self.userDetailView.hidden = YES;
                self.NextBtnView.hidden = YES;
                if ([[response objectForKey:@"template"] count])
                {
                    if ([[response objectForKey:@"cp_auto_camp_count"]integerValue] > 0)
                    {
                        cp_auto_camp_count = [[response objectForKey:@"cp_auto_camp_count"]integerValue];
                        self.promoApplyBtn.hidden = YES;
                        self.promoCodeText.hidden = YES;
                        self.closeImage.hidden = YES;
                        self.carePlanCostText.frame = CGRectMake(self.carePlanCostText.frame.origin.x, self.promoCodeText.frame.origin.y, self.carePlanCostText.frame.size.width, self.carePlanCostText.frame.size.height);
                        self.carePlanActualCost.frame = CGRectMake(self.carePlanActualCost.frame.origin.x, self.promoCodeText.frame.origin.y, self.carePlanActualCost.frame.size.width, self.carePlanActualCost.frame.size.height);
                        self.carePlanDiscountedCost.frame = CGRectMake(self.carePlanDiscountedCost.frame.origin.x, self.promoCodeText.frame.origin.y, self.carePlanDiscountedCost.frame.size.width, self.carePlanDiscountedCost.frame.size.height);
                    }
                    else
                    {
                        cp_auto_camp_count = 0;
                        self.promoApplyBtn.hidden = NO;
                        self.promoCodeText.hidden = NO;
                        self.closeImage.hidden = NO;
                    }
                    self.view.userInteractionEnabled = YES;
                    finalCost = [[response objectForKey:@"cost"] integerValue];
                    actualCost = [[response objectForKey:@"acost"] integerValue];
                    discountedCost = [[response objectForKey:@"cost"] integerValue];
                    searchArray = [[response objectForKey:@"template"] mutableCopy];
                    self.topTenCarePlanBtn.hidden = YES;
                    self.careplanTableView.hidden = NO;
                    self.noMatchLabel.hidden = YES;
                    self.orLabel.hidden = YES;
                    self.topOrLabel.hidden = YES;
                    [self.careplanTableView reloadData];
//                    if ([searchArray count] > 7)
//                    {
//                        self.careplanTableView.frame = CGRectMake(self.careplanTableView.frame.origin.x, self.careplanTableView.frame.origin.y, self.careplanTableView.frame.size.width, self.self.careplanTableView.contentSize.height + (([searchArray count]-7)*44));
//                        [self.careplanTableView setContentSize:CGSizeMake(self.careplanTableView.contentSize.width, self.careplanTableView.contentSize.height + (([searchArray count]-7)*44))];
//                        [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + (([searchArray count]-7)*44))];
//                        
//                        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height+ 100 + (([searchArray count]-7)*44));
//                    }
                    
                }
                else
                {
                    self.careplanTableView.hidden = YES;
                    self.noMatchLabel.hidden = NO;
                    self.orLabel.hidden = NO;
                    self.topOrLabel.hidden = YES;
                    self.topTenCarePlanBtn.hidden = NO;
                    self.topTenCarePlanBtn.frame = CGRectMake(self.topTenCarePlanBtn.frame.origin.x, self.orLabel.frame.origin.y+10, self.topTenCarePlanBtn.frame.size.width, self.topTenCarePlanBtn.frame.size.height);
                }
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}
- (void)doneButton:(id)sender
{
    [self.userNameText resignFirstResponder];
    [self.userMobileText resignFirstResponder];
    [self.userEmailText resignFirstResponder];
}
#pragma mark - Tableview Delegate/Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isTopTen)
        return [topTenPlanArray count];
    else
        return [searchArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    //Cell text attributes
    if (isTopTen)
    {
        cell.textLabel.text = [[topTenPlanArray objectAtIndex:indexPath.row] objectForKey:@"carename"];
        cell.tag = [[[topTenPlanArray objectAtIndex:indexPath.row] objectForKey:@"recno"] integerValue];
    }
    else
    {
        cell.textLabel.text = [[searchArray objectAtIndex:indexPath.row] objectForKey:@"carename"];
        cell.tag = [[[searchArray objectAtIndex:indexPath.row] objectForKey:@"recno"] integerValue];
    }
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    
    // To bring the arrow mark on right end of each cell.
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.userDetailView.hidden = NO;
    self.NextBtnView.hidden = NO;
    self.careplanTableView.hidden = YES;
    self.noMatchLabel.hidden = YES;
    self.orLabel.hidden = YES;
    self.topOrLabel.hidden = NO;
    self.topTenCarePlanBtn.hidden = NO;
    self.topTenCarePlanBtn.frame = CGRectMake(self.topTenCarePlanBtn.frame.origin.x, self.noMatchLabel.frame.origin.y+15, self.topTenCarePlanBtn.frame.size.width, self.topTenCarePlanBtn.frame.size.height);
    if (cp_auto_camp_count > 0)
    {
        if(actualCost != 0)
        {
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %d", actualCost]];
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@2
                                    range:NSMakeRange(0, [attributeString length])];
            self.carePlanActualCost.attributedText = attributeString;
            finalCost = discountedCost;
            if (discountedCost > 0)
                self.carePlanDiscountedCost.text = [NSString stringWithFormat:@"Rs %d", (int)discountedCost];
            else
                self.carePlanDiscountedCost.text = @"Free";
            
        }
        else if (actualCost == nil || actualCost == 0)
        {
            self.carePlanActualCost.text = @"Free";
            [self hidePromo];
        }
    }
    else if (finalCost > 0)
        self.carePlanActualCost .text = [NSString stringWithFormat:@"Rs %d", finalCost];
    else if (finalCost == 0)
    {
        self.carePlanActualCost.text = @"Free";
        [self hidePromo];
    }
    
    if (isTopTen)
    {
        self.searchField.text = [[topTenPlanArray objectAtIndex:indexPath.row] objectForKey:@"carename"];
        self.searchField.tag  = [[[topTenPlanArray objectAtIndex:indexPath.row] objectForKey:@"recno"] integerValue];
        careID = [[[topTenPlanArray objectAtIndex:indexPath.row] objectForKey:@"recno"] integerValue];
    }
    else
    {
        [self.view endEditing:YES];
        self.searchField.text = [[searchArray objectAtIndex:indexPath.row] objectForKey:@"carename"];
        self.searchField.tag  = [[[searchArray objectAtIndex:indexPath.row] objectForKey:@"recno"] integerValue];
        careID = [[[searchArray objectAtIndex:indexPath.row] objectForKey:@"recno"] integerValue];
    }
}
#pragma mark - Text filed Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.promoCodeText)
    {
        if (self.promoApplyBtn.tag == 666)
            return YES;
        else
            return NO;
    }
    else
        return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.searchField)
    {
        isTopTen = NO;
        self.userDetailView.hidden = YES;
        self.NextBtnView.hidden = YES;
        
        self.promoApplyBtn.tag = 666;
        self.carePlanActualCost.text = nil;
        self.carePlanDiscountedCost.text = nil;
        finalCost = 0;
        self.promoCodeText.text = nil;
        [self.promoApplyBtn setTitle:@"APPLY" forState:UIControlStateNormal];
        [self.promoApplyBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bg.png"] forState:UIControlStateNormal];
        
        self.topTenCarePlanBtn.frame = CGRectMake(self.topTenCarePlanBtn.frame.origin.x, self.noMatchLabel.frame.origin.y+15, self.topTenCarePlanBtn.frame.size.width, self.topTenCarePlanBtn.frame.size.height);
        if (textField.text == nil || textField.text.length <= 3)
        {
            self.careplanTableView.hidden = YES;
            self.topTenCarePlanBtn.hidden = NO;
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.searchField)
    {
        NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([str length] >= 3)
            
              [self makeRequestToSearchCarePlan:str];
        
        else if ([str length] < 3 && [str length] > 0)
        {
            self.noMatchLabel.hidden = NO;
            self.orLabel.hidden = NO;
            self.topOrLabel.hidden = YES;
            self.topTenCarePlanBtn.hidden = NO;
            self.topTenCarePlanBtn.frame = CGRectMake(self.topTenCarePlanBtn.frame.origin.x, self.orLabel.frame.origin.y+10, self.topTenCarePlanBtn.frame.size.width, self.topTenCarePlanBtn.frame.size.height);
            self.careplanTableView.hidden = YES;
            
        }
        else if (str.length == nil)
        {
            self.noMatchLabel.hidden = YES;
            self.orLabel.hidden = YES;
            self.topOrLabel.hidden = NO;
            self.topTenCarePlanBtn.frame = CGRectMake(self.topTenCarePlanBtn.frame.origin.x, self.noMatchLabel.frame.origin.y+15, self.topTenCarePlanBtn.frame.size.width, self.topTenCarePlanBtn.frame.size.height);
        }
    }
    return YES;
}

@end
