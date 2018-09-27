//
//  SmartRxServicesCell.h
//  SmartRx
//
//  Created by Manju Basha on 19/10/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxServicesCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *serviceImage;
@property (weak, nonatomic) IBOutlet UILabel *packageName;
@property (weak, nonatomic) IBOutlet UILabel *serviceStatus;
@property (weak, nonatomic) IBOutlet UILabel *paymentStatus;
@property (weak, nonatomic) IBOutlet UILabel *servicesFee;
@property (weak, nonatomic) IBOutlet UILabel *servicesDiscountFee;
@property (weak, nonatomic) IBOutlet UILabel *servicesDateTime;
-(void)setCellData:(NSArray *)arrAppDetails row:(NSInteger)rowIndex;
@end
