//
//  CheckOutCell.m
//  SmartRx
//
//  Created by Gowtham on 20/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "CheckOutCell.h"

@implementation CheckOutCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundCardView.layer.borderWidth = 1.0f;
    self.backgroundCardView.layer.borderColor = [UIColor blueColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)clickOnDeleteButton:(id)sender{
    if ([self.delegate respondsToSelector:@selector(deleteButtonClicked:)]) {
        [self.delegate deleteButtonClicked:_cellId];
    }
}
@end
