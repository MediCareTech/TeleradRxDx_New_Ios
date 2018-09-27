//
//  SmartRxImageTVC.m
//  SmartRx
//
//  Created by Pace on 15/07/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxImageTVC.h"
#import "UIImageView+WebCache.h"

@implementation SmartRxImageTVC

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
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - image
-(void)setImageToData:(NSArray *)arrImages startCount:(NSInteger)imageCount imgType:(BOOL)QA{
    self.imageArr = arrImages;
    NSInteger imageStartCount;
    
    if ([arrImages count] < 4 || imageCount == 0) {
        imageStartCount = 0;
        self.startCountForCell = imageStartCount;
    }else{
        imageStartCount = (imageCount * 3)-1 ;
        self.startCountForCell = imageStartCount;
    }
    int j =0;
    for (j = 0; j < 3; j++) {
        UIButton *btn = (UIButton *)[self viewWithTag:3000+j];
        btn.hidden = YES;
        btn.imageView.image = nil;
    }
    j = 0;
    for (NSInteger i = imageStartCount; i< [arrImages count]; i++, j++) {
        if ((imageStartCount + 4) == i ) {
            break;
        }
        __block __weak UIButton *btn = (UIButton *)[self viewWithTag:3000+j];
        btn.hidden = NO;
        [btn setBackgroundImage:[UIImage imageNamed:@"img_placeholder@2x.png"] forState:UIControlStateNormal];
        if (QA) {
            [btn.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s%@",kBaseUrlQAImg,arrImages[i]]] placeholderImage:[UIImage imageNamed:@"img_placeholder@2x.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                if (error) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"img_placeholder@2x.png"] forState:UIControlStateNormal];
                }else
                    [btn setBackgroundImage:image forState:UIControlStateNormal];
            }];
        }else{
            [btn.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s%@",kBaseUrlLabReport,arrImages[i]]] placeholderImage:[UIImage imageNamed:@"img_placeholder@2x.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                if (error) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"img_placeholder@2x.png"] forState:UIControlStateNormal];
                }else
                    [btn setBackgroundImage:image forState:UIControlStateNormal];
            }];
        }
    }
}

- (IBAction)imageBtnClicked:(id)sender {
    NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
    NSArray *arrExtensionType = [self.imageArr[((UIButton *)sender).tag - 3000+self.startCountForCell] componentsSeparatedByString:@"."];
    if ([arrExtensionType count] && [arrFileType containsObject:arrExtensionType[([arrExtensionType count]-1)]]) {
        [self.delegateImg openQlPreview:self.imageArr[((UIButton *)sender).tag - 3000+self.startCountForCell]];
    }else
        [self.delegateImg ShowImageInMainView:self.imageArr[((UIButton *)sender).tag - 3000+self.startCountForCell]];
}

@end
