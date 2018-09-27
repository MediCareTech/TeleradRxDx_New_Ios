//
//  WebViewViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 09/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "WebViewViewController.h"
#import "CTSUtility.h"
#import "UIUtility.h"
#import "SmartRxPaymentVC.h"
#import "SmartRxBookeConsultVC.h"
#import "SmartRxGetCarePlanVC.h"
#import "SmartRxBookServices.h"
#import "SmartRxGetManagedCarePlanVC.h"
#import "SmartRxBookAPPointmentVC.h"

@interface WebViewViewController ()

@property(nonatomic,strong) UIWebView *webview;

@end

@implementation WebViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"3D Secure";
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    self.webview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.webview.backgroundColor = [UIColor grayColor];
    indicator = [[UIActivityIndicatorView alloc]
                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(160, 300, 30, 30);
    [self.view addSubview:self.webview];
    [self.webview addSubview:indicator];
    
    
    NSLog(@"----------------THE URL IS  %@",self.redirectURL);
    [self.webview loadRequest:[[NSURLRequest alloc]
                                                initWithURL:[NSURL URLWithString:self.redirectURL]]];
}


#pragma mark - webview delegates

- (void)webViewDidStartLoad:(UIWebView*)webView {
    NSLog(@"webView %@",[webView.request URL].absoluteString);
    [indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    [indicator stopAnimating];
//
    //for payment proccessing return url finish
    NSDictionary *responseDict = [CTSUtility getResponseIfTransactionIsComplete:webView];
    if(responseDict){
        //responseDict> contains all the information related to transaction
        [self transactionComplete:responseDict];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"request url %@ scheme %@",[request URL],[[request URL] scheme]);
    
    //for load balance return url finish
    NSArray *loadMoneyResponse = [CTSUtility getLoadResponseIfSuccesfull:request];
    if(loadMoneyResponse){
        LogTrace(@"loadMoneyResponse %@",loadMoneyResponse);
        
        [self loadMoneyComplete:loadMoneyResponse];
    }
    
    
    
    //for general payments
    NSDictionary *responseDict = [CTSUtility getResponseIfTransactionIsFinished:request.HTTPBody];
    if(responseDict){
        //responseDict> contains all the information related to transaction
        [self transactionComplete:responseDict];
    }
    
    return YES;
    
}




-(void)transactionComplete:(NSDictionary *)responseDictionary{
    if([responseDictionary valueForKey:@"TxStatus"] != nil && [[responseDictionary valueForKey:@"TxStatus"] caseInsensitiveCompare:@"SUCCESS"] == NSOrderedSame){
        [[NSUserDefaults standardUserDefaults] setObject:responseDictionary forKey:@"paymentResponseDictionary"];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"fromEconsult"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"TransactionSuccess"];
            if([[[NSUserDefaults standardUserDefaults]objectForKey:@"fromEconsult"] boolValue])
                [[SmartRxBookeConsultVC sharedManagerEconsult] setPaymentResponseDictionary:[responseDictionary mutableCopy]];
            else
                [[SmartRxGetCarePlanVC sharedGetCarePlanVC] setPaymentResponseDictionary:[responseDictionary mutableCopy]];
        }
        else if ([[NSUserDefaults standardUserDefaults]objectForKey:@"fromServices"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"TransactionSuccess"];
            if([[[NSUserDefaults standardUserDefaults]objectForKey:@"fromServices"] boolValue])
                [[SmartRxBookServices sharedManagerServices] setPaymentResponseDictionary:[responseDictionary mutableCopy]];
            
        }else if ([[NSUserDefaults standardUserDefaults]objectForKey:@"fromCareProgram"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"TransactionSuccess"];
            if([[[NSUserDefaults standardUserDefaults]objectForKey:@"fromCareProgram"] boolValue])
                [[SmartRxGetManagedCarePlanVC sharedManagerCarePlanProgram] setPaymentResponseDictionary:[responseDictionary mutableCopy]];
            
        }else if ([[NSUserDefaults standardUserDefaults]objectForKey:@"fromAppointment"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"TransactionSuccess"];
            if([[[NSUserDefaults standardUserDefaults]objectForKey:@"fromAppointment"] boolValue])
                [[SmartRxBookAPPointmentVC sharedManagerAppointment] setPaymentResponseDictionary:[responseDictionary mutableCopy]];
            
        }
//        SmartRxBookeConsultVC *eConsultVc = [[SmartRxBookeConsultVC alloc]init];
//           eConsultVc.paymentResponseDictionary = [responseDictionary mutableCopy];
//        [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" transaction complete\n %@",[responseDictionary valueForKey:@"TxStatus"] ]];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"TransactionSuccess"];        
//        [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@"Error while processing your payment. Please try again later."]];
    
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
//    [self.navigationController popViewControllerAnimated:YES];
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxBookeConsultVC class]] || [controller isKindOfClass:[SmartRxGetCarePlanVC class]] || [controller isKindOfClass:[SmartRxBookServices class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
            
    }
    
    [self finishWebView];
}

-(void)loadMoneyComplete:(NSArray *)resPonseArray{
    [UIUtility toastMessageOnScreen:[NSString stringWithFormat:@" load Money Complete\n Response: %@",resPonseArray]];
    [self.navigationController popViewControllerAnimated:YES];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)finishWebView{
    
    if( [self.webview isLoading]){
        [self.webview stopLoading];
    }
    [self.webview removeFromSuperview];
    self.webview.delegate = nil;
    self.webview = nil;
    
}
@end
