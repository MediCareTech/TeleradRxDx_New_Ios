//
//  SmartRxConnectDBVC.m
//  SmartRx
//
//  Created by PaceWisdom on 09/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxConnectDBVC.h"
#import "SmartRxQuestionsPreviousVC.h"
@interface SmartRxConnectDBVC ()

@end

@implementation SmartRxConnectDBVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
}
#pragma mark - View Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self navigationBackButton];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
    {
        [self contctUsbtnClicked:nil];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)feedbackBtnClicked:(id)sender {
    [self performSegueWithIdentifier:@"FeedBackID" sender:nil];
}

- (IBAction)contctUsbtnClicked:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        [self performSegueWithIdentifier:@"eConsult" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"bookEcon_Direct" sender:nil];
    }
}

- (IBAction)inquiryBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"EnquiryID" sender:nil];
}

- (IBAction)previousQBtnClicked:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        [self performSegueWithIdentifier:@"QuestionPreviousID" sender:nil];
    }
    else
    {
        [self showALertView];
    }
    
}

- (IBAction)newQBtnClicked:(id)sender {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        [self performSegueWithIdentifier:@"QuestionNewID" sender:nil];
    }
    else
    {
        [self showALertView];
    }
   
}

- (IBAction)callBackBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"callBack" sender:nil];    
}

-(void)showALertView
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Login required" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"QuestionPreviousID"])
    {
        ((SmartRxQuestionsPreviousVC *)segue.destinationViewController).strQuid=_strQuid;
        ((SmartRxQuestionsPreviousVC *)segue.destinationViewController).numberOfQuestions=_numberOfQustns;
    }
    
}

@end
