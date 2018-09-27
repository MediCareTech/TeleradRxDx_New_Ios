//
//  AssignedCareplanTableCell.h
//  SmartRx
//
//  Created by SmartRx-iOS on 14/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssignedCareplanTableCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel *careProgramNameLbl;
@property(nonatomic,weak) IBOutlet UILabel *expireDate;

@end
