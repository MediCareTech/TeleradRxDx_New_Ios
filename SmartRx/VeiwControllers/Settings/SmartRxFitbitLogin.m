//
//  SmartRxFitbitLogin.m
//  SmartRx
//
//  Created by SmartRx-iOS on 04/04/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxFitbitLogin.h"
#import "SmartRxDashBoardVC.h"

@interface SmartRxFitbitLogin ()
{
    NSString  *clientID;
    NSString  *clientSecret ;
    NSURL     *authUrl ;
    NSURL     *refreshTokenUrl ;
    NSString  *redirectURI  ;
    NSString  *defaultScope ;
    NSString  *expiresIn ;
    NSString  *state ;

    NSString *authenticationCode;
    
}
@end

@implementation SmartRxFitbitLogin
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
    btnFaq.tag=1;
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_add_report.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    
    [btnFaq addTarget:self action:@selector(addEhr:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    // self.navigationItem.rightBarButtonItem = rightbutton;
    
    
}
-(void)loadVars{
    //------ Initialize all required vars -----
    clientID         = @"229VW2";
    clientSecret     = @"1d7fd7674cc93c43208ab27d1cecb831";
    redirectURI      = FitbitUrl;
    expiresIn        = @"31536000";
    authUrl          = [NSURL URLWithString:@"https://www.fitbit.com/oauth2/authorize"];
    refreshTokenUrl  = [NSURL URLWithString:@"https://api.fitbit.com/oauth2/token"];
    defaultScope     = @"sleep%20settings%20nutrition%20activity%20social%20heartrate%20profile%20weight%20location";
    state = [[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
    /** expiresIn Details
     // 86400 for 1 day
     // 604800 for 1 week
     // 2592000 for 30 days
     // 31536000 for 1 year
     */
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"connect With Fitbit";
    [self loadVars];
    [self navigationBackButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToSettingsPage:) name:@"FitbitNotofication" object:nil];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?response_type=code&client_id=%@&scope=%@&state=%@&redirect_uri=%@&expires_in=%@&prompt=login",authUrl,clientID,defaultScope,state,redirectURI,expiresIn]];
    NSLog(@"url......:%@",url);
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Action Methods

-(void)backToSettingsPage:(NSNotification *)notification{
    [self.delegate fitbitUpdate];
    [self backBtnClicked:nil];
}
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
