//
//  AppointmentTableViewCell.h
//  SmartRx
//
//  Created by PaceWisdom on 12/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppointmentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblDoctorName;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblStauts;
@property (weak, nonatomic) IBOutlet UILabel *lblReason;
@property (weak, nonatomic) IBOutlet UIImageView *cellImagView;
-(void)setCellData:(NSArray *)arrAppDetails row:(NSInteger)rowIndex;
@end
