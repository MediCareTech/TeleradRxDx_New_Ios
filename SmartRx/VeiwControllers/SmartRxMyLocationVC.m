//
//  SmartRxMyLocationVC.m
//  SmartRx
//
//  Created by Gowtham on 14/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxMyLocationVC.h"
#import "PatientLocationResponseModel.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxAddLocationsVC.h"

@interface SmartRxMyLocationVC ()
{
     MBProgressHUD *HUD;
    PatientLocationResponseModel *selectedLocation;
    NSString *titleStr;
}
@property(nonatomic,strong) NSArray *locationsArray;
@end

@implementation SmartRxMyLocationVC
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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"My Locations";
    [self navigationBackButton];

     [self.tableView setTableFooterView:[UIView new]];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self makeRquestForPatientLocations];
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
-(IBAction)clickOnAddNewAddressButton:(id)sender{
    titleStr = @"Add Address";
    [self performSegueWithIdentifier:@"addLocationVC" sender:nil];
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
        
        if (response) {
            
            NSArray *array = response[@"mylocations"];
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            for (NSDictionary *dict in array) {
                PatientLocationResponseModel *model = [[PatientLocationResponseModel alloc]init];
                if ([dict[@"city"] isKindOfClass:[NSDictionary class]]) {
                    model.cityName = dict[@"city"][@"name"];
                    model.cityId = dict[@"city"][@"id"];
                }
                
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
            dispatch_async(dispatch_get_main_queue(),^{
                 [self.tableView reloadData];
            });
           
            if (self.locationsArray.count) {
                self.tableView.hidden = NO;
                self.errorLabel.hidden = YES;
            } else {
                self.tableView.hidden = YES;
                self.errorLabel.hidden = NO;
            }
            
            
        }
        
        
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
    
    
}
-(void)makeRequestForDeleteLocation{
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&city_id=%@&lname=%@&address=%@&latitude=%@&longitude=%@&locality_id=%@&zipcode=%@&cid=%@&uid=%@&isopen=1&mode=delete&mylocid=%@",@"sessionid",sectionId,selectedLocation.cityId,selectedLocation.addressType,selectedLocation.address,@"",@"",selectedLocation.localityId,selectedLocation.zipcode,strCid,userId,selectedLocation.locationId];
    }
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"savelocations"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        
        NSLog(@"sucess 68 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            NSLog(@"failure");
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                
                if ([response[@"authorized"] integerValue] == 1 && [response[@"result"] integerValue] == 1) {
                    [self makeRquestForPatientLocations];
                    [self customAlertView:@"Deleted Succesfully" Message:@"" tag:1];
                    
                } else {
                    [self customAlertView:@"Some error occured" Message:@"Try again" tag:0];
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

-(void)addSpinnerView{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - TableView Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.locationsArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];
    cell.delegate = self;
    cell.cellId=indexPath;
    PatientLocationResponseModel *model = self.locationsArray[indexPath.row];
    cell.addressTypeLbl.text = model.addressType;
     cell.addressLbl.text=@"";
    NSString *addressStr = @"";
    
    if (![model.address isEqualToString:@""]) {
        addressStr = [addressStr stringByAppendingString:[NSString stringWithFormat:@"%@,",model.address]];
    }
    if ([model.localityName isKindOfClass:[NSString class]]) {
        addressStr = [addressStr stringByAppendingString:[NSString stringWithFormat:@"%@,%@",model.localityName,model.zoneName]];
        
    }
    cell.addressLbl.text = addressStr;

    NSString *cityStr = model.cityName;
    NSString *fullStr = [NSString stringWithFormat:@"%@%@%@",cityStr,@"-",model.zipcode];
    cell.cityLbl.text = fullStr;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PatientLocationResponseModel *model = self.locationsArray[indexPath.row];
    titleStr = @"Edit Address";

    [self performSegueWithIdentifier:@"addLocationVC" sender:model];
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 117.0f;
}
-(void)deleteButtonClicked:(NSIndexPath *)indexpath{
    selectedLocation = self.locationsArray[indexpath.row];
    [self makeRequestForDeleteLocation];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addLocationVC"]) {
        SmartRxAddLocationsVC *controller = segue.destinationViewController;
        controller.selectedLocationModel = sender;
        controller.titleStr = titleStr;
    }
}


@end
