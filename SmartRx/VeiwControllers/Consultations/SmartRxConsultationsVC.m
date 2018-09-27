//
//  SmartRxConsultationsVC.m
//  SmartRx
//
//  Created by Manju Basha on 08/05/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxConsultationsVC.h"
#import "SmartRxeConsultVC.h"
#import "SmartRxAppointmentsVC.h"
#import "SmartRxSecondOpinionDBVC.h"

@interface SmartRxConsultationsVC ()

@property(nonatomic,assign) BOOL isExpanded;
@property(nonatomic,strong) NSMutableArray *tableArray;
@property(nonatomic,strong) NSArray *tableExpandArray;
@property(nonatomic,strong) NSArray *tableImagesArr;

@end

@implementation SmartRxConsultationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isExpanded = NO;
    self.tableArray = [[NSMutableArray alloc]init];
    
    
    self.navigationItem.title = @"Services";
    NSArray *tempArr = [NSArray arrayWithObjects:@"E-Consult",@"Appointment",@"Services", nil];;
    
    [self.tableArray addObjectsFromArray:tempArr];
    
    self.tableExpandArray = [NSArray arrayWithObjects:@"E-Consult",@"Appointment",@"Services",@"Book Second Opinion",@"",@"", nil];
    self.tableImagesArr = [NSArray arrayWithObjects:@"eConsult.png",@"calender-Consult.png",@"services_menu.png",@"services_menu.png", nil];
    
    [self navigationBackButton];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
}
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Table view data source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    //Cell text attributes
    [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    
    self.consultationTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //To customize the separatorLines
    UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cell.frame.size.height-1, self.consultationTable.frame.size.width-1, 1)];
    separatorLine.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:separatorLine];
    
    // To bring the arrow mark on right end of each cell.
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.tableArray[indexPath.row];
    if (self.tableImagesArr.count-1 >= indexPath.row) {
        cell.imageView.image = [UIImage imageNamed:self.tableImagesArr[indexPath.row]];
        
    }
    if (indexPath.row > 3) {
        
        [cell setIndentationLevel:2];
        cell.indentationWidth = 25;
        
        float indentPoints = cell.indentationLevel * cell.indentationWidth;
        
        cell.contentView.frame = CGRectMake(indentPoints,cell.contentView.frame.origin.y,cell.contentView.frame.size.width - indentPoints,cell.contentView.frame.size.height);
    }
    
    //    if (indexPath.row == 0)
    //    {
    //        cell.textLabel.text = @"E-Consult";
    //        cell.imageView.image = [UIImage imageNamed:@"eConsult.png"];
    //    }
    //    else if (indexPath.row == 1)
    //    {
    //        cell.textLabel.text = @"Appointment";
    //        cell.imageView.image = [UIImage imageNamed:@"calender-Consult.png"];
    //    }
    //    else if (indexPath.row == 2)
    //    {
    //        cell.textLabel.text = @"Services";
    //        cell.imageView.image = [UIImage imageNamed:@"services_menu.png"];
    //    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        if (indexPath.row == 0)
        {
            if ([self getServiceAvailablity:@"2"]) {
                [self performSegueWithIdentifier:@"eConsultID" sender:nil];
            }else {
                [self customAlertView:@"" Message:@"This service is not availbel for you." tag:0];
            }
        }
        else if (indexPath.row == 1)
        {
            if ([self getServiceAvailablity:@"4"]) {
                [self performSegueWithIdentifier:@"AppointmentsID" sender:nil];
            }else {
                [self customAlertView:@"" Message:@"This service is not availbel for you." tag:0];
            }
        }
        else if (indexPath.row == 2)
        {
            if ([self getServiceAvailablity:@"14"]) {
                [self performSegueWithIdentifier:@"bookedServiceVC" sender:nil];
            }else {
                [self customAlertView:@"" Message:@"This service is not availbel for you." tag:0];
            }
        }else if (indexPath.row == 3){
            
            if ([self getServiceAvailablity:@"13"]) {
                SmartRxSecondOpinionDBVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"secondOpinionDBVc"];
                [self.navigationController pushViewController:controller animated:YES];            }else {
                    [self customAlertView:@"" Message:@"This service is not availbel for you." tag:0];
                }
            
            
            //            if (!self.isExpanded) {
            //                NSMutableArray *arrCells=[NSMutableArray array];
            //
            //                [arrCells addObject:[NSIndexPath indexPathForRow:4 inSection:0]];
            //                [self.tableArray insertObject:@"E-consult" atIndex:4];
            //
            //                [arrCells addObject:[NSIndexPath indexPathForRow:5 inSection:0]];
            //                [self.tableArray insertObject:@"Appointment" atIndex:5];
            //
            //                [self.consultationTable insertRowsAtIndexPaths:arrCells withRowAnimation:UITableViewRowAnimationLeft];
            //                _isExpanded = YES;
            //
            //            }else {
            //                NSMutableArray *arrCells=[NSMutableArray array];
            //                [arrCells addObject:[NSIndexPath indexPathForRow:4 inSection:0]];
            //                [self.tableArray removeObjectAtIndex:4];
            //
            //                [arrCells addObject:[NSIndexPath indexPathForRow:5 inSection:0]];
            //                [self.tableArray removeObjectAtIndex:4];
            //
            //                [self.consultationTable deleteRowsAtIndexPaths:arrCells withRowAnimation:UITableViewRowAnimationLeft];
            //                _isExpanded = NO;
            //
            //
            //            }
        }else if(indexPath.row == 4){
            [self performSegueWithIdentifier:@"eConsultID" sender:@"2"];
        }else if(indexPath.row == 4){
            [self performSegueWithIdentifier:@"AppointmentsID" sender:@"1"];
            
        }
        
    }
    else
    {
        if (indexPath.row == 0)
        {
            if ([self getServiceAvailablity:@"14"]) {
                [self performSegueWithIdentifier:@"bookEcon" sender:nil];
            }else {
                [self customAlertView:@"" Message:@"This service is not availbel for you." tag:0];
            }
        }
        else if (indexPath.row == 1)
        {
            if ([self getServiceAvailablity:@"14"]) {
                [self performSegueWithIdentifier:@"book_App" sender:nil];
            }else {
                [self customAlertView:@"" Message:@"This service is not availbel for you." tag:0];
            }
        }
        else if (indexPath.row == 2)
        {
            if ([self getServiceAvailablity:@"14"]) {
                [self performSegueWithIdentifier:@"book_Serv" sender:nil];
            }else {
                [self customAlertView:@"" Message:@"This service is not availbel for you." tag:0];
            }
        }
    }
}

-(BOOL)getServiceAvailablity:(NSString *)value{
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"enabledServices"];
    NSArray *array = [string componentsSeparatedByString:@"*"];
    if ([array containsObject:value]) {
        return YES;
    }
    return NO;
}
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"eConsultID"]) {
        SmartRxeConsultVC *controller = segue.destinationViewController;
        controller.scheduleType = sender;
    }else  if ([segue.identifier isEqualToString:@"AppointmentsID"]){
        SmartRxAppointmentsVC *controller = segue.destinationViewController;
        controller.scheduleType = sender;
    }
}


@end
