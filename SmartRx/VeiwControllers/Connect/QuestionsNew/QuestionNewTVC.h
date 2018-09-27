//
//  QuestionNewTVC.h
//  SmartRx
//
//  Created by PaceWisdom on 04/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionNewTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgReadUnRead;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

-(void)setCellData:(NSArray *)arrData :(NSInteger)index;
@end
