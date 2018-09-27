//
//  CTSUserDetails.m
//  RestFulltester
//
//  Created by Raji Nair on 24/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSUserDetails.h"
#import "CTSContactUpdate.h"

@implementation CTSUserDetails
@synthesize email, firstName, lastName, mobileNo, address;
- (instancetype)initWith:(CTSContactUpdate*)contact
                 address:(CTSUserAddress*)addressArg {
  self = [super init];
  if (self) {
    email = contact.email;
    firstName = contact.firstName;
    lastName = contact.lastName;
    mobileNo = contact.mobile;
    address = addressArg;
  }
  return self;
}

@end
