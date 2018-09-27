//
//  AppointmentTableViewCell.m
//  SmartRx
//
//  Created by PaceWisdom on 12/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "AppointmentTableViewCell.h"
#import "NSString+DateConvertion.h"
@implementation AppointmentTableViewCell

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
-(void)setCellData:(NSArray *)arrAppDetails row:(NSInteger)rowIndex
{
    
    self.lblDoctorName.text=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"dispname"];
    NSString *strDatTime=[NSString stringWithFormat:@"%@ %@",[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"appdate"],[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptime"]];
    self.lblDate.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
    //    self.lblStauts.text=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"];
    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 1)
        self.lblStauts.text = @"Pending";
    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 2)
        self.lblStauts.text = @"Confirmed";
    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 3)
        self.lblStauts.text = @"Completed";
    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 4)
        self.lblStauts.text = @"Cancelled";
    
    
    NSString *htmlString=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"reason"];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    if ([[attrStr string] length] > 0)
    {
        NSArray *tempArr = [[attrStr string] componentsSeparatedByString:@"***"];
        
        if ([tempArr count] == 3 && [[tempArr objectAtIndex:2] length])
        {
            self.lblReason.text=[tempArr objectAtIndex:2];
            self.lblDate.hidden=NO;
        }
        else if ([tempArr count] == 1)
        {
            self.lblReason.text=[attrStr string];
            self.lblDate.hidden=NO;
        }
        else
        {
            self.lblReason.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
            self.lblDate.hidden=YES;
        }
    }
    else{
        self.lblReason.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
        self.lblDate.hidden=YES;
    }
    CGRect frame = self.lblReason.frame;
    frame.size.width = 259.0; //you need to adjust this value
    self.lblReason.frame = frame;

    [self.lblReason sizeToFit];

    NSLog(@"apptype ==== %@",[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]);
    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]intValue] == 1 || [[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]intValue] == 3)
    {
        self.cellImagView.image=[UIImage imageNamed:@"icn_appointment.png"];
    }else if([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]intValue] == 2)
    {
        self.cellImagView.image=[UIImage imageNamed:@"icn_econsult.png"];
    }
    
}

@end
