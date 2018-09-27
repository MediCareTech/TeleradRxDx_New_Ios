//
//  SmartRxPHRVC.m
//  SmartRx
//
//  Created by Anil Kumar on 03/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxPHRVC.h"
#import "SmartRxPHRDetailsVC.h"
#import "SmartRxDataTVC.h"
#import "SmartRxImageTVC.h"
#import <QuickLook/QuickLook.h>
#import "SmartRxCommonClass.h"
#import "SmartRxCarePlaneSubVC.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"

@interface SmartRxPHRVC ()<ShowImageInMainView, QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    
}

@end

@implementation SmartRxPHRVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _healthMeasures = @[@"BMI",@"Blood Sugar",@"Blood Pressure",@"Pulse",@"Temperature"];
    
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];        
    [self addSpinnerView];
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
    
        if (![HUD isHidden]) {
            [HUD hide:YES];
        }

    // Do any additional setup after loading the view.
}

#pragma mark - Navigation Item methods
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

#pragma mark - Spinner method
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _healthMeasures.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    //Cell text attributes
    [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    
    _phrListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //To customize the separatorLines
    UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cell.frame.size.height-1, _phrListTable.frame.size.width-1, 1)];
    separatorLine.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:separatorLine];
    
    // To bring the arrow mark on right end of each cell.
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    for (int i=0; i<_healthMeasures.count; i++)
    {
        if (indexPath.row == i) {
            cell.textLabel.text = [_healthMeasures objectAtIndex:i];
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
    [dictTemp setObject:[_healthMeasures objectAtIndex:indexPath.row] forKey:@"Title"];
    [dictTemp setObject:@"" forKey:@"phrid"];
    if ([[_healthMeasures objectAtIndex:indexPath.row] isEqualToString:@"BMI"])
    {
        [dictTemp setObject:@"2" forKey:@"firstPickerNoOfComponents"];
        [dictTemp setObject:@"2" forKey:@"secondPickerNoOfComponents"];
        [dictTemp setObject:@"599" forKey:@"firstPickerNumberOfRowsInComponent"];
        [dictTemp setObject:@"599" forKey:@"secondPickerNumberOfRowsInComponent"];
        [dictTemp setObject:@"YES" forKey:@"heightIsSelected"];
        NSMutableArray *firstPickerComponentOneArray = [NSMutableArray arrayWithObject:@[@"Cm", @"Ft"]];
        [dictTemp setObject:firstPickerComponentOneArray forKey:@"firstPickerComponentOneArray"];
        NSMutableArray *secondPickerComponentOneArray = [NSMutableArray arrayWithObject:@[@"Kg", @"Lb"]];
        [dictTemp setObject:secondPickerComponentOneArray forKey:@"secondPickerComponentOneArray"];
        [dictTemp setObject:@"YES" forKey:@"pickerUINeeded"];
        [dictTemp setObject:@"bmi" forKey:@"testString"];
        [dictTemp setObject:@"7" forKey:@"type"];
    }
    else if ([[_healthMeasures objectAtIndex:indexPath.row] isEqualToString:@"Blood Sugar"])
    {
        [dictTemp setObject:@"3" forKey:@"numberOfComponents"];
        [dictTemp setObject:@"599" forKey:@"numberOfRowsInComponent"];
        [dictTemp setObject:@"NO" forKey:@"heightIsSelected"];
        NSMutableArray *componentOneArray = [NSMutableArray arrayWithObject:@[@"mg/dl", @"mmol/L"]];
        [dictTemp setObject:componentOneArray forKey:@"componentOneArray"];
        NSMutableArray *componentTwoArray = [NSMutableArray arrayWithObject:@[@"Fasting",@"Post Breakfast",@"Before Lunch",@"Post Lunch",@"Before dinner",@"Post Dinner",@"Random",@"Insulin",@"Basal Insulin"]];
        [dictTemp setObject:componentTwoArray forKey:@"componentTwoArray"];
        [dictTemp setObject:@"YES" forKey:@"pickerUINeeded"];
        [dictTemp setObject:@"blood_sugar" forKey:@"testString"];
        [dictTemp setObject:@"2" forKey:@"type"];
    }
    else if ([[_healthMeasures objectAtIndex:indexPath.row] isEqualToString:@"Daily Activities"])
    {
        [dictTemp setObject:@"3" forKey:@"numberOfComponents"];
        [dictTemp setObject:@"4" forKey:@"numberOfRowsInComponent"];
        [dictTemp setObject:@"NO" forKey:@"heightIsSelected"];
        NSMutableArray *componentOneArray = [NSMutableArray arrayWithObject:@[@"min", @"hour"]];
        [dictTemp setObject:componentOneArray forKey:@"componentOneArray"];
        NSMutableArray *componentTwoArray = [NSMutableArray arrayWithObject:@[@"BriskWalk",@"Regular Walk",@"Jogging",@"Yoga",@"Aerobics",@"Swimming",@"Cycling",@"Others"]];
        [dictTemp setObject:componentTwoArray forKey:@"componentTwoArray"];
        [dictTemp setObject:@"YES" forKey:@"pickerUINeeded"];
        [dictTemp setObject:@"daily_activity" forKey:@"testString"];
        [dictTemp setObject:@"3" forKey:@"type"];
    }
    else if ([[_healthMeasures objectAtIndex:indexPath.row] isEqualToString:@"Blood Pressure"])
    {
        [dictTemp setObject:@"2" forKey:@"numberOfLabels"];
        [dictTemp setObject:@"Systolic (BP)" forKey:@"label1"];
        [dictTemp setObject:@"Diastolic (BP)" forKey:@"label2"];
        [dictTemp setObject:@"mm/hg" forKey:@"unit"];
        [dictTemp setObject:@"NO" forKey:@"pickerUINeeded"];
        [dictTemp setObject:@"bp_disambiguation" forKey:@"testString"];
        [dictTemp setObject:@"4" forKey:@"type"];
    }
    else if ([[_healthMeasures objectAtIndex:indexPath.row] isEqualToString:@"Pulse"])
    {
        [dictTemp setObject:@"1" forKey:@"numberOfLabels"];
        [dictTemp setObject:@"Pulse" forKey:@"label1"];
        [dictTemp setObject:@"BPM" forKey:@"unit"];
        [dictTemp setObject:@"NO" forKey:@"pickerUINeeded"];
        [dictTemp setObject:@"pulse" forKey:@"testString"];
        [dictTemp setObject:@"5" forKey:@"type"];
        
    }
    else if ([[_healthMeasures objectAtIndex:indexPath.row] isEqualToString:@"Temperature"])
    {
        [dictTemp setObject:@"1" forKey:@"numberOfLabels"];
        [dictTemp setObject:@"Temperature" forKey:@"label1"];
        [dictTemp setObject:@"°F" forKey:@"unit"];
        [dictTemp setObject:@"NO" forKey:@"pickerUINeeded"];
        [dictTemp setObject:@"temperature" forKey:@"testString"];
        [dictTemp setObject:@"6" forKey:@"type"];        
    }
        [dictTemp setObject:@"Add" forKey:@"buttonTextString"];
    
        [self performSegueWithIdentifier:@"PHRDetails" sender:dictTemp];
    
}

#pragma mark - prepareForSegue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PHRDetails"])
    {
        ((SmartRxPHRDetailsVC *)segue.destinationViewController).navigationItem.title = [sender objectForKey:@"Title"];
        ((SmartRxPHRDetailsVC *)segue.destinationViewController).dictPhrDetails = [NSMutableDictionary alloc];
        ((SmartRxPHRDetailsVC *)segue.destinationViewController).dictPhrDetails = sender;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
