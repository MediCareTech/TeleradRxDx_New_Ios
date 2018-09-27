//
//  SmartRxAddLocationsVC.h
//  SmartRx
//
//  Created by Gowtham on 14/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientLocationResponseModel.h"

typedef NS_ENUM(NSUInteger, TableViewTtype) {
    CitiestableView,
    LocalityTableView,
};

@interface SmartRxAddLocationsVC : UIViewController<MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property(nonatomic,weak)  NSString *titleStr;
@property(nonatomic,assign) TableViewTtype tableViewType;
@property(nonatomic,weak) IBOutlet UITextField *addressTypeTF;
@property(nonatomic,weak) IBOutlet UITextField *zipcodeTF;
@property(nonatomic,weak) IBOutlet UITextField *cityTF;
@property(nonatomic,weak) IBOutlet UITextField *addressTF;
@property(nonatomic,weak) IBOutlet UITextField *localityTF;
@property(nonatomic,weak) IBOutlet UIView *menuView;
@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,strong) PatientLocationResponseModel *selectedLocationModel;
@property(nonatomic,strong) NSArray *citiesArray;
@property(nonatomic,strong) NSArray *localityArray;



@end
