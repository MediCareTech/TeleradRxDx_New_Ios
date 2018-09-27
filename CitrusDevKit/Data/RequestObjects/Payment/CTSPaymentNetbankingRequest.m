//
//  CTSPaymentNetbankingRequest.m
//  RestFulltester
//
//  Created by Raji Nair on 30/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSPaymentNetbankingRequest.h"

@implementation CTSPaymentNetbankingRequest
@synthesize merchantAccesskey, merchantTxnId, notifyUrl, returnUrl,
    requestSignature, amount, userDetails, paymentToken, merchant, merchantKey;
@end
