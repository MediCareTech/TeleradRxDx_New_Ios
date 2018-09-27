//
//  SmartRxCarePlanVC.h
//  SmartRx
//
//  Created by PaceWisdom on 09/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxCommonClass.h"
@interface SmartRxCarePlanVC : UIViewController<UITableViewDelegate,UITableViewDataSource,loginDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tblCarePlan;
@property (strong, nonatomic) IBOutlet UILabel *lblNoCarePlans;
@property (strong, nonatomic) NSMutableArray *arrCarePlans;
- (IBAction)getCarePlan:(id)sender;

@end
