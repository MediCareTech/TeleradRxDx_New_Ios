//
//  CTSPaymentDetailUpdate.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 12/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSPaymentDetailUpdate.h"

@implementation CTSPaymentDetailUpdate
@synthesize type, paymentOptions, password,defaultOption;
+(CTSPaymentDetailUpdate *)citrusPay{return nil;};
- (instancetype)init {
    self = [super init];
    if (self) {
        type = MLC_PROFILE_GET_PAYMENT_QUERY_TYPE;
        paymentOptions =
        (NSMutableArray<CTSPaymentOption>*)[[NSMutableArray alloc] init];
        password = nil;
    }
    return self;
}

-(CTSPaymentDetailUpdate *)initCitrusCash{
    self = [super init];
    if (self) {
        paymentOptions =
        (NSMutableArray<CTSPaymentOption>*)[[NSMutableArray alloc] init];
        [paymentOptions addObject:[[CTSPaymentOption alloc] initCitrusPayWithEmail:nil]];
    }
    return self;

}



-(instancetype)initCitrusPayWithEmail:(NSString *)email{
    self = [[CTSPaymentDetailUpdate alloc] init];
    [self.paymentOptions addObject:[[CTSPaymentOption alloc] initCitrusPayWithEmail:email]];
    return self;
}




- (void)addCard:(CTSElectronicCardUpdate*)eCard {
    eCard.expiryDate = [CTSUtility correctExpiryDate:eCard.expiryDate];
    [paymentOptions addObject:[[CTSPaymentOption alloc] initWithCard:eCard]];
}

- (BOOL)addNetBanking:(CTSNetBankingUpdate*)netBankDetail {
    [paymentOptions
     addObject:[[CTSPaymentOption alloc] initWithNetBanking:netBankDetail]];
    return YES;
}
- (CTSErrorCode)validate {
    CTSErrorCode error = NoError;
    for (CTSPaymentOption* payment in paymentOptions) {
        error = [payment validate];
        if (error != NoError) {
            return error;
        }
    }
    return error;
}


- (CTSErrorCode)validateTokenized{
    CTSErrorCode error = NoError;
    for (CTSPaymentOption* payment in paymentOptions) {
        if(payment.token == nil)
            error = TokenMissing;
        break;
    }
    return error;
}

-(BOOL)isTokenized{
    BOOL isTokenized = NO;
    for (CTSPaymentOption* payment in paymentOptions) {
        if(payment.token != nil)
            isTokenized = YES;
        break;
    }
    return isTokenized;
}



- (void)clearCVV {
    for (CTSPaymentOption* payment in paymentOptions) {
        payment.cvv = nil;
    }
}

- (void)clearNetbankCode {
    for (CTSPaymentOption* payment in paymentOptions) {
        payment.code = nil;
    }
}

-(void)addFakeNBCode{
    for (CTSPaymentOption* payment in paymentOptions) {
        payment.code = @"CID000";
    }
}

-(void)dummyCVVAndExpiryIfMaestro{
    for (CTSPaymentOption* payment in paymentOptions) {
        
        if(![payment.type isEqualToString:MLC_PROFILE_PAYMENT_NETBANKING_TYPE] && [payment.scheme isEqualToString:@"MTRO"]){
            if([payment.cvv isEqualToString:@""] || payment.cvv  == nil){
            payment.cvv = @"123";
            
            }
            if([payment.expiryDate isEqualToString:@""] || payment.expiryDate  == nil){
                payment.expiryDate = @"11/2019";
                
            }
        
        }
    }

}


-(void)amexCreditcardCorrectionIfNeeded{
    for (CTSPaymentOption* payment in paymentOptions) {
        
        if(![payment.type isEqualToString:MLC_PROFILE_PAYMENT_NETBANKING_TYPE] && [payment.scheme isEqualToString:@"AMEX"]){
            payment.type = MLC_PROFILE_PAYMENT_CREDIT_TYPE;
        }
    }

}

-(void)doCardCorrectionsIfNeeded{
    [self dummyCVVAndExpiryIfMaestro];
    [self amexCreditcardCorrectionIfNeeded];
}

@end
