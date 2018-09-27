//
//  SmartRxSecondOpinionDBVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 24/04/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxSecondOpinionDBVC.h"
#import "SmartRxBookeConsultVC.h"
#import "SmartRxBookAPPointmentVC.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxAppointmentsVC.h"
#import "SmartRxBookeConsultVC.h"

@interface SmartRxSecondOpinionDBVC ()

@end

@implementation SmartRxSecondOpinionDBVC
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
- (void)viewDidLoad {
    [super viewDidLoad];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Second Opinion" controler:self];

    [self.tableView setTableFooterView:[UIView new]];
    [self navigationBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Action Methods

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
#pragma mark - TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"E-Consult";
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"Book Appointment";
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.fromVc != nil) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"secondEconsult" sender:@"2"];
        }else if(indexPath.row == 1){
            [self performSegueWithIdentifier:@"secondAppointment" sender:@"1"];

        }
    }else {
        if (indexPath.row == 0) {
            SmartRxBookeConsultVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"bookEconsultVc"];
           // controller.scheduleType = @"3";
            [self.navigationController pushViewController:controller animated:YES];
            
        }else if(indexPath.row == 1){
            SmartRxAppointmentsVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"bookAppointmentController"];
            controller.scheduleType = @"3";
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"secondEconsult"]){
        SmartRxBookeConsultVC *controller = segue.destinationViewController;
      // controller.scheduleType = sender;
    }else if ([segue.identifier isEqualToString:@"secondAppointment"]) {
        SmartRxBookAPPointmentVC *controller = segue.destinationViewController;
        controller.scheduleType = sender;
    }
}


@end
