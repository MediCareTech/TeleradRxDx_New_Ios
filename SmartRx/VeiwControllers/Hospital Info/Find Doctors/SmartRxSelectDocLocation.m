//
//  SmartRxSelectDocLocation.m
//  SmartRx
//
//  Created by Anil Kumar on 14/10/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxSelectDocLocation.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxFindDoctorsVC.h"
#import "SmartRxServicesVC.h"
#import "SmartRxOurHospitalsVC.h"
@interface SmartRxSelectDocLocation ()
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    NSString *strLoctionId;
    NSString *locationString;
    NSString *strRegisterCall;
}

@end


@implementation SmartRxSelectDocLocation


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


#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [self navigationBackButton];
    self.arrSpeclist=[[NSMutableArray alloc]init];
    self.arrSpecAndDocResponse = [[NSMutableArray alloc]init];

    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForLocations];
    }
    else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
    }
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tblFindDoctorLocations addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self.tblFindDoctorLocations setTableFooterView:[UIView new]];
    // Do any additional setup after loading the view.
}
-(void)refreshTable
{
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForLocations];
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
#pragma mark - Request
-(void)makeRequestForLocations
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
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"cities/index"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"location";
            [self makeRequestForUserRegister];
        }
        else{
            
//            if (response)
//            {
//                SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
//                smartLogin.loginDelegate=self;
//                [smartLogin makeLoginRequest];
//            }
            //else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    self.view.userInteractionEnabled = YES;
                    
                    if (response == nil)
                    {
                        [self customAlertView:@"" Message:@"Locations Not available" tag:0];
                    }
                    else{
                        self.arrLocations = response;
                       // self.arrLocations=[response objectForKey:@"location"];
                        if ([self.arrLocations count])
                        {
                            strLoctionId=[[self.arrLocations objectAtIndex:0]objectForKey:@"id"];
                            //[self makeRequestForSpecialities];
                            self.arrLoadTbl=[self.arrLocations mutableCopy];
                            [self.tblFindDoctorLocations reloadData];
                        }
                        else{
                            NSLog(@"Not Available");
                        }
                    }
                });
            //}
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
                if ([strRegisterCall isEqualToString:@"location"])
                {
                    [self makeRequestForLocations];
                }
                else if ([strRegisterCall isEqualToString:@"getDocAndSpecilities"])
                {
                    [self makeRequestForDocAndSpecialities:@""];
                }
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


-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

#pragma mark - Tableveiw Datasource/Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrLoadTbl count];
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
    UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cell.frame.size.height-1, self.tblFindDoctorLocations.frame.size.width-1, 1)];
    separatorLine.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:separatorLine];
    
    // To bring the arrow mark on right end of each cell.
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
//    cell.imageView.image = [UIImage imageNamed:@"location.png"];
//    cell.imageView.layer.cornerRadius = 10.0;
    
    cell.textLabel.text = [[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"name"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (![HUD isHidden]) {
//            [HUD hide:YES];
//        }
//        [self addSpinnerView];
//    });
    strLoctionId=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"id"];
    locationString = [[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"name"];
    if (self.fromServices)
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self makeRequestForServiceList:strLoctionId];
    }
    else if (self.fromAboutUs)
        [self performSegueWithIdentifier:@"ourHospitalDesc" sender:[self.arrLoadTbl objectAtIndex:indexPath.row]];
    else
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self makeRequestForDocAndSpecialities:strLoctionId];
    }
}

-(void)makeRequestForServiceList:(NSString *)locationID
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
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"sessionid",sectionId,@"locid",locationID];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",@"cid",strCid,@"locid",locationID,@"isopen",@"1"];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mhoffer"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 3 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                //                [self.arrLoadTbl removeAllObjects];
                [self.arrSpeclist removeAllObjects];
                self.dictResponse = nil;
                self.dictResponse = [[response objectAtIndex:0] objectForKey:@"services"];
                self.arrSpecAndDocResponse = [[response objectAtIndex:0] objectForKey:@"services"];
                
                if ([self.arrSpecAndDocResponse count])
                {
                    [self performSegueWithIdentifier:@"ServicesID" sender:self.arrSpecAndDocResponse];
                }
                else
                {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    
                    // Configure for text only and offset down
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"No Services available in selected Location";
                    hud.labelFont = [UIFont systemFontOfSize:11];
                    hud.margin = 10.f;
                    hud.yOffset = 150.f;
                    hud.removeFromSuperViewOnHide = YES;
                    hud.animationType = MBProgressHUDAnimationFade;
                    [hud hide:YES afterDelay:2];
                    
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}
-(void)makeRequestForDocAndSpecialities:(NSString *)locationID
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
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&cid=%@,type=3",@"sessionid",sectionId,@"city_id",locationID,strCid];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",@"cid",strCid,@"city_id",locationID,@"isopen",@"1"];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlocdoc"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 3 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"getDocAndSpecilities";//@"GetDoctor";
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
//                [self.arrLoadTbl removeAllObjects];
                [self.arrSpeclist removeAllObjects];
                self.dictResponse = nil;
                
                self.dictResponse = [response objectForKey:@"docspec"];
                self.arrSpecAndDocResponse = [response objectForKey:@"docspec"];
                NSString *tempString = @"";
                
                for (int i=0; i< [self.dictResponse count]; i++)
                {
                    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                    tempString = [[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"deptname"];
                    [tempDict setObject:tempString forKey:@"speciality"];
                    [tempDict setObject:[[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"specid"] forKey:@"recNo"];
                    [self.arrSpeclist addObject:tempDict];
                    
                }
                NSSet *removeDuplicates = [NSSet setWithArray:self.arrSpeclist];
                self.arrSpeclist = [[removeDuplicates allObjects] mutableCopy];
                
                self.arrSpeclist = [self.arrSpeclist mutableCopy];
                
                if ([self.arrSpeclist count])
                {
//                    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
//                    [tempDict setObject:strLoctionId forKey:@"locId"];
//                    [tempDict setObject:locationString forKey:@"locName"];
//                    [self.arrSpeclist addObject:tempDict];
                    [self performSegueWithIdentifier:@"selectDoctor" sender:self.arrSpeclist];
                }
                else
                {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    
                    // Configure for text only and offset down
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"No Doctors available for selected Location";
                    hud.labelFont = [UIFont systemFontOfSize:11];
                    hud.margin = 10.f;
                    hud.yOffset = 150.f;
                    hud.removeFromSuperViewOnHide = YES;
                    hud.animationType = MBProgressHUDAnimationFade;
                    [hud hide:YES afterDelay:2];

                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}
#pragma mark - Alertview Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0 && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
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
    if([segue.identifier isEqualToString:@"selectDoctor"])
    {
        
        ((SmartRxFindDoctorsVC *)segue.destinationViewController).specialityArray = [[NSMutableArray alloc] init];
        ((SmartRxFindDoctorsVC *)segue.destinationViewController).specialityArray = sender;
        ((SmartRxFindDoctorsVC *)segue.destinationViewController).locationId = strLoctionId;
        ((SmartRxFindDoctorsVC *)segue.destinationViewController).locationName = locationString;
        ((SmartRxFindDoctorsVC *)segue.destinationViewController).dictResponse = [[NSMutableArray alloc] init];
        ((SmartRxFindDoctorsVC *)segue.destinationViewController).dictResponse = self.arrSpecAndDocResponse;
        ((SmartRxFindDoctorsVC *)segue.destinationViewController).responseDictionary = [[NSMutableDictionary alloc] init];
        ((SmartRxFindDoctorsVC *)segue.destinationViewController).responseDictionary = [self.dictResponse mutableCopy];
    }
    else if([segue.identifier isEqualToString:@"ServicesID"])
    {
        ((SmartRxServicesVC *)segue.destinationViewController).dictResponse = [[NSMutableArray alloc] init];
        ((SmartRxServicesVC *)segue.destinationViewController).dictResponse = self.arrSpecAndDocResponse;
    }
    else if([segue.identifier isEqualToString:@"ourHospitalDesc"])
    {
        ((SmartRxOurHospitalsVC *)segue.destinationViewController).dictData = [[NSMutableDictionary alloc] init];
        ((SmartRxOurHospitalsVC *)segue.destinationViewController).dictData = sender;
    }

}
@end

