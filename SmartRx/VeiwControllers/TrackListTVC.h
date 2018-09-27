//
//  TrackListTVC.h
//  SmartCare
//
//  Created by PaceWisdom on 16/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TrackListTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTrackname;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageVw;
@property (weak, nonatomic) IBOutlet UIView *backgroundVw;

-(void)setCellData:(NSDictionary *)dataDict;
@end
