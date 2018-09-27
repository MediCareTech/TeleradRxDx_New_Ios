//
//  SmartRxManagedCarePlanServiceDetailsVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 15/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxManagedCarePlanServiceDetailsVC.h"
#import "AssignedManagedCarePlanDetailsCell.h"
#import "SmartRxCartViewController.h"


@interface SmartRxManagedCarePlanServiceDetailsVC ()
{
    MBProgressHUD *HUD;
    
}
@property(nonatomic,strong) NSArray *serviceArray;

@end

@implementation SmartRxManagedCarePlanServiceDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setTableFooterView:[UIView new]];
    self.serviceArray = self.selectedCarePlan.serviceDetailsArray;
    if (self.serviceArray.count < 1) {
        self.noAppsLbl.hidden = NO;
    }else{
        self.noAppsLbl.hidden = YES;

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Request Methods
-(void)makeRequestForServiceDetails:(NSString *)serviceId{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&id=%@",@"sessionid",sectionId,serviceId];
    NSLog(@"bodyText........:%@",bodyText);
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrlLabReport,@"provider_services/view"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"response........:%@",response);

        if (response == nil)
        {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            [self customAlertView:@"" Message:@"Internal server error" tag:0];
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                NSDictionary *dict = (NSDictionary *)(response);
                ServicesResponseModel *model = [[ServicesResponseModel alloc]init];
                model.serviceName = dict[@"name"];
                model.serviceId = dict[@"user"][@"recno"];
                //model.serviceprice = [NSString stringWithFormat:@"%ld",[dict[@"price"] integerValue]];
                model.serviceprice = [NSString stringWithFormat:@"%ld",[dict[@"original_price"] integerValue]];
                model.servicediscountprice =@"0";
                
                // model.servicediscountprice = [self discountCalculation:dict[@"discount"]  ActualPrice:model.serviceprice];
                
                model.serviceDescription = dict[@"description"];
                model.providerName = dict[@"user"][@"dispname"];
                model.instructions = dict[@"instructions"];
                model.imagePath = dict[@"user"][@"logo_path"];
                model.isScheduled = YES;
                
                //model.isScheduled = [dict[@"is_scheduled"] boolValue];
                int type = [dict[@"service_type"] intValue];
                
                model.serviceType = [NSString stringWithFormat:@"%d",type];
                model.providerId = [NSString stringWithFormat:@"%ld",[dict[@"id"] integerValue]];
                
                model.providerServiceId = [NSString stringWithFormat:@"%d",[dict[@"user"][@"recno"] integerValue]];
                
                int locationType = [dict[@"home_collection"] intValue];;
                model.serviceLocation  = [NSString stringWithFormat:@"%d",locationType];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [self.delegate moveToServiceViewController:model];
                }];

               
            });
        }
    }failureHandler:^(id response) {
        
        NSLog(@"failure %@",response);
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Network not available." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
}
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - Action Methods
-(IBAction)clickCloseBtn:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Tableview Delegate/Datasource Methods
-(CGFloat)estimatedHeight:(NSString *)strToCalCulateHeight
{
    CGSize size=[[UIScreen mainScreen]bounds].size;
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
    AssignedManagedCareplanServiceResponse * model = self.serviceArray[indexPath.row];
    CGFloat height = [self estimatedHeight:model.serviceName];
    return height;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.serviceArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AssignedManagedCarePlanDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    AssignedManagedCareplanServiceResponse * model = self.serviceArray[indexPath.row];
    
    cell.careProgramProperty.text = model.serviceName;
    cell.careProgramProperty.numberOfLines = 5;
    cell.careProgramTotal.text = [NSString stringWithFormat:@"%@",model.serviceTotal];
    cell.careProgramAvailable.text = [NSString stringWithFormat:@"%@",model.serviceAvailable];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"didSelectRowAtIndexPath");

    if (![self getExpireDate:self.selectedCarePlan.expireDate]) {
        NSLog(@"getExpireDate");
    AssignedManagedCareplanServiceResponse *model = self.serviceArray[indexPath.row];
    if ([model.serviceAvailable integerValue] > 0) {
        NSString *creditSettings = [[NSUserDefaults standardUserDefaults] objectForKey:@"creditSettings"];
        if ([creditSettings integerValue] == 0) {
            [self showAlert:@"Credits are not available to book service."];
        }else {
            [self makeRequestForServiceDetails:model.serviceId];
        }
    }
    }
    
}
-(BOOL)getExpireDate:(NSString *)dateStr{
    
    NSLog(@"getExpireDate:%@",dateStr);
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    NSDate *date = [formatter dateFromString:dateStr];
    NSLog(@"getExpireDate date:%@",date);
    NSComparisonResult result = [date compare:[NSDate date]];
    BOOL value ;
    if (result == NSOrderedAscending || result == NSOrderedSame) {
        value = YES;
        NSLog(@"NSOrderedAscending");
    }else{
        NSLog(@"NSOrderedDecending");
        value = NO;
    }
    return value;
}
-(void)showAlert:(NSString *)message{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error!" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:okAction];
    [self presentViewController:controller animated:YES completion:nil];
    controller.view.tintColor = [UIColor blueColor];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
