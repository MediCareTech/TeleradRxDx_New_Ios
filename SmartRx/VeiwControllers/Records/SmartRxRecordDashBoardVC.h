//
//  SmartRxRecordDashBoardVC.h
//  SmartRx
//
//  Created by Anil Kumar on 03/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxRecordDashBoardVC : UIViewController<UITableViewDataSource,UITableViewDelegate,loginDelegate,MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblRecordDashBoard;
@end
