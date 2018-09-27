//
//  SmartRxOurHospitalsVC.m
//  SmartRx
//
//  Created by Anil Kumar on 06/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import "SmartRxOurHospitalsVC.h"
#import "SmartRxDashBoardVC.h"
@interface SmartRxOurHospitalsVC ()
{
    MBProgressHUD *HUD;
}
@end

@implementation SmartRxOurHospitalsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [self navigationBackButton];
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    self.locationName.text = [self.dictData objectForKey:@"locname"];
    if ([self.dictData objectForKey:@"locationimg"] != [NSNull null])
    {
        NSString *theURL = [NSString stringWithFormat:@"%s/%@",kAdminBaseUrl,[self.dictData objectForKey:@"locationimg"]];
        self.serviceImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:theURL]]];;
    }
    else
    {
        self.serviceImage.image = [UIImage imageNamed:@"doctor_dp_bg.jpg"];
    }
    [self.webView loadHTMLString:[self.dictData objectForKey:@"locationaddress"] baseURL:nil];
//    self.webView.scalesPageToFit=TRUE;
    self.webView.scrollView.bounces = NO;
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    
    // Do any additional setup after loading the view.
}

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)homeBtnClicked:(id)sender
{
    
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}
- (void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)callButtonClicked:(id)sender
{
    
    NSString *phoneNumber=[self.dictData objectForKey:@"loccontact"];
    NSString *number = [NSString stringWithFormat:@"%@",phoneNumber];
    NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@",number]];
    
    //check  Call Function available only in iphone
    if([[UIApplication sharedApplication] canOpenURL:callUrl])
    {
        [[UIApplication sharedApplication] openURL:callUrl];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ALERT" message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}
- (IBAction)locationButtonClicked:(id)sender
{
    NSString *htmlString=[self.dictData objectForKey:@"locationmap"];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    NSString *location = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                           (__bridge CFStringRef)[attrStr string],
                                                                                           NULL,
                                                                                           (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                           kCFStringEncodingUTF8);
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@",location];
    NSURL *url = [NSURL URLWithString:urlString];
    
//check  Call Function available only in iphone
    if([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Not able to open the specified location"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
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
