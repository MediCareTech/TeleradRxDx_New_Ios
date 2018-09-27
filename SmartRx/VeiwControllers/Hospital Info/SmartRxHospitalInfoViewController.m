//
//  SmartRxHospitalInfoViewController.m
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxHospitalInfoViewController.h"

@interface SmartRxHospitalInfoViewController ()

@end

@implementation SmartRxHospitalInfoViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action Methods
- (IBAction)servicesClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"ServicesID" sender:nil];
}

- (IBAction)specialityClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"SpecialityID" sender:nil];
}

- (IBAction)contactUsClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"ContactUsID" sender:nil];
}
@end
