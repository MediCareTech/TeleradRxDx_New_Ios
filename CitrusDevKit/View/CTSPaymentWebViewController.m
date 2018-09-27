//
//  PaymentWebViewController.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 13/05/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "CTSPaymentWebViewController.h"
#import "CTSUtility.h"
#import "UIUtility.h"
#import "CTSError.h"
#import "CTSPaymentLayer.h"

@interface CTSPaymentWebViewController ()
@property( strong) UIWebView *webview;
@end

@implementation CTSPaymentWebViewController
@synthesize redirectURL,reqId,response;

#define toNSString(cts) [NSString stringWithFormat:@"%d", cts]


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    LogTrace(@" viewDidLoad ");
    LogThread
    self.title = @"3D Secure";
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    //self.webview.scalesPageToFit = TRUE;
    self.webview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.webview.backgroundColor = [UIColor orangeColor];
    indicator = [[UIActivityIndicatorView alloc]
                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //Vikas
    indicator.center = CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0);
    
    [self.view addSubview:self.webview];
    [self.webview addSubview:indicator];
    transactionOver = NO;
    
    if (!self.consumerPortalRequest) {
        
        if (self.isForLoadMoney) {
            self.title = @"3D Secure";
            [self.webview loadRequest:[[NSURLRequest alloc]
                                       initWithURL:[NSURL URLWithString:redirectURL]]];
        }
        else{
         [self.webview loadHTMLString:redirectURL baseURL:[NSURL URLWithString:[CTSUtility fetchFromEnvironment:NEW_PAYMENT_BASE_URL]]];
        }
    }else{
        self.title = @"Consumer Portal";
        [self.webview loadRequest:self.consumerPortalRequest];
    }
    

   //  [self addBackButton];
    //Vikas
    [self addRightBarButton];
}

//Added Right Bar Button
//Vikas
-(void)addRightBarButton{
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(promptForCancelTransaction)];
    [closeButton setTitle:@"Cancel"];
    self.navigationItem.rightBarButtonItem = closeButton;


}

-(void)addBackButton{
    UIButton*back = [UIButton buttonWithType:UIButtonTypeSystem];
    [back addTarget:self action:@selector(promptForCancelTransaction) forControlEvents:UIControlEventTouchUpInside];
    back.frame = CGRectMake(10, 10, 50, 22);
//    back.frame = CGRectMake(0, 0, 34, 26);
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:back ];
}

-(void)dismissController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    LogTrace(@" view will desappear ");
    LogThread

    [super viewWillDisappear:animated];
    [self finishWebView];
    if(transactionOver == NO){
        NSDictionary* responseDict = [CTSUtility errorResponseTransactionForcedClosedByUser];
        if(responseDict){
            [self transactionComplete:(NSMutableDictionary *)responseDict];
        }
    }
}

#pragma mark - webview delegates

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    LogTrace(@"WEB_VIEW_DID_FAIL   URL %@ \n%@",[webView.request URL].absoluteString,error);

    
    if([error code] == NSURLErrorCancelled)
        return;
    
    if(reqId == PaymentChargeInnerWebLoadMoneyReqId){
        NSDictionary *userInf = [error userInfo];
        NSURL *failingUrl = [userInf objectForKey:@"NSErrorFailingURLKey"];
        LogTrace(@"failingUrl %@",failingUrl);
        if([CTSUtility isURL:failingUrl toUrl:[NSURL URLWithString:_returnUrl]]){
            NSArray *loadMoneyResponse = [CTSUtility getLoadResponseIfSuccesfull:[NSURLRequest requestWithURL:failingUrl]];
            NSDictionary *loadMoneyResponseDict = [NSDictionary dictionaryWithObject:loadMoneyResponse forKey:LoadMoneyResponeKey];
            transactionOver = YES;
            [self transactionComplete:(NSMutableDictionary *)loadMoneyResponseDict];
            return;
        }
    }
    [self transactionComplete:(NSMutableDictionary *)[CTSUtility errorResponseDeviceOffline:error]];
}

- (void)webViewDidStartLoad:(UIWebView*)webView {
    LogTrace(@"WEB_VIEW_DID_START_LOAD  URL %@",[webView.request URL].absoluteString);
    LogThread

    [indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    
    LogTrace(@" WEB_VIEW_FINISH_LOAD URL %@\n\n\n\n\n\n\n\n",[webView.request URL].absoluteString);
    LogThread
    NSURL *currentURL = [[webView request] URL];
    LogTrace(@"[self.webview isLoading] %d",[self.webview isLoading]);
    if(isCancelTriggered == NO){
        [indicator stopAnimating];
        if(reqId != PaymentChargeInnerWebLoadMoneyReqId){
            NSDictionary *responseDict = [CTSUtility getResponseIfTransactionIsComplete:webView];
            LogTrace(@"currentURL %@ return url %@",[currentURL description], _returnUrl);
            LogTrace(@"responseDict %@",responseDict);
            responseDict = [CTSUtility errorResponseIfReturnUrlDidntRespond:_returnUrl webViewUrl:[currentURL absoluteString] currentResponse:responseDict];
            if(responseDict){
                [self transactionComplete:(NSMutableDictionary *)responseDict];
            }
        }
        else{
            if([CTSUtility isURL:currentURL toUrl:[NSURL URLWithString:_returnUrl]]){
                NSArray *loadMoneyResponse = [CTSUtility getLoadResponseIfSuccesfull:[webView request]];
                NSDictionary *loadMoneyResponseDict = [NSDictionary dictionaryWithObject:loadMoneyResponse forKey:LoadMoneyResponeKey];
                [self transactionComplete:(NSMutableDictionary *)loadMoneyResponseDict];
            }
        }
    }
    else{
        [self handleCancelTrasaction:currentURL];
    }
}


-(void)handleCancelTrasaction:(NSURL *)currentURL{
    LogTrace(@" MPI url found %@ ",[currentURL absoluteString]);
    [self reloadReturnUrlForCancelTx];
}

-(BOOL)isMPIServletLoading:(NSString *)currentUrl{
    return  [CTSUtility string:currentUrl containsString:@"mpiServlet"];
}



-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
   
    LogTrace(@" WEB_VIEW_SHOULD_STARTLOAD %@",[request URL].absoluteString);
    
    LogThread
   
    //Vikas
    NSURL *currentURL = [request URL];
    if([CTSUtility isURL:currentURL toUrl:[NSURL URLWithString:_returnUrl]]){
        [self removeCancelButton];
    }
   
    LogTrace(@"response Should %@",[CTSUtility getResponseIfTransactionIsFinished:request.HTTPBody]);
    if(isCancelTriggered && [self isMPIServletLoading:[request URL].absoluteString] == NO){
        LogTrace(@"###A Cancel is triggered but another url is loading, wont allow");
        return NO;
    }else if(isCancelTriggered && [self isMPIServletLoading:[request URL].absoluteString] == YES){
        LogTrace(@"###B Cancel is triggered and MPI is loading, unsetting trigger");
        isCancelTriggered = NO;
    }
    
    
    return YES;
}

-(void)removeCancelButton{
  self.navigationItem.rightBarButtonItem = nil;
}


#pragma mark - Payment handler

-(void)transactionComplete:(NSMutableDictionary *)responseDictionary{
    LogTrace(@" transactionComplete ");
    LogThread
    [pleaseWait dismissWithClickedButtonIndex:10 animated:YES];

    transactionOver = YES;
    responseDictionary = [NSMutableDictionary dictionaryWithDictionary:responseDictionary];
    [self finishWebView];
    [responseDictionary setValue:toNSString(reqId) forKey:@"reqId"];
    [self setValue:responseDictionary forKey:@"response"];
}


-(void)finishWebView{
    LogTrace(@" finishWebView ");
    LogThread
    if( [self.webview isLoading]){
        [self.webview stopLoading];
    }
    self.webview.delegate = nil;
    [self.webview removeFromSuperview];
    self.webview = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


-(void)promptForCancelTransaction{
    if (!self.consumerPortalRequest) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to cancel this transaction?" delegate:self cancelButtonTitle:@"Yes"otherButtonTitles:@"No", nil];
            alert.tag = 1;
            [alert show];
        });
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:10 animated:YES];

    if(buttonIndex == 0){
        // [self pleaseWaitPrompt];
        [self cancelTransaction];
    }
    else if (buttonIndex == 1){
       
    }
}


-(void)pleaseWaitPrompt{
    dispatch_async(dispatch_get_main_queue(), ^{
        pleaseWait = [[UIAlertView alloc] initWithTitle:@"Please Wait !" message:@"Safely Ending the Transaction ..." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [pleaseWait show];
    });

}

/*
-(void)cancelTransaction{
    LogThread
    //[self removeCancelButton];
    cancelTxCount++;
    if(cancelTxCount <= 1){
        if(transactionOver == NO){
            LogTrace(@" Cancel Transaction ");
            if([self.webview isLoading]){
                LogTrace(@" loading already ");
                isCancelTriggered = YES;
            }
            else {
                [self reloadReturnUrlForCancelTx];
            }
        }
    }
    else{
        [self transactionComplete:(NSMutableDictionary *)[CTSUtility errorResponseTransactionFailed]];
    }
}
*/

//Vikas According to New Payment API

-(void) cancelTransaction{
    
    if (self.isForLoadMoney) {
        cancelTxCount++;
        if(cancelTxCount <= 1){
            if(transactionOver == NO){
                LogTrace(@" Cancel Transaction ");
                if([self.webview isLoading]){
                    LogTrace(@" loading already ");
                    isCancelTriggered = YES;
                }
                else {
                    [self reloadReturnUrlForCancelTx];
                }
            }
        }
        else{
            [self transactionComplete:(NSMutableDictionary *)[CTSUtility errorResponseTransactionFailed]];
        }
    }
    else{
        [self requestCancelTransactionWithPaymentInfo:self.paymentInfo withContact:self.contactInfo withAddress:self.userAddress bill:self.bill customParams:self.custParams ];
    }
}

- (void) requestCancelTransactionWithPaymentInfo:(CTSPaymentDetailUpdate*)paymentInfo
                                     withContact:(CTSContactUpdate*)contactInfo
                                     withAddress:(CTSUserAddress*)userAddress
                                            bill:(CTSBill *)bill
                                    customParams:(NSDictionary *)custParams{
    
                        
    NSString *pathString = [NSString stringWithFormat:@"%@/sslperf/%@%@",[CTSUtility fetchFromEnvironment:NEW_PAYMENT_BASE_URL],[CTSUtility fetchVanityUrl:[CTSUtility keyStore]],MLC_PAYMENT_CANCEL_TRANSACTION];
    
//    https://www.citruspay.com/sslperf/testing/cancel
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:pathString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *stringParameter = [NSString stringWithFormat:@"vanityUrl=%@&firstName=%@&lastName=%@&email=%@&phoneNumber=%@&addressCountry=%@&addressState=%@&addressCity=%@&addressStreet1=%@&addressStreet2=%@&addressZip=%@&returnUrl=%@&notifyUrl=%@&orderAmount=%@&currency=%@&secSignature=%@&merchantTxnId=%@&secSignature=%@&merchantAccessKey=%@&dpSignature=%@&isEMI=&pgCode=&dpFlag=&errorMessage=&retryCount=0&paymentModeType=Editable&couponCode=",[CTSUtility fetchVanityUrl:[CTSUtility keyStore]],contactInfo.firstName,contactInfo.lastName,contactInfo.email,contactInfo.mobile,userAddress.country,userAddress.state,userAddress.city,userAddress.street1,userAddress.street2,userAddress.zip,bill.returnUrl,bill.notifyUrl,bill.amount.value,bill.amount.currency,bill.requestSignature,bill.merchantTxnId,bill.requestSignature,bill.merchantAccessKey,bill.dpSignature];
    

    request = [CTSRestCore requestByAddingParameters:request withSerializeString:stringParameter];
    [self.webview loadRequest:request];
    
}

-(void)reloadReturnUrlForCancelTx{
    LogTrace(@"reloadReturnUrlForCancelTx");
    [self.webview loadRequest:[[NSURLRequest alloc]
                               initWithURL:[NSURL URLWithString:redirectURL]]];
}
@end
