//
//  SmartRxBookedAssessments.m
//  SmartRx
//
//  Created by Gowtham on 02/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxBookedAssessments.h"
#import "SmartRxDashBoardVC.h"
#import "BookedAssessmentsResponseModel.h"
#import "AssesmmentsQuestionResponseModel.h"
#import "AssessmentsCell.h"
#import "SmartRxAssessmentDetailsVc.h"

@interface SmartRxBookedAssessments ()
{
    MBProgressHUD *HUD;
    
}
@property(nonatomic,strong) NSArray *assessmentsArray;
@end

@implementation SmartRxBookedAssessments
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
    self.navigationItem.title = @"Assessments";
    self.noAppsLbl.hidden = YES;
    [self.tableView setTableFooterView:[UIView new]];
    [self navigationBackButton];
    [self makeRequestForAssessments];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Action Methods
-(void)backBtnClicked:(id)sender
{
    if (self.fromVc == nil) {
        [self.navigationController popViewControllerAnimated:YES];

    }else{
        [self homeBtnClicked:nil];
    }
        
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

#pragma mark - Request Methods

-(void)makeRequestForAssessments{
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];

    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&patientid=%@&list_page=%@&patid=%@&type=%@",@"sessionid",sectionId,userId,@"0",userId,@"patAllData"];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mgetpatassessment"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 1 %@",response);
        if (response == nil)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            //[smartLogin makeLoginRequest];
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //self.assessmentsList=[response objectForKey:@"app"];
                [HUD hide:YES];
                [HUD removeFromSuperview];
                
                NSArray *assessments = response[@"generalAssessments"];
                if (![assessments isKindOfClass:[NSArray class]]) {
                    self.tableView.hidden = YES;
                    self.noAppsLbl.hidden = NO;
                    return ;
                }
                NSMutableArray *tempArr = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in assessments) {
                    BookedAssessmentsResponseModel *model = [[BookedAssessmentsResponseModel alloc]init];
                    model.assessmentName = dict[@"assessment"];
                    model.date = [self dateConevter:dict[@"created"]];
                    model.sharedNotes = dict[@"shared_notes"];
                    
                    NSMutableArray *questionArr = [[NSMutableArray alloc]init];
                    NSArray *questions = dict[@"items"];
                    for (NSDictionary *questionDict in questions) {
                        AssesmmentsQuestionResponseModel *question = [[AssesmmentsQuestionResponseModel alloc]init];
                        question.question = questionDict[@"question"];
                        question.answer = questionDict[@"option"];
                        [questionArr addObject:question];
                    }
                    model.questions = [questionArr copy];
                    [tempArr addObject:model];

                }
                self.assessmentsArray = [tempArr copy];
                if (self.assessmentsArray.count) {
                    self.tableView.hidden = NO;
                    self.noAppsLbl.hidden = YES;
                    [self.tableView reloadData];
                }else {
                    self.tableView.hidden = YES;
                    self.noAppsLbl.hidden = NO;
                }

                
                
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Network not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 999;
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];

    
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999 )
    {
        //[self homeBtnClicked:nil];
        [self backBtnClicked:nil];
    }
}
-(NSString *)dateConevter:(NSString *)dateStr{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    //[format setTimeZone:timeZone];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    NSDate *date = [format dateFromString:dateStr];
    [format setDateFormat:@"dd-MMM-yyyy hh:mm a"];
    return [format stringFromDate:date];
}
#pragma mark - Tableview Delegate/Datasource Methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.assessmentsArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AssessmentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    BookedAssessmentsResponseModel *model = self.assessmentsArray[indexPath.row];
    cell.assessmentNameLbl.text = model.assessmentName;
    cell.dateLbl.text = [NSString stringWithFormat:@"completed on %@",model.date];
    return cell;
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BookedAssessmentsResponseModel *model = self.assessmentsArray[indexPath.row];
    [self performSegueWithIdentifier:@"assessmentsDetailVc" sender:model];
    //assessmentsDetailVc
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"assessmentsDetailVc"]) {
        SmartRxAssessmentDetailsVc *controller = segue.destinationViewController;
        controller.selectedAssessment = sender;
    }}


@end
