//
//  QuestionNewTVC.m
//  SmartRx
//
//  Created by PaceWisdom on 04/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "QuestionNewTVC.h"
#import "NSString+DateConvertion.h"

@implementation QuestionNewTVC

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
-(void)setCellData:(NSArray *)arrData :(NSInteger)index
{
    self.lblTitle.text=[[arrData objectAtIndex:index]objectForKey:@"qtitle"];
    
    
    NSString *htmlString=[[[arrData objectAtIndex:index]objectForKey:@"qdesc"]stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
       
    self.lblDescription.text=[attrStr string];//[[[arrData objectAtIndex:index]objectForKey:@"qdesc"]stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    NSString *modifiedDate=[NSString stringWithFormat:@"%@",[[arrData objectAtIndex:index]objectForKey:@"modified"]];
    self.lblTime.text=[NSString convertStringToDate:modifiedDate];
    if ([[[arrData objectAtIndex:index]objectForKey:@"iscompleted"]integerValue] == 1) {
        self.imgReadUnRead.image=[UIImage imageNamed:@"icn_click.png"];
    }
    else if ([[[arrData objectAtIndex:index]objectForKey:@"askrfeed"]integerValue] == 2) {
        self.imgReadUnRead.image=[UIImage imageNamed:@"icn_chat_bubble.png"];
    }
    else{
        self.imgReadUnRead.image=[UIImage imageNamed:@"icn_bubble.png"];
    }
}
@end
