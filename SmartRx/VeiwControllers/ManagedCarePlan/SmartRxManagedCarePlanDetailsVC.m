//
//  SmartRxManagedCarePlanDetailsVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 14/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxManagedCarePlanDetailsVC.h"
#import "SmartRxDashBoardVC.h"
#import "AssignedManagedCarePlanDetailsCell.h"
#import "AssignedCarePlanDetailsResponse.h"
#import "SmartRxManagedCarePlanServiceDetailsVC.h"
#import "SmartRxCartViewController.h"
#import "ResponseModels.h"
#import "SmartRxCarePlaneSubVC.h"

@interface SmartRxManagedCarePlanDetailsVC ()<ServiceDelegate>
{
    CGSize viewSize;
}
@property(nonatomic,strong) NSArray *titlesArray;
@property(nonatomic,strong) NSArray *tableArray;

@end

@implementation SmartRxManagedCarePlanDetailsVC
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
    [[SmartRxCommonClass sharedManager] setNavigationTitle:self.selectedCarePlan.packageName controler:self];
    [self.tableView setTableFooterView:[UIView new]];
    [self.carePlanTableView setTableFooterView:[UIView new]];
    viewSize=[[UIScreen mainScreen]bounds].size;
    self.titlesArray = [NSArray arrayWithObjects:@"Detailed Assessments",@"Health Coach Follow ups(phone/email/chat/sms)",@"Care plans",@"Care manager assistance",@"Chat with care team",@"Continuous monitoring",@"Weekly & monthly newsletters, Health recipes & Stress busters",@"E-Consult",@"Second Opinion",@"Mini Health Check",@"Diagnostic / Lab Tests", nil];
    [self dataSetUp];
    [self navigationBackButton];

}
-(void)dataSetUp{
    
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < self.titlesArray.count ; i++) {
        AssignedCarePlanDetailsResponse * model = [[AssignedCarePlanDetailsResponse alloc]init];
        if ([self.titlesArray[i] isEqualToString:@"Detailed Assessments"]) {
            model.title = self.titlesArray[i];
            model.available = self.selectedCarePlan.detailedAssessmentsAvailable;
            model.total = self.selectedCarePlan.detailedAssessments;
        } else if ([self.titlesArray[i] isEqualToString:@"Health Coach Follow ups(phone/email/chat/sms)"]) {
            model.title = self.titlesArray[i];
            model.total = self.selectedCarePlan.healthCoachFollowUps;
            model.available = self.selectedCarePlan.healthCoachFollowUpsAvailable;
        }else if ([self.titlesArray[i] isEqualToString:@"Care plans"]) {

            if (self.selectedCarePlan.carePlansArray.count > 0) {
                model.title = @"Care plans \n (Details)";
            }else {
                model.title = self.titlesArray[i];
            }
          //  model.title = self.titlesArray[i];
            model.total = self.selectedCarePlan.careplans;
            model.available = self.selectedCarePlan.careplansAvailable;
        }else if ([self.titlesArray[i] isEqualToString:@"Customised health plan"]) {
            model.title = self.titlesArray[i];
            if ([self.selectedCarePlan.customisedHealthPlan integerValue] == 1) {
                model.total = @"YES";
                model.available = @"YES";
            }else {
                model.total = @"NO";
                model.available = @"NO";
            }
           
        }else if ([self.titlesArray[i] isEqualToString:@"Care manager assistance"]) {
            model.title = self.titlesArray[i];
            if ([self.selectedCarePlan.careManagerAssistance integerValue] == 1) {
                model.total = @"YES";
                model.available = @"YES";
            }else {
                model.total = @"NO";
                model.available = @"NO";
            }
            
        }
        else if ([self.titlesArray[i] isEqualToString:@"Chat with care team"]) {
            model.title = self.titlesArray[i];

            if ([self.selectedCarePlan.ChatWithCareTeam integerValue] == 1) {
                model.total = @"YES";
                model.available = @"YES";
            }else {
                model.total = @"NO";
                model.available = @"NO";
            }
            
        }else if ([self.titlesArray[i] isEqualToString:@"Continuous monitoring"]) {
            model.title = self.titlesArray[i];

            if ([self.selectedCarePlan.continuousMonitoring integerValue] == 1) {
                model.total = @"YES";
                model.available = @"YES";
            }else {
                model.total = @"NO";
                model.available = @"NO";
            }
            
        }
        else if ([self.titlesArray[i] isEqualToString:@"Weekly & monthly newsletters, Health recipes & Stress busters"]) {
            model.title = self.titlesArray[i];

                if ([self.selectedCarePlan.newsletters integerValue] == 1) {
                    model.total = @"YES";
                    model.available = @"YES";
                }else {
                    model.total = @"NO";
                    model.available = @"NO";
                }
        }
        else if ([self.titlesArray[i] isEqualToString:@"E-Consult"]) {
                model.title = self.titlesArray[i];
            model.total = self.selectedCarePlan.econsults;
            model.available = self.selectedCarePlan.econsultsAvailable;
        }
        else if ([self.titlesArray[i] isEqualToString:@"Second Opinion"]) {
            model.title = self.titlesArray[i];
            model.total = self.selectedCarePlan.secondOpinion;
            model.available = self.selectedCarePlan.secondOpinionAvailable;
        }else if ([self.titlesArray[i] isEqualToString:@"Mini Health Check"]) {
            model.title = self.titlesArray[i];
            model.total = self.selectedCarePlan.miniHealthCheck;
            model.available = self.selectedCarePlan.miniHealthCheckAvailable;
        }else if ([self.titlesArray[i] isEqualToString:@"Diagnostic / Lab Tests"]) {
            model.title = self.titlesArray[i];
            model.total = @"Show";
            model.available = @"";
        }
        [tempArr addObject:model];
        
    }
    self.tableArray = [tempArr copy];
    dispatch_async(dispatch_get_main_queue(),^{
        [self.tableView reloadData];
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Servvide Delegate Methods

-(void)moveToServiceViewController:(ServicesResponseModel *)model{
    
    SmartRxCartViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"cartViewController"];
    controller.selectedService = model;
    [self.navigationController pushViewController:controller animated:YES];
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
-(IBAction)clickOnCloseBtn:(id)sender{
    [self hideItemsView];
}
-(void)showItemsView{
    [UIView animateWithDuration:0.2 animations:^{
        self.carePlanSubView.frame=CGRectMake(0,  self.carePlanSubView.frame.origin.y,  self.carePlanSubView.frame.size.width,  self.carePlanSubView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}
-(void)hideItemsView{
    [UIView animateWithDuration:0.2 animations:^{
        self.carePlanSubView.frame=CGRectMake(viewSize.width,  self.carePlanSubView.frame.origin.y,  self.carePlanSubView.frame.size.width,  self.carePlanSubView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}
#pragma mark - Tableview Delegate/Datasource Methods
-(CGFloat)estimatedHeight:(NSString *)strToCalCulateHeight
{
    CGSize size = [[UIScreen mainScreen]bounds].size;
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, self.view.frame.size.width-160,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    //    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width-160,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    CGFloat heightLbl=expectedLabelSize.height;
    heightLbl = heightLbl+ 40;
    
    return heightLbl;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if(tableView == self.tableView) {
        AssignedCarePlanDetailsResponse * model = self.tableArray[indexPath.row];
         height = [self estimatedHeight:model.title];
    }
    else {
        height = 44.0f;
    }
   
    return height;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = self.selectedCarePlan.carePlansArray.count;
    if(tableView == self.tableView) {
        count = self.tableArray.count;
    }else {
        count = self.selectedCarePlan.carePlansArray.count;
    }
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
    AssignedManagedCarePlanDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    AssignedCarePlanDetailsResponse * model = self.tableArray[indexPath.row];

    cell.careProgramProperty.text = model.title;
    cell.careProgramProperty.numberOfLines = 5;
    cell.careProgramTotal.text = [NSString stringWithFormat:@"%@",model.total];
    cell.careProgramAvailable.text = [NSString stringWithFormat:@"%@",model.available];
        if ([model.title isEqualToString:@"Care plans \n (Details)"]) {
            NSMutableAttributedString *text =
            [[NSMutableAttributedString alloc]
             initWithString:@"Care plans \n (Details)"];
            NSRange range = [model.title rangeOfString:@"(Details)"];
            [text addAttribute:NSForegroundColorAttributeName
                         value:[UIColor redColor]
                         range:range];
            cell.careProgramProperty.attributedText = text;
        }
    if (self.tableArray.count-1 == indexPath.row) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
        UILabel *titleLbl = [cell viewWithTag:100];
        UILabel *detailLbl = [cell viewWithTag:101];

        titleLbl.text = model.title;
        detailLbl.text = @"Show Details";
        detailLbl.textColor = [UIColor redColor];
        return cell;
        
    }
    return cell;
    }else {
        UITableViewCell *itemsCell = [tableView dequeueReusableCellWithIdentifier:@"itemsCell"];
        CareWellnessCarePlansResponseModel *carePlan =self.selectedCarePlan.carePlansArray[indexPath.row];
        itemsCell.textLabel.text = carePlan.carePlanName;
        
        return itemsCell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        
    if (self.tableArray.count-1 == indexPath.row) {
        [self performSegueWithIdentifier:@"assignedCareplanServiceDetailsVc" sender:nil];
    }
    AssignedManagedCarePlanDetailsCell *cell=(AssignedManagedCarePlanDetailsCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell.careProgramProperty.text isEqualToString:@"Care plans \n (Details)"]) {
        [self showItemsView];
    }
    }else {
        CareWellnessCarePlansResponseModel *carePlan =self.selectedCarePlan.carePlansArray[indexPath.row];
//           NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:carePlan.careId,@"careid",carePlan.careId,@"Title", nil];
        SmartRxCarePlaneSubVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"carePlanSubVc"];
        controller.strOpId = carePlan.careId;
        controller.strTitle = carePlan.carePlanName;
        [self.navigationController pushViewController:controller animated:YES];
    }
    

    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"assignedCareplanServiceDetailsVc"]) {
        SmartRxManagedCarePlanServiceDetailsVC *controller = segue.destinationViewController;
        controller.selectedCarePlan = self.selectedCarePlan;
        controller.delegate = self;
    }
}


@end
