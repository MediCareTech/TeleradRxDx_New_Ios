//
//  QuestionDetailsTVC.h
//  SmartRx
//
//  Created by PaceWisdom on 20/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionDetailsTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeAnswer;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewQuestion;
@property (weak, nonatomic) IBOutlet UIImageView *imgviwQuesDivider;

//-(void)setQuestionData:(NSDictionary *)dictData;
-(void)setQuestionData:(NSDictionary *)dictData height:(CGFloat)lblHeight;

@end
