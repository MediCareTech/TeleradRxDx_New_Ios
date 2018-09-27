//
//  SmartRxRecordDashBoardVC.m
//  SmartRx
//
//  Created by Anil Kumar on 03/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxRecordDashBoardVC.h"
#import "SmartRxDataTVC.h"
#import "SmartRxImageTVC.h"
#import <QuickLook/QuickLook.h>
#import "SmartRxCommonClass.h"
#import "SmartRxCarePlaneSubVC.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"

@interface SmartRxRecordDashBoardVC ()<ShowImageInMainView, QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    
}

@end

@implementation SmartRxRecordDashBoardVC

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
    self.navigationItem.hidesBackButton=YES;
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"My Records" controler:self];

    [self navigationBackButton];
    
//    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
//    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
//    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlab"];
//    
//    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
//        NSLog(@"sucess 28 %@",response);
//        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
//        {
//            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
//            smartLogin.loginDelegate=self;
//            [smartLogin makeLoginRequest];
//            
//        }
//
//        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
//        if ([networkAvailabilityCheck reachable])
//        {
//            [self makeRequestForReports];
//        }
//        else{
//            
//            [self customAlertView:@"Network not available" Message:@"" tag:0];
//            
//        }
//        
//    } failureHandler:^(id response) {
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading reports failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        [HUD hide:YES];
//        [HUD removeFromSuperview];
//        
//    }];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFaq.tag=1;
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

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller{
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    //Cell text attributes
    [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];

    self.tblRecordDashBoard.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //To customize the separatorLines
    UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, 60, self.tblRecordDashBoard.frame.size.width-1, 1)];
    separatorLine.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:separatorLine];
    
    // To bring the arrow mark on right end of each cell.
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
 
    if(indexPath.row == 0)
    {
        cell.textLabel.text = @"Personal Health Record (PHR)";
        cell.imageView.image = [UIImage imageNamed:@"chart.png"];
    }
   else if(indexPath.row == 1)
    {
        cell.textLabel.text = @"Reports";
        cell.imageView.image = [UIImage imageNamed:@"lab_reports.png"];
    }else if(indexPath.row == 2)
    {
        cell.textLabel.text = @"EHR";
        cell.imageView.image = [UIImage imageNamed:@"calorie"];
    } else if(indexPath.row == 3)
    {
        cell.textLabel.text = @"Assessments";
        cell.imageView.image = [UIImage imageNamed:@"chart.png"];
    }else if(indexPath.row == 4)
    {
        cell.textLabel.text = @"Care Plans";
        cell.imageView.image = [UIImage imageNamed:@"chart.png"];
    }

    
//    cell.imageView.frame = CGRectMake(10, 10, 32, 32);
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"MyPHRID" sender:nil];
    }
    else if(indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"MyRecordDetailsID" sender:nil];
    }else if(indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"ehrDashBoardVc" sender:nil];
    }else if(indexPath.row == 3)
    {
        [self performSegueWithIdentifier:@"bookedAssessmentsVc" sender:nil];
    }else if(indexPath.row == 4)
    {
        [self performSegueWithIdentifier:@"careplansListVc" sender:nil];
    }
    //careplansListVc
}


#pragma mark - Action Methods

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
#pragma mark - Custom AlertView
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

#pragma mark - Spinner method
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}
#pragma mark - Request methods
-(void)makeRequestForReports
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
}

@end
