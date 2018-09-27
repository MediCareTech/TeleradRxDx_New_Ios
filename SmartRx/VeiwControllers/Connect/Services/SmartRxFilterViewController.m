//
//  SmartRxFilterViewController.m
//  SmartRx
//
//  Created by Gowtham on 22/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxFilterViewController.h"
#import "ProviderServiesHandler.h"

@interface SmartRxFilterViewController ()
{
    MBProgressHUD *HUD;
    PatientLocationResponseModel *selectedLocation;
}

@property(nonatomic,weak) NSArray *filterTypesArr;
@property(nonatomic,strong) NSArray *locationsArray;
@property(nonatomic,strong) NSArray *typeArray;
@property(nonatomic,strong) NSArray *providersArray;



@end

@implementation SmartRxFilterViewController
-(void)navigationBackButton{
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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Filters";
    [self.tableView setTableFooterView:[UIView new]];
    [self.filterTableView setTableFooterView:[UIView new]];
    self.filterTableView.hidden = YES;
       [self navigationBackButton];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    ProviderServiesHandler *handler = [ProviderServiesHandler sharedInstance];
    self.typeArray = handler.providerServicesArr;
    self.filterTypesArr = [NSArray arrayWithObjects:@"All",@"Type",@"Location",@"Provider Name", nil];
    //self.typeArray= [NSArray arrayWithObjects:@"Labs & Diagnostics",@"Home Care", nil];

    //[self.tableView reloadData];
}
#pragma mark - Action Methods
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Request methods

-(void)makeRquestForPatientLocations{
    
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
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mylocations"];
    
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        
        NSLog(@"sucess 7 %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        } else {
        
        if (response) {
            
            NSArray *array = response[@"mylocations"];
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            for (NSDictionary *dict in array) {
                PatientLocationResponseModel *model = [[PatientLocationResponseModel alloc]init];
                
                model.cityName = dict[@"city"][@"name"];
                model.cityId = dict[@"city"][@"id"];
                if ([dict[@"locality"] isKindOfClass:[NSDictionary class]]) {
                    model.localityName = dict[@"locality"][@"name"];
                    model.localityId = dict[@"locality"][@"id"];
                    model.zoneName = dict[@"locality"][@"zone"][@"name"];
                }
                
                model.addressType = dict[@"type"];
                model.zipcode = dict[@"zipcode"];
                model.address = dict[@"address"];
                model.locationId = dict[@"id"];
                
                [tempArray addObject:model];
                
            }
            self.locationsArray = [tempArray copy];
            
        }
            dispatch_async(dispatch_get_main_queue(),^{
                [self.filterTableView reloadData];
                
            });
        }
        

        
        
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
    
    
}
-(void)makeRquestForProvideNames{
    
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
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"providers/index"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        
        NSLog(@"sucess 7 %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        if (response) {
            
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            
            for (NSDictionary *dict in response) {
                [tempArray addObject:dict[@"dispname"]];
            }
            
            self.providersArray = [tempArray copy];
            dispatch_async(dispatch_get_main_queue(),^{
                [self.filterTableView reloadData];
            });
        }
        
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
#pragma mark - Tableview Delegate/Datasource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count;
    if (tableView == self.tableView) {
        count = self.filterTypesArr.count;
    } else {
        if (self.tableViewType == TypeTableView ) {
            count = self.typeArray.count;
        } else if (self.tableViewType == LocationTableView){
            if (self.locationsArray.count) {
                count = self.locationsArray.count;

            }else {
                count = 1;
            }
        } else {
            count = self.providersArray.count;
        }
    }
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell;
    
    
    if (tableView == self.tableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = self.filterTypesArr[indexPath.row];
        cell.textLabel.numberOfLines = 2;
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"filterCell"];
        if (self.tableViewType == TypeTableView ) {
            cell.textLabel.text = self.typeArray[indexPath.row][@"name"];
        } else if (self.tableViewType == LocationTableView){
            if (self.locationsArray.count) {
        

            PatientLocationResponseModel *model = self.locationsArray[indexPath.row];
            
            NSString *addressStr = [NSString stringWithFormat:@"%@-%@",model.addressType,model.cityName];
            
            cell.textLabel.text = addressStr;
                cell.textLabel.textColor = [UIColor blackColor];

            cell.textLabel.numberOfLines = 2;
            }else {
                cell.textLabel.text = @"+ Add New Location";
                cell.textLabel.textColor = [UIColor blueColor];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            }
        } else {
            
            cell.textLabel.text = self.providersArray[indexPath.row];
        }
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tableView) {
        
        if (indexPath.row == 0) {
            [self.delegate allServicesSelected];
            [self.navigationController popViewControllerAnimated:YES ];            
        } else if(indexPath.row == 1){
            self.tableViewType = TypeTableView;
        } else if(indexPath.row == 2) {
            self.tableViewType = LocationTableView;
        } else if (indexPath.row == 3){
            self.tableViewType = ProviderNameTableView;
        }
        self.filterTableView.hidden = NO;
        [self reloadFilterTableView:self.tableViewType];
    }
    else {
        if (self.tableViewType == TypeTableView) {
            NSString *type = self.typeArray[indexPath.row][@"id"];
            
//            if (indexPath.row == 0) {
//                type = @"3";
//            } else {
//                type = @"5";
//            }
            [self.delegate selectedType:type];
        } else if (self.tableViewType == LocationTableView) {
            if (self.locationsArray.count) {
                
        PatientLocationResponseModel *model = self.locationsArray[indexPath.row];
            [self.delegate selectedLocation:model];
            }else {
                [self performSegueWithIdentifier:@"addNewAddressVc" sender:nil];
                return;
            }
        } else
        {
            
            [self.delegate selectedProvider:self.providersArray[indexPath.row]];
            
        }
        
        [self.navigationController popViewControllerAnimated:YES ];
    }
    
    
}
-(void)reloadFilterTableView:(TableViewTtype)tableView{
    if (tableView == TypeTableView) {
        [self.filterTableView reloadData];
    } else if (tableView == LocationTableView) {
        if (self.locationsArray.count) {
            [self.filterTableView reloadData];
        } else {
            [self makeRquestForPatientLocations];
        }
    } else if (tableView == ProviderNameTableView) {
        if (self.providersArray.count) {
            [self.filterTableView reloadData];
        } else {
            [self makeRquestForProvideNames];
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height ;
    
    
    
    
    if (tableView == self.tableView) {
        if (indexPath.row == 3) {
            height = 55.0f;
        } else {
            height = 44.0f;
            
        }
    } else {
        if (self.tableViewType == LocationTableView) {
            height = 55.0f;

        } else{
            height = 44.0f;
        }
    }
    
    return height;
}
#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRquestForPatientLocations];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}
-(void)errorSectionId:(id)sender
{
   
    self.view.userInteractionEnabled = YES;
}

#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
