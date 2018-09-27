//
//  AnswerDetailsTVC.h
//  SmartRx
//
//  Created by PaceWisdom on 20/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnswerDetailsTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeAnswer;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imgViwAnswer;
@property (weak, nonatomic) IBOutlet UIImageView *imgviwDivider;
-(void)setAnswerData:(NSArray *)arrAnswers row:(NSInteger)index lblHeight:(CGFloat)lblHeight;

@end
