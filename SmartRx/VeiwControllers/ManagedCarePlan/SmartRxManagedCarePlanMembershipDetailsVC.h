//
//  SmartRxManagedCarePlanMembershipDetailsVC.h
//  SmartRx
//
//  Created by SmartRx-iOS on 17/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetCarePlanResponseModel.h"
#import "MembershipTypesResponseModel.h"
#import "ResponseModels.h"

@protocol BuyDelegate <NSObject>
-(void)updatePurchaseDetails:(CareWellnessCategoryItemResponseModel *)membership;
@end

@interface SmartRxManagedCarePlanMembershipDetailsVC : UIViewController

@property(nonatomic,strong) GetCarePlanResponseModel *selectedCarePlan;
@property(nonatomic,strong) NSArray *membershipDetails;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *careProgramName;

@property(nonatomic,weak) id<BuyDelegate> delegate;

@property (retain, nonatomic) UIPickerView *dependentsPickerView;
@property (strong, nonatomic) UIView *actionSheet;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@end
