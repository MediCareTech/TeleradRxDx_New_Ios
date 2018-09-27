//
//  GetCarePlanBuyCell.m
//  SmartRx
//
//  Created by SmartRx-iOS on 16/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "GetCarePlanBuyCell.h"

@implementation GetCarePlanBuyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)clickOnSilverButton:(id)sender{
    if ([self.cellDelegate respondsToSelector:@selector(silverButtonClicked:)]) {
        [self.cellDelegate silverButtonClicked:_cellId];
    }
}
-(IBAction)clickOnGoldButton:(id)sender{
    if ([self.cellDelegate respondsToSelector:@selector(goldButtonClicked:)]) {
        [self.cellDelegate goldButtonClicked:_cellId];
    }
}-(IBAction)clickOnPlatinumButton:(id)sender{
    if ([self.cellDelegate respondsToSelector:@selector(platinumButtonClicked:)]) {
        [self.cellDelegate platinumButtonClicked:_cellId];
    }
}

@end
