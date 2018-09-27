//
//  SmartRxSettingsVc.m
//  SmartRx
//
//  Created by SmartRx-iOS on 04/04/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxSettingsVc.h"
#import "SettingsCell.h"
#import "SmartRxDashBoardVC.h"

@interface SmartRxSettingsVc ()
@property(nonatomic,strong) NSArray *tableArray;
@property(nonatomic,strong) NSMutableArray *selectedSettings;

@end

@implementation SmartRxSettingsVc
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
    btnFaq.tag=1;
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_add_report.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    
    [btnFaq addTarget:self action:@selector(addEhr:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    // self.navigationItem.rightBarButtonItem = rightbutton;
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Settings" controler:self];

    [self.tableView setTableFooterView:[UIView new]];
    self.tableArray = [NSArray arrayWithObjects:@"Fitbit", nil];
    self.selectedSettings = [[NSMutableArray alloc]init];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"fitbitAccess"]) {
    [self.selectedSettings addObject:@"Fitbit"];
    }
    [self navigationBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark -Fitbit delegate methods
-(void)fitbitUpdate{
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"fitbitAccess"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.selectedSettings addObject:@"Fitbit"];
    [self.tableView reloadData];
}
#pragma mark -Tableview methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.settingTitle.text = self.tableArray[indexPath.row];
    if ([self.selectedSettings containsObject:self.tableArray[indexPath.row]]) {
        cell.checkBox.image = [UIImage imageNamed:@"checked"];
    }else {
        cell.checkBox.image = [UIImage imageNamed:@"unchecked"];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"fitbitAccess"]) {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"fitbitAccess"];
         [self.selectedSettings removeObject:self.tableArray[indexPath.row]];
        [self.tableView reloadData];
    }else {
         [self performSegueWithIdentifier:@"fitbitVc" sender:nil];

    }
//    if ([self.selectedSettings containsObject:self.tableArray[indexPath.row]]) {
//        [self.selectedSettings removeObject:self.tableArray[indexPath.row]];
//    }else {
//        [self.selectedSettings addObject:self.tableArray[indexPath.row]];
//    }
//    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fitbitVc"]) {
        SmartRxFitbitLogin *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}


@end
