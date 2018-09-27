//
//  SmartRxAssessmentsVc.h
//  SmartRx
//
//  Created by Gowtham on 23/01/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxAssessmentsVc : UIViewController<MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *noAppsLbl;

@end
