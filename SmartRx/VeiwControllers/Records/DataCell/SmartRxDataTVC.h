//
//  SmartRxDataTVC.h
//  SmartRx
//
//  Created by Pace on 14/07/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxDataTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblByMe;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) NSDictionary *dictCategory;

-(void)setDataForCell:(id)data;

@end
