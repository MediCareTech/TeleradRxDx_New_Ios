//
//  SmartRxAssessmentQuestionsVc.m
//  SmartRx
//
//  Created by Gowtham on 23/01/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxAssessmentQuestionsVc.h"
#import "WebViewJavascriptBridge.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxBookedAssessments.h"

@interface SmartRxAssessmentQuestionsVc ()
@property WebViewJavascriptBridge* bridge;

@end

@implementation SmartRxAssessmentQuestionsVc
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


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Assessments";

    [self navigationBackButton];

    if (_bridge) {
        return;
    }
    
    [WebViewJavascriptBridge enableLogging];
    [_bridge disableJavscriptAlertBoxSafetyTimeout];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [_bridge setWebViewDelegate:self];
    
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        dispatch_async(dispatch_get_main_queue(),^{
            [self moveToAseessmentsController];
        });
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    [self loadExamplePage:_webView];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"UIWebViewNavigationType:%ld",(long)navigationType);
    return YES;
}
- (void)loadExamplePage:(UIWebView*)webView {
    NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *urlStr = [NSString stringWithFormat:@"%s/admin/userpage.php?page=updatepatienttrackers&patientid=%@&trackerid=%@&mode=open&cid=%@",kBaseUrlQAImg,userId,self.selectedAssessment.trackerId,strCid];
    
    NSLog(@"web url:%@",urlStr);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0];
    //self.webView.delegate
    
//    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
//    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
//    
//    
//    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
//    
//    
//    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
//    [NSURLCache setSharedURLCache:sharedCache];
//    
//    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
//        
//        NSLog(@"domain:%@",cookie.domain);
//        
//        if([[cookie domain] isEqualToString:CacheUrl]) {
//            
//            
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//        }
//        
//    }
//    
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Action Methods
-(void)moveToAseessmentsController{
    //bookedAssessments
    
    SmartRxBookedAssessments *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"bookedAssessments"];
    controller.fromVc = @"questionsVc";
    [self.navigationController pushViewController:controller animated:YES];
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
-(void)backBtnClicked:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
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
