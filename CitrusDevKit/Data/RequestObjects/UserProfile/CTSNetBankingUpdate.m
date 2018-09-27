//
//  CTSNetBankingUpdate.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 19/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSNetBankingUpdate.h"

@implementation CTSNetBankingUpdate
@synthesize type, name, bank, code, issuerCode, token;
- (instancetype)init {
  self = [super init];
  if (self) {
    type = MLC_PROFILE_PAYMENT_NETBANKING_TYPE;
  }
  return self;
}

@end
