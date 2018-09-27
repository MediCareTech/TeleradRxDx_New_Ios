//
//  SmartRxBookAppoitmentController.m
//  TeleradRxdx
//
//  Created by Gowtham on 24/05/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxBookAppoitmentController.h"
#import "UserDetails.h"
#import "SmartRxCommonClass.h"
#import "SmartRxDashBoardVC.h"

@interface SmartRxBookAppoitmentController ()
{
    MBProgressHUD *HUD;

}

@end

@implementation SmartRxBookAppoitmentController

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
    
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Book Appointment"  controler:self];
    self.webView.delegate = self;
    [self navigationBackButton];
    
    NSString *bookingUrl = [UserDetails getQikWellApi];
   
    NSString *urlStr = [NSString stringWithFormat:@"%@userid=%@",BOOK_APPOITMENT_API,[UserDetails getQikWellId]];
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    [self.webView loadRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:bookingUrl]]];
    
}
-(void)addSpinnerView{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [HUD hide:YES];
    [HUD removeFromSuperview];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
