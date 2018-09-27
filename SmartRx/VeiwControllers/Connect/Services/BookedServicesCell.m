//
//  BookedServicesCell.m
//  SmartRx
//
//  Created by Gowtham on 05/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "BookedServicesCell.h"

@implementation BookedServicesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)clickOnDetailsButton:(id)sender{
    if ([self.delegate respondsToSelector:@selector(detailButtonClicked:)]) {
        [self.delegate detailButtonClicked:_cellId];
    }
}

@end
