//
//  SmartRxBookServiceCell.m
//  SmartRx
//
//  Created by Gowtham on 12/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxBookServiceCell.h"
#import "UIImageView+AFNetworking.h"
@implementation SmartRxBookServiceCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setService:(ServicesResponseModel *)service{
    
    _service = service;
       NSString *escapedString = [_service.imagePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"%s%@",kBaseUrlQAImg,escapedString];
   
    [self.thumbnailImage setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
     [self setNeedsLayout];
}
-(IBAction)clickOnSelectButton:(id)sender{
    if ([self.cellDelegate respondsToSelector:@selector(cellSubmitButtonClicked:)]) {
        [self.cellDelegate cellSubmitButtonClicked:_cellId];
    }
}

@end
