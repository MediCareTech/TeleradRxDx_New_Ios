//
//  LocationCell.m
//  SmartRx
//
//  Created by Gowtham on 14/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "LocationCell.h"

@implementation LocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)clckOnDeleteButton:(id)sender{
    if ([self.delegate respondsToSelector:@selector(deleteButtonClicked:)]) {
        [self.delegate deleteButtonClicked:self.cellId];
    }
}


@end
