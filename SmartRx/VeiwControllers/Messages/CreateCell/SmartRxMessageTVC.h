//
//  SmartRxMessageTVC.h
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@protocol swipeCellDelegate <NSObject>

-(void)swipeCellRightDoneBtnClicked:(UITableViewCell *)sender;
-(void)swipeCellRightUpdateBtnClicked:(UITableViewCell *)sender;

@end

@interface SmartRxMessageTVC : SWTableViewCell<SWTableViewCellDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imgViewMessages;
@property (strong, nonatomic) IBOutlet UILabel *lblSenderName;
@property (strong, nonatomic) IBOutlet UILabel *lblMessage;

@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) id swipeCellDelegate;
@property (weak, nonatomic) IBOutlet UIImageView *imgReadUnread;

-(void)setmessageInfo:(NSDictionary *)messageDict;
@end
