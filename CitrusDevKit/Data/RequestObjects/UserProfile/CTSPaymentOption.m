//
//  CTSPaymentOption.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 20/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSPaymentOption.h"
/**
 *  internal class should not be used by consumer
 */
//@implementation CTSPaymentOption
//@synthesize type, cardName, ownerName, number, expiryDate, scheme, bankName;
//
//- (instancetype)initWithCard:(CTSElectronicCardUpdate*)card {
//  self = [super init];
//  if (self) {
//    type = card.type;
//    cardName = card.name;
//    ownerName = card.ownerName;
//    number = card.number;
//    expiryDate = card.expiryDate;
//    scheme = card.scheme;
//  }
//  return self;
//}
//
//- (instancetype)initWithNetBanking:(CTSNetBankingUpdate*)bankDetails {
//  self = [super init];
//  if (self) {
//    type = bankDetails.type;
//    bankName = bankDetails.name;
//  }
//  return self;
//}
//@end

@implementation CTSPaymentOption
@synthesize type, name, owner, number, expiryDate, scheme, bank, token, mmid,
    impsRegisteredMobile, cvv, code;


-(instancetype)initCitrusPayWithEmail:(NSString *)email{
    self = [super init];
    if (self) {
        type = MLC_CITRUS_PAY_TYPE;
        owner = email;//MLC_CITRUS_PAY_HOLDER;
        number = MLC_CITRUS_PAY_NUMBER;
        expiryDate = MLC_CITRUS_PAY_EXPIRY;
        scheme = MLC_CITRUS_PAY_SCHEME;
        cvv = MLC_CITRUS_PAY_CVV;
    }
    return self;

}


- (instancetype)initWithCard:(CTSElectronicCardUpdate*)eCard {
  self = [super init];
  if (self) {
    type = eCard.type;
    name = eCard.name;
    owner = eCard.ownerName;
    number = eCard.number;
    expiryDate = eCard.expiryDate;
    scheme = eCard.scheme;
    cvv = eCard.cvv;
    token = eCard.token;
    code = eCard.bankcode;
  }
  return self;
}

- (instancetype)initWithNetBanking:(CTSNetBankingUpdate*)bankDetails {
  self = [super init];
  if (self) {
    type = bankDetails.type;
    bank = bankDetails.bank;
    name = bankDetails.name;
    token = bankDetails.token;
    code = bankDetails.code;
  }
  return self;
}

- (instancetype)initWithTokenized:(CTSTokenizedPayment*)tokenizedPayment {
  self = [super init];
  if (self) {
    type = tokenizedPayment.type;
    token = tokenizedPayment.token;
    cvv = tokenizedPayment.cvv;
  }
  return self;
}

- (CTSErrorCode)validate {
    CTSErrorCode error = NoError;
    CTSPaymentType paymentType =[self fetchPaymentType];

    
    if (paymentType == MemberCard) {
        error = [self validateCard];
        if(error != NoError){
            return error;
        }
        error = [self validateCardOwner];
    }
    else if(paymentType == MemberNetbank){
        if([CTSUtility islengthInvalid:code]){
            return BankIssuerCode;
        }
    }
    else if (paymentType == TokenizedCard){
        if([CTSUtility islengthInvalid:token]){
            return TokenMissing;
        }
    }
    else if(paymentType == TokenizedNetbank){
        if([CTSUtility islengthInvalid:token]){
            return TokenMissing;
        }
        
        if([CTSUtility islengthInvalid:code]){
            return BankIssuerCode;
        }
    }
    else if(paymentType == CitrusPay){
        return NoError;
    }
    else if(paymentType == UndefinedPayment){
        return UndefinedPaymentType;
    }
    
    
    
    return error;
}


-(CTSErrorCode)validateCardOwner{
    CTSErrorCode error = NoError;


    
    if ([CTSUtility stringContainsSpecialChars:owner exceptChars:@"" exceptCharSet:[NSCharacterSet whitespaceCharacterSet]] || [CTSUtility islengthInvalid:owner]||owner == nil) {
        error = CardHolderNameInvalid;
    }
    return error;

}

- (CTSErrorCode)validateCard {
  CTSErrorCode error = NoError;
  if ([CTSUtility validateCardNumber:number] == NO) {
    return CardNumberNotValid;
  }  if ([CTSUtility isMaestero:number]== NO && [CTSUtility validateExpiryDate:expiryDate] == NO) {
    return ExpiryDateNotValid;
  }  if ([CTSUtility isMaestero:number]== NO &&[CTSUtility validateCVV:cvv cardNumber:number] == NO) {
    return CvvNotValid;
  }
    
  return error;
}

- (CTSPaymentType)fetchPaymentType {
    if([type isEqualToString:MLC_CITRUS_PAY_TYPE]){
        return CitrusPay;
    }
  else if (self.token != nil && self.cvv != nil) {
    return TokenizedCard;
  } else if (self.token != nil && self.cvv == nil) {
    return TokenizedNetbank;
  } else if (self.token == nil && self.cvv != nil) {
    return MemberCard;
  } else if (self.token == nil && self.cvv == nil) {
    return MemberNetbank;
  } else {
    return UndefinedPayment;
  }
}

- (CTSPaymentToken*)fetchPaymentToken {
  CTSPaymentToken* paymentToken = [[CTSPaymentToken alloc] init];
  CTSPaymentMode* paymentMode = nil;
  switch ([self fetchPaymentType]) {
    case TokenizedCard:
      paymentToken.id = token;
      paymentToken.cvv = cvv;
      paymentToken.type = TYPE_TOKENIZED;

      break;
    case TokenizedNetbank:
      paymentToken.id = token;
      paymentToken.type = TYPE_TOKENIZED;

      break;
    case MemberCard:
      paymentToken.type = TYPE_MEMBER;
      paymentMode = [[CTSPaymentMode alloc] init];
      paymentMode.cvv = cvv;
      paymentMode.holder = owner;
      paymentMode.number = number;
      paymentMode.scheme = scheme;
      paymentMode.expiry = expiryDate;
      paymentMode.type = type;

      break;
    case MemberNetbank:
      paymentToken.type = TYPE_MEMBER;
      paymentMode = [[CTSPaymentMode alloc] init];
      paymentMode.type = type;
      paymentMode.code = code;

      break;
      case CitrusPay:
          paymentToken.type = TYPE_MEMBER;
          paymentMode = [[CTSPaymentMode alloc] init];
          paymentMode.cvv = cvv;
          paymentMode.holder = owner;
          paymentMode.number = number;
          paymentMode.scheme = scheme;
          paymentMode.expiry = expiryDate;
          paymentMode.type = type;
          
    default:
      break;
  }
  paymentToken.paymentMode = paymentMode;
  return paymentToken;
}

@end