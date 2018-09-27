//
//  CTSRuleInfo.m
//  CTS iOS Sdk
//
//  Created by Yadnesh on 9/1/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "CTSRuleInfo.h"
#import "CTSUtility.h"
@implementation CTSRuleInfo
@synthesize operationType;
@synthesize ruleName,alteredAmount,originalAmount;
-(NSString *)toDpTypeString{
    
    NSString *typeString = nil;
    switch (operationType) {
        case DPRequestTypeValidate:
            typeString = @"validateRule";
            break;
        case DPRequestTypeSearchAndApply:
            typeString = @"searchAndApply";
            break;
        case DPRequestTypeCalculate:
            typeString = @"calculatePricing";
            break;
        default:
            break;
    }
    return typeString;
}

-(void)amountCorrections{
    originalAmount = [CTSUtility convertToDecimalAmountString:originalAmount];
    alteredAmount = [CTSUtility convertToDecimalAmountString:alteredAmount];

}
@end
