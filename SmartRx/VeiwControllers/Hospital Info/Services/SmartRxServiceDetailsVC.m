//
//  SmartRxServiceDetailsVC.m
//  SmartRx
//
//  Created by Anil Kumar on 05/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import "SmartRxServiceDetailsVC.h"
#import "SmartRxDashBoardVC.h"
@interface SmartRxServiceDetailsVC ()
{
    MBProgressHUD *HUD; 
}
@end

@implementation SmartRxServiceDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];        
    [self navigationBackButton];
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    self.specialityName.text = self.navigationItem.title;
    if (self.fromAboutUs)
    {
        if ([self.dictData objectForKey:@"imgsrc"] != [NSNull null])
        {
            NSString *theURL = [NSString stringWithFormat:@"%s%@",kBaseUrlQAImg,[self.dictData objectForKey:@"imgsrc"]];
            self.serviceImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:theURL]]];;
        }
        else
        {
            self.serviceImage.image = [UIImage imageNamed:@"doctor_dp_bg.jpg"];
        }
        [self.webView loadHTMLString:[self.dictData objectForKey:@"desc"] baseURL:nil];
    }
    else{
        if ([[self.dictResponse objectAtIndex:0]objectForKey:@"imgsrc"] != [NSNull null])
        {
            NSString *theURL = [NSString stringWithFormat:@"%s%@",kBaseUrlQAImg,[[self.dictResponse objectAtIndex:0]objectForKey:@"imgsrc"]];
            self.serviceImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:theURL]]];;
        }
        else
        {
            self.serviceImage.image = [UIImage imageNamed:@"doctor_dp_bg.jpg"];
        }
        [self.webView loadHTMLString:[[self.dictResponse objectAtIndex:0]objectForKey:@"desc"] baseURL:nil];
    }
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)specialityButton:(id)sender {
}
@end
