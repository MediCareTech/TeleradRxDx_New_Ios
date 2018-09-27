//
//  TrackListTVC.m
//  SmartCare
//
//  Created by PaceWisdom on 16/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "TrackListTVC.h"

@implementation TrackListTVC

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    _backgroundVw.backgroundColor = [UIColor whiteColor];
    // self.contentView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    _backgroundVw.layer.cornerRadius = 3.0;
    _backgroundVw.layer.masksToBounds = NO;
    
    _backgroundVw.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
    
    _backgroundVw.layer.shadowOffset = CGSizeMake( 0, 0);
    _backgroundVw.layer.shadowOpacity = 0.8;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - Setting data
-(void)setCellData:(NSDictionary *)dataDict
{
    _lblTrackname.text=[dataDict objectForKey:@"tracker"];
//    _imgviwTrackList.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[dataDict objectForKey:@"trackerid"]]];
}
@end
