//
//  SmartRxTermsConditionsVC.m
//  SmartRx
//
//  Created by PaceWisdom on 09/07/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxTermsConditionsVC.h"

@interface SmartRxTermsConditionsVC ()
{
    MBProgressHUD *HUD;
}

@end

@implementation SmartRxTermsConditionsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addSpinnerView];
        //change
    
    NSString *urlStr = [NSString stringWithFormat:@"%s/%@",kBaseUrlQAImg,@"termsofuse.html"];
   [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - spinner
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}
#pragma mark - Webview Delegates
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
}

- (IBAction)backButtonCliked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
