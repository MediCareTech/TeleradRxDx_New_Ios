//
//  CTSElectronicCard.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 19/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSElectronicCardUpdate.h"
#import "CreditCard-Validator.h"

@implementation CTSElectronicCardUpdate
@synthesize type, name, ownerName, number, expiryDate, scheme, cvv;
- (instancetype)initCreditCard {
  self = [super init];
  if (self) {
    type = MLC_PROFILE_PAYMENT_CREDIT_TYPE;
  }
  return self;
}

- (instancetype)initDebitCard {
  self = [super init];
  if (self) {
    type = MLC_PROFILE_PAYMENT_DEBIT_TYPE;
  }
  return self;
}


@end
