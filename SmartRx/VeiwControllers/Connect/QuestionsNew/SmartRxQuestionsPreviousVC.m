//
//  SmartRxQuestionsNewVC.m
//  SmartRx
//
//  Created by PaceWisdom on 04/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxQuestionsPreviousVC.h"
#import "QuestionNewTVC.h"
#import "SmartRxQuestionDetailsVC.h"
#import "SmartRxDashBoardVC.h"
#import "NSString+DateConvertion.h"


@interface SmartRxQuestionsPreviousVC ()
{
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    
}

@end

@implementation SmartRxQuestionsPreviousVC

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
#pragma mark - View Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
    self.tblQuestionNew.hidden=YES;
    self.lblNoQes.hidden=YES;
    
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tblQuestionNew addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self.tblQuestionNew setTableFooterView:[UIView new]];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"NewQueAdded"] == YES)
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
            [self makeRequestForNewQuestions];
        else{
            //_arrQuestions=[database fetchQuestionsFromDataBase];
            _arrQuestions=[[SmartRxDB sharedDBManager] fetchPreviousQuestionsFromDataBase];
            _tblQuestionNew.hidden=NO;
            self.lblNoQes.hidden=YES;
            [_tblQuestionNew reloadData];
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"NewQueAdded"];
        }
    }
    else if ([[NSUserDefaults standardUserDefaults]boolForKey:@"QuestionReply"] == YES)
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
            [self makeRequestForNewQuestions];
        else{
            //_arrQuestions=[database fetchQuestionsFromDataBase];
            _arrQuestions=[[SmartRxDB sharedDBManager] fetchPreviousQuestionsFromDataBase];
            _tblQuestionNew.hidden=NO;
            self.lblNoQes.hidden=YES;
            [_tblQuestionNew reloadData];
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"QuestionReply"];
        }
        
    }
    else{
        
        //_arrQuestions=[database fetchQuestionsFromDataBase];
        _arrQuestions=[[SmartRxDB sharedDBManager] fetchPreviousQuestionsFromDataBase];
        NSArray *array = [_arrQuestions valueForKey:@"qid"];
        if ([array containsObject:_strQuid])
        {
            _tblQuestionNew.hidden=NO;
            self.lblNoQes.hidden=YES;
            [_tblQuestionNew reloadData];
        }
        else{
            NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
            if ([networkAvailabilityCheck reachable])
                [self makeRequestForNewQuestions];
            else{
                //_arrQuestions=[database fetchQuestionsFromDataBase];
                _arrQuestions=[[SmartRxDB sharedDBManager] fetchPreviousQuestionsFromDataBase];
                _tblQuestionNew.hidden=NO;
                self.lblNoQes.hidden=YES;
                [_tblQuestionNew reloadData];
            }
        }
    }
//    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
//    if ([networkAvailabilityCheck reachable])
//    {
//        [self makeRequestForNewQuestions];
//    }
//    else{
//        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alertView show];
//        alertView=nil;
//    }
}
-(void)refreshTable
{
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForNewQuestions];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request method
-(void)makeRequestForNewQuestions
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mqa"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 27 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            self.arrQuestions=[response objectForKey:@"qalist"];
            if ([self.arrQuestions count])
                [[SmartRxDB sharedDBManager] savePreviousQuestionsInDataBase:self.arrQuestions];
            dispatch_async(dispatch_get_main_queue(), ^{
        
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                [refreshControl endRefreshing];
                if ([self.arrQuestions count])
                {
                    self.tblQuestionNew.hidden=NO;
                    [self.tblQuestionNew reloadData];
                }
                else{
                    self.lblNoQes.hidden=NO;
                }
                
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}

-(void)addSpinnerView
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
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
#pragma mark - TableView DataSource/Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrQuestions count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"QuestionNewCell";
    QuestionNewTVC *cell=(QuestionNewTVC *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setCellData:[self.arrQuestions copy] :indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:[[self.arrQuestions objectAtIndex:indexPath.row]objectForKey:@"qtitle"],@"title",[[self.arrQuestions objectAtIndex:indexPath.row]objectForKey:@"qdesc"],@"des",[[self.arrQuestions objectAtIndex:indexPath.row]objectForKey:@"modified"],@"time",[[self.arrQuestions objectAtIndex:indexPath.row]objectForKey:@"qid"],@"qid",[[self.arrQuestions objectAtIndex:indexPath.row]objectForKey:@"iscompleted"],@"Answred", [[self.arrQuestions objectAtIndex:indexPath.row]objectForKey:@"qid"],@"qid",[[self.arrQuestions objectAtIndex:indexPath.row]objectForKey:@"askrfeed"],@"askrfeed",nil];
    QuestionNewTVC *cell=(QuestionNewTVC *)[tableView cellForRowAtIndexPath:indexPath];
    [[NSUserDefaults standardUserDefaults]setObject:cell.lblTime.text forKey:@"yestime"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self performSegueWithIdentifier:@"QAdetailsID" sender:dictTemp];
}
#pragma mark - TableView Storyboard Preapare segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"QAdetailsID"]) {
        ((SmartRxQuestionDetailsVC *)segue.destinationViewController).dictQuestionDetails=sender;
    }
}
#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForNewQuestions];
    }
    else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
    }
}
-(void)errorSectionId:(id)sender
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

@end
