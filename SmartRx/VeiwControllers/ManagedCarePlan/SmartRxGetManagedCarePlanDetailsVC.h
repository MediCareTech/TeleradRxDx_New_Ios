//
//  SmartRxGetManagedCarePlanDetailsVC.h
//  SmartRx
//
//  Created by SmartRx-iOS on 15/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetCarePlanResponseModel.h"
@interface SmartRxGetManagedCarePlanDetailsVC : UIViewController

@property(nonatomic,strong) GetCarePlanResponseModel *selectedCarePlan;

@property(nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property(nonatomic,weak) IBOutlet UITableView *tableView;

@end
