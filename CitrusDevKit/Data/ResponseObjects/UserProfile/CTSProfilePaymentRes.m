//
//  CTSProfilePaymentRes.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 13/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSProfilePaymentRes.h"

@implementation CTSProfilePaymentRes
@synthesize type,defaultOption,paymentOptions;



- (void )getDefaultOptionOnTheTop{
    
    CTSPaymentOption *defaultOne = nil;
    if(defaultOption){
        for(CTSPaymentOption *option in paymentOptions){
            if([option.name isEqualToString:defaultOption]){
                defaultOne = [option copy];
                [paymentOptions removeObject:option];
                break;
            }
        }
        if (defaultOne) {
            [paymentOptions insertObject:defaultOne atIndex:0];
        }
    }
}

-(CTSPaymentOption *)getDefaultOption{
    
    CTSPaymentOption *defaultOne = nil;
    if(defaultOption){
        for(CTSPaymentOption *option in paymentOptions){
            if([option.name isEqualToString:defaultOption]){
                defaultOne = option;
                break;
            }
            
            
        }
        
    }
    return defaultOne;
}

- (NSArray *)getSavedNBPaymentOption {
    NSMutableArray *wellDOption = [[NSMutableArray alloc] init];
    for (CTSPaymentOption *object in self.paymentOptions) {
        if ([object.type isEqualToString:@"netbanking"]) {
            [wellDOption addObject:object];
        }
    }
    return wellDOption;
}

- (NSArray *)getSavedCCPaymentOption {
    NSMutableArray *wellDOption = [[NSMutableArray alloc] init];
    for (CTSPaymentOption *object in self.paymentOptions) {
        if ([object.type isEqualToString:@"credit"]) {
            [wellDOption addObject:object];
        }
    }
    return wellDOption;
}
- (NSArray *)getSavedDCPaymentOption {
    NSMutableArray *wellDOption = [[NSMutableArray alloc] init];
    for (CTSPaymentOption *object in self.paymentOptions) {
        if ([object.type isEqualToString:@"debit"]) {
            [wellDOption addObject:object];
        }
    }
    return wellDOption;
}
@end
