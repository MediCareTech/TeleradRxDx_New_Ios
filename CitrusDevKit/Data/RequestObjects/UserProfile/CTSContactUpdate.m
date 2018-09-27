//
//  CTSContactUpdate.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 12/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSUtility.h"

#define FIRST_NAME_DEFAULT @"Tester"
#define LAST_NAME_DEFAULT @"Citrus"
#define EMAIL_DEFAULT @"tester@gmail.com"
#define MOBILE_NAME_DEFAULT @"9170164284"





@implementation CTSContactUpdate
@synthesize type, firstName, lastName, email, mobile, password;
- (instancetype)init {
  self = [super init];
  if (self) {
    password = nil;
    type = MLC_PROFILE_GET_CONTACT_QUERY_TYPE;
  }
  return self;
}

- (instancetype)initDefault {
    self = [super init];
    if (self) {
        password = nil;
        type = MLC_PROFILE_GET_CONTACT_QUERY_TYPE;
        [self substituteDefaults];
    }
    return self;
}

-(void)substituteDefaults{
    if([CTSUtility islengthInvalid:firstName]){
        firstName = FIRST_NAME_DEFAULT;
    }

    if([CTSUtility islengthInvalid:lastName]){
        lastName = LAST_NAME_DEFAULT;
    }
    
    if([CTSUtility islengthInvalid:email] || [CTSUtility validateEmail:email] == NO){
        email = EMAIL_DEFAULT;
    }
    
    if([CTSUtility islengthInvalid:mobile] || [CTSUtility validateMobile:mobile] == NO){
        mobile = MOBILE_NAME_DEFAULT;
    }
}

-(void)substituteFromProfile:(CTSProfileContactRes *)profile{
    if([CTSUtility islengthInvalid:firstName]){
        firstName = profile.firstName;
    }
    
    if([CTSUtility islengthInvalid:lastName]){
        lastName = profile.lastName;
    }
    
    if([CTSUtility islengthInvalid:email] || [CTSUtility validateEmail:email] == NO){
        email = profile.email;
    }
    
    if([CTSUtility islengthInvalid:mobile] || [CTSUtility validateMobile:mobile] == NO){
        mobile = profile.mobile;
    }


}

@end
