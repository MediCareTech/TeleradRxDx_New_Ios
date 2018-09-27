//
//  SmartRxSpecialityVC.m
//  SmartRx
//
//  Created by PaceWisdom on 23/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxSpecialityVC.h"
#import "SmartRxCommonClass.h"
#import "SmartRxSpecialityDetailsVC.h"
#import "SmartRxFindDoctorsVC.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"


@interface SmartRxSpecialityVC ()
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    
}

@end

@implementation SmartRxSpecialityVC

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

#pragma mark - View Life Cyle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self navigationBackButton];
    self.arrTitles=[[NSArray alloc]init];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"])
    {
        
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForSpecialities];
        }
        else{
            self.arrTitles=[[SmartRxDB sharedDBManager] fetchSpecialitiesFromDataBase];
            [self.tblSpeciality reloadData];
        }
    }
    else{
        [self customAlertView:@"Not valid user" Message:@"Please register" tag:0];
    }
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tblSpeciality addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    if ([self.strDocOrSpec isEqualToString:@"Doctor"])
    {
        self.navigationItem.title=@"Find Doctors";
    }
    else
    {
        self.navigationItem.title=@"Specialties";
    }
    [self.tblSpeciality setTableFooterView:[UIView new]];
    
}
-(void)refreshTable
{
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForSpecialities];
    }
    else{
        
        self.arrTitles=[[SmartRxDB sharedDBManager] fetchSpecialitiesFromDataBase];
        [self.tblSpeciality reloadData];
    }
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

#pragma mark - Custom Methods
-(void)makeRequestForSpecialities
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    }
    else{
        bodyText=[NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mspec"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"hi sucess %@",response);
        
        if (([response count] == 0 && [sectionId length] == 0))
        {
            
            [self makeRequestForUserRegister];
        }
        else if([sectionId length] == 0 && [[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            //[self makeRequestForUserRegister];
        }
        else
        {
            if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
            {
                SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                smartLogin.loginDelegate=self;
                [smartLogin makeLoginRequest];
                
            }
            else{
                [[SmartRxDB sharedDBManager] saveSpeciality:[response objectForKey:@"spec"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    self.view.userInteractionEnabled = YES;
                    [refreshControl endRefreshing];
                    self.arrTitles=[response objectForKey:@"spec"];
                    [self.tblSpeciality reloadData];
                });
            }
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
}
-(void)makeRequestForUserRegister
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    
    
    [self addSpinnerView];
    NSString *strMobile=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    NSString *strCode=[[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",strMobile];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"code",strCode]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mregister"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"hey sucess %@",response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            [[NSUserDefaults standardUserDefaults]setObject:strCode forKey:@"code"];
            [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cidd"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [self performSegueWithIdentifier:@"RegisterID" sender:[response objectForKey:@"cid"]];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cid"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                self.arrTitles=[[SmartRxDB sharedDBManager] fetchSpecialitiesFromDataBase];
                if ([self.arrTitles count])
                    [self.tblSpeciality reloadData];
                else
                    [self makeRequestForSpecialities];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            
            
        });
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
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


#pragma mark - TableView Datasource/Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrTitles count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"SpecialCell";
    UITableViewCell *cell=(UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text=[[self.arrTitles objectAtIndex:indexPath.row]objectForKey:@"title"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.strDocOrSpec isEqualToString:@"Doctor"])
    {
        [self performSegueWithIdentifier:@"FindDoctorsId" sender:[[self.arrTitles objectAtIndex:indexPath.row]objectForKey:@"recno"]];
    }
    else
    {
        [self performSegueWithIdentifier:@"SpecialDetailID" sender:[[self.arrTitles objectAtIndex:indexPath.row]objectForKey:@"description"]];
    }
}

#pragma mark - TableView Storyboard Preapare segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SpecialDetailID"]) {
        
        ((SmartRxSpecialityDetailsVC *)segue.destinationViewController).strDescription=sender;
    }
    else if ([segue.identifier isEqualToString:@"FindDoctorsId"]) {
        ((SmartRxFindDoctorsVC *)segue.destinationViewController).strSpecId=sender;
    }
}
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForSpecialities];
    }
    else{

        self.arrTitles=[[SmartRxDB sharedDBManager] fetchSpecialitiesFromDataBase];
        [self.tblSpeciality reloadData];
        
    }
    
    
}
-(void)errorSectionId:(id)sender
{
    NSLog(@"error");
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    self.view.userInteractionEnabled = YES;
}
@end
