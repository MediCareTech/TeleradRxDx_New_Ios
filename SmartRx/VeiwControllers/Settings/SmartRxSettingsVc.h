//
//  SmartRxSettingsVc.h
//  SmartRx
//
//  Created by SmartRx-iOS on 04/04/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxFitbitLogin.h"

@interface SmartRxSettingsVc : UIViewController<UITableViewDataSource,UITableViewDelegate,FitbitUpdateDelegate>
@property(nonatomic,weak) IBOutlet UITableView *tableView;

@end
