//
//  SmartRxFilterViewController.h
//  SmartRx
//
//  Created by Gowtham on 22/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientLocationResponseModel.h"

typedef NS_ENUM(NSUInteger, TableViewTtype) {
    TypeTableView,
    LocationTableView,
    ProviderNameTableView
};


@protocol FilterDelegate <NSObject>

-(void)allServicesSelected;
-(void)selectedLocation:(PatientLocationResponseModel *)selectedLocation;
-(void)selectedProvider:(NSString *)provider;
-(void)selectedType:(NSString *)type;

@end
@interface SmartRxFilterViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>


@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,weak) IBOutlet UITableView *filterTableView;

@property(nonatomic,assign) TableViewTtype tableViewType;
@property(nonatomic,weak) id<FilterDelegate> delegate;

@end
