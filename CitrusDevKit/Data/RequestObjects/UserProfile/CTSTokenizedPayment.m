//
//  CTSTokenizedPayment.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 24/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSTokenizedPayment.h"

@implementation CTSTokenizedPayment
@synthesize type, cvv, token;

- (instancetype)initWithToken:(NSString*)tokenArg cvv:(NSString*)cvvArg {
  self = [super init];
  if (self) {
    cvv = cvvArg;
    token = tokenArg;
  }
  return self;
}
@end
