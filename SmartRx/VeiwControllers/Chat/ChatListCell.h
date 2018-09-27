//
//  ChatListCell.h
//  SmartRx
//
//  Created by SmartRx-iOS on 22/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatHistoryResponseModel.h"

@interface ChatListCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UIImageView *thumbnailImageView;
@property(nonatomic,weak) IBOutlet UILabel *doctorName;
@property(nonatomic,weak) IBOutlet UILabel *lastMessageTime;

-(void)setCellData:(ChatHistoryResponseModel *)model;
@end
