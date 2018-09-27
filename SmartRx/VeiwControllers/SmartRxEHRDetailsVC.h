//
//  SmartRxEHRDetailsVC.h
//  CareBridge
//
//  Created by Gowtham on 27/07/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EhrModel.h"
@interface SmartRxEHRDetailsVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) EhrModel *selectedEhrModel;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *noAppsLbl;

@property(nonatomic,strong) NSArray *ehrDetailsArr;
@property(nonatomic,strong) NSString *titleStr;

@end
