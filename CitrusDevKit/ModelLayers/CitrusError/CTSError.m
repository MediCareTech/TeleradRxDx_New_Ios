//
//  CTSError.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 26/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSError.h"

@implementation CTSError

+ (NSError*)getErrorForCode:(CTSErrorCode)code {
    NSString* errorDescription = @"CitrusDefaultError";
    
    switch (code) {
        case UserNotSignedIn:
            errorDescription = @"This proccess cannot be completed without signing "
            @"in, Please signin";
            break;
        case EmailNotValid:
            errorDescription =
            @"Invalid email address,expected e.g. rob@gmail.com";
            break;
        case MobileNotValid:
            errorDescription = @"Invalid mobile number.";
            break;
        case CvvNotValid:
            errorDescription = @"Invalid CVV, expected 3 digits for non Amex and 4 for Amex";
            break;
        case CardNumberNotValid:
            errorDescription = @"Invalid card number";
            break;
        case ExpiryDateNotValid:
            errorDescription = @"Invalid expiry date ";
            break;
        case ServerErrorWithCode:
            errorDescription = @"server sent error code";
            break;
        case InvalidParameter:
            errorDescription = @"Invalid parameter passed to method";
            break;
        case OauthTokenExpired:
            errorDescription = @"Oauth Token expired, Please refresh it from server";
            break;
        case CantFetchSignupToken:
            errorDescription = @"Can not fetch Signup Oauth token from merchant";
            break;
        case TokenMissing:
            errorDescription = @"Token for payment is missing";
            break;
        case WrongBill:
            errorDescription = @"Bill not valid";
            break;
        case NoViewController:
            errorDescription = @"Invalid ReturnViewController";
            break;
        case ReturnUrlNotValid:
            errorDescription = @"Invalid Return url";
            break;
        case PrepaidBillFetchFailed:
            errorDescription = @"Couldn't fetch prepaid bill";
            break;
        case NoOrMoreInstruments:
            errorDescription = @"Zero or More than one payment instruments";
            break;
        case AmountNotValid:
            errorDescription = @"Invalid Amount";
            break;
        case BankAccountNotValid:
            errorDescription = @"Invalid Bank Account";
            break;
        case ReturnUrlCallbackNotValid:
            errorDescription = @"CitrusPay Completed the Transaction, Merchant Server did Not Return Data from \"postResponseiOS()\"";
            break;
        case TransactionForcedClosed:
            errorDescription = @"Transaction was Forced to End";
            break;
        case NoCookieFound:
            errorDescription = @"Cookie is not available or Expired, Please signin";
            break;
        case TransactionAlreadyInProgress:
            errorDescription = @"Transaction Already In Progress";
            break;
        case InsufficientBalance:
            errorDescription = @"Insufficient Balance. Please add Money in Citrus Account";
            break;
        case CardHolderNameInvalid:
            errorDescription = @"Card Owner Name Invalid, Cannot be Empty or Contain Special Charecters";
            break;
        case DeleteCardNumberNotValid:
            errorDescription = @"Invalid Card number, last four digits are expected";
            break;
        case MessageNotValid:
            errorDescription = @"Message length can't be Greater than 255 Characters";
            break;
        case BinCardLengthNotValid:
            errorDescription = @"First Six Digits of Card Number are Expected";
            break;
        case DPRuleNameNotValid:
            errorDescription = @"Dynamic Pricing Rule Name Invalid";
            break;
        case DPAlteredAmountNotValid:
            errorDescription = @"Altered Amount Invalid";
            break;
        case PaymentInfoInValid:
            errorDescription = @"Payment Information Invalid";
            break;
        case DPRequestTypeInvalid:
            errorDescription = @"Dynamic Pricing Request Invalid";
            break;
        case DPSignatureInvalid:
            errorDescription = @"Dynamic Pricing Signature Invalid";
            break;
        case DPResponseNotFound:
            errorDescription = @"Please Request Dynamic Pricing Info First";
            break;
        case CitrusPaymentTypeInvalid:
            errorDescription = @"Invalid Payment Option";
            break;
        case BankIssuerCode:
            errorDescription = @"Bank Issuer Code Missing";
            break;
        case UndefinedPaymentType:
            errorDescription = @"CTSPaymentInfoUpdate Object was not Configured Properly";
            break;
        case NoSigninData:
            errorDescription = @"User is not Signed in";
            break;
        case BillUrlNotInvalid:
            errorDescription = @"Bill Url is Invalid";
            break;
        case DPOriginalAmountNotValid:
            errorDescription = @"Original Amount Invalid";
            break;
        case CardTokenInvalid:
            errorDescription = @"Card Token is invalid";
            break;
        case DPMerchantQueryNotValid:
            errorDescription = @"Something is wrong in Merchant Access key or Signature";
            break;
        case TransactionFailed:
            errorDescription = @"Transaction Failed";
            break;
        case KeyStoreNotSet:
            errorDescription = @"KeyStore is not Set";
            break;
        case CitrusLinkResponseNotFound:
            errorDescription = @"Please Call requestCitrusLink:mobile:completion: first";
            break;
        case CompletionHandlerNotFound:
            errorDescription = @"Please pass CompletionHandler";
            break;
        case UnknownPasswordType:
            errorDescription = @"Unknown password type";
            break;
        case NoNewPrepaidPrelivilage:
            errorDescription = @"Your Keys Do not Have Citrus Wallet Privilege, Please Contact Citrus Support";
            break;
        case NoRefreshToken:
            errorDescription = @"No Refresh Token Found";
            break;
        case PasswordTypeNotAllowed:
            errorDescription = @"Password Type not Allowed";
            break;
        case LoadMoneyFailed:
            errorDescription = @"Load Money in Citrus Cash Account Failed";
            break;
        default:
            break;
    }
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey : errorDescription};
    return
    [NSError errorWithDomain:CITRUS_ERROR_DOMAIN code:code userInfo:userInfo];
}


+(NSString *)lengthInvalidFor:(NSString *)forInvalid{
    return [NSString stringWithFormat:@"%@ length Invalid, can't be Empty or Greater than 255 characters",forInvalid];
    
}

+ (NSError*)getServerErrorWithCode:(int)errorCode
                          withInfo:(NSDictionary*)information {
    NSMutableDictionary* userInfo =
    [[NSMutableDictionary alloc] initWithDictionary:information];
    
    [userInfo addEntriesFromDictionary:@{
                                         NSLocalizedDescriptionKey :
                                             [NSString stringWithFormat:@"Server threw an error\ncode %d", errorCode]
                                         }];
    
    return [NSError errorWithDomain:CITRUS_ERROR_DOMAIN
                               code:ServerErrorWithCode
                           userInfo:userInfo];
}


+(NSString *)getFakeJsonForCode:(CTSErrorCode)errorCode{
    NSString* fakeErrorJson = nil;
    
    switch (errorCode) {
        case InternetDown:
            fakeErrorJson = @"{\"description\":\"could not connect to server\",\"type\":\"server error\"}";
            break;
            
        default:
            fakeErrorJson = @"{\"description\":\"NA\",\"type\":\"NA\"}";
            
            break;
    }
    return fakeErrorJson;
    
}


+(NSError *)errorForStatusCode:(int)statusCode{
    NSString *errorDescription ;
    switch (statusCode) {
        case 0:
            errorDescription = @"Could not connect to server.";
            break;
        case 200:
            errorDescription = @"Request Complete";
            break;
        case 400:
            errorDescription = @"Bad Request";
            break;
        case 401:
            errorDescription = @"Unauthorized Access";
            break;
        case 403:
            errorDescription = @"Access forbidden";
            break;
        case 503:
            errorDescription = @"Server Unavailable";
            break;
        case 504:
            errorDescription = @"Gateway Timeout";
            break;
        default:
            errorDescription = @"Oops Something went wrong";
            
            break;
    }
    
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey : errorDescription};
    
    return
    [NSError errorWithDomain:CITRUS_ERROR_DOMAIN code:statusCode userInfo:userInfo];
}

+(NSError *)convertToError:(CTSPaymentTransactionRes *)ctsPaymentTxRes{
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey : ctsPaymentTxRes.txMsg};
    
    return
    [NSError errorWithDomain:CITRUS_ERROR_DOMAIN code:(NSInteger)ctsPaymentTxRes.pgRespCode userInfo:userInfo];
    
}

+(NSError *)convertToErrorDyIfNeeded:(CTSDyPResponse *)response{
    NSError *error = nil;
    if([response isError]){
        NSDictionary* userInfo = @{NSLocalizedDescriptionKey : response.resultMessage};
        error =     [NSError errorWithDomain:CITRUS_ERROR_DOMAIN_DP code:(NSInteger)[response resultCode] userInfo:userInfo];
        
        
    }
    return error;
    
}

+(NSError *)convertCTSResToErrorIfNeeded:(CTSResponse *)response{
    NSError *error = nil;
    if([response isError]){
        NSDictionary* userInfo = @{NSLocalizedDescriptionKey : response.responseMessage};
        error =     [NSError errorWithDomain:CITRUS_ERROR_DOMAIN code:(NSInteger)[response errorCode] userInfo:userInfo];
    }
    return error;
}





@end
