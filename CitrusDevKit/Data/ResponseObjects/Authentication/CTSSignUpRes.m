//
//  CTSSignUpRes.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 27/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSSignUpRes.h"

@implementation CTSSignUpRes
@synthesize userName;
- (instancetype)initWithUserName:(NSString*)userNameArg {
  self = [super init];
  if (self) {
    self.userName = userNameArg;
  }
  return self;
}

- (NSString*)description {
  return [NSString stringWithFormat:@"%@ username", userName];
}

+ (JSONKeyMapper*)keyMapper {
  return [[JSONKeyMapper alloc] initWithDictionary:@{
    @"username" : @"userName",
  }];
}
@end
