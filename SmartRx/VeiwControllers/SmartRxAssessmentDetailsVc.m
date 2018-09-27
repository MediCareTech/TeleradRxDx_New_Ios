//
//  SmartRxAssessmentDetailsVc.m
//  SmartRx
//
//  Created by Gowtham on 02/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxAssessmentDetailsVc.h"
#import "SmartRxDashBoardVC.h"
#import "AssessmentsQuestionsCell.h"
#import "AssessmentsQuestionsCell.h"

@interface SmartRxAssessmentDetailsVc ()
@property(nonatomic,strong)NSArray *questionsArr;
@end

@implementation SmartRxAssessmentDetailsVc
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
    //self.navigationItem.title = self.selectedAssessment.assessmentName;
    [[SmartRxCommonClass sharedManager] setNavigationTitle:self.selectedAssessment.assessmentName controler:self];
    NSLog(@"shared note:%@",self.selectedAssessment.sharedNotes);
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.estimatedRowHeight = 1000;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.questionsArr = self.selectedAssessment.questions;
    [self navigationBackButton];

    // Do any additional setup after loading the view.
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
#pragma mark - Tableview Delegate/Datasource Methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.row == self.questionsArr.count) {
        height = [self estimatedHeight:self.selectedAssessment.sharedNotes];
        
    }else {
      
        
        AssesmmentsQuestionResponseModel *model = self.questionsArr[indexPath.row];
        height = [self estimatedHeight:model.question];
        
    }
    return height;
    
}
-(CGFloat)estimatedHeight:(NSString *)strToCalCulateHeight
{
    strToCalCulateHeight = [strToCalCulateHeight stringByAppendingString:@"Submitted to : "];
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, self.view.frame.size.width-45,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    //    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width-45,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    CGFloat heightLbl=expectedLabelSize.height;
    
    heightLbl = heightLbl+ 40;
    
    return heightLbl;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    if ([self.selectedAssessment.sharedNotes isEqual:[NSNull null]]) {
        count = self.questionsArr.count;

    }
    else if ([self.selectedAssessment.sharedNotes isEqualToString:@""]) {
        count = self.questionsArr.count;
        
    }else {

        count = self.questionsArr.count+1;

    }
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AssessmentsQuestionsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (indexPath.row == self.questionsArr.count) {
        cell.textLabel.text = [NSString stringWithFormat:@"Notes: %@",self.selectedAssessment.sharedNotes];;
        [cell.textLabel sizeToFit];
        cell.textLabel.numberOfLines = 100;
        cell.detailTextLabel.text = @"";

    }else{
        AssesmmentsQuestionResponseModel *model = self.questionsArr[indexPath.row];
        cell.textLabel.text = model.question;
        [cell.textLabel sizeToFit];
        cell.textLabel.numberOfLines = 5;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"\n%@",model.answer];
        [cell.detailTextLabel sizeToFit];
        cell.detailTextLabel.numberOfLines = 5;
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    }
    return cell;
    
    
}


    

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SmartRxAssessmentDetailsVc"]) {
        SmartRxAssessmentDetailsVc *controller = segue.destinationViewController;
        controller.selectedAssessment = sender;
    }
}
*/

@end
