//
//  SmartRxAboutUsVC.m
//  SmartRx
//
//  Created by Anil Kumar on 05/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import "SmartRxAboutUsVC.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxServiceDetailsVC.h"
#import "SmartRxSelectDocLocation.h"
#import "SmartRxHospitalDetailsVC.h"
@interface SmartRxAboutUsVC ()
{
    NSArray *staticMenuArray;
    MBProgressHUD *HUD;
    NSString *hospitalName;
}
@end

@implementation SmartRxAboutUsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableAboutUs.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.dictResponse = [[NSMutableArray alloc]init];
    self.dictResponseAbtUs = [[NSMutableArray alloc]init];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"])
    {
        hospitalName = [NSString stringWithFormat:@"About %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"]];
    }
    staticMenuArray = @[hospitalName];
    self.tableCellData = [[NSMutableArray alloc]initWithArray:staticMenuArray];
    self.tableCellData = [self.tableCellData mutableCopy];
    [self makeRequestForAboutUsMenu];
    [self navigationBackButton];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    //    [self makeRequestForAboutUsMenu];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)homeBtnClicked:(id)sender
{
    
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}
- (void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - Request Methods

-(void)makeRequestForAboutUsMenu
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mabout"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                self.dictResponse = [[response objectAtIndex:0] objectForKey:@"about_sections"];
                
                if ([self.dictResponse count])
                {
                    [self addSpinnerView];
                    [self.tableCellData setObject:self.dictResponse atIndexedSubscript:1];
                    [self.tableAboutUs reloadData];
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    
                }
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}

-(void)makeRequestForAboutUsPage
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mhservice"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                [self performSegueWithIdentifier:@"hospitalDesc" sender:response];
                
                self.dictResponseAbtUs = response;
                
                if ([self.dictResponseAbtUs count])
                {
                    [self addSpinnerView];
                    //                    [self.tableCellData setObject:self.dictResponse atIndexedSubscript:1];
                    //                    [self.tableAboutUs reloadData];
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    
                }
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
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
        NSLog(@"sucess 8 %@",response);
        
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
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}

#pragma mark - Tableveiw Datasource/Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    return [self.tableCellData count];
    return [self.dictResponse count]+1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    //To customize the separatorLines
    UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cell.frame.size.height-1, self.tableAboutUs.frame.size.width-1, 1)];
    separatorLine.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:separatorLine];
    
    // To bring the arrow mark on right end of each cell.
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row < 1)
    {
        cell.textLabel.text = [staticMenuArray objectAtIndex:indexPath.row];
    }
    else
    {
        cell.textLabel.text = [[self.dictResponse objectAtIndex:indexPath.row-1] objectForKey:@"title"];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    if (indexPath.row == 0)
    {
        [self makeRequestForAboutUsPage];
    }
    //    else if (indexPath.row == 1)
    //    {
    //        [self performSegueWithIdentifier:@"selectLocation" sender:nil];
    //
    //    }
    else if (indexPath.row >= 1)
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self performSegueWithIdentifier:@"serviceDetails" sender:[self.dictResponse objectAtIndex:indexPath.row-1]];
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
#pragma mark - prepareForSegue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"serviceDetails"])
    {
        ((SmartRxServiceDetailsVC *)segue.destinationViewController).navigationItem.title =  [sender objectForKey:@"title"];
        ((SmartRxServiceDetailsVC *)segue.destinationViewController).dictData = [[NSMutableDictionary alloc] init];
        ((SmartRxServiceDetailsVC *)segue.destinationViewController).dictData = sender;
        ((SmartRxServiceDetailsVC *)segue.destinationViewController).fromAboutUs = YES;
    }
    else if([segue.identifier isEqualToString:@"selectLocation"])
    {
        ((SmartRxSelectDocLocation *)segue.destinationViewController).fromAboutUs = YES;
        ((SmartRxSelectDocLocation *)segue.destinationViewController).fromServices = NO;
    }
    else if ([segue.identifier isEqualToString:@"hospitalDesc"])
    {
        ((SmartRxHospitalDetailsVC *)segue.destinationViewController).navigationItem.title = hospitalName;
        ((SmartRxHospitalDetailsVC *)segue.destinationViewController).dataArray = [[NSMutableArray alloc] init];
        ((SmartRxHospitalDetailsVC *)segue.destinationViewController).dataArray = sender;
        
    }
}

@end
