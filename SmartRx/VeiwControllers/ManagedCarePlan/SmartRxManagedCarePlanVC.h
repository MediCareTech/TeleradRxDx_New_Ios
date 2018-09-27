//
//  SmartRxManagedCarePlanVC.h
//  SmartRx
//
//  Created by SmartRx-iOS on 11/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxManagedCarePlanVC : UIViewController<MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *noAppsLbl;

@end
