//
//  SmartRxViewController.m
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxViewController.h"
#import "SmartRxCommonClass.h"

@interface SmartRxViewController ()
{
    UIActivityIndicatorView *spinner;
}

@end

@implementation SmartRxViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    
    
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForMessageCount];
    }
    else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
    }

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
-(void)makeRequestForMessageCount
{
    
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mmsg"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 34 %@",response);
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            spinner = nil;
            self.view.userInteractionEnabled = YES;
            self.lblMessageCount.text=[NSString stringWithFormat:@"%lu", (unsigned long)[[response objectForKey:@"msg"]count]];
            
        });
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
    }];
}

-(void)addSpinnerView{
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(140,200 , 44, 44);
    [self.view addSubview:spinner];
    spinner.backgroundColor = [UIColor orangeColor];
    [spinner startAnimating];
    self.view.userInteractionEnabled = NO;
}

#pragma mark - Action Methods
- (IBAction)messageButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"Messages" sender:Nil];
}

- (IBAction)hospitalInfoClicked:(id)sender {
    [self performSegueWithIdentifier:@"HospitalInfo" sender:Nil];
}

- (IBAction)logoutButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
