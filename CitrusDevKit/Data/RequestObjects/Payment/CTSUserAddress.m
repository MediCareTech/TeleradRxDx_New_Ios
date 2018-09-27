//
//  CTSUserAddress.m
//  RestFulltester
//
//  Created by Raji Nair on 24/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSUserAddress.h"
#import "CTSUtility.h"
#define DEFAULT_CITY @"Mumbai"
#define DEFAULT_COUNTRY @"INDIA"
#define DEFAULT_STATE @"Maharashtra"
#define DEFAULT_STREET1 @"streetone"
#define DEFAULT_STREET2 @"streettwo"
#define DEFAULT_ZIP @"400052"


@implementation CTSUserAddress
@synthesize city, country, state, street1, street2, zip;




- (instancetype)initDefault {
    self = [super init];
    if (self) {
        [self substituteDefaults];
    }
    return self;
}

-(void)substituteDefaults{
    if([CTSUtility islengthInvalid:city]){
        city = DEFAULT_CITY;
    }
    
    if([CTSUtility islengthInvalid:country]){
        country = DEFAULT_COUNTRY;
    }
    
    if([CTSUtility islengthInvalid:state]){
        state = DEFAULT_STATE;
    }
    
    if([CTSUtility islengthInvalid:street1]){
        street1 = DEFAULT_STREET1;
    }
    
    if([CTSUtility islengthInvalid:street2]){
        street2 = DEFAULT_STREET2;
    }
    
    if([CTSUtility islengthInvalid:zip]){
        zip = DEFAULT_ZIP;
    }
    
    
}
@end
