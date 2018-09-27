//
//  SmartRxCartCheckOutController.m
//  SmartRx
//
//  Created by Gowtham on 20/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxCartCheckOutController.h"
#import "SmartRxDB.h"
#import "Cart+CoreDataProperties.h"
#import "SmartRxAppDelegate.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxPaymentVC.h"
#import "SmartRxBookedServicesController.h"


@interface SmartRxCartCheckOutController ()
{
    MBProgressHUD *HUD;
    int cartTotalAmount;
    int cartDiscountPrice;
    BOOL promoApplied;
    NSInteger finalCost;
    BOOL isPaymentSuccess;
    NSString *paymentType;
    NSString *payOption;
    NSString *campId;
    
}
@property(nonatomic,strong) NSArray *cartArray;
@property(nonatomic,strong) NSArray *bookingArray;
@end

@implementation SmartRxCartCheckOutController

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
+ (id)sharedManagerBookServices {
    static SmartRxCartCheckOutController *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Checkout";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setTableFooterView:[UIView new]];
    self.cartOriginalPrice.hidden = YES;
    self.closeImage.hidden = YES;
    [self navigationBackButton];
    [self clickOnPayNowButton:nil];
    [self getCartItems];
    NSLog(@"booking array......:%@",self.bookingArray);
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
            isPaymentSuccess = YES;
            [self makeRequsrForBooking];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TransactionSuccess"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self customAlertView:@"" Message:@"Sorry we were not able to process the payment. Please try again after sometime to book the E-Consult." tag:0];
        }
    }
    
}

-(void)getCartItems{
    
    self.cartArray = [[SmartRxDB sharedDBManager] fetchCartItems];
    
    [self createBookinArray];
   
    for ( Cart *cart in self.cartArray) {
        cartTotalAmount += [cart.servicePrice intValue];
        
    }
    finalCost = cartTotalAmount;
    if (cartTotalAmount == 0 && self.cartArray.count == 0) {
        self.cartDiscountedPrice.hidden = YES;
    } else if (cartTotalAmount == 0) {
        self.cartDiscountedPrice.text = @"Free";
        self.payNowBtn.hidden = YES;
        self.payLaterBtn.hidden = YES;
        payOption = @"1";
        paymentType = @"1";
    }else {
        self.cartDiscountedPrice.text = [NSString stringWithFormat:@"Rs. %d",cartTotalAmount];

    }
    
    [self.cartDiscountedPrice sizeToFit];
    
    self.cartCountLbl.text = [NSString stringWithFormat:@"( %lu )",(unsigned long)self.cartArray.count];
    
}

#pragma mark - Action Methods
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
-(IBAction)clickOnPayNowButton:(id)sender{
    payOption = @"2";
    paymentType = @"1";
    
    [self.payNowBtn setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateNormal];
    [self.payLaterBtn setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
}
-(IBAction)clickOnPayLaterButton:(id)sender{
    payOption = @"3";
    paymentType = @"2";
    [self.payNowBtn setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
    [self.payLaterBtn setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateNormal];
}
-(IBAction)clickOnBookNowButton:(id)sender{
    
    if (self.cartArray.count) {
        
        if ([paymentType isEqualToString:@"2"] || [self.cartDiscountedPrice.text isEqualToString:@"Free"]) {
            
         [self makeRequsrForBooking];
       
        }else {
            
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"fromServiceView"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self customAlertView:@"Note" Message:@"You will be taken to the payment gateway to complete the transaction, as you do not have credits." tag:2];
           
        }
    }
   
}
-(IBAction)clickOnApplyButton:(id)sender{
    
    if (self.promoApplyBtn.tag == 666)
    {
        [self.promoCodeTf resignFirstResponder];
        if ([self.promoCodeTf.text length] > 0 && self.promoCodeTf.text != nil)
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
        self.closeImage.hidden = YES;
        self.payLaterBtn.hidden = NO;
        self.payNowBtn.hidden = NO;
        self.promoApplyBtn.tag = 666;
        self.cartDiscountedPrice.text = [NSString stringWithFormat:@"Rs. %d",cartTotalAmount];
        self.cartOriginalPrice.text = nil;
        finalCost = cartTotalAmount;
        [self.cartDiscountedPrice sizeToFit];
        [self.cartOriginalPrice sizeToFit];
//        NSArray *arr = [self.consultationActualCost.text componentsSeparatedByString:@" "];
//        if ([arr count]  >= 2)
//            finalCost = [[arr objectAtIndex:1] integerValue];
//        else
//            finalCost = 0;
        promoApplied = NO;
        cartDiscountPrice = 0;
        
        [self.promoApplyBtn setTitle:@"APPLY" forState:UIControlStateNormal];
        [self.promoApplyBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bg.png"] forState:UIControlStateNormal];
    }

}
#pragma mark - Textfield methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (finalCost == 0) {
        return  NO;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - Request methods
-(void)makeRequestCheckPromo{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
    NSString *serviceId = @"";
    int value = 0;
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for ( Cart *cart in self.cartArray) {
        if (![array containsObject:cart.providerServiceId]) {
            if (value == 0) {
            serviceId = [serviceId stringByAppendingString:cart.providerServiceId];
        }else {
            serviceId = [serviceId stringByAppendingString:[NSString stringWithFormat:@",%@",cart.providerServiceId]];
        }
            [array addObject:cart.providerServiceId];
            value = 1;
        }
    }
    NSLog(@"service id......:%@",serviceId);
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *mobile=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobileNumber"];
    NSString *name=[[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&for=3&promocode=%@&mobile=%@&name=%@&service_id=%@",@"cid",strCid,@"sessionid",sectionId, self.promoCodeTf.text,mobile,name,serviceId];
       // bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&for=3&promocode=%@&mobile=%@&name=%@",@"cid",strCid,@"sessionid",sectionId, self.promoCodeTf.text,mobile,name];
    }
    else{
        bodyText=[NSString stringWithFormat:@"%@=%@&%@=%@&for=3&promocode=%@&mobile=%@&name=%@&service_id=%@",@"cid",strCid,@"isopen",@"1", self.promoCodeTf.text,mobile,name,serviceId];
    }
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mchkcamp"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        
        NSLog(@"hi sucess %@",response);
        
        if (([response count] == 0 && [sectionId length] == 0))
        {
            //[self makeRequestForUserRegister];
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
                    
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    //NSArray *tempArr = response[@"campaign"];
                    
                    if ([[response objectForKey:@"chkredeem"] integerValue] == 1) {
                        
                        self.promoApplyBtn.tag = 999;
                        self.closeImage.hidden = NO;

                        [self.promoApplyBtn setTitle:nil forState:UIControlStateNormal];
                        [self.promoApplyBtn setBackgroundImage:nil forState:UIControlStateNormal];
                        
                        promoApplied = YES;
                        self.cartOriginalPrice.hidden = NO;
                        if (!promoApplied) {
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Promo code applied. Thank you." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
                        
                    NSDictionary *campainDict = response[@"campaign"][0];
                        campId = [NSString stringWithFormat:@"%@", campainDict[@"recno"]];
                     double  discountedCost =   [self promocodeApply:campainDict service:response[@"serviceid"]];
                        
//                    float discountPercent = [campainDict[@"discount"] floatValue];
//                    discountPercent = discountPercent/100;
//                    //NSInteger calCost = [price integerValue];
//                    float discount = cartTotalAmount * discountPercent;
//                    double discountedCost = ceilf(cartTotalAmount - discount);
                        
                        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %.0d", cartTotalAmount]];
                        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                                value:@2
                                                range:NSMakeRange(0, [attributeString length])];
                        self.cartOriginalPrice.attributedText = attributeString;
                        cartDiscountPrice = discountedCost;
                        if (discountedCost>0) {
                            finalCost = cartDiscountPrice;
                    self.cartDiscountedPrice.text = [NSString stringWithFormat:@"Rs. %.0f",discountedCost];
        
                } else{
                    
                    self.cartDiscountedPrice.text = @"Free";
                    self.payNowBtn.hidden = YES;
                    self.payLaterBtn.hidden = YES;
                }
                        [self.cartOriginalPrice sizeToFit];

                        [self.cartDiscountedPrice sizeToFit];
             
                    } else {
                        [self promocodeError:[response objectForKey:@"chkredeem"]];
                    }
                });
                
            }
        }
    }failureHandler:^(id response) {
                
                NSLog(@"failure %@",response);
                [HUD hide:YES];
                [HUD removeFromSuperview];
                [self customAlertView:@"Network not available" Message:@"Try again" tag:0];

            }];
            
}
-(void)makeRequsrForBooking{
    
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *price;
    if (promoApplied) {
        
        if ([self.cartDiscountedPrice.text isEqualToString:@"Free"]) {
            price = @"";
        } else {
            price = [NSString stringWithFormat:@"%d",cartDiscountPrice];
        }
    } else {
        price = [NSString stringWithFormat:@"%d",cartTotalAmount];
    }
    NSString *promoCode;
    if (promoApplied) {
        promoCode = campId;
    } else {
        promoCode = @"";
    }

    
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        
        if (!isPaymentSuccess) {
        
        bodyText = [NSString stringWithFormat:@"%@=%@&campid=%@&user_id=%@&econ_consult_type=%@&payment_type=%@&payoption=%@&service_price=%@&payraw=%@",@"sessionid",sectionId,promoCode,userId,@"2",paymentType,payOption,price,@""];
            
        } else {
          }
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    NSLog(@"body text......:%@",bodyText);
    NSLog(@"bookinng array........:%@",self.bookingArray);
     NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"member_services/createBulk"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postData = [[NSMutableData alloc]initWithData:[[NSString stringWithFormat:@"%@",bodyText ] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.bookingArray options:NSJSONWritingPrettyPrinted error:nil];
    NSData *dataa = [[NSString stringWithFormat:@"%@",self.bookingArray ] dataUsingEncoding:NSUTF8StringEncoding];
    [postData appendData:[[NSString stringWithFormat:@"&items="] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:data];
    
    [request setHTTPBody:postData];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *  data, NSURLResponse *  response, NSError * error) {
        
        dispatch_async(dispatch_get_main_queue(),^{
        if (!error) {
            
        NSString *errStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [HUD hide:YES];
            [HUD removeFromSuperview];
            id temp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"success data...:%@",temp);
 
            if (temp == nil) {
                SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                smartLogin.loginDelegate=self;
                //[smartLogin makeLoginRequest];
            }
            
            NSArray *successArray = temp[@"success"];
            if (successArray.count) {
                [[SmartRxDB sharedDBManager]deleteCartDataBase];
                self.cartOriginalPrice.text = nil;
                self.cartDiscountedPrice = nil;
                self.cartCountLbl.text = [NSString stringWithFormat:@"(%@)",@"0"];
                [self customAlertView:@"" Message:@"Thank you. Your Services is booked." tag:555];
            } else{
                NSString *dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"failure data:%@",dataStr);
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error booking Service please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            

        } else {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            [self customAlertView:@"Network not available" Message:@"Try again" tag:0];
        }
            
             });
    }];
    [dataTask resume];
    
}

-(void)promocodeError:(NSString *)value{
    
  NSInteger errorValue = [value integerValue];
    
   NSString *errorMessage = @"Promo code is invalid. Please try again.";
    
    switch (errorValue) {
        case -3:
            errorMessage = @"You already used this promo code";
            break;
        case -4:
            errorMessage = @"This promo code expired.";
            break;
        case -5:
            errorMessage = @"Given promo code not sent to this user";
            break;
        case -6:
            errorMessage = @"Promo code is invalid. Please try again.";
            break;
        case -7:
            errorMessage = @"Given promo code is not applicable at this location.";
            break;
        case -8:
            errorMessage = @"Given promo code is not applicable for this visit.";
            break;
        case -9:
            errorMessage = @"Given promo code is not applicable for Services.";
            break;
        default:
            break;
    }
    [self customAlertView:errorMessage Message:@"" tag:0];
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}


-(void)createBookinArray{
    
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
    for (Cart *cart in self.cartArray) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd-MM-yyyy"];
        NSDate *date = [formatter dateFromString:cart.scheduledDate];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [formatter stringFromDate:date];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"user_id",cart.serviceType,@"service_type",cart.servicePrice,@"service_price",cart.providerServiceId,@"provider_service_id",dateStr,@"scheduled_date",cart.scheduledTime,@"scheduled_time",cart.bookingLocationId,@"booking_location_id", nil];
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
        [tempDict setObject:userId forKey:@"user_id"];
        [tempDict setObject:cart.serviceType forKey:@"service_type"];
        if (cart.bookingLocationId) {
            [tempDict setObject:cart.bookingLocationId forKey:@"booking_location_id"];
        }
        
        [tempDict setObject:cart.servicePrice forKey:@"service_price"];
        [tempDict setObject:cart.providerServiceId forKey:@"provider_service_id"];
        if (dateStr) {
     [tempDict setObject:dateStr forKey:@"scheduled_date"];
        }
        if (cart.scheduledTime) {
            [tempDict setObject:cart.scheduledTime forKey:@"scheduled_time"];

        }

        [tempArray addObject:tempDict];
    }
    self.bookingArray = [tempArray copy];
    
}
-(double)promocodeApply:(NSDictionary *)promoDetails service:(NSArray *)servicesList{
    float discountPercent = [promoDetails[@"discount"] floatValue];
    discountPercent = discountPercent/100;
    double cartAmnt = 0;
    for (Cart *cart  in self.cartArray) {
        if ([servicesList containsObject:cart.providerServiceId]) {
        float discount = [cart.servicePrice integerValue] * discountPercent;
        double discountCost =  ceilf( [cart.servicePrice integerValue] - discount);
            NSLog(@"discountCost.......:%f",discountCost);
        cartAmnt += discountCost;
        }else {
            cartAmnt +=[cart.servicePrice integerValue];
        }
    }
    NSLog(@"cartAmnt.......:%f",cartAmnt);

    return cartAmnt;
}
-(void)sectionIdGenerated:(id)sender;
{
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequsrForBooking];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}
#pragma mark - Tableview Delegate And Datasource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cartArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CheckOutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkOutCell"];
    cell.delegate = self;
    cell.cellId = indexPath;
    Cart *cartItem = self.cartArray[indexPath.row];
    if ([cartItem.isScheduled boolValue] == 0) {
        cell.timeTxtLbl.hidden = YES;
    }
    cell.serviceNameLbl.text = cartItem.serviceName;
    cell.dateLbl.text = cartItem.scheduledDate;
    cell.timeLbl.text = cartItem.scheduledTime;
    if ([cartItem.servicePrice integerValue] == 0) {
        cell.priceLbl.text = @"Free";
    }else {
        cell.priceLbl.text = [NSString stringWithFormat:@"Rs. %@",cartItem.servicePrice];
    }
    cell.providerNameLbl.text = cartItem.providerName;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 123.0f;
}
-(void)deleteButtonClicked:(NSIndexPath *)indexpath{
    Cart *cartItem = self.cartArray[indexpath.row];
    [[SmartRxDB sharedDBManager] deleteCartItem:cartItem];
    cartTotalAmount = 0;
    [self getCartItems];
    if (promoApplied) {
        [self makeRequestCheckPromo];
    }
    [self. tableView reloadData];
    
}
#pragma mark - Custom AlertView

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
    if (alertView.tag == 2 ){
        [self performSegueWithIdentifier:@"servicePayment" sender:nil];
    } else if (alertView.tag == 555){
        BOOL isAppear;
        for (UIViewController *controller in [self.navigationController viewControllers])
        {
            if ([controller isKindOfClass:[SmartRxBookedServicesController class]])
            {
                isAppear = YES;
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
        if (!isAppear) {
            [self homeBtnClicked:nil];
        }

        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Storyboard Preapare segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"servicePayment"]) {
        
        ((SmartRxPaymentVC *)segue.destinationViewController).costValue = [NSString stringWithFormat:@"%ld", (long)finalCost];
        ((SmartRxPaymentVC *)segue.destinationViewController).packageResponse = [[NSMutableDictionary alloc]init];
        ((SmartRxPaymentVC *)segue.destinationViewController).packageResponse = self.packageResponse;
    }
}
@end
