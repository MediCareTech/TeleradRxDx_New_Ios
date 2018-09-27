//
//  SmartRxHsDashBoardVC.m
//  SmartRx
//
//  Created by PaceWisdom on 09/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxHsDashBoardVC.h"
#import "SmartRxSpecialityVC.h"
#import "SmartRxSelectDocLocation.h"
@interface SmartRxHsDashBoardVC ()

@end

@implementation SmartRxHsDashBoardVC

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

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
//    UIBarButtonItem *leftItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icn_back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backBtnClicked:)];
//    self.navigationItem.leftBarButtonItem=leftItem;
    // Do any additional setup after loading the view.
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

-(void)showALertView
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Login Required" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
}

- (IBAction)ipBtnClicked:(id)sender {
}

- (IBAction)contctUsbtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"ContactID" sender:nil];
}
- (IBAction)feedbackBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"FeedBackID" sender:nil];
}
- (IBAction)inquiryBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"EnquiryID" sender:nil];
}
- (IBAction)servicesClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"selLocation" sender:@"ServicesLocation"];
//    [self performSegueWithIdentifier:@"ServicesID" sender:nil];
}

- (IBAction)findDoctorsBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"selLocation" sender:@"Doctor"];
}

- (IBAction)specilalitiesBtnClicked:(id)sender {
    [self performSegueWithIdentifier:@"HsID" sender:@"Spec"];
    
}

- (IBAction)aboutUsClicked:(id)sender
{
    [self performSegueWithIdentifier:@"aboutUs" sender:@"aboutus"];    
}
#pragma mark - Prepare Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"HsID"])
    {
        ((SmartRxSpecialityVC *)segue.destinationViewController).strDocOrSpec=sender;
    }
    if([sender isEqualToString:@"ServicesLocation"])
    {
        ((SmartRxSelectDocLocation *)segue.destinationViewController).fromServices = YES;
    }
    if([sender isEqualToString:@"Doctor"])
    {
        ((SmartRxSelectDocLocation *)segue.destinationViewController).fromServices = NO;
    }
}
@end
