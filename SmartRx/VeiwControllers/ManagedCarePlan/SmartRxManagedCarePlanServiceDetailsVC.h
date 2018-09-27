//
//  SmartRxManagedCarePlanServiceDetailsVC.h
//  SmartRx
//
//  Created by SmartRx-iOS on 15/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssignedManagedCareplanResponse.h"
#import "AssignedManagedCareplanServiceResponse.h"
#import "ServicesResponseModel.h"

@protocol ServiceDelegate <NSObject>

-(void)moveToServiceViewController:(ServicesResponseModel *)model;

@end

@interface SmartRxManagedCarePlanServiceDetailsVC : UIViewController

@property(nonatomic,strong) AssignedManagedCareplanResponse *selectedCarePlan;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *noAppsLbl;

@property(nonatomic,weak) id<ServiceDelegate> delegate;


@end
