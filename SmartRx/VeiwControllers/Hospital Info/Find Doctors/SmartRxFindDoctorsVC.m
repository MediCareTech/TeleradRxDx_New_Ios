//
//  SmartRxFindDoctorsVC.m
//  SmartRx
//
//  Created by PaceWisdom on 09/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxFindDoctorsVC.h"
#import "SmartRxCommonClass.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxBookAPPointmentVC.h"
#import "SmartRxViewDoctorProfile.h"

#define kNoDoctors 1400

@interface SmartRxFindDoctorsVC ()
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    NSString *strRegisterCall;
}

@end

@implementation SmartRxFindDoctorsVC

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
    [self navigationBackButton];
    self.tblFindDoctors.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.arrDoctors = [[NSMutableArray alloc]init];
    self.deleteRowsList = [[NSMutableArray alloc]init];
    self.doctorDict = [[NSMutableDictionary alloc]init];
    self.searchDoctorDict = [[NSMutableDictionary alloc]init];
    self.selectSpecialityArray = [[NSMutableArray alloc]init];
    int tableDataCount = 0;
   

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deptname"
                                                                   ascending:YES] ;
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.dictResponse = [[self.dictResponse sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
    if ([self.dictResponse count])
    {
        for (int i=0; i<[self.specialityArray count]; i++)
        {
            NSMutableArray *doctorArray = [[NSMutableArray alloc]init];
            for (int j=0; j<[self.dictResponse count]; j++)
            {
                if([[[self.specialityArray objectAtIndex:i]objectForKey:@"speciality"] isEqualToString:[[self.dictResponse objectAtIndex:j] objectForKey:@"deptname"]])
                {
                    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                    [tempDict setObject:[[self.dictResponse objectAtIndex:j]objectForKey:@"dispname"] forKey:@"docname"];
                    [tempDict setObject:[[self.dictResponse objectAtIndex:j]objectForKey:@"recno"] forKey:@"docid"];
                    [doctorArray addObject:tempDict];
                    tableDataCount++;
                }
            }
            [self.doctorDict setObject:doctorArray forKey:[[self.specialityArray objectAtIndex:i]objectForKey:@"speciality"]];
        }
    }

    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"speciality"
                                                                   ascending:YES] ;
    NSArray *sortDescriptors1 = [NSArray arrayWithObject:sortDescriptor1];
    self.specialityArray = [[self.specialityArray sortedArrayUsingDescriptors:sortDescriptors1] mutableCopy];
    NSLog(@"doctor data.....:%@",self.doctorDict);
    NSLog(@"specialityArray data.....:%@",self.specialityArray);

    self.tblFindDoctors.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tblFindDoctors reloadData];
    self.searchResult = [NSMutableArray arrayWithCapacity:tableDataCount];
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

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}

#pragma mark - Tableveiw Datasource/Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    return [self.specialityArray count];
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.selectSpecialityArray count];
    }
    return [self.doctorDict count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        for(int i=0; i<[self.searchDoctorDict count]; i++)
        {
            if([[self.selectSpecialityArray objectAtIndex:section] isEqualToString:[[self.dictResponse objectAtIndex:i] objectForKey:@"deptname"]])
            {
                NSString *tempString = [self.selectSpecialityArray objectAtIndex:section];
                NSString *type = NSStringFromClass([[self.searchDoctorDict objectForKey:tempString] class]);
                if([type isEqualToString:@"__NSDictionaryM"])
                {
                    return 1;
                }
                else
                    return [[self.searchDoctorDict objectForKey:tempString] count];
                break;
            }
        }
    }
    else
    {
        NSString *tempString = [[self.specialityArray objectAtIndex:section]objectForKey:@"speciality"];
        return [[self.doctorDict objectForKey:tempString] count];
//        break;

//        for(int i=0; i<[self.doctorDict count]; i++)
//        {
//            if([[[self.specialityArray objectAtIndex:section]objectForKey:@"speciality"] isEqualToString:[[self.dictResponse objectAtIndex:i] objectForKey:@"deptname"]])
//            {
//                NSString *tempString = [[self.specialityArray objectAtIndex:section]objectForKey:@"speciality"];
//                return [[self.doctorDict objectForKey:tempString] count];
//                break;
//            }
//        }
    }
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier=@"CellID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
//    if([[[self.specialityArray objectAtIndex:indexPath.section]objectForKey:@"speciality"] isEqualToString:[[self.dictResponse objectAtIndex:indexPath.row]objectForKey:@"deptname"]])
//    {
        //Cell text attributes
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        
        //To customize the separatorLines
        UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cell.frame.size.height-1, self.tblFindDoctors.frame.size.width-1, 1)];
        separatorLine.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:separatorLine];
    
    // To bring the arrow mark on right end of each cell.
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    cell.imageView.image = [UIImage imageNamed:@"doctor.png"];
    cell.imageView.layer.cornerRadius = 10.0;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        NSString *tempString = [self.selectSpecialityArray objectAtIndex:indexPath.section];
        NSString *type = NSStringFromClass([[self.searchDoctorDict objectForKey:tempString] class]);
        if([type isEqualToString:@"__NSDictionaryM"])
        {
            cell.textLabel.text = [[self.searchDoctorDict objectForKey:tempString] objectForKey:@"docname"];
            cell.imageView.tag =[[[self.searchDoctorDict objectForKey:tempString] objectForKey:@"docid"] integerValue];
        }
        else
        {
            cell.textLabel.text = [[[self.searchDoctorDict objectForKey:tempString]objectAtIndex:indexPath.row]objectForKey:@"docname"];
            cell.imageView.tag =[[[[self.searchDoctorDict objectForKey:tempString]objectAtIndex:indexPath.row]objectForKey:@"docid"] integerValue];
        }
        
    }
    else
    {
        NSString *tempString = [[self.specialityArray objectAtIndex:indexPath.section]objectForKey:@"speciality"];
        cell.textLabel.text = [[[self.doctorDict objectForKey:tempString]objectAtIndex:indexPath.row]objectForKey:@"docname"];
    }
    return cell;
    //    }
//    else
//    {
//        cell.hidden = YES;
//        [cell removeFromSuperview];
//        [self.deleteRowsList addObject:indexPath];
//    }
//    
//    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int indexCount = 0;
    for (int i=0 ; i< indexPath.section;i++)
    {
        indexCount = indexCount + [tableView numberOfRowsInSection:i];
    }
    indexCount = indexCount + indexPath.row;

    BOOL resultFound = NO;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        for (int i=0; i< [self.dictResponse count]; i++)
        {
            if (!resultFound)
            {               
                if ([[[self.dictResponse objectAtIndex:i] objectForKey:@"recno"] integerValue] == [[[tableView cellForRowAtIndexPath:indexPath] imageView]tag])
                {
                    self.dictDoctorDetails = [self.dictResponse objectAtIndex:i];
                    resultFound = YES;
                    break;
                }
            }
        }
    }
    else
    {
        
        self.dictDoctorDetails = [self.dictResponse objectAtIndex:indexCount];
    }
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    
    [self addSpinnerView];
    [self performSegueWithIdentifier:@"doctorDetails" sender:self.dictDoctorDetails];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.selectSpecialityArray objectAtIndex:section];
    }
    return [[self.specialityArray objectAtIndex:section]objectForKey:@"speciality"];
}

#pragma mark - UISearchDisplayDelegate Methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.searchResult removeAllObjects];
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    [tempArray addObject:[self.responseDictionary valueForKey:@"dispname"]];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    
    self.searchResult = [NSMutableArray arrayWithArray: [[tempArray objectAtIndex:0]  filteredArrayUsingPredicate:resultPredicate]];
    NSLog(@"The search resukt %@",self.searchResult);
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (searchString.length< 2) {
        return NO;
    }
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];

    self.searchDoctorDict = [self.searchDoctorDict mutableCopy];
    [self.searchDoctorDict removeAllObjects];
    self.selectSpecialityArray = [self.selectSpecialityArray mutableCopy];
    [self.selectSpecialityArray removeAllObjects];
    NSSet *removeDuplicates = [NSSet setWithArray:self.searchResult];
    self.searchResult = [[removeDuplicates allObjects] mutableCopy];
    self.searchResult = [self.searchResult mutableCopy];
    for (int i=0; i<[self.searchResult count]; i++)
    {
        NSString *temp = @"";
        NSMutableArray *doctorArray = [[NSMutableArray alloc]init];
        for (int j=0; j<[self.dictResponse count]; j++)
        {
            if([[[self.searchResult objectAtIndex:i] lowercaseString] isEqualToString:[[[self.dictResponse objectAtIndex:j] objectForKey:@"dispname"] lowercaseString]])
            {
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                [tempDict setObject:[[self.dictResponse objectAtIndex:j]objectForKey:@"dispname"] forKey:@"docname"];
                [tempDict setObject:[[self.dictResponse objectAtIndex:j]objectForKey:@"recno"] forKey:@"docid"];
                [tempDict setObject:[[self.dictResponse objectAtIndex:j]objectForKey:@"deptname"] forKey:@"deptname"];
//                temp = [[self.dictResponse objectAtIndex:j]objectForKey:@"deptname"];
                [self.selectSpecialityArray addObject:[[self.dictResponse objectAtIndex:j]objectForKey:@"deptname"]];
                [doctorArray addObject:tempDict];
            }
        }
        for (int k=0; k<[doctorArray count];k++)
        {
            temp = [[doctorArray objectAtIndex:k]objectForKey:@"deptname"];
            if ([self.searchDoctorDict objectForKey:temp])
            {
                NSLog(@"classtype:%@",NSStringFromClass([[self.searchDoctorDict objectForKey:temp] class]));
                NSString *type = NSStringFromClass([[self.searchDoctorDict objectForKey:temp] class]);
                if([type isEqualToString:@"__NSDictionaryM"])
                {
                    if (![[[self.searchDoctorDict objectForKey:temp] objectForKey:@"docname"]isEqualToString:[[doctorArray objectAtIndex:k]objectForKey:@"docname"]])
                    {
                        NSMutableArray *arr = [NSMutableArray arrayWithObject:[self.searchDoctorDict objectForKey:temp]];
                        arr = [arr mutableCopy];
                        [arr addObject:[doctorArray objectAtIndex:k]];
                        [self.searchDoctorDict setObject:arr forKey:temp];
                    }
                }
                else
                {
                    for(int s=0;s<[[self.searchDoctorDict objectForKey:temp] count];s++)
                    {
//                        if (![[self.searchDoctorDict objectForKey:temp] containsObject:[[doctorArray objectAtIndex:k]objectForKey:@"docname"]])
                        if (![[[doctorArray objectAtIndex:k]objectForKey:@"docname"] isEqualToString:[[[self.searchDoctorDict objectForKey:temp] objectAtIndex:s] objectForKey:@"docname"]])
                        {
                            NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[self.searchDoctorDict objectForKey:temp]];
                            arr = [arr mutableCopy];
                            [arr addObject:[doctorArray objectAtIndex:k]];
                            [self.searchDoctorDict setObject:arr forKey:temp];
                        }
                    }
                    NSLog(@"success or failure");

                }
            }
            else
                [self.searchDoctorDict setObject:[doctorArray objectAtIndex:k] forKey:temp];
            
        }
    }
    removeDuplicates = [NSSet setWithArray:self.selectSpecialityArray];
    NSLog(@"selectSpecialityArray:%@",self.selectSpecialityArray);
    NSLog(@"searchDoctorDict:%@",self.searchDoctorDict);
    self.selectSpecialityArray = [[removeDuplicates allObjects] mutableCopy];
    self.selectSpecialityArray = [self.selectSpecialityArray mutableCopy];
        
    
    return YES;
}

#pragma mark - Alertview Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kNoDoctors && buttonIndex == 0)
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

#pragma mark - Add Doctor Details

- (void)appointmentButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"bookAppointment" sender:self.dictDoctorDetails];
}
#pragma mark - prepareForSegue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((SmartRxViewDoctorProfile *)segue.destinationViewController).doctorArray = [[NSMutableDictionary alloc] init];
    ((SmartRxViewDoctorProfile *)segue.destinationViewController).doctorArray = sender;
    ((SmartRxViewDoctorProfile *)segue.destinationViewController).dictResponse = self.dictResponse;
    ((SmartRxViewDoctorProfile *)segue.destinationViewController).locationId = self.locationId;
    ((SmartRxViewDoctorProfile *)segue.destinationViewController).locationName = self.locationName;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fromEconsultToDocProfile"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end
