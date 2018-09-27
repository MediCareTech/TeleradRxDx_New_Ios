//
//  SmartRxMessageTVC.m
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxMessageTVC.h"
#import "NSString+DateConvertion.h"

@implementation SmartRxMessageTVC
{
    NSInteger postop_rectype;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setmessageInfo:(NSDictionary *)messageDict
{
    //
    
    NSLog(@"operation === %@",[messageDict objectForKey:@"operation"]);
    [self addingSwipe:messageDict];
    
    if ([[messageDict objectForKey:@"status"] isEqualToString:@"1"])
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"shell_bg_msg.png"]]];
    else
        [self setBackgroundColor:[UIColor whiteColor]];
    
   
//    if([[messageDict objectForKey:@"operation"] isEqualToString:@"1"])
//    {
//         self.lblSenderName.text=@"Care Message";
//        self.imgViewMessages.image=[UIImage imageNamed:@"icn_care_msg.png"];
//        
//    }
//    else if([[messageDict objectForKey:@"operation"] isEqualToString:@"2"])
//    {
//         self.lblSenderName.text=@"Promotions";
//        self.imgViewMessages.image=[UIImage imageNamed:@"icn_msg_promotion.png"];
//    }
//    else if([[messageDict objectForKey:@"operation"] isEqualToString:@"3"])
//    {
//         self.lblSenderName.text=@"Communication";
//        self.imgViewMessages.image=[UIImage imageNamed:@"icn_communication.png"];
//    }
//    else if([[messageDict objectForKey:@"operation"] isEqualToString:@"4"])
//    {
//         self.lblSenderName.text=@"Appointment";
//        self.imgViewMessages.image=[UIImage imageNamed:@"icn_msg_app.png"];
//    }
//    else if([[messageDict objectForKey:@"operation"] isEqualToString:@"5"])
//    {
//         self.lblSenderName.text=@"Question & Answer Alert";
//        self.imgViewMessages.image=[UIImage imageNamed:@"icn_qna.png"];
//    }
//    else if([[messageDict objectForKey:@"operation"] isEqualToString:@"6"])
//    {
//      self.lblSenderName.text=@"Feedback Alert";
//        self.imgViewMessages.image=[UIImage imageNamed:@"icn_feedback.png"];
//    }
    postop_rectype = [[messageDict objectForKey:@"postop_rectype"]integerValue];
    if([[messageDict objectForKey:@"postop_rectype"]integerValue] > 0)
        _imgViewMessages.image = [UIImage imageNamed:@"c.png"];
    else
        _imgViewMessages.image = [UIImage imageNamed:@"m.png"];
    
    if ([[messageDict objectForKeyedSubscript:@"status"] isEqualToString:@"2"])
        _imgReadUnread.hidden=NO;
    else
        _imgReadUnread.hidden=YES;
    
   // self.lblSenderName.text=[messageDict objectForKey:@"Name"];
    NSString *alerttxt=[messageDict objectForKey:@"alerttxt"];
    
    self.lblMessage.text=[self convertHTML:alerttxt];
    self.lblTime.text=[NSString convertStringToDate:[NSString stringWithFormat:@"%@",[messageDict objectForKey:@"updateddate"]]];
    
}

-(NSString *)convertHTML :(NSString *)html {
    
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    html = [html stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];    
    return html;
}
-(void)addingSwipe:(NSDictionary *)messageDict
{
    // Add utility buttons
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    if([[messageDict objectForKey:@"postop_rectype"]integerValue] > 0)
    {

            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:[UIImage imageNamed:@"view_msg.png"]];
            [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:[UIImage imageNamed:@"ignore_msg.png"]];
    }
    else 
    {
        if ([[messageDict objectForKeyedSubscript:@"status"] isEqualToString:@"2"])
        {
            if([[messageDict objectForKey:@"dcw_type"]integerValue] == 1 || [[messageDict objectForKey:@"dcw_type"]integerValue] == 2)
            {
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:[UIImage imageNamed:@"book_msg.png"]];
            }
            else
                [rightUtilityButtons sw_addUtilityButtonWithColorAndDisable:[UIColor clearColor] icon:[UIImage imageNamed:@"task_complete_msg.png"]];
        }
        else
        {
            NSLog(@"DCW_TYPE : %ld", (long)[[messageDict objectForKey:@"dcw_type"]integerValue]);
            if([[messageDict objectForKey:@"dcw_type"]integerValue] == 1 || [[messageDict objectForKey:@"dcw_type"]integerValue] == 2)
            {
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:[UIImage imageNamed:@"book_msg.png"]];
            }
            else
                [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:[UIImage imageNamed:@"done_msg.png"]];
        }
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:[UIImage imageNamed:@"ignore_msg.png"]];
    }
    
    self.rightUtilityButtons = rightUtilityButtons;
    self.delegate = self;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            [self hideUtilityButtonsAnimated:YES];
            [self setBackgroundColor:[UIColor whiteColor]];
            _imgReadUnread.hidden=NO;
            [self.swipeCellDelegate performSelectorOnMainThread:@selector(swipeCellRightDoneBtnClicked:) withObject:self waitUntilDone:YES];
            break;
        }
        case 1:
        {
            [self hideUtilityButtonsAnimated:YES];
            
            [self.swipeCellDelegate performSelectorOnMainThread:@selector(swipeCellRightUpdateBtnClicked:) withObject:self waitUntilDone:YES];
            break;
        }
        default:
            break;
    }
}
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

@end
