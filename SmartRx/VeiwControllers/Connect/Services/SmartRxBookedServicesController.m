//
//  SmartRxBookedServicesController.m
//  SmartRx
//
//  Created by Gowtham on 05/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxBookedServicesController.h"
#import "SmartRxDashBoardVC.h"
#import "BookedServiceResponseModel.h"
#import "SmartRxServicesDetails.h"


@interface SmartRxBookedServicesController ()
{
     MBProgressHUD *HUD;
}

@end

@implementation SmartRxBookedServicesController
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
    self.navigationItem.title = @"Booked Services";
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.hidden = YES;
    self.noServicesLabel.hidden = NO;
    [self navigationBackButton];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self makeRequestForServicesList];
}
#pragma mark - Action Methods

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
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)clcikOnBookNowButton:(id)sender{
    [self performSegueWithIdentifier:@"newServicesBookVC" sender:nil];
}
#pragma mark - Request Methods

-(void)makeRequestForServicesList{
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
   
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"sessionid=%@",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"member_services/index"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO successHandler:^(id response) {
        
        dispatch_async(dispatch_get_main_queue(),^{
            [HUD hide:YES];
            [HUD removeFromSuperview];
            NSLog(@"results........:%@",response);
           // NSArray *array = response[@"provider_services"];
            
            if (response) {
                
                NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dict in response) {
                    
                    BookedServiceResponseModel *model = [[BookedServiceResponseModel alloc]init];
                    model.paymentStatus = dict[@"payment_status_text"];
                    model.serviceName = dict[@"provider_service"][@"name"];
                    model.serviceId = [NSString stringWithFormat:@"%@",dict[@"id"]];
                    model.locationName = dict[@"locstring"];
                    
                    model.isScheduled = [dict[@"provider_service"][@"is_scheduled"] boolValue];
                      model.bookingRecNo = [NSString stringWithFormat:@"%@",dict[@"id"]];
                    model.servicePrice = [NSString stringWithFormat:@"%ld",[dict[@"provider_service"][@"original_price"] integerValue]];
                    
                    model.serviceDiscountprice = [NSString stringWithFormat:@"%ld",[dict[@"current_price"] integerValue]];
                    //model.serviceDiscountprice =[NSString stringWithFormat:@"%ld",[dict[@"provider_service"][@"effective_price"] integerValue]];

                    
                    model.serviceDescription = dict[@"provider_service"][@"description"];
                    model.providerName = dict[@"user"][@"dispname"];
                    model.instructions = dict[@"provider_service"][@"instructions"];
                    
                    int type = [dict[@"provider_service"][@"home_collection"] intValue];
                    if (type == 0) {
                         model.serviceType =@"At Provider location below";
                    } else {
                        model.serviceType =@"Home collection at location below";
                    }
                    
                    //model.serviceType = [NSString stringWithFormat:@"%d",type];
                    model.providerId = [NSString stringWithFormat:@"%ld",[dict[@"id"] integerValue]];
                    model.bookingStatus = dict[@"status_text"];
                    if ([dict[@"scheduled_time"] isKindOfClass:[NSString class]]) {
                        model.scheduledTime = dict[@"scheduled_time"];
                    } else {
                        model.scheduledTime= @"";
                    }
                    
                    model.scheduledDate = [self dateConvertor:dict[@"scheduled_date"]];
                    [tempArray addObject:model];
                    
                }
                self.bookedServiceArray = [tempArray copy];
                
                if (self.bookedServiceArray.count) {
                    self.tableView.hidden = NO;
                    self.noServicesLabel.hidden = YES;

                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.tableView reloadData];
                        
                    });

                } else{
                    self.tableView.hidden = YES;
                    self.noServicesLabel.hidden = NO;

                }
            
               // self.errorLabel.hidden = YES;
                
            } else {
                
               
                
                
            }

        });
        
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        dispatch_async(dispatch_get_main_queue(),^{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading Services list failed. Please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = 9999;
        [alert show];
        });
        
        
    }];
    
}
-(NSString *)dateConvertor:(NSString *)dateStr{
    
    if ([dateStr isKindOfClass:[NSString class]]) {
        
    
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone systemTimeZone];
    [format setTimeZone:gmt];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:SSZ"];
    
    NSDate *date = [format dateFromString:dateStr];
    [format setDateFormat:@"dd MMM yyyy"];
    
    NSString *str = [format stringFromDate:date];
    return str;
    }
    return @"";
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    
}
#pragma mark - Table View Methods
-(CGFloat)estimatedHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, 260,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    //    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(300,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    CGFloat heightLbl=expectedLabelSize.height;
    
    heightLbl = heightLbl+ 128;
    
    return heightLbl;
    
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat cellHeight;
//     BookedServiceResponseModel *model = self.bookedServiceArray[indexPath.row];
//    cellHeight = [self estimatedHeight:model.serviceName];
//    return cellHeight;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.bookedServiceArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BookedServicesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bookedServiceCell"];
    BookedServiceResponseModel *model = self.bookedServiceArray[indexPath.row];
    cell.cellId = indexPath;
    cell.delegate = self;
    cell.detailsButton.layer.borderWidth = 1.0;
    cell.detailsButton.layer.cornerRadius = 6.0;
    cell.detailsButton.layer.masksToBounds = YES;
    cell.serviceNameLbl.text = model.serviceName;
    cell.serviceNameLbl.numberOfLines = 10;
    //[cell.serviceNameLbl sizeToFit];
    cell.statusLbl.text = model.bookingStatus;
    cell.paymentTypeLbl.text = model.paymentStatus;
    if ([model.scheduledTime isEqualToString:@""]) {
        cell.dateTextLbl.hidden = YES;
        cell.timeTextLbl.hidden = YES;
    }else {
        cell.dateTextLbl.hidden = NO;
        cell.timeTextLbl.hidden = NO;
    }
    cell.dateLbl.text = model.scheduledDate;
    cell.timeLbl.text = model.scheduledTime;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
      BookedServiceResponseModel *model = self.bookedServiceArray[indexPath.row];
    [self performSegueWithIdentifier:@"serviceDetailVC" sender:model];
}
-(void)detailButtonClicked:(NSIndexPath *)indexpath{
        BookedServiceResponseModel *model = self.bookedServiceArray[indexpath.row];
    [self performSegueWithIdentifier:@"serviceDescriptionVC" sender:model];
}
-(void)submitButtonClicked:(BookedServiceResponseModel *)model{
    [self performSegueWithIdentifier:@"serviceDetailVC" sender:model];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 9999)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"serviceDescriptionVC"]) {
        SmartRxSErviceDescriptionController *controller = segue.destinationViewController;
        controller.buttonDelegate = self;
        controller.selectedService = sender;
    } else if ([segue.identifier isEqualToString:@"serviceDetailVC"]){
        SmartRxServicesDetails *controller = segue.destinationViewController;
        controller.selectedService = sender;
    }
}


@end
