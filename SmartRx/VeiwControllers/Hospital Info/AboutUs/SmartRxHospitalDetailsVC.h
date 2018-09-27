//
//  SmartRxHospitalDetailsVC.h
//  SmartRx
//
//  Created by Anil Kumar on 09/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxHospitalDetailsVC : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
@property (strong, nonatomic) NSMutableDictionary *dictData;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UILabel *locationName;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *aboutUsTabView;
@property (weak, nonatomic) IBOutlet UIView *contactUsTabView;
@property (weak, nonatomic) IBOutlet UIImageView *hospitalImage;
@property (weak, nonatomic) IBOutlet UIButton *keyFeatureBtn;
@property (weak, nonatomic) IBOutlet UIButton *contactUsBtn;
@property (weak, nonatomic) IBOutlet UILabel *keyFeatureLbl;
@property (weak, nonatomic) IBOutlet UILabel *contactUsLbl;
@property (weak, nonatomic) IBOutlet UITableView *contactUsTable;
@property (assign, nonatomic) NSString *strTitle;

@property (strong, nonatomic) NSArray *arrLocations;
@property (strong, nonatomic) NSMutableArray *arrLoadTbl;

- (IBAction)keyFeatureClicked:(id)sender;
- (IBAction)contactUsClicked:(id)sender;

@end
