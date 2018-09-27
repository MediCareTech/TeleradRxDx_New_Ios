//
//  CTSPaymentLayer.m
//  RestFulltester
//
//  Created by Raji Nair on 19/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//
#import "CTSPaymentDetailUpdate.h"
#import "CTSContactUpdate.h"
#import "CTSPaymentLayer.h"
#import "CTSPaymentMode.h"
#import "CTSPaymentRequest.h"
#import "CTSAmount.h"
#import "CTSPaymentToken.h"
#import "CTSPaymentMode.h"
#import "CTSUserDetails.h"
#import "CTSUserAddress.h"
#import "CTSPaymentTransactionRes.h"
#import "CTSGuestCheckout.h"
#import "CTSPaymentNetbankingRequest.h"
#import "CTSTokenizedCardPayment.h"
#import "CTSUtility.h"
#import "CTSError.h"
#import "CTSProfileLayer.h"
#import "CTSAuthLayer.h"
#import "CTSRestCoreRequest.h"
#import "CTSUtility.h"
#import "CTSOauthManager.h"
#import "CTSTokenizedPaymentToken.h"
#import "NSObject+logProperties.h"
//#import "MerchantConstants.h"
#import "CTSUserAddress.h"
#import "CTSCashoutToBankRes.h"
#import "PayLoadWebviewDto.h"
#import "CTSPrepaidPayReq.h"
#import "CitrusSdk.h"
//#import "WebViewViewController.h"
#import "UIUtility.h"
#import "CTSHtmlParser.h"

@interface CTSPaymentLayer (){
    
    CTSPaymentDetailUpdate  *aPaymentInfo;
    CTSBill *aBill;
    CTSContactUpdate *aContactInfo;
    CTSUserAddress *aUserAddress;
    NSDictionary *aCustParams;
}

@property(strong) CTSHtmlParser *htmlParser;

@end

@implementation CTSPaymentLayer
@synthesize merchantTxnId;
@synthesize signature;
@synthesize delegate,citrusCashBackViewController,paymentWebViewController,citrusPayWebview;

- (CTSPaymentRequest*)configureReqPayment:(CTSPaymentDetailUpdate*)paymentInfo
                                  contact:(CTSContactUpdate*)contact
                                  address:(CTSUserAddress*)address
                                   amount:(NSString*)amount
                                returnUrl:(NSString*)returnUrl
                                notifyUrl:(NSString*)notifyUrl
                                signature:(NSString*)signatureArg
                                    txnId:(NSString*)txnId
                           merchantAccess:(NSString *)merchantAccessKey
                           withCustParams:(NSDictionary *)custParams
                                   origin:(NSString *)origin
{
    
    
    
    
    contact = [CTSUtility correctContactIfNeeded:contact];
    address = [CTSUtility correctAdressIfNeeded:address];
    
    

    NSMutableDictionary *newDict = nil;
    
    NSString *dpOfferToken = [custParams objectForKey:ID_FLAGS_IS_DP_TRANSACTION];
    if(dpOfferToken){
        newDict = [[NSMutableDictionary alloc] initWithDictionary:custParams];
        [newDict removeObjectForKey:ID_FLAGS_IS_DP_TRANSACTION];
        if([newDict count] == 0){
            newDict = nil;
        }
        custParams = newDict;
    }
    
    CTSPaymentRequest* paymentRequest = [[CTSPaymentRequest alloc] init];
    paymentRequest.amount = [self ctsAmountForAmount:amount];
    paymentRequest.merchantAccessKey = merchantAccessKey;
    paymentRequest.merchantTxnId = txnId;
    paymentRequest.notifyUrl = notifyUrl;
    paymentRequest.requestSignature = signatureArg;
    paymentRequest.returnUrl = returnUrl;
    paymentRequest.paymentToken =
    [[paymentInfo.paymentOptions objectAtIndex:0] fetchPaymentToken];
    paymentRequest.customParameters = custParams;
    
    
    contact.email = contact.email.lowercaseString;
    paymentRequest.userDetails =
    [[CTSUserDetails alloc] initWith:contact address:address];
    paymentRequest.requestOrigin = origin;
    paymentRequest.offerToken = dpOfferToken;
    return paymentRequest;
}



- (CTSPrepaidPayReq*)configureReqPayment:(CTSBill *)bill
                                  origin:(NSString *)origin
                                 contact:(CTSContactUpdate *)contact
                                 address:(CTSUserAddress *)address
{
    
    
    contact = [CTSUtility correctContactIfNeeded:contact];
    address = [CTSUtility correctAdressIfNeeded:address];
    CTSPrepaidUser *user = [[CTSPrepaidUser alloc] initWithContact:contact address:address];
    
    CTSPrepaidPayReq *paymentRequest = [[CTSPrepaidPayReq alloc] init];
    paymentRequest.merchantTxnId = bill.merchantTxnId;
    paymentRequest.requestSignature = bill.requestSignature;
    paymentRequest.merchantAccessKey = bill.merchantAccessKey;
    paymentRequest.notifyUrl = bill.notifyUrl;
    paymentRequest.amount = bill.amount;
    paymentRequest.userDetails = user;
    paymentRequest.returnUrl = bill.returnUrl;
    paymentRequest.requestOrigin = origin;
    paymentRequest.customParameters = bill.customParameters;

        
    return paymentRequest;
}


- (CTSAmount*)ctsAmountForAmount:(NSString*)amount {
    CTSAmount* ctsAmount = [[CTSAmount alloc] init];
    ctsAmount.value = amount;
    ctsAmount.currency = CURRENCY_INR;
    return ctsAmount;
}


- (void)requestChargeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
                          withContact:(CTSContactUpdate*)contactInfo
                          withAddress:(CTSUserAddress*)userAddress
                                 bill:(CTSBill *)bill
                         customParams:(NSDictionary *)custParams
                withCompletionHandler:(ASMakeTokenizedPaymentCallBack)callback{
    
    [self addCallback:callback forRequestId:PaymentUsingtokenizedCardBankReqId];
    
    
    if(bill.customParameters && custParams == nil){
        custParams = bill.customParameters;
    }
    
    
    CTSPaymentRequest* paymentrequest =
    [self configureReqPayment:paymentInfo
                      contact:contactInfo
                      address:userAddress
                       amount:bill.amount.value
                    returnUrl:bill.returnUrl
                    notifyUrl:bill.notifyUrl
                    signature:bill.requestSignature
                        txnId:bill.merchantTxnId
               merchantAccess:bill.merchantAccessKey
               withCustParams:custParams
                       origin:SOURCE_TYPE_WALLET];
    
    
    CTSErrorCode error = [paymentInfo validateTokenized];
    LogTrace(@" validation error 1 %d ", error);
    
    if (error != NoError) {
        [self makeTokenizedPaymentHelper:nil
                                   error:[CTSError getErrorForCode:error]];
        return;
    }
    if(![CTSUtility validateBill:bill]){
        [self makeTokenizedPaymentHelper:nil
                                   error:[CTSError getErrorForCode:WrongBill]];
        return;
    }
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_CITRUS_SERVER_URL
                                   requestId:PaymentUsingtokenizedCardBankReqId
                                   headers:nil
                                   parameters:nil
                                   json:[paymentrequest toJSONString]
                                   httpMethod:POST];
    [restCore requestAsyncServer:request];
    
    
}

- (void)requestChargePayment:(CTSPaymentDetailUpdate*)paymentInfo
                 withContact:(CTSContactUpdate*)contactInfo
                 withAddress:(CTSUserAddress*)userAddress
                        bill:(CTSBill *)bill
                customParams:(NSDictionary *)custParams
       withCompletionHandler:(ASMakeGuestPaymentCallBack)callback{
    
    [self addCallback:callback forRequestId:PaymentAsGuestReqId];
    
    if([paymentInfo.paymentOptions count] != 1){
        [self makeGuestPaymentHelper:nil
                               error:[CTSError getErrorForCode:NoOrMoreInstruments]];
        return;
        
    }
    
    CTSPaymentOption *paymentOption = [paymentInfo.paymentOptions objectAtIndex:0];
    LogTrace(@"requestChargePayment no return paymentOption.type %@ scheme %@  cvv %@ token %@",paymentOption.type,paymentOption.scheme,paymentOption.cvv,paymentOption.token);
    
    
    CTSErrorCode error = NoError;
    if([paymentInfo isTokenized]){
        error = [paymentInfo validateTokenized];
    }
    else{
        error = [paymentInfo validate];
    }

    
    LogTrace(@"validation error 2 %d ", error);
    
    if (error != NoError) {
        [self makeGuestPaymentHelper:nil
                               error:[CTSError getErrorForCode:error]];
        return;
    }
    if(![CTSUtility validateBill:bill]){
        [self makeGuestPaymentHelper:nil
                               error:[CTSError getErrorForCode:WrongBill]];
        return;
    }
    
    [paymentInfo doCardCorrectionsIfNeeded];

    
    
    NSString *sourceType = SOURCE_TYPE_GUEST;
    if([paymentInfo isTokenized]){
        sourceType = SOURCE_TYPE_WALLET;
    }

    if(bill.customParameters && custParams == nil){
        custParams = bill.customParameters;
    }
    
    CTSPaymentRequest* paymentrequest =
    [self configureReqPayment:paymentInfo
                      contact:contactInfo
                      address:userAddress
                       amount:bill.amount.value
                    returnUrl:bill.returnUrl
                    notifyUrl:bill.notifyUrl
                    signature:bill.requestSignature
                        txnId:bill.merchantTxnId
               merchantAccess:bill.merchantAccessKey
               withCustParams:custParams
                       origin:sourceType];
    
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
                                   requestId:PaymentAsGuestReqId
                                     headers:nil
                                  parameters:nil
                                        json:[paymentrequest toJSONString]
                                  httpMethod:POST];
    [restCore requestAsyncServer:request];
    
    
    
}

//Vikas new Payment API
- (void)requestNewChargePayment:(CTSPaymentDetailUpdate*)paymentInfo
                    withContact:(CTSContactUpdate*)contactInfo
                    withAddress:(CTSUserAddress*)userAddress
                           bill:(CTSBill *)bill
          withCompletionHandler:(ASMakeNewPaymentCallBack)callback{
    
    [self addCallback:callback forRequestId:PaymentNewAsGuestReqId];
    
    if([paymentInfo.paymentOptions count] != 1){
        [self makeGuestPaymentHelper:nil
                               error:[CTSError getErrorForCode:NoOrMoreInstruments]];
        return;
        
    }
    
    CTSErrorCode error = NoError;
    if([paymentInfo isTokenized]){
        error = [paymentInfo validateTokenized];
    }
    else{
        error = [paymentInfo validate];
    }
    

    LogTrace(@"validation error 3 %d ", error);
    
    if (error != NoError) {
        [self makeGuestPaymentHelper:nil
                               error:[CTSError getErrorForCode:error]];
        [UIUtility toastMessageOnScreen:@"Please enter a valid card number"]; 
        return;
    }

    
    if(![CTSUtility validateBill:bill]){
        [self makeGuestPaymentHelper:nil
                               error:[CTSError getErrorForCode:WrongBill]];
        return;
    }
    
    [paymentInfo doCardCorrectionsIfNeeded];
    
    //Vikas
    
    aPaymentInfo = paymentInfo;
    aBill = bill;
    aContactInfo = contactInfo;
    aUserAddress = userAddress;
    
    NSString *sourceType = SOURCE_TYPE_GUEST;
    if([paymentInfo isTokenized]){
        sourceType = SOURCE_TYPE_WALLET;
    }
    NSDictionary *custParams = nil;
    if(bill.customParameters && custParams == nil){
        custParams = bill.customParameters;
        aCustParams = custParams;
       
    }
    
    CTSPaymentRequest* paymentrequest =
    [self configureReqPayment:paymentInfo
                      contact:contactInfo
                      address:userAddress
                       amount:bill.amount.value
                    returnUrl:bill.returnUrl
                    notifyUrl:bill.notifyUrl
                    signature:bill.requestSignature
                        txnId:bill.merchantTxnId
               merchantAccess:bill.merchantAccessKey
               withCustParams:custParams
                       origin:sourceType];
    //Vikas
//    NSString *pathString = [NSString stringWithFormat:@"https://citruspay.com%@",MLC_CITRUS_NEW_SERVER_URL];
    NSString *pathString = [NSString stringWithFormat:@"%@%@",[CTSUtility fetchFromEnvironment:NEW_PAYMENT_BASE_URL],MLC_CITRUS_NEW_SERVER_URL];
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:pathString
                                   requestId:PaymentNewAsGuestReqId
                                     headers:nil
                                  parameters:nil
                                        json:[paymentrequest toJSONString]
                                  httpMethod:POST];
    
    request.isAlternatePath = TRUE;
    [restCore requestAsyncServer:request];
    
    
    
}


- (void)requestChargeCitrusCashWithContact:(CTSContactUpdate*)contactInfo
                               withAddress:(CTSUserAddress*)userAddress
                                      bill:(CTSBill *)bill
                              customParams:(NSDictionary *)custParams
                      returnViewController:(UIViewController *)controller
                     withCompletionHandler:(ASCitruspayCallback)callback{
    
    [self addCallback:callback forRequestId:PaymentAsCitruspayReqId];
    
    
    
    if(controller == nil){
        [self makeCitrusPayHelper:nil error:[CTSError getErrorForCode:NoViewController]];
        return;
        
    }
    if(![CTSUtility isUserCookieValid]){
        [self makeCitrusPayHelper:nil error:[CTSError getErrorForCode:NoCookieFound]];
        return;
        
    }
    
    if(![CTSUtility validateBill:bill]){
        [self makeCitrusPayHelper:nil error:[CTSError getErrorForCode:WrongBill]];
        return;
        
    }

    
    citrusCashBackViewController = controller;
    cCashReturnUrl = bill.returnUrl;
    prepaidRequestType = PaymentAsCitruspayReqId;
    
    
    CTSProfileLayer *profileLayer = [[CTSProfileLayer alloc] initWithKeyStore:keystore];
    [profileLayer requestContactInformationWithCompletionHandler:^(CTSProfileContactRes *contactInfoArg, NSError *error) {
        if(error == nil){
            CTSContactUpdate *contact = [CTSUtility convertFromProfile:contactInfoArg];
            if(contact.mobile == nil || [CTSUtility validateMobile:contact.mobile] == YES){
                contact.mobile = contactInfo.mobile;
            }

            CTSProfileLayer *profileLayer = [CitrusPaymentSDK fetchSharedProfileLayer];
            [profileLayer requestGetBalance:^(CTSAmount *amount, NSError *error) {
                float balance = [amount.value floatValue];
                float txAmount = [bill.amount.value floatValue];
                if((balance *100) >= (txAmount*100)){
                    [self requestChargeInternalCitrusCashWithContact:contact withAddress:userAddress bill:bill customParams:custParams  withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
                        LogTrace(@"paymentInfo %@",paymentInfo);
                        LogTrace(@"error %@",error);
                        [self handlePaymentResponse:paymentInfo error:error] ;
                    }];
                }
                else{
                    [self makeCitrusPayHelper:nil error:[CTSError getErrorForCode:InsufficientBalance]];
                }
            }];
        }
        else{
            [self makeCitrusPayHelper:nil error:error];
        }
    }];
}


//{
//    "amount":{
//        "value":"1",
//        "currency":"INR"
//    },
//    "merchantTxnId":"144281756671350",
//    "merchantAccessKey":"F2VZD1HBS2VVXJPMWO77",
//    "requestSignature":"aac4925b1397b9d31f1a90ed54cb6ce0506b21dc",
//    "returnUrl":"https:\/\/salty-plateau-1529.herokuapp.com\/redirectURL.stg3.php",
//    "userDetails":{
//        "firstName":"Tester",
//        "lastName":"Citrus",
//        "email":"tester@gmail.com",
//        "mobileNo":"9999999999",
//        "street1":"streetone",
//        "street2":"streettwo",
//        "city":"Mumbai",
//        "state":"Maharashtra",
//        "country":"India",
//        "zip":"400052"
//    }
//}


- (void)requestChargeCitrusWalletWithContact:(CTSContactUpdate*)contactInfo
                                 address:(CTSUserAddress*)userAddress
                                        bill:(CTSBill *)bill
                        returnViewController:(UIViewController *)controller
                       withCompletionHandler:(ASCitruspayCallback)callback{
    
    [self addCallback:callback forRequestId:PayPrepaidNewReqId];

    

    
    if(![CTSUtility validateBill:bill]){
        [self prepaidPayHelper:nil error:[CTSError getErrorForCode:WrongBill]];
        return;
    }
    
    if(controller == nil){
        [self prepaidPayHelper:nil error:[CTSError getErrorForCode:NoViewController]];
        return;
        
    }
    
    
    
    
    
    citrusCashBackViewController = controller;
    cCashReturnUrl = bill.returnUrl;
    prepaidRequestType = PayPrepaidNewInternalReqId;

    
    [self requestChargeInternalCitrusWalletWithContact:contactInfo address:userAddress bill:bill returnViewController:controller withCompletionHandler:^(CTSPrepaidPayResp *prepaidPay, NSError *error) {
        if(error){
            [self prepaidPayHelper:nil error:error];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableDictionary *finalReturnurldata = [NSMutableDictionary dictionaryWithDictionary:prepaidPay.responseParams ];
                [finalReturnurldata addEntriesFromDictionary:prepaidPay.customParams];
                [self loadCitrusCashPaymentWebview:bill.returnUrl pgParameters:finalReturnurldata];
            });
        }

    }];
}





//new prepaid pay api
- (void)requestChargeInternalCitrusWalletWithContact:(CTSContactUpdate*)contact
                                  address:(CTSUserAddress *)address
                                     bill:(CTSBill *)bill
                   returnViewController:(UIViewController *)controller
                  withCompletionHandler:(ASPrepaidPayCallback)callback{

    [self addCallback:callback forRequestId:PayPrepaidNewInternalReqId];
    
    OauthStatus* oauthStatus = [CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypePrepaidSignin];
    NSString *signinToken = oauthStatus.oauthToken;
    
    if(signinToken == nil){
        [self prepaidPayInternalHelper:nil error:oauthStatus.error];
        return;
    }
    
    
    CTSPrepaidPayReq *paymentReq = [self configureReqPayment:bill origin:SOURCE_TYPE_WALLET contact:contact address:address];
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PREPAID_PAY_NEW_PATH
                                   requestId:PayPrepaidNewInternalReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:signinToken]
                                   parameters:nil
                                   json:[paymentReq toJSONString]
                                   httpMethod:POST];
    
    
    [restCore requestAsyncServer:request];
}








- (void)requestChargeInternalCitrusCashWithContact:(CTSContactUpdate*)contactInfo
                                       withAddress:(CTSUserAddress*)userAddress
                                              bill:(CTSBill *)bill
                                      customParams:(NSDictionary *)custParams
                             withCompletionHandler:(ASMakeCitruspayCallBackInternal)callback{
    [self addCallback:callback forRequestId:PaymentAsCitruspayInternalReqId];
    //NSString *email = [CTSUtility readFromDisk:CTS_SIGNIN_USER_EMAIL];
    
    CTSPaymentDetailUpdate *paymentCitrus = [[CTSPaymentDetailUpdate alloc] initCitrusPayWithEmail:contactInfo.email];
    
    if(bill.customParameters && custParams == nil){
        custParams = bill.customParameters;
    }
    
    CTSPaymentRequest* paymentrequest =
    [self configureReqPayment:paymentCitrus
                      contact:contactInfo
                      address:userAddress
                       amount:bill.amount.value
                    returnUrl:bill.returnUrl
                    notifyUrl:bill.notifyUrl
                    signature:bill.requestSignature
                        txnId:bill.merchantTxnId
               merchantAccess:bill.merchantAccessKey
               withCustParams:custParams
                       origin:SOURCE_TYPE_WALLET];
    
    
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
                                   requestId:PaymentAsCitruspayInternalReqId
                                     headers:nil
                                  parameters:nil
                                        json:[paymentrequest toJSONString]
                                  httpMethod:POST];
    [restCore requestAsyncServer:request];
    
}


- (void)requestLoadMoneyInCitrusPay:(CTSPaymentDetailUpdate *)paymentInfo
                        withContact:(CTSContactUpdate*)contactInfo
                        withAddress:(CTSUserAddress*)userAddress
                             amount:( NSString *)amount
                          returnUrl:(NSString *)returnUrl
                       customParams:(NSDictionary *)custParams
              withCompletionHandler:(ASLoadMoneyCallBack)callback{
    [self addCallback:callback forRequestId:PaymentLoadMoneyCitrusPayReqId];
    
    __block NSString *amountBlock = amount;
    
    
    if([paymentInfo.paymentOptions count] != 1){
        [self loadMoneyHelper:nil
                        error:[CTSError getErrorForCode:NoOrMoreInstruments]];
        return;
        
    }
    
    CTSErrorCode error = NoError;
    if([paymentInfo isTokenized]){
        error = [paymentInfo validateTokenized];
    }
    else{
        error = [paymentInfo validate];
    }
    
    [paymentInfo doCardCorrectionsIfNeeded];
    
    // LogTrace(@"validation error %d ", error);
    
    if (error != NoError) {
        [self loadMoneyHelper:nil
                        error:[CTSError getErrorForCode:error]];
        return;
    }
    CTSProfileLayer *profileLayer = [[CTSProfileLayer alloc] initWithKeyStore:keystore];
    [profileLayer requestContactInformationWithCompletionHandler:^(CTSProfileContactRes *contactInfoArg, NSError *error) {
        if(error == nil){
        CTSContactUpdate *contactFetched = [CTSUtility convertFromProfile:contactInfoArg];
            
            if(contactFetched.mobile == nil || [CTSUtility validateMobile:contactFetched.mobile] == YES){
                contactFetched.mobile = contactInfo.mobile;
            }
            
        [self requestGetPrepaidBillForAmount:amount returnUrl:returnUrl withCompletionHandler:^(CTSPrepaidBill *prepaidBill, NSError *error) {
            
            if(error == nil){
                NSString *source= SOURCE_TYPE_GUEST;
                if([paymentInfo isTokenized]){
                    source = SOURCE_TYPE_WALLET;
                }
                
                
                
                CTSPaymentRequest* paymentrequest =
                [self configureReqPayment:paymentInfo
                                  contact:contactFetched
                                  address:userAddress
                                   amount:amountBlock
                                returnUrl:prepaidBill.returnUrl
                                notifyUrl:prepaidBill.notifyUrl
                                signature:prepaidBill.signature
                                    txnId:prepaidBill.merchantTransactionId
                           merchantAccess:prepaidBill.merchantAccessKey
                           withCustParams:custParams
                                   origin:source];
                
                paymentrequest.notifyUrl = prepaidBill.notifyUrl;
                
                CTSRestCoreRequest* request =
                [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
                                               requestId:PaymentLoadMoneyCitrusPayReqId
                                                 headers:nil
                                              parameters:nil
                                                    json:[paymentrequest toJSONString]
                                              httpMethod:POST];
                [restCore requestAsyncServer:request];
            }
            else {
                [self loadMoneyHelper:nil error:error];
            }
        }];
        }
        else{
            [self loadMoneyHelper:nil error:error];
        }

    }];
}





- (void)requestMerchantPgSettings:(NSString*)vanityUrl
            withCompletionHandler:(ASGetMerchantPgSettingsCallBack)callback {
    [self addCallback:callback forRequestId:PaymentPgSettingsReqId];
    
    if (vanityUrl == nil) {
        [self getMerchantPgSettingsHelper:nil
                                    error:[CTSError
                                           getErrorForCode:InvalidParameter]];
    }
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PAYMENT_GET_PGSETTINGS_PATH
                                   requestId:PaymentPgSettingsReqId
                                   headers:nil
                                   parameters:@{
                                                MLC_PAYMENT_GET_PGSETTINGS_QUERY_VANITY : vanityUrl
                                                } json:nil
                                   httpMethod:POST];
    [restCore requestAsyncServer:request];
}



- (void)requestLoadMoneyPgSettingsCompletionHandler:(ASGetMerchantPgSettingsCallBack)callback{
    
    [self requestMerchantPgSettings:@"prepaid" withCompletionHandler:^(CTSPgSettings *pgSettings, NSError *error) {
        callback(pgSettings,error);
    }];
    
}


-(void)requestGetPrepaidBillForAmount:(NSString *)amount returnUrl:(NSString *)returnUrl withCompletionHandler:(ASGetPrepaidBill)callback{
    
    [self addCallback:callback forRequestId:PaymentGetPrepaidBillReqId];
    
    
    OauthStatus* oauthStatus = [CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypeAnyPasswordSignin];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self getPrepaidBillHelper:nil error:oauthStatus.error];
        return;
    }
    
    if(returnUrl == nil){
        [self getPrepaidBillHelper:nil error:[CTSError
                                              getErrorForCode:ReturnUrlNotValid]];
        return;
    }
    
    if([CTSUtility validateAmountString:amount]== NO){
        [self getPrepaidBillHelper:nil error:[CTSError
                                              getErrorForCode:AmountNotValid]];
        return;
        
    }
    
    
    
    NSDictionary *params = @{MLC_PAYMENT_GET_PREPAID_BILL_QUERY_AMOUNT:amount,
                             MLC_PAYMENT_GET_PREPAID_BILL_QUERY_CURRENCY:MLC_PAYMENT_GET_PREPAID_BILL_QUERY_CURRENCY_INR,
                             MLC_PAYMENT_GET_PREPAID_BILL_QUERY_REDIRECT:returnUrl};
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PAYMENT_GET_PREPAID_BILL_PATH
                                   requestId:PaymentGetPrepaidBillReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:params
                                   json:nil
                                   httpMethod:POST];
    [restCore requestAsyncServer:request];
    
    
}


#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)requestChargeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
                          withContact:(CTSContactUpdate*)contactInfo
                          withAddress:(CTSUserAddress*)userAddress
                                 bill:(CTSBill *)bill
                         customParams:(NSDictionary *)custParams
                 returnViewController:(UIViewController *)controller
                withCompletionHandler:(ASCitruspayCallback)callback{
    
    
    [self addCallback:callback forRequestId:PaymentChargeInnerWeblTokenReqId];
    
    
    if(controller == nil || ![controller isKindOfClass:[UIViewController class]]){
        [self chargeTokenInnerWebviewHelper:nil error:[CTSError getErrorForCode:NoViewController]];
        return;
    }
    
    [paymentInfo doCardCorrectionsIfNeeded];
    CTSPaymentOption *paymentOption = [paymentInfo.paymentOptions objectAtIndex:0];
    if(![paymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_NETBANKING_TYPE]){
        
        if ([paymentOption.scheme isEqualToString:@"AMEX"]) {
            if (paymentOption.cvv.length!=4){
                
                [self chargeTokenInnerWebviewHelper:nil error:[CTSError getErrorForCode:CvvNotValid]];
                return;
            }
        }
        else{
            if (paymentOption.cvv.length!=3){
                [self chargeTokenInnerWebviewHelper:nil error:[CTSError getErrorForCode:CvvNotValid]];
                return;
            }
            
        }
    }
    
    //    if(citrusCashBackViewController){
    //        [self chargeTokenInnerWebviewHelper:nil error:[CTSError getErrorForCode:TransactionAlreadyInProgress]];
    //        return;
    //    }
    
    citrusCashBackViewController = controller;
    
    
    [self requestChargeTokenizedPayment:paymentInfo withContact:contactInfo withAddress:userAddress bill:bill customParams:custParams withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        if(!error){
            
            BOOL hasSuccess =
            ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
             (error == nil))
            ? YES
            : NO;
            if(hasSuccess){
                // Your code to handle success.
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (hasSuccess && error.code != ServerErrorWithCode) {
                        [self loadPaymentWebview:paymentInfo.redirectUrl reqId:PaymentChargeInnerWeblTokenReqId returnUrl:bill.returnUrl];
                    }else{
                        [self chargeTokenInnerWebviewHelper:nil error:[CTSError convertToError:paymentInfo]];
                    }
                });
            }
        }
        else {
            [self chargeTokenInnerWebviewHelper:nil error:error];
        }
        
    }];
    
    
}
#pragma GCC diagnostic pop



#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)requestChargePayment:(CTSPaymentDetailUpdate*)paymentInfo
                 withContact:(CTSContactUpdate*)contactInfo
                 withAddress:(CTSUserAddress*)userAddress
                        bill:(CTSBill *)bill
                customParams:(NSDictionary *)custParams
        returnViewController:(UIViewController *)controller
       withCompletionHandler:(ASCitruspayCallback)callback{
    [self addCallback:callback forRequestId:PaymentChargeInnerWebNormalReqId];
    //add callback
    //do validation
    if(controller == nil || ![controller isKindOfClass:[UIViewController class]]){
        [self chargeNormalInnerWebviewHelper:nil error:[CTSError getErrorForCode:NoViewController]];
        return;
    }
    
    CTSPaymentOption *paymentOption = [paymentInfo.paymentOptions objectAtIndex:0];
    
    
    LogTrace(@"requestChargePayment return paymentOption.type %@ scheme %@  cvv %@ token %@",paymentOption.type,paymentOption.scheme,paymentOption.cvv,paymentOption.token);
    [paymentInfo doCardCorrectionsIfNeeded];
    if(![paymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_NETBANKING_TYPE]){
        
        if ([paymentOption.scheme isEqualToString:@"AMEX"]) {
            if (paymentOption.cvv.length!=4){
                
                [self chargeNormalInnerWebviewHelper:nil error:[CTSError getErrorForCode:CvvNotValid]];
                return;
            }
        }
        else{
            if (paymentOption.cvv.length!=3){
                [self chargeNormalInnerWebviewHelper:nil error:[CTSError getErrorForCode:CvvNotValid]];
                return;
            }
            
        }
    }
    //    if(citrusCashBackViewController){
    //        [self chargeNormalInnerWebviewHelper:nil error:[CTSError getErrorForCode:TransactionAlreadyInProgress]];
    //        return;
    //    }
    //TODO add payment option wise validations
    
    citrusCashBackViewController = controller;
    

    [self requestChargePayment:paymentInfo withContact:contactInfo withAddress:userAddress bill:bill customParams:custParams withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        if(!error){
            
            BOOL hasSuccess =
            ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
             (error == nil))? YES: NO;
            // Your code to handle success.
            dispatch_async(dispatch_get_main_queue(), ^{
                if (hasSuccess && error.code != ServerErrorWithCode) {
                    [self loadPaymentWebview:paymentInfo.redirectUrl reqId:PaymentChargeInnerWebNormalReqId returnUrl:bill.returnUrl];
                }
                else{
                    [self chargeNormalInnerWebviewHelper:nil error:[CTSError convertToError:paymentInfo]];
                }
            });
        }
        else {
            [self chargeNormalInnerWebviewHelper:nil error:error];
        }
    }];
    
}


//Vikas New payment method
- (void)requestDirectChargePayment:(CTSPaymentDetailUpdate*)paymentInfo
                    withContact:(CTSContactUpdate*)contactInfo
                    withAddress:(CTSUserAddress*)userAddress
                           bill:(CTSBill *)bill
           returnViewController:(UIViewController *)controller
          withCompletionHandler:(ASCitruspayCallback)callback {
    
    
    [self addCallback:callback forRequestId:PaymentChargeInnerWebNormalReqId];
    //add callback
    //do validation
    if(controller == nil || ![controller isKindOfClass:[UIViewController class]]){
        [self chargeNormalInnerWebviewHelper:nil error:[CTSError getErrorForCode:NoViewController]];
        return;
    }
    [paymentInfo doCardCorrectionsIfNeeded];
    CTSPaymentOption *paymentOption = [paymentInfo.paymentOptions objectAtIndex:0];
    if(![paymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_NETBANKING_TYPE]){
        
        if ([paymentOption.scheme isEqualToString:@"AMEX"]) {
            if (paymentOption.cvv.length!=4){
                
                [self chargeNormalInnerWebviewHelper:nil error:[CTSError getErrorForCode:CvvNotValid]];
                return;
            }
        }
        else{
            if (paymentOption.cvv.length!=3){
                [self chargeNormalInnerWebviewHelper:nil error:[CTSError getErrorForCode:CvvNotValid]];
                return;
            }
            
        }
    }
    
    citrusCashBackViewController = controller;
    if ([paymentOption.code isEqualToString:@"CID002"] || [paymentOption.code isEqualToString:@"CID019"] || [paymentOption.code isEqualToString:@"CID041"] || [paymentOption.code isEqualToString:@"CID016"] || [paymentOption.code isEqualToString:@"CID031"] || [paymentOption.code isEqualToString:@"CID070"]) {
        
        [self requestChargePayment:paymentInfo withContact:contactInfo withAddress:userAddress bill:bill customParams:nil withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
            if(!error){
                
                BOOL hasSuccess =
                ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
                 (error == nil))? YES: NO;
                // Your code to handle success.
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (hasSuccess && error.code != ServerErrorWithCode) {
                        [self loadPaymentWebview:paymentInfo.redirectUrl reqId:PaymentChargeInnerWebNormalReqId returnUrl:bill.returnUrl];
                    }
                    else{
                        [self chargeNormalInnerWebviewHelper:nil error:[CTSError convertToError:paymentInfo]];
                    }
                });
            }
            else {
                [self chargeNormalInnerWebviewHelper:nil error:error];
            }
        }];
    }
    else{
        
        [self requestNewChargePayment:paymentInfo withContact:contactInfo withAddress:userAddress bill:bill withCompletionHandler:^(NSString *responseString , NSError *error) {
            if(responseString){
                NSString *html =[CTSUtility getHTMLWithString:responseString];
                NSString *htmlString = [NSString stringWithFormat:@"<html>%@</html>",html];
                
                self.htmlParser = [[CTSHtmlParser alloc]
                                   loadHtmlByURL:htmlString];
                BOOL isErrorInResponse = FALSE;
                NSMutableString *errorString;
                for (CTSHtmlElement *currentElement in self.htmlParser.elementArray) {
                    if ([currentElement.value isEqualToString:@"Access is denied"]) {
                        isErrorInResponse = TRUE;
                    }
                    errorString = (NSMutableString*)currentElement.value;
                    NSLog(@"Value = %@",currentElement.value);
                }
                 
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                 if (!isErrorInResponse) {
                 [self loadNewPaymentWebview:htmlString reqId:PaymentChargeInnerWebNormalReqId returnUrl:bill.returnUrl];
                 }
                 else{
                 //
                 NSDictionary* userInfo = @{NSLocalizedDescriptionKey : errorString};
                 NSError *error = [NSError errorWithDomain:CITRUS_ERROR_DOMAIN code:-1 userInfo:userInfo];
                 [self chargeNormalInnerWebviewHelper:nil error:error];
                 }
                 });
            }
            else {
                [self chargeNormalInnerWebviewHelper:nil error:error];
            }
        }];
    }

    
}

#pragma GCC diagnostic pop

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)requestLoadMoneyInCitrusPay:(CTSPaymentDetailUpdate *)paymentInfo
                        withContact:(CTSContactUpdate*)contactInfo
                        withAddress:(CTSUserAddress*)userAddress
                             amount:( NSString *)amount
                          returnUrl:(NSString *)returnUrl
                       customParams:(NSDictionary *)custParams
               returnViewController:(UIViewController *)controller
              withCompletionHandler:(ASCitruspayCallback)callback{
    
    [self addCallback:callback forRequestId:PaymentChargeInnerWebLoadMoneyReqId];
    //add callback
    //do validation
    
    
    if(controller == nil || ![controller isKindOfClass:[UIViewController class]]){
        [self chargeLoadMoneyInnerWebviewHelper:nil error:[CTSError getErrorForCode:NoViewController]];
        return;
    }
    
    CTSPaymentOption *paymentOption = [paymentInfo.paymentOptions objectAtIndex:0];
    [paymentInfo doCardCorrectionsIfNeeded];
    if(![paymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_NETBANKING_TYPE]){
        if ([paymentOption.scheme isEqualToString:@"AMEX"]) {
            if (paymentOption.cvv.length!=4){
                
                [self chargeLoadMoneyInnerWebviewHelper:nil error:[CTSError getErrorForCode:CvvNotValid]];
                return;
            }
        }
        else{
            if (paymentOption.cvv.length!=3){
                [self chargeLoadMoneyInnerWebviewHelper:nil error:[CTSError getErrorForCode:CvvNotValid]];
                return;
            }
            
        }
    }
    
    
    citrusCashBackViewController = controller;
    
    
    
    
    [self requestLoadMoneyInCitrusPay:paymentInfo withContact:contactInfo withAddress:userAddress amount:amount returnUrl:returnUrl  customParams:custParams withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
        if(!error){
            
            BOOL hasSuccess =
            ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
             (error == nil))
            ? YES: NO;
            if(hasSuccess){
                // Your code to handle success.
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (hasSuccess && error.code != ServerErrorWithCode) {
                        
                        [self loadPaymentWebview:paymentInfo.redirectUrl reqId:PaymentChargeInnerWebLoadMoneyReqId returnUrl:returnUrl];
                    }else{
                        [self chargeLoadMoneyInnerWebviewHelper:nil error:[CTSError convertToError:paymentInfo]];
                    }
                });
            }
        }
        else {
            [self chargeLoadMoneyInnerWebviewHelper:nil error:error];
        }
    }];
    
}






- (void)requestChargeDynamicPricingContact:(CTSContactUpdate*)contactInfo
                               withAddress:(CTSUserAddress*)userAddress
                              customParams:(NSDictionary *)custParams
                      returnViewController:(UIViewController *)controller
                     withCompletionHandler:(ASCitruspayCallback)callback{
    
    
    [self addCallback:callback forRequestId:PayUsingDynamicPricingReqId];
    
    
    
    
    
    CTSDyPResponse *dyResponse = [self fetchCachedDataForKey:CACHE_KEY_DP_RESPONSE];
    CTSBill *bill = [self fetchCachedDataForKey:CACHE_KEY_DP_BILL];
    CTSPaymentDetailUpdate *paymentInfo = [self fetchCachedDataForKey:CACHE_KEY_DP_PAYMENT_INFO];
    CTSUser *userInfo = [self fetchCachedDataForKey:CACHE_KEY_DP_USER_INFO];
    
    if(dyResponse == nil){
        [self dpPayHelper:nil error:[CTSError getErrorForCode:DPResponseNotFound]];
        return;
    }
    
    
    //from payment into determine the type of request form the rest request accordingly
    //get the response and return it back to the async call
    CTSContactUpdate *contactUpdate = [[CTSContactUpdate alloc] init];
    contactUpdate.email = userInfo.email;
    contactUpdate.mobile = userInfo.mobile;
    contactUpdate.firstName = contactInfo.firstName;
    contactUpdate.lastName = contactInfo.lastName;
    
    NSMutableDictionary *custParamsMutable = [[NSMutableDictionary alloc] init];
    
    if(custParams != nil){
        [custParamsMutable addEntriesFromDictionary:custParams];
    }
    
    [custParamsMutable setObject:dyResponse.offerToken forKey:ID_FLAGS_IS_DP_TRANSACTION];
    
    CTSPaymentOption *paymentOption = [paymentInfo.paymentOptions objectAtIndex:0];
    CTSPaymentType paymentType = [paymentOption fetchPaymentType];
    
    if(paymentType != CitrusPay && paymentType != UndefinedPayment){
        [self requestChargePayment:paymentInfo withContact:contactUpdate withAddress:userAddress bill:bill customParams:custParamsMutable returnViewController:controller withCompletionHandler:^(CTSCitrusCashRes *citrusCashResponse, NSError *error) {
            [self dpPayHelper:citrusCashResponse error:error];
        }];
    }
    else if(paymentType == CitrusPay){
        [self requestChargeCitrusCashWithContact:contactUpdate withAddress:userAddress bill:bill customParams:custParamsMutable returnViewController:controller withCompletionHandler:^(CTSCitrusCashRes *citrusCashResponse, NSError *error) {
            [self dpPayHelper:citrusCashResponse error:error];
            
        }];
    }
    else if(paymentType == UndefinedPayment){
        [self dpPayHelper:nil error:[CTSError getErrorForCode:CitrusPaymentTypeInvalid]];
        
    }
    
}
#pragma GCC diagnostic pop

-(void)requestCashoutToBank:(CTSCashoutBankAccount *)bankAccount amount:(NSString *)amount completionHandler:(ASCashoutToBankCallBack)callback{
    
    [self addCallback:callback forRequestId:PaymentCashoutToBankReqId];
    
    
    OauthStatus* oauthStatus = [CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypeAnyPasswordSignin];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self cashoutToBankHelper:nil error:oauthStatus.error];
        return;
    }
    
    if(bankAccount == nil){
        [self cashoutToBankHelper:nil error:[CTSError
                                             getErrorForCode:BankAccountNotValid]];
        
    }
    
    if([CTSUtility validateAmountString:amount]== NO){
        [self getPrepaidBillHelper:nil error:[CTSError
                                              getErrorForCode:AmountNotValid]];
        
    }
    
    NSDictionary *params = @{MLC_CASHOUT_QUERY_AMOUNT:amount,
                             MLC_CASHOUT_QUERY_CURRENCY:MLC_CASHOUT_QUERY_CURRENCY_INR,
                             MLC_CASHOUT_QUERY_ACCOUNT:bankAccount.number,
                             MLC_CASHOUT_QUERY_IFSC:bankAccount.branch,
                             MLC_CASHOUT_QUERY_OWNER:bankAccount.owner
                             };
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_CASHOUT_PATH
                                   requestId:PaymentCashoutToBankReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:params
                                   json:nil
                                   httpMethod:POST];
    [restCore requestAsyncServer:request];
    
}


-(void)requestGetPGHealthWithCompletionHandler:(ASGetPGHealth)callback{
    [self addCallback:callback forRequestId:PGHealthReqId];
    
    
    
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_PGHEALTH_PATH
                                   requestId:PGHealthReqId
                                   headers:nil
                                   parameters:@{MLC_PGHEALTH_QUERY_BANKCODE:MLC_PGHEALTH_QUERY_ALLBANKS}
                                   json:nil
                                   httpMethod:POST];
    
    
    [restCore requestAsyncServer:request];
}


-(void)requestCardDetails:(NSString *)firstSix completionHandler:(ASCardBinServiceCallback)callback{

    
    [self addCallback:callback forRequestId:PaymentCardBinServiceReqId];
    
    
    if(firstSix.length < 6 || [CTSUtility isNonNumeric:firstSix]){
        [self cardBinServiceHelper:nil error:[CTSError getErrorForCode:BinCardLengthNotValid]];
        return;
    }
    else{
        firstSix = [firstSix substringToIndex:6];
    }
    
    NSString *pathString = [NSString stringWithFormat:@"%@%@",MLC_CARD_BIN_SERVICE_PATH,firstSix];
    
    
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:pathString
                                   requestId:PaymentCardBinServiceReqId
                                   headers:nil
                                   parameters:nil
                                   json:nil
                                   httpMethod:GET];
    request.isAlternatePath = YES;
    [restCore requestAsyncServer:request];

}




-(void)requestPerformDynamicPricingRule:(CTSRuleInfo *)ruleInfo paymentInfo:(CTSPaymentDetailUpdate *)payment bill:(CTSBill *)bill user:(CTSUser *)user type:(DPRequestType)requestType extraParams:(NSDictionary *)extraParams completionHandler:(ASPerformDynamicPricingCallback)callback{
    

    [self addCallback:callback forRequestId:PaymentDynamicPricingReqId];
    
    [self removedDpCachedData];
    
    
    //validations
    //search and apply needs
    //original amount
    
    //calculate
    //original,rule name
    
    //validate
    //rule name, original, altered
    
    //payment info validation
    //issuer code
    //saved card only token
    
    if(requestType > DPRequestTypeSearchAndApply || requestType < DPRequestTypeValidate){
        [self dyPricingHelper:nil error:[CTSError getErrorForCode:DPRequestTypeInvalid]];
        return;
    }
    
    if([CTSUtility validateBill:bill] == NO){
        [self dyPricingHelper:nil error:[CTSError getErrorForCode:WrongBill]];
        return;
    }
    
    if([CTSUtility islengthInvalid:bill.dpSignature]){
        [self dyPricingHelper:nil error:[CTSError getErrorForCode:WrongBill]];
        return;
    }
    
    if(requestType == DPRequestTypeCalculate || requestType == DPRequestTypeValidate){
        if([CTSUtility islengthInvalid:ruleInfo.ruleName] == YES){
            [self dyPricingHelper:nil error:[CTSError getErrorForCode:DPRuleNameNotValid]];
            return;
        }
    }
    
    if(requestType == DPRequestTypeValidate){
        if( [CTSUtility validateAmountString:ruleInfo.alteredAmount] == NO){
            [self dyPricingHelper:nil error:[CTSError getErrorForCode:DPAlteredAmountNotValid]];
            return;
        }
    }

    CTSErrorCode error = [payment validate];
    if( error!= NoError){
        [self dyPricingHelper:nil error:[CTSError getErrorForCode:error]];
        return;
    }

    CTSDyPValidateRuleReq *ruleRequest = [[CTSDyPValidateRuleReq alloc] init];
    
    CTSPaymentOption *paymentOption = [payment.paymentOptions objectAtIndex:0];
    ruleRequest.paymentInfo = [CTSPaymentLayer toDpPayment:paymentOption];
    
    if(ruleRequest.paymentInfo == nil){
        [self dyPricingHelper:nil error:[CTSError getErrorForCode:PaymentInfoInValid]];
        return;
    }

    ruleRequest.ruleName = ruleInfo.ruleName;//validate, calculate
    ruleRequest.email = user.email;//optional if exists
    ruleRequest.phone = user.mobile;//optional if exists
    ruleRequest.merchantAccessKey = bill.merchantAccessKey;
    ruleRequest.signature = bill.dpSignature;
    ruleRequest.merchantTransactionId = bill.merchantTxnId;
    
    ruleRequest.originalAmount = [[CTSAmount alloc] initWithValue:bill.amount.value];
    ruleRequest.alteredAmount = [[CTSAmount alloc] initWithValue:ruleInfo.alteredAmount];
    
    [self cacheData:bill key:CACHE_KEY_DP_BILL];
    [self cacheData:payment key:CACHE_KEY_DP_PAYMENT_INFO];
    [self cacheData:user key:CACHE_KEY_DP_USER_INFO];
    

    ruleRequest.extraParams = [self fetchExtraParam:requestType extra:extraParams];
    
    
    NSString *url = [NSString stringWithFormat:@"%@%@",[CTSUtility fetchFromEnvironment:DP_BASE_URL],MLC_DYNAMIC_PRICING_PATH];
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:url
                                   requestId:PaymentDynamicPricingReqId
                                   headers:nil
                                   parameters:nil
                                   json:[ruleRequest toJSONString]
                                   httpMethod:POST];
    
    request.isAlternatePath = YES;
    [restCore requestAsyncServer:request];

}


-(void)requestPerformDynamicPricingRule:(CTSRuleInfo *)ruleInfo paymentInfo:(CTSPaymentDetailUpdate *)payment billUrl:(NSString *)billUrl user:(CTSUser *)user  extraParams:(NSDictionary *)extraParams completionHandler:(ASPerformDynamicPricingCallback)callback{
    
    [self addCallback:callback forRequestId:PaymentDynamicPricingReqId];
    
    [self removedDpCachedData];
    
    
    //validations
    //search and apply needs
    //original amount
    
    //calculate
    //original,rule name
    
    //validate
    //rule name, original, altered
    
    //payment info validation
    //issuer code
    //saved card only token
    
    //add bill url validation
    //add ruleinfo validation
    
    
    
    
    if(ruleInfo.operationType > DPRequestTypeSearchAndApply || ruleInfo.operationType < DPRequestTypeValidate){
        [self dyPricingHelper:nil error:[CTSError getErrorForCode:DPRequestTypeInvalid]];
        return;
    }
    
    if(ruleInfo.operationType == DPRequestTypeValidate){
        if( [CTSUtility validateAmountString:ruleInfo.alteredAmount] == NO){
            [self dyPricingHelper:nil error:[CTSError getErrorForCode:DPAlteredAmountNotValid]];
            return;
        }
    }
    
    if([CTSUtility validateAmountString:ruleInfo.originalAmount] == NO){
        [self dyPricingHelper:nil error:[CTSError getErrorForCode:DPOriginalAmountNotValid]];
        return;
    }
    
    CTSErrorCode error = [payment validate];
    if( error!= NoError){
        [self dyPricingHelper:nil error:[CTSError getErrorForCode:error]];
        return;
    }
    
    if([NSURL URLWithString:billUrl] == nil){
        [self dyPricingHelper:nil error:[CTSError getErrorForCode:BillUrlNotInvalid]];
        return;
        
    }
    
    [ruleInfo amountCorrections];
    
    
    
    [CTSUtility requestDPBillForRule:ruleInfo billURL:billUrl callback:^(CTSBill *bill, NSError *error) {
        if(error){
            [self dyPricingHelper:nil error:error];
        }
        else {
            
            if([CTSUtility validateBill:bill] == NO){
                [self dyPricingHelper:nil error:[CTSError getErrorForCode:WrongBill]];
                return;
            }
            
            if([CTSUtility islengthInvalid:bill.dpSignature]){
                [self dyPricingHelper:nil error:[CTSError getErrorForCode:WrongBill]];
                return;
            }
            
            if(ruleInfo.operationType == DPRequestTypeCalculate || ruleInfo.operationType == DPRequestTypeValidate){
                if([CTSUtility islengthInvalid:ruleInfo.ruleName] == YES){
                    [self dyPricingHelper:nil error:[CTSError getErrorForCode:DPRuleNameNotValid]];
                    return;
                }
            }
            
            CTSDyPValidateRuleReq *ruleRequest = [[CTSDyPValidateRuleReq alloc] init];
            
            CTSPaymentOption *paymentOption = [payment.paymentOptions objectAtIndex:0];
            ruleRequest.paymentInfo = [CTSPaymentLayer toDpPayment:paymentOption];
            
            if(ruleRequest.paymentInfo == nil){
                [self dyPricingHelper:nil error:[CTSError getErrorForCode:PaymentInfoInValid]];
                return;
            }
            
            ruleRequest.ruleName = ruleInfo.ruleName;//validate, calculate
            ruleRequest.email = user.email;//optional if exists
            ruleRequest.phone = user.mobile;//optional if exists
            ruleRequest.merchantAccessKey = bill.merchantAccessKey;
            ruleRequest.signature = bill.dpSignature;
            ruleRequest.merchantTransactionId = bill.merchantTxnId;
            
            ruleRequest.originalAmount = [[CTSAmount alloc] initWithValue:bill.amount.value];
            ruleRequest.alteredAmount = [[CTSAmount alloc] initWithValue:ruleInfo.alteredAmount];
            
            [self cacheData:bill key:CACHE_KEY_DP_BILL];
            [self cacheData:payment key:CACHE_KEY_DP_PAYMENT_INFO];
            [self cacheData:user key:CACHE_KEY_DP_USER_INFO];
            
            
            ruleRequest.extraParams = [self fetchExtraParam:ruleInfo.operationType extra:extraParams];
            
            
            NSString *url = [NSString stringWithFormat:@"%@",[CTSUtility fetchFromEnvironment:DP_BASE_URL]];
            
            CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                           initWithPath:url
                                           requestId:PaymentDynamicPricingReqId
                                           headers:nil
                                           parameters:nil
                                           json:[ruleRequest toJSONString]
                                           httpMethod:POST];
            
            request.isAlternatePath = YES;
            [restCore requestAsyncServer:request];
        }
    }];
    
}



-(void)requestDPRuleCheck:(CTSDyPValidateRuleReq *)validateRule type:(DPRequestType)requestType  completionHandler:(ASPerformDynamicPricingCallback)callback{
    [self addCallback:callback forRequestId:PaymentDPValidateRuleReqId];
    
    //validation
    
    //validation according to type
    
    
    
    
    NSString *path;
    if(requestType == DPRequestTypeValidate){
        path = MLC_DP_VALIDATE_RULE_PATH;
        
    }
    else if (requestType == DPRequestTypeCalculate){
        path = MLC_DP_CALCULATE_RULE_PATH;
    }
    else{
        
        //return invalid request type error
        
    }
    
    
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_DP_VALIDATE_RULE_PATH
                                   requestId:PaymentDPValidateRuleReqId
                                   headers:nil
                                   parameters:nil
                                   json:[validateRule toJSONString]
                                   httpMethod:POST];
    [restCore requestAsyncServer:request];
    
}


-(void)requestDPQueryMerchant:(NSString *)merchantAccessKey signature:(NSString *)signatureArg completionHandler:(ASPerformDynamicPricingCallback)callback{

    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_DP_MERCHANT_QUERY_PATH
                                   requestId:PaymentDPQueryMerchantReqId
                                   headers:nil
                                   parameters:nil
                                   json:[CTSUtility toJson:@{MLC_DP_MERCHANT_QUERY_MERCHANTACCKEY:merchantAccessKey,MLC_DP_MERCHANT_QUERY_SIGNATURE:signatureArg}]
                                   httpMethod:POST];
    [restCore requestAsyncServer:request];
    
}


-(void)requestTransferMoneyTo:(NSString *)username amount:(NSString *)amount message:(NSString *)message completionHandler:(ASMoneyTransferCallback)callback{
    [self addCallback:callback forRequestId:PaymentRequestTransferMoney];
    
    
    
    //    NSError *userNameValidationError = [CTSUtility verifiyEmailOrMobile:username];
    //
    //    if(userNameValidationError){
    //        [self  transferMoneyHelper:nil error:userNameValidationError];
    //        return;
    //    }
    
    
    
    username = [CTSUtility mobileNumberToTenDigitIfValid:username];
    if (!username) {
        [self  transferMoneyHelper:nil error:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }
    
    if(message.length > 255){
        [self  transferMoneyHelper:nil error:[CTSError getErrorForCode:MessageNotValid]];
        return;
        
    }
    
    if([CTSUtility validateAmountString:amount]== NO){
        [self  transferMoneyHelper:nil error:[CTSError getErrorForCode:AmountNotValid]];
        return;
        
    }
    
    OauthStatus* oauthStatus = [CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypeAnyPasswordSignin];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self  transferMoneyHelper:nil error:oauthStatus.error];
        return;
    }
    
    
    
    if (message == nil) {
        message = @"";
    }
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_TRANSFER_MONEY_PATH
                                   requestId:PaymentRequestTransferMoney
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:@{
                                                MLC_TRANSFER_MONEY_QUERY_TO:username,
                                                MLC_TRANSFER_MONEY_QUERY_AMOUNT:amount,
                                                MLC_TRANSFER_MONEY_QUERY_CURRENCY:CURRENCY_INR,
                                                MLC_TRANSFER_MONEY_QUERY_MESSAGE:message}
                                   json:nil
                                   httpMethod:POST];
    [restCore requestAsyncServer:request];
    
    
    
}

#pragma mark - authentication protocol mehods
- (void)signUp:(BOOL)isSuccessful
   accessToken:(NSString*)token
         error:(NSError*)error {
    if (isSuccessful) {
    }
}


- (instancetype)init {
    finished = YES;
    NSDictionary* dict = [self getRegistrationDict];
    
    NSString *baseUrl = [self fetchBaseUrl];
    
    self =
    [super initWithRequestSelectorMapping:dict baseUrl:baseUrl];
    
    
    CTSKeyStore *keyStore = [CTSUtility fetchCachedKeyStore];
    if(keyStore){
        [self setKeyStore:keyStore];
    }
    return self;
}


+(CTSPaymentLayer*)fetchSharedPaymentLayer {
    static CTSPaymentLayer *sharedPaymentLayer = nil;
    @synchronized(self) {
        if (sharedPaymentLayer == nil)
            sharedPaymentLayer = [CTSPaymentLayer new];
    }
    return sharedPaymentLayer;
}


- (instancetype)initWithKeyStore:(CTSKeyStore *)keystoreArg{
    CTSPaymentLayer *payment = [CTSPaymentLayer new];
    [payment setKeyStore:keystoreArg];
    return payment;
}

-(NSDictionary *)getRegistrationDict{
    return @{
             toNSString(PaymentAsGuestReqId) : toSelector(handleReqPaymentAsGuest:),
             toNSString(PaymentNewAsGuestReqId) : toSelector(handleReqNewPaymentAsGuest:),
             toNSString(PaymentUsingtokenizedCardBankReqId) : toSelector(handleReqPaymentUsingtokenizedCardBank:),
             toNSString(PaymentUsingSignedInCardBankReqId) : toSelector(handlePaymentUsingSignedInCardBank:),
             toNSString(PaymentPgSettingsReqId) : toSelector(handleReqPaymentPgSettings:),
             toNSString(PaymentAsCitruspayInternalReqId) : toSelector(handlePayementUsingCitruspayInternal:),
             toNSString(PaymentAsCitruspayReqId) : toSelector(handlePayementUsingCitruspay:),
             toNSString(PaymentGetPrepaidBillReqId) : toSelector(handleGetPrepaidBill:),
             toNSString(PaymentLoadMoneyCitrusPayReqId) : toSelector(handleLoadMoneyCitrusPay:),
             toNSString(PaymentCashoutToBankReqId) : toSelector(handleCashoutToBank:),
             toNSString(PaymentChargeInnerWebNormalReqId) : toSelector(handleChargeNormalInnerWebview:),
             toNSString(PaymentChargeInnerWeblTokenReqId) : toSelector(handleChargeTokenInnerWebview:),
             toNSString(PaymentChargeInnerWebLoadMoneyReqId) : toSelector(handleChargeLoadMoneyInnerWebview:),
             toNSString(PGHealthReqId) : toSelector(handlePGHealthResponse:),
             toNSString(PaymentDynamicPricingReqId) : toSelector(handleDyPResponse:),
             toNSString(PaymentRequestTransferMoney) : toSelector(handleTransferMoneyResponse:),
             toNSString(PaymentCardBinServiceReqId):toSelector(handleCardBinResponse:),
             //toNSString(PayUsingDynamicPricingReqId):toSelector(handlePayUsingDynamicPricingResponse:),
             toNSString(PayPrepaidNewInternalReqId):toSelector(handlePrePaidPay:),
             };
}


- (instancetype)initWithUrl:(NSString *)url
{
    
    if(url == nil){
        url = [CTSUtility fetchFromEnvironment:BASE_URL];
    }
    self = [super initWithRequestSelectorMapping:[self getRegistrationDict]
                                         baseUrl:url];
    return self;
}



#pragma mark - response handlers methods


-(void)handleGetPrepaidBill:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSPrepaidBill* bill = nil;
    if (error == nil) {
        bill =
        [[CTSPrepaidBill alloc] initWithString:response.responseString
                                         error:&jsonError];
        
        [bill logProperties];
    }
    
    [self getPrepaidBillHelper:bill error:error];
    
}



- (void)handleReqPaymentAsGuest:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSPaymentTransactionRes* payment = nil;
    if (error == nil) {
        payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
        
        [payment logProperties];
        //    [delegate payment:self
        //        didMakePaymentUsingGuestFlow:resultObject
        //                               error:error];
    }
    [self makeGuestPaymentHelper:payment error:error];
}

//Vikas new payment api
- (void)handleReqNewPaymentAsGuest:(CTSRestCoreResponse*)response {
    
    if (response != nil) {
        [response logProperties];
        [self makeGuestNewPaymentHelper:response.responseString error:response.error];
    }
    
}

- (void)handleReqPaymentUsingtokenizedCardBank:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSPaymentTransactionRes* payment = nil;
    if (error == nil) {
        LogTrace(@"error:%@", jsonError);
        payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
        [payment logProperties];
    }
    [self makeTokenizedPaymentHelper:payment error:error];
}

- (void)handlePaymentUsingSignedInCardBank:(CTSRestCoreResponse*)response {
//    NSError* error = response.error;
//    JSONModelError* jsonError;
//    CTSPaymentTransactionRes* payment = nil;
//    if (response.indexData > -1) {
//        CTSPaymentDetailUpdate* paymentDetail =
//        [self fetchAndRemovedCachedDataForKey:response.indexData];
//        [paymentDetail logProperties];
//        __block CTSProfileLayer* profile = [[CTSProfileLayer alloc] init];
//        [profile updatePaymentInformation:paymentDetail
//                    withCompletionHandler:^(NSError* error) {
//                        LogTrace(@" error %@ ", error);
//                    }];
//        
//        payment =
//        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
//                                                   error:&jsonError];
//    }
//    [self makeUserPaymentHelper:payment error:error];
}


-(void)handleLoadMoneyCitrusPay:(CTSRestCoreResponse *)response {
    
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSPaymentTransactionRes* payment = nil;
    if (error == nil) {
        LogTrace(@"error:%@", jsonError);
        payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
        [payment logProperties];
    }
    [self loadMoneyHelper:payment error:error];
    
}

-(void)handlePayementUsingCitruspayInternal:(CTSRestCoreResponse*)response  {
    
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSPaymentTransactionRes* payment = nil;
    if (error == nil) {
        LogTrace(@"error:%@", jsonError);
        payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
        [payment logProperties];
    }
    [self makeCitrusPayInternalHelper:payment error:error];
    
    
    
}

-(void)handlePayementUsingCitruspay:(CTSRestCoreResponse*)response  {
    
    //call back view controller
    // or delegate
    //reset view controller and callback
    
    
    
    
}



- (void)handleReqPaymentPgSettings:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSPgSettings* pgSettings = nil;
    if (error == nil) {
        pgSettings = [[CTSPgSettings alloc] initWithString:response.responseString
                                                     error:&jsonError];
        [pgSettings logProperties];
    }
    [self getMerchantPgSettingsHelper:pgSettings error:error];
}

- (void)handleCashoutToBank:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSCashoutToBankRes* cashoutBankRes = nil;
    if (error == nil) {
        cashoutBankRes = [[CTSCashoutToBankRes alloc] initWithString:response.responseString
                                                               error:&jsonError];
    }
    [self cashoutToBankHelper:cashoutBankRes error:error];
}

-(void)handlePaymentResponse:(CTSPaymentTransactionRes *)paymentInfo error:(NSError *)error{
    
    BOOL hasSuccess =
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
     (error == nil))
    ? YES
    : NO;
    if(hasSuccess){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadCitrusCashPaymentWebview:paymentInfo.redirectUrl];
        });
        
    }
    else{
        //TODO: add the helper call
        [self makeCitrusPayHelper:nil error:[CTSError convertToError:paymentInfo]];
        
    }
}


- (void)handleChargeNormalInnerWebview:(CTSRestCoreResponse*)response {}
- (void)handleChargeTokenInnerWebview:(CTSRestCoreResponse*)response {}
- (void)handleChargeLoadMoneyInnerWebview:(CTSRestCoreResponse*)response {}


- (void)handlePGHealthResponse:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    CTSPGHealthRes* pgHealthRes = nil;
    if (error == nil) {
        pgHealthRes = [[CTSPGHealthRes alloc] init];
        NSDictionary *responseDict =  [NSJSONSerialization JSONObjectWithData: [response.responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options: NSJSONReadingMutableContainers
                                                                        error: &error];
        
        pgHealthRes.responseDict = [NSMutableDictionary dictionaryWithDictionary:responseDict];
        
    }
    [self pgHealthHelper:pgHealthRes error:error];
}


- (void)handleDyPResponse:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    CTSDyPResponse *dpResponse = nil;
    JSONModelError* jsonError;
    if (error == nil) {
        dpResponse = [[CTSDyPResponse alloc] initWithString:response.responseString error:&jsonError];

        
        if(jsonError == nil){
           error = [CTSError convertToErrorDyIfNeeded:dpResponse];
            if(error){
                dpResponse = nil;
            }
        }
        else {
            error = jsonError;
        }

        if(!error){
            [self cacheData:dpResponse key:CACHE_KEY_DP_RESPONSE];
        }
        
    }
    [self dyPricingHelper:dpResponse error:error];
    
}

-(void)handleDPMerchantQuery:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    CTSDyPResponse *dpResponse = nil;
    JSONModelError* jsonError;
    if (error == nil) {
        dpResponse = [[CTSDyPResponse alloc] initWithString:response.responseString error:&jsonError];
        error = jsonError;
    }
    [self dpMerchantQueryHelper:dpResponse error:error];
    
    
    
    
}


-(void)handleValidateResponse:(CTSRestCoreResponse *)response{
    
    NSError* error = response.error;
    CTSDyPResponse *dpResponse = nil;
    JSONModelError* jsonError;
    if (error == nil) {
        dpResponse = [[CTSDyPResponse alloc] initWithString:response.responseString error:&jsonError];
        error = jsonError;
    }
    [self dpValidateRuleHelper:dpResponse error:error];
    
    
}


-(void)handleTransferMoneyResponse:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    CTSTransferMoneyResponse *txMoney = nil;
    JSONModelError* jsonError;
    if (error == nil) {
        txMoney = [[CTSTransferMoneyResponse alloc] initWithString:response.responseString error:&jsonError];
        error = jsonError;
    }
    
    
    [self transferMoneyHelper:txMoney error:error];
}


-(void)handleCardBinResponse:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    CTSCardBinResponse *cardBinResponse = nil;
    JSONModelError* jsonError;
    if (error == nil) {
        cardBinResponse = [[CTSCardBinResponse alloc] initWithString:response.responseString error:&jsonError];
        error = jsonError;
    }
    
    [self cardBinServiceHelper:cardBinResponse error:error];
}


-(void)handlePrePaidPay:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    CTSPrepaidPayResp *prepaidresponse = nil;
    JSONModelError* jsonError;
    if (error == nil) {
        prepaidresponse = [[CTSPrepaidPayResp alloc] initWithString:response.responseString error:&jsonError];
        error = jsonError;
    }
    [self prepaidPayInternalHelper:prepaidresponse error:error];
}


#pragma mark - helper methods
- (void)makeUserPaymentHelper:(CTSPaymentTransactionRes*)payment
                        error:(NSError*)error {
    ASMakeUserPaymentCallBack callback = [self
                                          retrieveAndRemoveCallbackForReqId:PaymentUsingSignedInCardBankReqId];
    
    if (callback != nil) {
        callback(payment, error);
    } else {
        [delegate payment:self didMakeUserPayment:payment error:error];
    }
}

- (void)makeTokenizedPaymentHelper:(CTSPaymentTransactionRes*)payment
                             error:(NSError*)error {
    ASMakeTokenizedPaymentCallBack callback = [self
                                               retrieveAndRemoveCallbackForReqId:PaymentUsingtokenizedCardBankReqId];
    if (callback != nil) {
        callback(payment, error);
    } else {
        [delegate payment:self didMakeTokenizedPayment:payment error:error];
    }
}

- (void)makeGuestPaymentHelper:(CTSPaymentTransactionRes*)payment
                         error:(NSError*)error {
    ASMakeGuestPaymentCallBack callback =
    [self retrieveAndRemoveCallbackForReqId:PaymentAsGuestReqId];
    if (callback != nil) {
        callback(payment, error);
    } else {
        [delegate payment:self didMakePaymentUsingGuestFlow:payment error:error];
    }
}

//Vikas New payment api
- (void)makeGuestNewPaymentHelper:(NSString*)responseString error:(NSError*)error{
    ASMakeNewPaymentCallBack callback =
    [self retrieveAndRemoveCallbackForReqId:PaymentNewAsGuestReqId];
    if (callback != nil) {
        callback(responseString, error);
    } else {
        [delegate payment:self didMakeNewPaymentUsingGuestFlow:responseString error:error];
    }
}

-(void)makeCitrusPayInternalHelper:(CTSPaymentTransactionRes*)payment
                             error:(NSError*)error{
    
    ASMakeCitruspayCallBackInternal callback =
    [self retrieveAndRemoveCallbackForReqId:PaymentAsCitruspayInternalReqId];
    if (callback != nil) {
        callback(payment, error);
    }
    
}
- (void)loadMoneyHelper:(CTSPaymentTransactionRes*)payment
                  error:(NSError*)error {
    ASLoadMoneyCallBack callback = [self
                                    retrieveAndRemoveCallbackForReqId:PaymentLoadMoneyCitrusPayReqId];
    
    if (callback != nil) {
        callback(payment, error);
    } else {
        [delegate payment:self didLoadMoney:payment error:error];
    }
}


-(void)makeCitrusPayHelper:(CTSCitrusCashRes*)paymentRes
                     error:(NSError*)error{
    
    ASCitruspayCallback callback =
    [self retrieveAndRemoveCallbackForReqId:PaymentAsCitruspayReqId];
    
    if (callback != nil) {
        callback(paymentRes, error);
    }
    else{
        [delegate payment:self
     didPaymentCitrusCash:paymentRes
                    error:error];
    }
    [self resetCitrusPay];
}



- (void)getMerchantPgSettingsHelper:(CTSPgSettings*)pgSettings
                              error:(NSError*)error {
    ASGetMerchantPgSettingsCallBack callback =
    [self retrieveAndRemoveCallbackForReqId:PaymentPgSettingsReqId];
    if (callback != nil) {
        callback(pgSettings, error);
    } else {
        [delegate payment:self didRequestMerchantPgSettings:pgSettings error:error];
    }
}


-(void)cashoutToBankHelper:(CTSCashoutToBankRes *)cashoutToBankRes error:(NSError *)error{
    ASCashoutToBankCallBack callback = [self retrieveAndRemoveCallbackForReqId:PaymentCashoutToBankReqId];
    if (callback != nil) {
        callback(cashoutToBankRes, error);
    } else {
        [delegate payment:self didCashoutToBank:cashoutToBankRes error:error ];
    }
    
}

-(void)getPrepaidBillHelper:(CTSPrepaidBill*)bill
                      error:(NSError*)error{
    
    ASGetPrepaidBill callback =
    [self retrieveAndRemoveCallbackForReqId:PaymentGetPrepaidBillReqId];
    
    if (callback != nil) {
        callback(bill, error);
    }
    else{
        [delegate payment:self
        didGetPrepaidBill:bill error:error];
    }
}

- (void)chargeNormalInnerWebviewHelper:(CTSCitrusCashRes*)response error:(NSError *)error {
    [self resetCitrusPay];
    ASCitruspayCallback  callback  = [self retrieveAndRemoveCallbackForReqId:PaymentChargeInnerWebNormalReqId];
    if (callback != nil) {
        callback(response, error);
    }
}

- (void)chargeTokenInnerWebviewHelper:(CTSCitrusCashRes*)response error:(NSError *)error {
    [self resetCitrusPay];
    
    ASCitruspayCallback  callback  = [self retrieveAndRemoveCallbackForReqId:PaymentChargeInnerWeblTokenReqId];
    
    if (callback != nil) {
        callback(response, error);
    }
   
    
}
- (void)chargeLoadMoneyInnerWebviewHelper:(CTSCitrusCashRes*)response  error:(NSError *)error{
    LogTrace(@" chargeLoadMoneyInnerWebviewHelper ");
    LogThread
    [self resetCitrusPay];
    LogTrace(@" %@ ",[response.responseDict valueForKey:@"loadMoneyResponseKey"]);
    NSArray *array =   [response.responseDict valueForKey:@"loadMoneyResponseKey"];
    
    LogTrace(@" array %@ ",[array objectAtIndex:0]);
    NSString *responseStr = [array objectAtIndex:0];

    if([responseStr isEqualToString:@"failed"]){
        error = [CTSError getErrorForCode:LoadMoneyFailed];
        response = nil;
    }
    
    ASCitruspayCallback  callback  = [self retrieveAndRemoveCallbackForReqId:PaymentChargeInnerWebLoadMoneyReqId];
        callback(response, error);
}

- (void)payusingHelper:(CTSCitrusCashRes*)response  error:(NSError *)error{
    LogTrace(@" chargeLoadMoneyInnerWebviewHelper ");
    LogThread
    
    
    ASCitruspayCallback  callback  = [self retrieveAndRemoveCallbackForReqId:PayUsingDynamicPricingReqId];
    
    if (callback != nil) {
        callback(response, error);
    }
}


- (void)pgHealthHelper:(CTSPGHealthRes*)pgHealthRes error:(NSError*)error {
    ASGetPGHealth callback = [self retrieveAndRemoveCallbackForReqId:PGHealthReqId];
    if (callback != nil) {
        callback(pgHealthRes, error);
    }
}


-(void)dyPricingHelper:(CTSDyPResponse *)response error:(NSError *)error{
     ASPerformDynamicPricingCallback callback = [self retrieveAndRemoveCallbackForReqId:PaymentDynamicPricingReqId];
    if (callback != nil) {
        callback(response, error);
    }
}


-(void)dpValidateRuleHelper:(CTSDyPResponse *)response error:(NSError *)error{
    
    ASDPValidateRuleCallback callback = [self retrieveAndRemoveCallbackForReqId:PaymentDPValidateRuleReqId];
    if (callback != nil) {
        callback(response, error);
    }
}

-(void)dpMerchantQueryHelper:(CTSDyPResponse *)response error:(NSError *)error{
    ASPerformDynamicPricingCallback callback = [self retrieveAndRemoveCallbackForReqId:PaymentDPQueryMerchantReqId];
    if (callback != nil) {
        callback(response, error);
    }
}


-(void)transferMoneyHelper:(CTSTransferMoneyResponse *)response error:(NSError *)error{
    ASMoneyTransferCallback callback = [self retrieveAndRemoveCallbackForReqId:PaymentRequestTransferMoney];
    if(callback != nil){
        callback(response,error);
    }
}


-(void)cardBinServiceHelper:(CTSCardBinResponse *)response error:(NSError *)error{
    ASCardBinServiceCallback callback = [self retrieveAndRemoveCallbackForReqId:PaymentCardBinServiceReqId];
    if(callback != nil){
        callback(response,error);
    }
}

-(void)dpPayHelper:(CTSCitrusCashRes *)response error:(NSError *)error{
    [self removedDpCachedData ];
    ASCitruspayCallback callback = [self retrieveAndRemoveCallbackForReqId:PayUsingDynamicPricingReqId];
    callback(response,error);
}


-(void)resetCitrusPay{
    if( [citrusPayWebview isLoading]){
        [citrusPayWebview stopLoading];
    }
    [citrusPayWebview removeFromSuperview];
    citrusPayWebview.delegate = nil;
    citrusPayWebview = nil;
    citrusCashBackViewController = nil;
    cCashReturnUrl = nil;
    prepaidRequestType = -1;
}

-(void)prepaidPayInternalHelper:(CTSPrepaidPayResp *)prepaidPayRes error:(NSError *)error{
    ASPrepaidPayCallback callback = [self retrieveAndRemoveCallbackForReqId:PayPrepaidNewInternalReqId];
    callback(prepaidPayRes,error);
}
-(void)prepaidPayHelper:(CTSCitrusCashRes*)response  error:(NSError *)error{
    [self resetCitrusPay];
    ASCitruspayCallback callback = [self retrieveAndRemoveCallbackForReqId:PayPrepaidNewReqId];
    callback(response,error);
}

#pragma mark -  CitrusPayWebView

- (void)webViewDidStartLoad:(UIWebView*)webView {
    LogTrace(@"webViewDidStartLoad ");
}


-(void)loadCitrusCashPaymentWebview:(NSString *)url{
    
    citrusPayWebview = [[UIWebView alloc] init];
    citrusPayWebview.delegate = self;
    [citrusCashBackViewController.view addSubview:citrusPayWebview];
    [citrusPayWebview loadRequest:[[NSURLRequest alloc]
                                   initWithURL:[NSURL URLWithString:url]]];
    
    //    citrusPayWebview. frame = CGRectMake(0, 0,citrusCashBackViewController.view.frame.size.width , citrusCashBackViewController.view.frame.size.height);
    
    
    
}

-(void)loadCitrusCashPaymentWebview:(NSString *)url pgParameters:(NSDictionary *)pgParams{
    
    citrusPayWebview = [[UIWebView alloc] init];
    citrusPayWebview.delegate = self;
    [citrusCashBackViewController.view addSubview:citrusPayWebview];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    request = [CTSRestCore requestByAddingParameters:request parameters:pgParams];
    
    [citrusPayWebview loadRequest:request];
    //citrusPayWebview. frame = CGRectMake(0, 0,citrusCashBackViewController.view.frame.size.width , citrusCashBackViewController.view.frame.size.height);
 
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    LogTrace(@"error %@ ",error);


    if(prepaidRequestType == PaymentAsCitruspayReqId){
    [self makeCitrusPayHelper:nil error:error];
    }
    else if(prepaidRequestType == PayPrepaidNewInternalReqId){
        [self prepaidPayHelper:nil error:error];
    }
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    LogTrace(@"did finish loading");
    NSString *webviewUrl = [[[webView request] URL] absoluteString];
    LogTrace(@"currentURL %@",webviewUrl);
    if( [CTSUtility isURL:[NSURL URLWithString:cCashReturnUrl] toUrl:[NSURL URLWithString:webviewUrl]]){
    
        NSDictionary *responseDict = [CTSUtility getResponseIfTransactionIsComplete:webView];
        
        responseDict = [CTSUtility errorResponseIfReturnUrlDidntRespond:cCashReturnUrl webViewUrl:webviewUrl currentResponse:responseDict];
        
        if(responseDict){
            CTSCitrusCashRes *response = [[CTSCitrusCashRes alloc] init];
            response.responseDict = [NSMutableDictionary dictionaryWithDictionary:responseDict];
            NSError *error = [CTSUtility extractError:response.responseDict];
            
            if(prepaidRequestType == PaymentAsCitruspayReqId){
                [self makeCitrusPayHelper:response error:error];
            }
            else if(prepaidRequestType == PayPrepaidNewInternalReqId){
                [self prepaidPayHelper:response error:error];
            }
        }
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    LogTrace(@"response Should %@",[CTSUtility getResponseIfTransactionIsFinished:request.HTTPBody]);
    
    NSArray* cookies =
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[request URL]];
    LogTrace(@"cookie array:%@", cookies);
    if([CTSUtility isVerifyPage:[[request URL] absoluteString]]){
        [self makeCitrusPayHelper:nil
                            error:[CTSError getErrorForCode:UserNotSignedIn]];
        
    }
    return YES;
}


- (void)makeUserPayment:(CTSPaymentDetailUpdate*)paymentInfo
            withContact:(CTSContactUpdate*)contactInfo
            withAddress:(CTSUserAddress*)userAddress
                 amount:(NSString*)amount
          withReturnUrl:(NSString*)returnUrl
          withSignature:(NSString*)signature
              withTxnId:(NSString*)merchantTxnId
  withCompletionHandler:(ASMakeUserPaymentCallBack)callback{}


/**
 *  called when client request to make a tokenized payment
 *
 *  @param paymentInfo Payment Information
 *  @param contactInfo contact Information
 *  @param amount      payment amount
 */
- (void)makeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
                 withContact:(CTSContactUpdate*)contactInfo
                 withAddress:(CTSUserAddress*)userAddress
                      amount:(NSString*)amount
               withReturnUrl:(NSString*)returnUrl
               withSignature:(NSString*)signature
                   withTxnId:(NSString*)merchantTxnId
       withCompletionHandler:(ASMakeTokenizedPaymentCallBack)callback{}

- (void)makePaymentUsingGuestFlow:(CTSPaymentDetailUpdate*)paymentInfo
                      withContact:(CTSContactUpdate*)contactInfo
                           amount:(NSString*)amount
                      withAddress:(CTSUserAddress*)userAddress
                    withReturnUrl:(NSString*)returnUrl
                    withSignature:(NSString*)signature
                        withTxnId:(NSString*)merchantTxnId
            withCompletionHandler:(ASMakeGuestPaymentCallBack)callback{}


-(void)loadPaymentWebview:(NSString *)url reqId:(int)reqId returnUrl:(NSString *)returnUrl{
    //dispatch_async(dispatch_get_main_queue(), ^{
    LogTrace(@" loadPaymentWebview ");
    LogThread
    if(paymentWebViewController != nil){
        [self removeObserver:self forKeyPath:@"paymentWebViewController.response"];
        [paymentWebViewController finishWebView];
    }
    paymentWebViewController = [[CTSPaymentWebViewController alloc] init];
    [self addObserver:self forKeyPath:@"paymentWebViewController.response" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    paymentWebViewController.redirectURL = url;
    paymentWebViewController.reqId = reqId;
    paymentWebViewController.returnUrl = returnUrl ;
    paymentWebViewController.isForLoadMoney = TRUE;
    LogTrace(@"citrusCashBackViewController.navigationController %@",citrusCashBackViewController.navigationController);
    //    if(citrusCashBackViewController.navigationController){
    //    [citrusCashBackViewController.navigationController pushViewController:paymentWebViewController animated:YES];
    //    }{
   UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:paymentWebViewController];
    
//Vikas change No -> Yes
    if(citrusCashBackViewController.navigationController){
        [citrusCashBackViewController presentViewController:navigationController animated:YES completion:nil];
    }
    
}

//Vikas new payment
-(void)loadNewPaymentWebview:(NSString *)url reqId:(int)reqId returnUrl:(NSString *)returnUrl{
    //dispatch_async(dispatch_get_main_queue(), ^{
    LogTrace(@" loadPaymentWebview ");
    LogThread
    
    if(paymentWebViewController != nil){
        [self removeObserver:self forKeyPath:@"paymentWebViewController.response"];
        [paymentWebViewController finishWebView];
    }
    if (!paymentWebViewController) {
        paymentWebViewController = [[CTSPaymentWebViewController alloc] init];
    }
    //passing all the value to paymentWebViewController class
    paymentWebViewController.paymentInfo = aPaymentInfo;
    paymentWebViewController.bill = aBill;
    paymentWebViewController.contactInfo = aContactInfo;
    paymentWebViewController.userAddress = aUserAddress;
    paymentWebViewController.custParams = aCustParams;
    paymentWebViewController.isForLoadMoney = FALSE;
   
    [self addObserver:self forKeyPath:@"paymentWebViewController.response" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    paymentWebViewController.redirectURL = url;
    paymentWebViewController.reqId = reqId;
    paymentWebViewController.returnUrl = returnUrl ;
    LogTrace(@"citrusCashBackViewController.navigationController %@",citrusCashBackViewController.navigationController);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:paymentWebViewController];
    
    //Vikas change No -> Yes
    if(citrusCashBackViewController.navigationController){
        [citrusCashBackViewController presentViewController:navigationController animated:YES completion:nil];
    }
    
    // });
}




-(void)loadPaymentWebview:(PayLoadWebviewDto *)loadWebview{
    LogTrace(@" loadPaymentWebview ");
    LogThread
    if(paymentWebViewController != nil){
        [self removeObserver:self forKeyPath:@"paymentWebViewController.response"];
        [paymentWebViewController finishWebView];
    }
    paymentWebViewController = [[CTSPaymentWebViewController alloc] init];
    [self addObserver:self forKeyPath:@"paymentWebViewController.response" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    paymentWebViewController.redirectURL = loadWebview.url;
    paymentWebViewController.reqId = loadWebview.reqId;
    paymentWebViewController.returnUrl = loadWebview.returnUrl ;
    LogTrace(@"citrusCashBackViewController.navigationController %@",citrusCashBackViewController.navigationController);
    //Vikas
//    [citrusCashBackViewController.navigationController pushViewController:paymentWebViewController animated:YES];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:paymentWebViewController];
    
    //Vikas change No -> Yes
    if(citrusCashBackViewController.navigationController){
        [citrusCashBackViewController presentViewController:navigationController animated:YES completion:nil];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    LogTrace(@" observeValueForKeyPath ");
    LogThread
    for(NSString *keys in change){
        LogTrace(@"Checking key %@, Value %@",keys,[change valueForKey:keys]);
    }
    
    CTSCitrusCashRes *response = [[CTSCitrusCashRes alloc] init];
    response.responseDict =  [NSMutableDictionary dictionaryWithDictionary:[change valueForKey:@"new"]];
    int toIntReqId = [CTSUtility extractReqId:response.responseDict];
    NSError *error = [CTSUtility extractError:response.responseDict];
    
    [self dismissController];
    [self removeObserver:self forKeyPath:@"paymentWebViewController.response"];
    paymentWebViewController=nil;
    citrusCashBackViewController = nil;
    if(error){
        response = nil;
    }
    switch (toIntReqId) {
        case PaymentChargeInnerWebNormalReqId:
            [self chargeNormalInnerWebviewHelper:response error:error];
            break;
        case PaymentChargeInnerWeblTokenReqId:
            [self chargeTokenInnerWebviewHelper:response error:error];
            break;
        case PaymentChargeInnerWebLoadMoneyReqId:
            [self chargeLoadMoneyInnerWebviewHelper:response error:error];
            break;
        default:
            break;
    }
}

-(void)dismissController{
    [paymentWebViewController dismissViewControllerAnimated:YES completion:nil];
}


+(CTSDyPPaymentInfo *)toDpPayment:(CTSPaymentOption *)paymentOption{
    CTSDyPPaymentInfo *paymentInfo = nil;
    
    CTSPaymentType paymentType = [paymentOption fetchPaymentType];
    
    
    
    
    switch (paymentType) {
        case MemberCard:
            if([paymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_CREDIT_TYPE]){
                paymentInfo = [[CTSDyPPaymentInfo alloc] initCreditCardMode];
            }
            else if([paymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_DEBIT_TYPE]){
                paymentInfo = [[CTSDyPPaymentInfo alloc] initDebitCardMode];
            }
            paymentInfo.cardType = paymentOption.scheme;
            paymentInfo.cardNo = paymentOption.number;
            break;
            
        case MemberNetbank:
            paymentInfo = [[CTSDyPPaymentInfo alloc] initNetbankMode];
            paymentInfo.issuerId = paymentOption.code;
            break;
            
        case TokenizedCard:
            paymentInfo = [[CTSDyPPaymentInfo alloc] initSavedOptionMode];
            paymentInfo.paymentToken = paymentOption.token;
            break;
            
        case TokenizedNetbank:
            paymentInfo = [[CTSDyPPaymentInfo alloc] initSavedOptionMode];
            paymentInfo.paymentToken = paymentOption.token;
            paymentInfo.issuerId = paymentOption.code;


            break;
            
        case CitrusPay:
            paymentInfo = [[CTSDyPPaymentInfo alloc] initCitrusWalletMode];
            break;
            
        case UndefinedPayment:
            //TODO raise error
            break;
        default:
            break;
    }
    
    

    return paymentInfo;
    
}

-(NSMutableDictionary *)fetchExtraParam:(DPRequestType)type extra:(NSDictionary *)extraParams{
    NSMutableDictionary *extraParamRequest = nil;
    
    if(extraParams == nil){
        extraParamRequest = [[NSMutableDictionary alloc] init];
        [extraParamRequest addEntriesFromDictionary:extraParams];
    }
    switch (type) {
        case DPRequestTypeValidate:
            [extraParamRequest addEntriesFromDictionary:MLC_DYNAMIC_PRICING_QUERY_VALIDATION_DICT];
            break;
        case DPRequestTypeCalculate:
            [extraParamRequest addEntriesFromDictionary:MLC_DYNAMIC_PRICING_QUERY_CALCULATE_DICT];
            break;
        case DPRequestTypeSearchAndApply:
            [extraParamRequest addEntriesFromDictionary:MLC_DYNAMIC_PRICING_QUERY_SEARCHANDAPPLY_DICT];
            break;
        default:
            //validation error
            break;
    }
    return extraParamRequest;
}

-(void)removedDpCachedData{
    [self fetchAndRemovedCachedDataForKey:CACHE_KEY_DP_RESPONSE];
    [self fetchAndRemovedCachedDataForKey:CACHE_KEY_DP_BILL];
    [self fetchAndRemovedCachedDataForKey:CACHE_KEY_DP_PAYMENT_INFO];
    [self fetchAndRemovedCachedDataForKey:CACHE_KEY_DP_USER_INFO];
}

@end
