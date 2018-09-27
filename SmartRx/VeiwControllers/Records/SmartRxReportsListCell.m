//
//  SmartRxReportsListCell.m
//  SmartRx
//
//  Created by Gowtham on 11/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxReportsListCell.h"

@implementation SmartRxReportsListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)clickOnImageButton:(id)sender{
    if ([self respondsToSelector:@selector(clickOnImageButton:)]) {
        [self.delagte clickOnImageButton:self.cellId];
    }
}

@end
