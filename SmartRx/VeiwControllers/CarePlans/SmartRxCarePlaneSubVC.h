//
//  SmartRxCarePlaneSubVC.h
//  SmartRx
//
//  Created by PaceWisdom on 09/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxCarePlaneSubVC : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblCarePlanSub;
@property (weak, nonatomic) IBOutlet UILabel *lblNoCarePlans;
@property (strong, nonatomic) NSArray *arrCareSubPlans;
@property (assign, nonatomic) NSString *strOpId;
@property (assign, nonatomic) NSString *strTitle;
@property (strong, nonatomic) NSDictionary *dictCarplanIcons;

@end
