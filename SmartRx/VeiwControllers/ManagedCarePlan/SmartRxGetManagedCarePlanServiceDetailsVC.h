//
//  SmartRxGetManagedCarePlanServiceDetailsVC.h
//  SmartRx
//
//  Created by SmartRx-iOS on 17/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxGetManagedCarePlanServiceDetailsVC : UIViewController

@property(nonatomic,strong) NSArray *serviceArray;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *noAppsLbl;

@end
