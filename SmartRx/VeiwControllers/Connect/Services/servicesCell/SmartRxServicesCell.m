//
//  SmartRxServicesCell.m
//  SmartRx
//
//  Created by Manju Basha on 19/10/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxServicesCell.h"
#import "NSString+DateConvertion.h"

@implementation SmartRxServicesCell
{
    NSInteger finalCost, actualCost;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setCellData:(NSArray *)arrServDetails row:(NSInteger)rowIndex
{
    
    if([[arrServDetails objectAtIndex:rowIndex]objectForKey:@"service_name"] != [NSNull null])
        self.packageName.text=[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"service_name"];
    else
        self.packageName.text = @"";
    
    if([[arrServDetails objectAtIndex:rowIndex]objectForKey:@"paystatus"] != [NSNull null])
    {
        NSString *paystr = [[arrServDetails objectAtIndex:rowIndex]objectForKey:@"paystatus"];
        if ([paystr caseInsensitiveCompare:@"PAID"])
            self.paymentStatus.text = @":  Not Paid";
        else
            self.paymentStatus.text = @":  Paid";

    }
//        self.paymentStatus.text=[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"paystatus"];
    else
        self.paymentStatus.text = @"Details Not available";
    
    NSString *dateStr = [NSString timeFormating:[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"service_date"] funcName:@"servicesBooking"];
    self.servicesDateTime.text= [NSString stringWithFormat:@"%@ %@", dateStr, [[arrServDetails objectAtIndex:rowIndex]objectForKey:@"service_time"]];
    
    NSString *fee = [[arrServDetails objectAtIndex:rowIndex]objectForKey:@"service_amount"];
    self.servicesFee.text = [NSString stringWithFormat:@"Rs %@", fee];
    if ([[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"appstatus"] integerValue] == 1)
    {
        self.serviceStatus.text = @":  Pending";
        self.serviceImage.image = [UIImage imageNamed:@"services_pending.png"];
    }
    else if ([[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"appstatus"] integerValue] == 2)
    {
        self.serviceStatus.text = @":  Confirmed";
        self.serviceImage.image = [UIImage imageNamed:@"services_booked.png"];
    }
    else if ([[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"appstatus"] integerValue] == 3)
    {
        self.serviceStatus.text = @":  Completed";
        self.serviceImage.image = [UIImage imageNamed:@"services_cancelled.png"];
    }
    else if ([[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"appstatus"] integerValue] == 4)
    {
        self.serviceStatus.text = @":  Cancelled";
        self.serviceImage.image = [UIImage imageNamed:@"services_cancelled.png"];
    }
    finalCost = [[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"paid_amount"] integerValue];
    if ([[arrServDetails objectAtIndex:0]objectForKey:@"service_amount"] != [NSNull null])
    {
        if([[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"service_amount"] integerValue] > 0)
        {
            if ([[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"service_amount"] integerValue] != [[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"paid_amount"] integerValue])
            {
                [self setAutoDiscountValue:[[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"service_amount"] integerValue]];
            }
            else
            {
                self.servicesDiscountFee.text = @"";
                finalCost = [[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"paid_amount"] integerValue];
            }
            
        }
    }
    else
    {
        self.servicesFee.text = @"Free";
        self.servicesDiscountFee.text = @"";
        if ([[arrServDetails objectAtIndex:0]objectForKey:@"service_amount"] != [NSNull null])
            finalCost = [[[arrServDetails objectAtIndex:rowIndex]objectForKey:@"service_amount"] integerValue];
        else
            finalCost = 0;
    }
    
    
    
}
-(void)setAutoDiscountValue:(NSInteger)costReceived
{
    if(costReceived != 0 && costReceived != finalCost)
    {
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs %d", costReceived]];
        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                value:@2
                                range:NSMakeRange(0, [attributeString length])];
        self.servicesFee.attributedText = attributeString;
        if (finalCost > 0)
        {
            self.servicesDiscountFee.text = [NSString stringWithFormat:@"Rs %d", (int)finalCost];
        }
        else
        {
            self.servicesDiscountFee.text = @"Free";
        }
        
    }
    else if (finalCost == 0)
    {
        self.servicesDiscountFee.text = @"Free";
    }
}
@end
