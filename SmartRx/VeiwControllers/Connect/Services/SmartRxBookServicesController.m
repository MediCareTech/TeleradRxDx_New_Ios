//
//  SmartRxBookServicesController.m
//  SmartRx
//
//  Created by Gowtham on 12/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxBookServicesController.h"
#import "SmartRxCommonClass.h"
#import "ServicesResponseModel.h"
#import "SmartRxCartViewController.h"
#import "UIBarButtonItem+Badge.h"
#import "SmartRxAppDelegate.h"
#import "SmartRxDB.h"
#import "UsersResponseModel.h"
#import "UIImageView+WebCache.h"


@interface SmartRxBookServicesController ()
{
    MBProgressHUD *HUD;
    int totalPages;
    int currentPage;
    BOOL isSeraching;
    NSString *postString,*seacrhPostString;
    UsersResponseModel *selectedUser;
    CGSize viewSize;

}

@property(nonatomic,strong) NSMutableArray *servicesArray;
@property(nonatomic,strong) NSArray *servicesListArray;
@property(nonatomic,strong) NSArray *searchedArray;
@property (strong, nonatomic) NSTimer * searchTimer;
@property(nonatomic,strong) NSArray *usersList;


@end

@implementation SmartRxBookServicesController
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
    
    UIImage *image = [UIImage imageNamed:@"cart"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,image.size.width, image.size.height);
    [button addTarget:self action:@selector(cartButtonPress:) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    // Make BarButton Item
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = navLeftButton;
    self.navigationItem.rightBarButtonItem.badgeValue = @"1";
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.tableView registerClass:[SmartRxBookServiceCell class] forCellReuseIdentifier:@"serviceBookCell"];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UName"] length] >0)
    {
        self.patientnameTF.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"UName"];
       
    }

    
    currentPage = 1;
    self.errorLabel.hidden = YES;
    [self.view addSubview:self.detailContainerView];
    [self.view bringSubviewToFront:self.detailContainerView];
   // self.searchImage.image = [UIImage imageNamed:@"search"];
    [self hideDetailContainerView];
    [self navigationBackButton];
    self.servicesArray = [[NSMutableArray alloc]init];
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
     viewSize = [UIScreen mainScreen].bounds.size;
    
    _actionSheet = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    _actionSheet.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = _actionSheet.bounds;
    [_actionSheet addSubview:backgroundView];
    
    self.patientsPicker = [[UIPickerView alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    [UIPickerView setAnimationDelegate:self];
    self.patientsPicker.delegate = self;
    self.patientsPicker.dataSource = self;
    self.patientsPicker.backgroundColor = [UIColor whiteColor];
    
    
    [self.searchTF addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    
    [self postBodyCreation];
    [self makeRequestForUsersList];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [[SmartRxDB sharedDBManager] fetchCartItems];
    SmartRxAppDelegate *appdelegate  = (SmartRxAppDelegate *)[UIApplication sharedApplication].delegate;
    self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)appdelegate.cartCount];
    
}
-(void)postBodyCreation{
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    postString = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
  
    if (self.selectedProviderId != nil && self.selectedServiceId != nil) {
        NSLog(@"postBodyCreation2");
        postString = [NSString stringWithFormat:@"%@=%@&service_type=%@&filter_provider=%@",@"sessionid",sectionId,self.selectedServiceId,self.selectedProviderId];
    }
   else  if (self.selectedServiceId != nil) {
        NSLog(@"postBodyCreation");
        postString = [NSString stringWithFormat:@"%@=%@&service_type=%@",@"sessionid",sectionId,self.selectedServiceId];
    }else if (self.selectedProviderId != nil && ![self.selectedProviderId isEqualToString:@"All"]){
        NSLog(@"postBodyCreation1");
        postString = [NSString stringWithFormat:@"sessionid=%@&filter_provider=%@",sectionId,self.selectedProviderId];
    }
     [self makeRequestForServicesList:currentPage loader:NO];
}
#pragma mark - Action methods
-(void)backBtnClicked:(id)sener
{
    //[self hideKeyboardBtnClicked:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)cartButtonPress:(id)sender
{
    [self performSegueWithIdentifier:@"CheckOutVC" sender:nil];
    NSLog(@"%@",@"button pressed");
}
-(void)cancelButtonPressed:(id)sender
{
    _actionSheet.hidden = YES;
}
-(void)doneButtonPressed:(id)sender
{
    selectedUser = [ self.usersList objectAtIndex:[self.patientsPicker selectedRowInComponent:0]];
    self.patientnameTF.text = selectedUser.patientName;
    _actionSheet.hidden = YES;

}
-(void)cellSubmitButtonClicked:(NSIndexPath *)inddexPath{
    ServicesResponseModel *model ;
    if (isSeraching) {
        model   = self.searchedArray[inddexPath.row];
        
    }else {
        model   = self.servicesArray[inddexPath.row];
    }
    //ServicesResponseModel *model = self.servicesArray[inddexPath.row];
    [self performSegueWithIdentifier:@"cartVc" sender:model];
}
-(IBAction)filterButtonClicked:(id)sender{
    [self.view endEditing:YES];
    [self performSegueWithIdentifier:@"filterVc" sender:nil];
}
-(IBAction)clickOnPatientsButton:(id)sender{
   // [self loadPicker];
}
-(void)cancelButtonClicked{
    [self hideDetailContainerView];
}
-(void)submitButtonClicked:(ServicesResponseModel *)model{
    [self performSegueWithIdentifier:@"cartVc" sender:model];
    [self hideDetailContainerView];
}

- (void)loadPicker
{
    if (!_pickerToolbar)
    {
        _pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-260, 320, 44)];
        _pickerToolbar.barStyle = UIBarStyleBlackTranslucent; //UIBarStyleBlackOpaque;
        [_pickerToolbar sizeToFit];
    }
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [barItems addObject:cancelBtn];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    flexSpace.width = 200.0f;
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [barItems addObject:doneBtn];
    
    [_pickerToolbar setItems:barItems animated:YES];
    
    [_actionSheet addSubview:_pickerToolbar];
    
    [_actionSheet addSubview:self.patientsPicker];
    [self.patientsPicker reloadAllComponents];
    
    [self.view addSubview:_actionSheet];
    [self.view bringSubviewToFront:_actionSheet];
    _actionSheet.hidden = NO;
    
}
#pragma mark - Request methods

-(void)makeRequestForServicesList:(int)currentPageIndex loader:(BOOL)load{
    
    if (load) {
        if (![HUD isHidden]) {
            [HUD hide:YES];
        }
        [self addSpinnerView];
    }
   
    NSString *pageIndex = [NSString stringWithFormat:@"%d",currentPageIndex];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = nil;
    if (seacrhPostString == nil) {
        bodyText = [NSString stringWithFormat:@"%@&page=%@",postString,pageIndex];

    }else {
        bodyText = [NSString stringWithFormat:@"%@&page=%@",seacrhPostString,pageIndex];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"provider_services/index"];
    NSLog(@"body text12...:%@",bodyText);
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO successHandler:^(id response) {
        if (response == nil)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        } else {
        dispatch_async(dispatch_get_main_queue(),^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            NSLog(@"response.........:%@",response);
            seacrhPostString = nil;
            if (isSeraching) {
                [self.servicesArray removeAllObjects];
                isSeraching = NO;
            }
            NSArray *array = response[@"provider_services"];
            
            currentPage = [response[@"pagination"][@"current_page"] intValue];
            
            totalPages = [response[@"pagination"][@"total_pages"] intValue];
           
            if ([array isKindOfClass:[NSArray class]]) {
               
            for (NSDictionary *dict in array) {
                
                ServicesResponseModel *model = [[ServicesResponseModel alloc]init];
            
                model.serviceName = dict[@"name"];
                model.serviceId = dict[@"user"][@"recno"];
                //model.serviceprice = [NSString stringWithFormat:@"%ld",[dict[@"price"] integerValue]];
                model.serviceprice = [NSString stringWithFormat:@"%ld",[dict[@"original_price"] integerValue]];
                
                model.servicediscountprice = [NSString stringWithFormat:@"%ld",[dict[@"effective_price"] integerValue]];
                
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
                [self.servicesArray addObject:model];
                
            }
                if (self.servicesListArray == nil) {
                    self.servicesListArray = [self.servicesArray copy];
                }
                if (self.servicesArray.count) {
                    self.errorLabel.hidden = YES;
                    self.tableView.hidden = NO;
                     [self.tableView reloadData]; 
                }
               
            } else {
              [self.servicesArray removeAllObjects];
                self.tableView.hidden = YES;
                self.errorLabel.hidden = NO;
            }
          
        });
        }
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
-(void)makeRequestForUsersList{
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
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mmulti"];
    
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if (response) {
            NSArray *array = response[@"family_members"];
            
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            
            for (NSDictionary *dict in array) {
                UsersResponseModel *model = [[UsersResponseModel alloc]init];
                
                model.patientName = dict[@"dispname"];
                model.patientId = dict[@"recno"];
                [tempArray addObject:model];
            }
            self.usersList = [tempArray copy];
            
//            if (self.usersList.count) {
//                selectedUser = self.usersList[0];
//                self.patientnameTF.text = selectedUser.patientName;
//            }
          
        }
        
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading Services list failed. Please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];

    }];
    
}

-(NSString *)discountCalculation:(NSString *)discountStr ActualPrice:(NSString *)price{
    if (!discountStr) {
        return nil;
    }
    float discountPercent = [discountStr floatValue];
    discountPercent = discountPercent/100;
    NSInteger calCost = [price integerValue];
    float discount = calCost * discountPercent;
    double discountedCost = ceilf(calCost - discount);
    return [NSString stringWithFormat:@"%.0f",discountedCost];

}

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

#pragma mark - Tableview Delegate/Datasource Methods
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!isSeraching){
    if (indexPath.row == self.servicesArray.count-1) {
        if (currentPage!=totalPages) {
             dispatch_async(dispatch_get_main_queue(),^{

                 [self makeRequestForServicesList:currentPage+1 loader:NO];

            });
        }
    }
    }
    // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,(unsigned long)NULL), ^(void)
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count;
    if (isSeraching) {
        count = self.searchedArray.count;
    } else{
        if (currentPage==totalPages) {
            count = self.servicesArray.count;

        } else {
            if (self.servicesArray.count >1) {
                count = self.servicesArray.count+1;
            }else {
                count = self.servicesArray.count;
            }
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //loadingCell
    NSInteger count ;
    if (isSeraching) {
        count  = self.searchedArray.count;
    }else {
        count  = self.servicesArray.count;

    }
    UITableViewCell *dafaultCell;
    if (count == indexPath.row && currentPage!=totalPages) {
        dafaultCell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell" forIndexPath:indexPath];
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[dafaultCell.contentView viewWithTag:100];
        [activityIndicator startAnimating];
    } else {
    SmartRxBookServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"serviceBookCell"];
//    if (cell == nil)
//    {
//        cell = [[SmartRxBookServiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"serviceBookCell"];
//        }
    
    cell.cellDelegate = self;
    cell.cellId = indexPath;
    ServicesResponseModel *model;
    if (isSeraching) {
        model = self.searchedArray[indexPath.row];
        
    } else {
        model = self.servicesArray[indexPath.row];
    }
    
    if ([model.serviceLocation isEqualToString:@"0"]) {
        cell.serviceTypeImage.image = [UIImage imageNamed:@"provider"];
    } else{
        cell.serviceTypeImage.image = [UIImage imageNamed:@"home"];
    }
    
    cell.serviceName.text = model.serviceName;
    cell.providerName.text = model.providerName;
   
    if ([model.serviceDescription isKindOfClass:[NSString class]]) {
        
        cell.serviceDescription.attributedText = [self getPlainText:model.serviceDescription];
        //cell.serviceDescription.text = model.serviceDescription;

    } else {
        cell.serviceDescription.text = @"";
    }
     NSString *rupeesStr=@"\u20B9";
    if (model.servicediscountprice) {
        if (![model.servicediscountprice isEqualToString:model.serviceprice] ) {
            NSString *discountStr = nil;
            if ([model.servicediscountprice integerValue] == 0) {
                discountStr = @"Free";
            }else {
                discountStr = [NSString stringWithFormat:@"%@ %@",rupeesStr,model.servicediscountprice];
            }
        
        cell.serviceDiscountedPrice.text = discountStr;
        
         NSString *originalAmount = [NSString stringWithFormat:@"%@ %@",rupeesStr,model.serviceprice];
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:originalAmount];
        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                value:@2
                                range:NSMakeRange(0, [attributeString length])];
        
        cell.serviceOriginalPrice.attributedText = attributeString;
        } else {
             NSString *discountStr = [NSString stringWithFormat:@"%@ %@",rupeesStr,model.serviceprice];
            cell.serviceDiscountedPrice.text = discountStr;
            cell.serviceOriginalPrice.text = @"";
        }
        
    }else {
        NSString *discountStr = [NSString stringWithFormat:@"%@ %@",rupeesStr,model.serviceprice];
        cell.serviceDiscountedPrice.text = discountStr;
        cell.serviceOriginalPrice.text = @"";
    }
    
     cell.thumbnailImage.image = nil;
     cell.service = model;
        
    //NSString *urlString = [NSString stringWithFormat:@"%s%@",kBaseUrlQAImg,model.imagePath];
    
   // NSURL *url = [NSURL URLWithString:urlString];
    
   //  [cell.thumbnailImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeHolder.png"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
//    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *  data, NSURLResponse * response, NSError *  error) {
//        if (data) {
//            UIImage *image = [UIImage imageWithData:data];
//            if (image) {
//                dispatch_async(dispatch_get_main_queue(),^{
//                    cell.thumbnailImage.image = nil;
//                    SmartRxBookServiceCell *updateCell =(id)[tableView cellForRowAtIndexPath:indexPath];
//                    if (updateCell)
//                        updateCell.thumbnailImage.image = image;
//                    
//                });
//            }
//        }
//    }];
   // [task resume];
        
        return cell;
    }
    return dafaultCell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ServicesResponseModel *model ;
    if (isSeraching) {
        model   = self.searchedArray[indexPath.row];

    }else {
        model   = self.servicesArray[indexPath.row];

    }
    
    [self.detailController reloadTableView:model];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.detailContainerView.frame = CGRectMake(0, 64, self.detailContainerView.frame.size.width, self.detailContainerView.frame.size.height);
    }];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   NSInteger count  = self.servicesArray.count;
    if (count == indexPath.row && currentPage!=totalPages) {
        return 44.0f;
    }
    return 130.0f;
}
-(NSMutableAttributedString *)getPlainText:(NSString *)htmlString{
    
    NSError *err = nil;
    
    NSAttributedString *attributeStr = [[NSAttributedString alloc]initWithData: [htmlString dataUsingEncoding:NSUnicodeStringEncoding]options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }documentAttributes: nil error: &err];
    
    NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithAttributedString:attributeStr];
    
    NSRange range = (NSRange){0,[newString length]};
    
    [newString enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        
        UIFont *replacementFont =  [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        [newString addAttribute:NSFontAttributeName value:replacementFont range:range];
        
    }];
    if (newString.string.length == 4) {
        return [[NSMutableAttributedString alloc]initWithString:@""];
    }
    return newString;
}
-(void)hideDetailContainerView{
    self.detailContainerView.frame = CGRectMake(self.view.frame.size.width+5, 64 , self.detailContainerView.frame.size.width, self.detailContainerView.frame.size.height);
}
#pragma mark - Filter Methods  

-(void)selectedProvider:(NSString *)provider{
    [self.servicesArray removeAllObjects];

    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];

    postString = [NSString stringWithFormat:@"sessionid=%@&filter_provider=%@",sectionId,provider];
    [self makeRequestForServicesList:1  loader:YES];
    
}
-(void)allServicesSelected{
    [self.servicesArray removeAllObjects];

    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    postString = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    
    [self makeRequestForServicesList:currentPage  loader:YES];
    
}
-(void)selectedLocation:(PatientLocationResponseModel *)selectedLocation{
    [self.servicesArray removeAllObjects];

    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    if (selectedLocation.cityId != nil && selectedLocation.localityId !=nil) {
         if (selectedLocation.localityId == nil) {
        postString = [NSString stringWithFormat:@"%@=%@&city_id=%@",@"sessionid",sectionId,selectedLocation.cityId];
         }else{
              postString = [NSString stringWithFormat:@"%@=%@&city_id=%@",@"sessionid",sectionId,selectedLocation.cityId];
              // postString = [NSString stringWithFormat:@"%@=%@&@&locality_id=%@",@"sessionid",sectionId,selectedLocation.localityId];
         }
    }else {
       
              postString = [NSString stringWithFormat:@"%@=%@&location_id=%@",@"sessionid",sectionId,selectedLocation.locationId];
        

    }
       // postString = [NSString stringWithFormat:@"%@=%@&location_id=%@&locality_id=%@&city_id=%@",@"sessionid",sectionId,selectedLocation.locationId,selectedLocation.localityId,selectedLocation.cityId];
    [self makeRequestForServicesList:currentPage loader:YES];

}
-(void)selectedType:(NSString *)type{
    [self.servicesArray removeAllObjects];

    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    postString = [NSString stringWithFormat:@"%@=%@&service_type=%@",@"sessionid",sectionId,type];
    
    
    [self makeRequestForServicesList:currentPage loader:YES];

}
#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self postBodyCreation];
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

#pragma mark - Textfield Delegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
//    if (textField == self.searchTF) {
//        isSeraching = NO;
//        NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        if ([str length] >= 3){
//            isSeraching = YES;
//            seacrhPostString = postString;
//            seacrhPostString =  [seacrhPostString stringByAppendingString:[NSString stringWithFormat:@"&name=%@",str]];
//            [self makeRequestForServicesList:1 loader:YES];
//        }else if(str.length == 0){
//            [self.servicesArray removeAllObjects];
//            [self makeRequestForServicesList:1 loader:YES];
////            [self.servicesArray addObjectsFromArray:self.servicesListArray];
////            [self.tableView reloadData];
//        }
//
    
        
        
        
        
//        NSString *searchText = textField.text;
//        if (searchText.length == 1 && [string isEqualToString:@""]) {
//           searchText = @"";
//        } else if ([string isEqualToString:@""]){
//            searchText = [searchText substringToIndex:[searchText length]-1];
//        } else {
//            searchText = [searchText stringByAppendingString:string];
//        }
//        
//        if (searchText.length < 1 ) {
//            isSeraching = NO;
//        } else {
//            isSeraching = YES;
//
//        }
//        
//        NSPredicate *predicate =
//        [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@",
//         @"serviceName", searchText];
//        self.searchedArray = [self.servicesArray filteredArrayUsingPredicate:predicate];
//        if (self.searchedArray.count || isSeraching == NO) {
//            if (self.searchedArray.count > 0) {
//                self.tableView.hidden = NO;
//                self.errorLabel.hidden = YES;
//            }
//          else  if (isSeraching == NO && self.servicesArray.count  < 1) {
//                self.tableView.hidden = YES;
//                self.errorLabel.hidden = NO;
//            }
//           
//        } else {
//                self.tableView.hidden = NO;
//                self.errorLabel.hidden = YES;
//        }
//        [self.tableView reloadData];
   // }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];

    return YES;
}
-(void)textFieldDidChange :(UITextField *)textField{
    
    // if a timer is already active, prevent it from firing
    if (self.searchTimer != nil) {
        [self.searchTimer invalidate];
        self.searchTimer = nil;
    }
    
    // reschedule the search: in 1.0 second, call the searchForKeyword: method on the new textfield content
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval: 0.50
                                                        target: self
                                                      selector: @selector(searchForKeyword:)
                                                      userInfo: self.searchTF.text
                                                       repeats: NO];
    
}

- (void) searchForKeyword:(NSTimer *)timer
{
    NSString *keyword = (NSString*)timer.userInfo;
        isSeraching = NO;
        if ([keyword length] >= 3){
            isSeraching = YES;
            seacrhPostString = postString;
            seacrhPostString =  [seacrhPostString stringByAppendingString:[NSString stringWithFormat:@"&name=%@",keyword]];
            [self makeRequestForServicesList:1 loader:YES];
        }else if(keyword.length == 0){
            [self.servicesArray removeAllObjects];
            [self makeRequestForServicesList:1 loader:YES];
            //            [self.servicesArray addObjectsFromArray:self.servicesListArray];
            //            [self.tableView reloadData];
        
        }
   
}


#pragma mark - PickerView  methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.usersList.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    UsersResponseModel *model = self.usersList[row];
    return model.patientName;
    
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
   selectedUser = self.usersList[row];
    
    NSLog(@"yhkgs:%@",selectedUser.patientName);

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 9999)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"serviceDetailVc"]) {
        self.detailController = segue.destinationViewController;
        self.detailController.buttonDelegate  = self;
        
    } else if([segue.identifier isEqualToString:@"cartVc"]){
        SmartRxCartViewController *controller = segue.destinationViewController;
        controller.selectedService = sender;
        
    } else if ([segue.identifier isEqualToString:@"filterVc"]){
        SmartRxFilterViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}


@end
