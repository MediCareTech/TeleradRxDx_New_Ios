//
//  AnswerDetailsTVC.m
//  SmartRx
//
//  Created by PaceWisdom on 20/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "AnswerDetailsTVC.h"
#import "NSString+DateConvertion.h"

@implementation AnswerDetailsTVC

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
-(void)setAnswerData:(id )arrAnswers row:(NSInteger)index lblHeight:(CGFloat)lblHeight
{
    self.lblTitle.text=[NSString stringWithFormat:@"%@ Says:",[arrAnswers objectForKey:@"dispname"]];
    
    
    NSString *htmlString=[[arrAnswers objectForKey:@"sentmsg"]stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];

    self.lblDescription.text=[attrStr string];
    NSString *strTime=[arrAnswers objectForKey:@"senton"];
    NSArray *arrTemp=[strTime componentsSeparatedByString:@" "];
    NSString *strDate=[[arrTemp objectAtIndex:0] substringToIndex:[[arrTemp objectAtIndex:0] length]-5];
    NSLog(@"str date === %@",strDate);
    self.lblTimeAnswer.text=[NSString stringWithFormat:@"%@ %@ %@",strDate,[arrTemp objectAtIndex:1],[arrTemp objectAtIndex:2]];
    //[[arrAnswers objectForKey:@"sentmsg"]stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    if ([self.lblTitle.text length] > 30)
    {
        self.lblDescription.frame = CGRectMake(self.lblDescription.frame.origin.x, self.lblTitle.frame.size.height+20, self.lblDescription.frame.size.width, self.lblDescription.frame.size.height);
        
    }

}

@end
