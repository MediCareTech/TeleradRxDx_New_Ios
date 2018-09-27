//
//  QuestionDetailsTVC.m
//  SmartRx
//
//  Created by PaceWisdom on 20/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "QuestionDetailsTVC.h"
#import "NSString+DateConvertion.h"

@implementation QuestionDetailsTVC

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

-(void)setQuestionData:(NSDictionary *)dictData height:(CGFloat)lblHeight
{
    self.lblTitle.text=[dictData objectForKey:@"title"];
    self.lblTime.text=[NSString timeFormating:[dictData objectForKey:@"time"] funcName:@"dataTVC"];
    NSString *htmlString=[[dictData objectForKey:@"des"]stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    self.lblDescription.text=[attrStr string];
    
//    [self.lblTime setNumberOfLines:0];
//    [self.lblTime sizeToFit];
    
//    [self.lblTitle setNumberOfLines:0];
    [self.lblTitle sizeToFit];
    self.lblTitle.textAlignment = NSTextAlignmentJustified;
//    [self.lblDescription setNumberOfLines:0];
    [self.lblDescription sizeToFit];
    self.lblDescription.textAlignment = NSTextAlignmentJustified;
    if ([self.lblTitle.text length] > 60)
    {
        self.lblTime.frame = CGRectMake(self.lblTime.frame.origin.x, self.lblTitle.frame.size.height+10, self.lblTime.frame.size.width, self.lblTime.frame.size.height);
        self.lblDescription.frame = CGRectMake(self.lblDescription.frame.origin.x, self.lblTitle.frame.size.height+self.lblTime.frame.size.height+20, self.lblDescription.frame.size.width, self.lblDescription.frame.size.height);
        
    }
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"yestime"] isEqualToString:@"Yesterday"])
    {
        NSArray *arrTemp=[self.lblTime.text componentsSeparatedByString:@" "];
        self.lblTime.text=[NSString stringWithFormat:@"%@,%@ %@",@"Yesterday",[arrTemp objectAtIndex:1],[arrTemp objectAtIndex:2]];
    }
    self.imgviwQuesDivider.backgroundColor=[UIColor blueColor];
    if ([[dictData objectForKey:@"Answred"]integerValue] == 1)
    {
        self.imgViewQuestion.image=[UIImage imageNamed:@"icn_click.png"];
    }
    else if ([[dictData objectForKey:@"askrfeed"]integerValue] == 2) {
        self.imgViewQuestion.image=[UIImage imageNamed:@"icn_chat_bubble.png"];;
    }
    else{
        self.imgViewQuestion.image=[UIImage imageNamed:@"icn_bubble.png"];
    }
    
    
}
@end
