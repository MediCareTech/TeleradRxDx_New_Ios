//
//  SmartRxeConsultCell.h
//  SmartRx
//
//  Created by Anil Kumar on 19/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxeConsultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eConsultImage;
@property (weak, nonatomic) IBOutlet UILabel *docName;
@property (weak, nonatomic) IBOutlet UILabel *department;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *eConsultDateTime;

-(void)setCellData:(NSArray *)arrAppDetails row:(NSInteger)rowIndex;
@end
