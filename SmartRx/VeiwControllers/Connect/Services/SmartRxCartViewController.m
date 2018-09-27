//
//  SmartRxCartViewController.m
//  SmartRx
//
//  Created by Gowtham on 13/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxCartViewController.h"
#import "SmartRxCartDetailController.h"
#import "ServiceTypeManager.h"
#import "UIBarButtonItem+Badge.h"
#import "PatientLocationResponseModel.h"
#import "NSString+DateConvertion.h"
#import "CartRequestModel.h"
#import "SmartRxDB.h"
#import "SmartRxAppDelegate.h"
#import "SmartRxAddLocationsVC.h"


@interface SmartRxCartViewController ()
{
    MBProgressHUD *HUD;
    PatientLocationResponseModel *selectedLocation;
    NSString *selectedDate;
    NSString *selectedTime;


}
@property(nonatomic,strong) NSArray *locationsArray;
@property(nonatomic,strong) NSArray *availableDatesArr;
@property(nonatomic,strong) NSArray *availableTimeSlots;


@end

@implementation SmartRxCartViewController
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
#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Add to cart";
    self.subView.hidden = YES;
    self.subView.layer.borderWidth = .5;
    self.subView.layer.borderColor = [UIColor grayColor].CGColor;
    
    pickerAction = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    pickerAction.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = pickerAction.bounds;
    [pickerAction addSubview:backgroundView];
    
    [self navigationBackButton];
    [self updateUI];
   
    [self hideDetailContainerView];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    SmartRxAppDelegate *appdelegate  = (SmartRxAppDelegate *)[UIApplication sharedApplication].delegate;
    self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)appdelegate.cartCount];
    if ([self.selectedService.serviceLocation isEqualToString:@"0"]) {
        self.locationType.text = @"Provider location";
        self.serviceTypeImage.image = [UIImage imageNamed:@"provider"];
//        self.locationTF.text = @"At provideer location";
//        self.addNewAddressBtn.backgroundColor = [UIColor clearColor];
//        [self.addNewAddressBtn setTitle:@"" forState:UIControlStateNormal];
    } else {
         self.serviceTypeImage.image = [UIImage imageNamed:@"home"];
    }
     [self makeRquestForPatientLocations];
}
#pragma mark - Action Methods

- (IBAction)dateBtnClicked:(id)sender
{
    self.subView.hidden = YES;
    if (self.selectedService.isScheduled) {
        self.datePickerView.datePickerMode=UIDatePickerModeDate;
        selectedTime = nil;
        [self ChooseDP:@"Date"];
    }
   
}
-(void)cartButtonPress:(id)sender
{
    [self performSegueWithIdentifier:@"cartCheckOutVc" sender:nil];

}
-(void)backBtnClicked:(id)sener
{
    //[self hideKeyboardBtnClicked:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)clickOnSeeMoreButton:(id)sender{
    
    [self.detailController reloadTableView:self.selectedService];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.detailContainerView.frame = CGRectMake(0, 64, self.detailContainerView.frame.size.width, self.detailContainerView.frame.size.height);
    }];
}
-(IBAction)clickOnTimeSlotesButton:(id)sender{
     if (self.selectedService.isScheduled) {
         if (self.availableTimeSlots.count) {
             self.tableViewType = TimeSlotsTable;
             self.subView.hidden = NO;
             [self.tableView reloadData];
         } else {
             [self customAlertView:@"" Message:@"No Time slots available" tag:0];
         }
    
     } else{
         
     }
}
-(IBAction)clickOnAddnewLocationButton:(UIButton *)sender{
    
    
    if(sender.tag == 999){
        [self performSegueWithIdentifier:@"addLocationVC" sender:nil];
    } else {
        if (self.locationsArray.count) {
            self.tableViewType = LocationTable;
            self.subView.hidden = NO;
            [self.tableView reloadData];
        }
        

    }
    
}
-(IBAction)clickOnCheckOutButton:(id)sender{

    //&& self.locationsArray.count
    if (!selectedLocation ) {
            [self customAlertView:@"Please select the location" Message:@"" tag:0];
        
    } else if(self.selectedService.isScheduled){
        
        if (!selectedDate) {
            [self customAlertView:@"Please select the date" Message:@"" tag:0];
        } else if (!selectedTime) {
            [self customAlertView:@"Please select the time" Message:@"" tag:0];
        } else {
            
                [self addToCart];
            [self performSegueWithIdentifier:@"cartCheckOutVc" sender:nil];
        }
    } else {
        [self addToCart];
        [self performSegueWithIdentifier:@"cartCheckOutVc" sender:nil];
    }

}
-(IBAction)clickOnAddToCartButton:(id)sender{
    
    if (!selectedLocation) {
        
        [self customAlertView:@"Please select the location" Message:@"" tag:0];
        
    } else if(self.selectedService.isScheduled){
        if (!selectedDate) {
            [self customAlertView:@"Please select the date" Message:@"" tag:0];
        } else if (!selectedTime) {
            [self customAlertView:@"Please select the time" Message:@"" tag:0];
        } else {
           
            [self addToCart];
           [self.navigationController popViewControllerAnimated:YES];
        }
        
    } else {
        [self addToCart];
        [self.navigationController popViewControllerAnimated:YES];
    }

}
-(void)addToCart{
    CartRequestModel *model = [self getCartModel];
    
    BOOL save= [[SmartRxDB sharedDBManager] saveCartData:model];
    
    NSString *alertStr;
    if (save) {
        alertStr = @"Successfully added to cart" ;
        //[self customAlertView:@"Successfully added to cart" Message:@"" tag:999];
    } else {
        
        alertStr = @"Failed to adding cart";
        [self customAlertView:@"Failed to adding cart" Message:@"" tag:0];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = alertStr;
    hud.labelFont = [UIFont systemFontOfSize:11];
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    hud.animationType = MBProgressHUDAnimationFade;
    [hud hide:YES afterDelay:2];
    
}
-(CartRequestModel *)getCartModel{
    
       CartRequestModel *model = [[CartRequestModel alloc]init];
        model.serviceType = self.selectedService.serviceType;
        model.providerServiceId = self.selectedService.providerId;
        if (self.selectedService.servicediscountprice) {
            model.servicePrice = self.selectedService.servicediscountprice;
        } else {
            model.servicePrice = self.selectedService.serviceprice;
            
        }
       model.isScheduled = self.selectedService.isScheduled;
        model.scheduledTime = selectedTime;
        model.scheduledDate = selectedDate;
        model.bookingLocationId = selectedLocation.locationId;
        model.serviceName = self.selectedService.serviceName;
        model.providerName = self.selectedService.providerName;
       model.userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
        
//        BOOL save= [[SmartRxDB sharedDBManager] saveCartData:model];
//        
//        if (save) {
//            
//            [self customAlertView:@"Successfully added to cart" Message:@"" tag:999];
//        } else {
//            [self customAlertView:@"Failed to adding cart" Message:@"" tag:0];
//        }

    return model;
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
        
        if ([self.selectedService.serviceLocation isEqualToString:@"0"]) {
            bodyText = [NSString stringWithFormat:@"uid=%@&cid=%@&isopen=1",self.selectedService.providerServiceId,strCid];
        } else {
            bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
        }
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
                
                model.cityName = dict[@"city"][@"name"];
                model.cityId = dict[@"city"][@"id"];
                if ([dict[@"locality"] isKindOfClass:[NSDictionary class]]) {
                    model.localityName = dict[@"locality"][@"name"];

                }
                
                if ([self.selectedService.serviceLocation isEqualToString:@"0"]){
                    model.localityId =  [NSString stringWithFormat:@"%d",[dict[@"id"] integerValue]];
                } else {
                    
                    if ([dict[@"locality"] isKindOfClass:[NSDictionary class]]) {
                       model.localityId = [NSString stringWithFormat:@"%d",[dict[@"locality"][@"id"] integerValue]];
                        
                    }
                    
                }
                
                
                model.addressType = dict[@"type"];
                model.zipcode = dict[@"zipcode"];
                model.address = dict[@"address"];
                model.locationId = [NSString stringWithFormat:@"%d",[dict[@"id"] integerValue]];
                [tempArray addObject:model];
                
            }
            self.locationsArray = [tempArray copy];
            if (self.locationsArray.count) {
                selectedLocation = self.locationsArray[0];
                NSString *locationStrr = selectedLocation.addressType;
                if (selectedLocation.localityName != nil) {
                    locationStrr = [locationStrr stringByAppendingString:[NSString stringWithFormat:@"-%@",selectedLocation.localityName]];
                }
                locationStrr = [locationStrr stringByAppendingString:[NSString stringWithFormat:@"-%@",selectedLocation.cityName]];
               // NSString *locationStr = [NSString stringWithFormat:@"%@-%@-%@",selectedLocation.addressType,selectedLocation.localityName,selectedLocation.cityName];;
                self.locationTF.text = locationStrr;
                self.addNewAddressBtn.backgroundColor = [UIColor clearColor];
                [self.addNewAddressBtn setTitle:@"" forState:UIControlStateNormal];
                self.addNewAddressBtn.tag = 333;
                
            } else {
                
                 if ([self.selectedService.serviceLocation isEqualToString:@"0"]) {
                     
                     self.addNewAddressBtn.backgroundColor = [UIColor clearColor];
                     [self.addNewAddressBtn setTitle:@"" forState:UIControlStateNormal];
                     self.locationTF.text = @"At provider location";
                      self.addNewAddressBtn.tag = 333;
                 } else {
                      self.addNewAddressBtn.tag = 999;
                 }
                
               

            }
            //[self.tableView reloadData];
            
        }
        
        
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
    
    
}
-(void)makeRequestForAvailbleDates{
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];

    NSString *bodyText=nil;
    bodyText = [NSString stringWithFormat:@"%@=%@&type=1&sch_type=1",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"medates"];//@"mdocs"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO successHandler:^(id response) {
        dispatch_async(dispatch_get_main_queue(),^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            NSArray *responseArray = response[@"econdates"];
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            for (NSArray *firstArr in responseArray) {
                
                for (NSString *str in firstArr) {
                    
                    double value = [str doubleValue];
                    [tempArray addObject:[self dateConvertor:value]];
                }
                
            }
            self.availableDatesArr = [tempArray copy];
            
        });
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Not able to fetch user credits and other details due to network issues. Please try again" Message:@"Try again" tag:0];
    }];
    
}
-(void)makeRequestForTimeSlots{
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *bodyText=nil;
    bodyText = [NSString stringWithFormat:@"%@=%@&doa=%@",@"sessionid",sectionId,self.dateTF.text];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mstime"];//@"mdocs"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO successHandler:^(id response) {
        dispatch_async(dispatch_get_main_queue(),^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            NSArray *responseArray = response[@"stime"];
           
           if ([responseArray isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            for (NSString *timeStr in responseArray) {
                
                [tempArray addObject:timeStr];
    
            }
            
            self.availableTimeSlots = [tempArray copy];
            
            if (self.availableTimeSlots.count) {
                self.timeTF.text = self.availableTimeSlots[0];
                selectedTime = self.availableTimeSlots[0];
            } else {
                [self customAlertView:@"No time slots" Message:@"" tag:0];
            }
           } else {
               [self customAlertView:@"No time slots" Message:@"" tag:0];
           }
        });
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Network not availble" Message:@"Try again" tag:0];
    }];

}
-(NSDate *)dateConvertor:(double)timeInetr{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInetr];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    return [formatter dateFromString:dateStr];
}

-(void)addSpinnerView{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

-(void)updateUI{
    
    self.serviceName.text = self.selectedService.serviceName;
    self.providerName.text= self.selectedService.providerName;
    ServiceTypeManager *manager = [ServiceTypeManager sharedManager];
    if ([self.selectedService.serviceType isKindOfClass:[NSString class]]) {
        self.typeLbl.text = [manager getSelectedServiceType:self.selectedService.serviceType];
    }else{
        self.freeTextType.hidden = YES;
    }
   
    if ([self.selectedService.serviceDescription isKindOfClass:[NSString class]]) {
        self.descrptionLbl.attributedText = [self getPlainText:self.selectedService.serviceDescription];

    } else {
        self.descrptionLbl.text = @"";

    }
    
    self.originalPriceLbl.hidden = YES;
    
     if (self.selectedService.servicediscountprice) {
          NSString *rupee = @"Rs.";
         if (![self.selectedService.servicediscountprice isEqualToString:self.selectedService.serviceprice]) {
             self.originalPriceLbl.hidden = NO;
             NSString *originalPrice = [NSString stringWithFormat:@"%@%@",rupee,self.selectedService.serviceprice];
             NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:originalPrice];
             [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                     value:@2
                                     range:NSMakeRange(0, [attributeString length])];
             
             _originalPriceLbl.attributedText = attributeString;
             
             [self.originalPriceLbl sizeToFit];
             NSString *discountPrice = nil;
             if ([self.selectedService.servicediscountprice integerValue] == 0) {
                 discountPrice = @"Free";
             }else {
             discountPrice = [NSString stringWithFormat:@"%@%@",rupee,self.selectedService.servicediscountprice];
             }
             self.dicountPriceLbl.text = discountPrice;
             NSLog(@"discout price1......:%@",discountPrice);

             [self.dicountPriceLbl sizeToFit];

         } else {
             NSLog(@"discout price......:%@",self.selectedService.serviceprice);
             NSString *discountPrice = [NSString stringWithFormat:@"%@%@",rupee,self.selectedService.serviceprice];
             
             self.dicountPriceLbl.text = discountPrice;
             
            // _originalPriceLbl.hidden = YES;

         }
         
         
         
     } else {
         
         NSString *rupee = @"Rs.";
         
         NSString *discountPrice = [NSString stringWithFormat:@"%@%@",rupee,self.selectedService.serviceprice];

         self.dicountPriceLbl.text = discountPrice;
         
         _originalPriceLbl.hidden = YES;
         
     }
    
    if (self.selectedService.isScheduled == false) {
        self.timeButton.hidden = YES;
        self.dateButton.hidden = YES;
        self.dateImage.hidden = YES;
        self.timeImage.hidden = YES;
        self.timeBackgroundImage.hidden = YES;
        self.dateBackgroundImage.hidden = self;
        self.dateTF.hidden = YES;
        self.timeTF.hidden = YES;
        self.addToCartBtn.frame = CGRectMake(self.addToCartBtn.frame.origin.x, self.addToCartBtn.frame.origin.y-70, self.addToCartBtn.frame.size.width, self.addToCartBtn.frame.size.height);
        self.checkOutBtn.frame = CGRectMake(self.checkOutBtn.frame.origin.x, self.checkOutBtn.frame.origin.y-70, self.checkOutBtn.frame.size.width, self.checkOutBtn.frame.size.height);
    }
    
    
}


-(void)hideTheDetailView{
    
    [self hideDetailContainerView];
}
-(void)hideDetailContainerView{
    
    self.detailContainerView.frame = CGRectMake(self.view.frame.size.width+5, 64 , self.detailContainerView.frame.size.width, self.detailContainerView.frame.size.height);
}
#pragma mark - Tableview Delegate And Datasource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count;
    if (self.tableViewType == TimeSlotsTable) {
        count = self.availableTimeSlots.count;
    } else {
        if ([self.selectedService.serviceLocation isEqualToString:@"0"]) {
            count = self.locationsArray.count;
        } else {
        count = self.locationsArray.count +1;
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell ;
    if (self.tableViewType == TimeSlotsTable) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = self.availableTimeSlots[indexPath.row];

    } else {
        if (indexPath.row < self.locationsArray.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            PatientLocationResponseModel *model = self.locationsArray[indexPath.row];
             NSString *locationStrr = model.addressType;
            
            if (model.localityName != nil) {
                locationStrr = [locationStrr stringByAppendingString:[NSString stringWithFormat:@"-%@",model.localityName]];
            }
            locationStrr = [locationStrr stringByAppendingString:[NSString stringWithFormat:@"-%@",model.cityName]];
            
            NSString *locationStr = [NSString stringWithFormat:@"%@-%@-%@",model.addressType,model.localityName,model.cityName];
            cell.textLabel.text = locationStrr;

        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];

        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableViewType == TimeSlotsTable ) {
        self.timeTF.text = self.availableTimeSlots[indexPath.row];
        selectedTime = self.availableTimeSlots[indexPath.row];


    } else {
        if (indexPath.row < self.locationsArray.count) {
            PatientLocationResponseModel *model = self.locationsArray[indexPath.row];
            NSString *locationStr = [NSString stringWithFormat:@"%@-%@-%@",model.addressType,model.localityName,model.cityName];
            NSString *locationStrr = model.addressType;
            
            if (model.localityName != nil) {
                locationStrr = [locationStrr stringByAppendingString:[NSString stringWithFormat:@"-%@",model.localityName]];
            }
            locationStrr = [locationStrr stringByAppendingString:[NSString stringWithFormat:@"-%@",model.cityName]];
            self.locationTF.text = locationStrr;
        } else {
        
            [self performSegueWithIdentifier:@"addLocationVC" sender:@"Add Address"];
            
        }
    }
    self.subView.hidden = YES;
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


#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if (alertView.tag ==  999)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
}
#pragma mark - Date Picker

-(void)ChooseDP:(id)sender{
    //    pickerAction = [[UIActionSheet alloc] initWithTitle:@"Date"
    //                                               delegate:nil
    //                                      cancelButtonTitle:nil
    //                                 destructiveButtonTitle:nil
    //                                      otherButtonTitles:nil];
    
    self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, self.view.frame.size.height-216, 0.0, 0.0)];
    self.datePickerView.backgroundColor = [UIColor whiteColor];
    NSString *date = self.dateTF.text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if ([sender isEqualToString:@"Date"])
    {
        self.datePickerView.minimumDate = [NSDate date];
        //[self.datePickerView setMinimumDate:[NSDate date]];
        self.datePickerView.datePickerMode = UIDatePickerModeDate;
    }
    else
    {
        self.datePickerView.datePickerMode = UIDatePickerModeTime;
    }
    if([date length]>0)
    {
        [self.datePickerView setDate:[NSString stringToDate:date]];
    }
    //    //format datePicker mode. in this example time is used
    //    self.datePickerView.datePickerMode = UIDatePickerModeTime;
    //    [dateFormatter setDateFormat:@"h:mm a"];
    //    //calls dateChanged when value of picker is changed
    //    [self.datePickerView addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    toolbarPicker = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-260, 320, 44)];
    toolbarPicker.barStyle=UIBarStyleBlackOpaque;
    [toolbarPicker sizeToFit];
    NSMutableArray *itemsBar = [[NSMutableArray alloc] init];
    //calls DoneClicked
    UIBarButtonItem *bbitem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [itemsBar addObject:bbitem];
    
    [toolbarPicker setItems:itemsBar animated:YES];
    [pickerAction addSubview:toolbarPicker];
    [pickerAction addSubview:self.datePickerView];
    [self.view addSubview:pickerAction];
    pickerAction.hidden = NO;
}
- (void)doneClicked:(id)sender
{
    
    NSDate *dateAppointment=self.datePickerView.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyy"];
    NSString *strDate = [dateFormat stringFromDate:dateAppointment];
    NSLog(@"date ==== %@",strDate);
    self.dateTF.text=strDate;
    selectedDate = strDate;
    self.datePickerView.hidden=YES;
    [self makeRequestForTimeSlots];
    [self closeDatePicker:nil];
    
}
-(BOOL)closeDatePicker:(id)sender{
    pickerAction.hidden = YES;
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"cartDetailVc"]) {
        self.detailController = segue.destinationViewController;
        self.detailController.buttonDelegate = self;
    }else  if ([segue.identifier isEqualToString:@"addLocationVC"]) {
        SmartRxAddLocationsVC *controller = segue.destinationViewController;
        controller.titleStr = sender;
    }
}


@end
