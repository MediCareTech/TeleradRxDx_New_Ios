//
//  CTSPrepaidUser.m
//  CTS iOS Sdk
//
//  Created by Yadnesh on 9/22/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "CTSPrepaidUser.h"

@implementation CTSPrepaidUser
@synthesize firstName,lastName,email,mobileNo,street1,street2,city,state,country,zip;
- (instancetype)initWithContact:(CTSContactUpdate *)contact address:(CTSUserAddress*)address
{
    self = [super init];
    if (self) {
        self.firstName = contact.firstName;
        self.lastName = contact.lastName;
        self.email = contact.email;
        self.mobileNo = contact.mobile;
        self.street1 = address.street1;
        self.street2 = address.street2;
        self.city = address.city;
        self.state = address.state;
        self.country = address.country;
        self.zip = address.zip;
    }
    return self;
}
@end
