//
//  SmartRxPHRVC.h
//  SmartRx
//
//  Created by Anil Kumar on 03/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxPHRVC : UIViewController<UITableViewDataSource,UITableViewDelegate,loginDelegate,MBProgressHUDDelegate>
@property (assign, nonatomic) NSString *strTitle;
@property (nonatomic, retain) NSArray *healthMeasures;
@property (nonatomic, weak) IBOutlet UITableView *phrListTable;
@end
