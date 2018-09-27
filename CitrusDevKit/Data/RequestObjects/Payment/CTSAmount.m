//
//  CTSAmount.m
//  RestFulltester
//
//  Created by Raji Nair on 24/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSAmount.h"

@implementation CTSAmount
@synthesize currency, value;
- (instancetype)init
{
    self = [super init];
    if (self) {
        currency = @"INR";
    }
    return self;
}

- (instancetype)initWithValue:(NSString *)valueArg
{
    self = [super init];
    if (self) {
        currency = @"INR";
        value = valueArg;
        

    }
    return self;
}
@end
