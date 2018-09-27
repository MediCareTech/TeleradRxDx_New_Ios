//
//  SmartRxManagedCarePlanDetailsVC.h
//  SmartRx
//
//  Created by SmartRx-iOS on 14/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssignedManagedCareplanResponse.h"
#import "AssignedManagedCareplanServiceResponse.h"
@interface SmartRxManagedCarePlanDetailsVC : UIViewController

@property(nonatomic,strong) AssignedManagedCareplanResponse *selectedCarePlan;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UIView *carePlanSubView;
@property(nonatomic,weak) IBOutlet UITableView *carePlanTableView;


@end
