//
//  CTSDyPPaymentInfo.m
//  CTS iOS Sdk
//
//  Created by Yadnesh on 7/27/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "CTSDyPPaymentInfo.h"
@implementation CTSDyPPaymentInfo
- (instancetype)initNetbankMode
{
    self = [super init];
    if (self) {
        _paymentMode = NETBANKING_MODE;
    }
    return self;
}

- (instancetype)initCreditCardMode
{
    self = [super init];
    if (self) {
        _paymentMode = CREDIT_CARD_MODE;
    }
    return self;
}

- (instancetype)initDebitCardMode
{
    self = [super init];
    if (self) {
        _paymentMode = DEBIT_CARD_MODE;
    }
    return self;
}

- (instancetype)initCitrusWalletMode
{
    self = [super init];
    if (self) {
        _paymentMode = CITRUS_WALLET;
    }
    return self;
}


- (instancetype)initSavedOptionMode{
    self = [super init];
    if (self) {
        _paymentMode = OPTION_SAVED_MODE;
    }
    return self;
}


@end
