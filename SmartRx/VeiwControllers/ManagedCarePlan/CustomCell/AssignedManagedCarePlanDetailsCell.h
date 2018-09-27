//
//  AssignedManagedCarePlanDetailsCell.h
//  SmartRx
//
//  Created by SmartRx-iOS on 14/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssignedManagedCarePlanDetailsCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *careProgramProperty;
@property(nonatomic,weak) IBOutlet UILabel *careProgramTotal;
@property(nonatomic,weak) IBOutlet UILabel *careProgramAvailable;


@end
