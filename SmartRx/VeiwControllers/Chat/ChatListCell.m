//
//  ChatListCell.m
//  SmartRx
//
//  Created by SmartRx-iOS on 22/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "ChatListCell.h"
#import "UIImageView+WebCache.h"

@implementation ChatListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.thumbnailImageView.layer.cornerRadius = 25;
    self.thumbnailImageView.layer.masksToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setCellData:(ChatHistoryResponseModel *)model{
    self.doctorName.text = model.doctorName;
    self.lastMessageTime.text = model.lastMessageTime;
    NSString *escapedString = [model.doctorProfilePic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //NSLog(@"profilepic.....:%@",escapedString);
    [self.thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:escapedString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            self.thumbnailImageView.image = [UIImage imageNamed:@"BlankUser.jpg"];                    }
        else {
            self.thumbnailImageView.image = image;
        }
    }];
}
@end
