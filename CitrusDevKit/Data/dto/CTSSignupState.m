//
//  SignupState.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 10/09/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSSignupState.h"

@implementation CTSSignupState
- (instancetype)initWithEmail:(NSString*)email
                       mobile:(NSString*)mobile
                     password:(NSString*)password {
  self = [super init];
  if (self) {
    self.email = email;
    self.mobile = mobile;
    self.password = password;
  }
  return self;
}
@end
