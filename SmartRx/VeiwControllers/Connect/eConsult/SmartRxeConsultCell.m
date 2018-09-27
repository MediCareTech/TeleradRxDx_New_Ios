//
//  SmartRxeConsultCell.m
//  SmartRx
//
//  Created by Anil Kumar on 19/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import "SmartRxeConsultCell.h"
#import "NSString+DateConvertion.h"

@implementation SmartRxeConsultCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellData:(NSArray *)arrAppDetails row:(NSInteger)rowIndex
{
    
    if([[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"dispname"] != [NSNull null] && [[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"dispname"] && [[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"dispname"] length] > 0 )
        self.docName.text=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"dispname"];
    else
        self.docName.text = @"Doctor TBA";
    
    if([[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"deptname"] != [NSNull null])
        self.department.text=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"deptname"];
    else
        self.department.text = @"<null>";
    
    NSString *strDatTime=[NSString stringWithFormat:@"%@ %@",[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"appdate"],[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptime"]];
    self.eConsultDateTime.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
    
    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 1)
    {
        self.statusLabel.text = @"Pending";
        self.eConsultImage.image = [UIImage imageNamed:@"econsult_pending.png"];
    }
    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 2)
    {
        self.statusLabel.text = @"Confirmed";
        self.eConsultImage.image = [UIImage imageNamed:@"econsult_booked.png"];
    }
    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 3)
    {
        self.statusLabel.text = @"Completed";
        self.eConsultImage.image = [UIImage imageNamed:@"econsult_completed.png"];
    }
    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 4)
    {
        self.statusLabel.text = @"Cancelled";
        self.eConsultImage.image = [UIImage imageNamed:@"econsult_completed.png"];
    } else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 5)
    {
        self.statusLabel.text = @"Payment requested";
        self.eConsultImage.image = [UIImage imageNamed:@"econsult_completed.png"];
    }
    
    //    NSString *htmlString=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"reason"];
    //    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    //
    //    if ([[attrStr string] length] > 0)
    //    {
    //        self.lblReason.text=[attrStr string];
    //        self.lblDate.hidden=NO;
    //    }
    //    else{
//        self.lblReason.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
//        self.lblDate.hidden=YES;
//    }
//    //[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"reason"];
//    NSLog(@"apptype ==== %@",[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]);
//    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]intValue] == 1)
//    {
//        self.cellImagView.image=[UIImage imageNamed:@"icn_appointment.png"];
//    }else if([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]intValue] == 2)
//    {
//        self.cellImagView.image=[UIImage imageNamed:@"icn_econsult.png"];
//    }
//    
}

@end
