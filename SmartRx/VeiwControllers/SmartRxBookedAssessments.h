//
//  SmartRxBookedAssessments.h
//  SmartRx
//
//  Created by Gowtham on 02/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxBookedAssessments : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *noAppsLbl;
@property(nonatomic,strong) NSString *fromVc;

@end
