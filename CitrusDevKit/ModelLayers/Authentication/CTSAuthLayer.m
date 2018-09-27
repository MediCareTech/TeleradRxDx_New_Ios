//
//  CTSAuthLayer.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 23/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSAuthLayer.h"
#import "RestLayerConstants.h"
#import "CTSAuthLayerConstants.h"
#import "CTSSignUpRes.h"
#import "UserLogging.h"
#import "CTSUtility.h"
#import "CTSError.h"
#import "CTSOauthManager.h"
#import "NSObject+logProperties.h"
#import "CTSSignupState.h"
#import "CTSProfileLayer.h"
#import "CTSPaymentWebViewController.h"
#import "CTSRestCore.h"
#import "CitrusSdk.h"
#import <CommonCrypto/CommonDigest.h>
#ifndef MIN
#import <NSObjCRuntime.h>
#endif

@implementation CTSAuthLayer
@synthesize delegate;

#pragma mark - public methods

- (void)requestResetPassword:(NSString*)userNameArg
           completionHandler:(ASResetPasswordCallback)callBack;
{
    
  [self addCallback:callBack forRequestId:RequestForPasswordResetReqId];

    OauthStatus* oauthStatus = [CTSOauthManager fetchSignupTokenStatus:keystore];
  NSString* oauthToken = oauthStatus.oauthToken;

  if (oauthStatus.error != nil) {
    [self resetPasswordHelper:oauthStatus.error];
  }

  if (![CTSUtility validateEmail:userNameArg]) {
    [self resetPasswordHelper:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
    userNameArg = userNameArg.lowercaseString;
  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_REQUEST_CHANGE_PWD_REQ_PATH
         requestId:RequestForPasswordResetReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
        parameters:@{MLC_REQUEST_CHANGE_PWD_QUERY_USERNAME : userNameArg.lowercaseString}
              json:nil
        httpMethod:POST];

  [restCore requestAsyncServer:request];
}

- (void)requestInternalSignupMobile:(NSString*)mobile email:(NSString*)email {
  if (![CTSUtility validateEmail:email]) {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readPasswordSigninOauthToken]
                         error:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
    mobile = [CTSUtility mobileNumberToTenDigitIfValid:mobile];
    
  if (!mobile) {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readPasswordSigninOauthToken]
                         error:[CTSError getErrorForCode:MobileNotValid]];
    return;
  }

    email = email.lowercaseString;

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_SIGNUP_REQ_PATH
         requestId:SignupStageOneReqId
           headers:[CTSUtility readSignupTokenAsHeader]
        parameters:@{
          MLC_SIGNUP_QUERY_EMAIL : email.lowercaseString,
          MLC_SIGNUP_QUERY_MOBILE : mobile
        } json:nil
        httpMethod:POST];

  [restCore requestAsyncServer:request];
}



- (void)requestInternalBindUserName:(NSString *)email mobile:(NSString *)mobile {

    email = email.lowercaseString;

    
    
        CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_BIND_USER_REQ_PATH
                                   requestId:BindUserRequestId
                                   headers:[CTSUtility readSignupTokenAsHeader]
                                   parameters:@{
                                                MLC_BIND_USER_QUERY_EMAIL : email,
                                                MLC_BIND_USER_QUERY_MOBILE : mobile
                                                } json:nil
                                   httpMethod:MLC_BIND_USER_REQ_TYPE];
    
    [restCore requestAsyncServer:request];
}





- (void)requestSignUpWithEmail:(NSString*)email
                        mobile:(NSString*)mobile
                      password:(NSString*)password
             completionHandler:(ASSignupCallBack)callBack {
  [self addCallback:callBack forRequestId:SignupOauthTokenReqId];

  if (![CTSUtility validateEmail:email]) {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readPasswordSigninOauthToken]
                         error:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
    mobile = [CTSUtility mobileNumberToTenDigitIfValid:mobile];
  if (!mobile) {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readPasswordSigninOauthToken]
                         error:[CTSError getErrorForCode:MobileNotValid]];
    return;
  }

    email = email.lowercaseString;

  userNameSignup = email;
  mobileSignUp = mobile;
  if (password == nil) {
    passwordSignUp = [self generatePseudoRandomPassword];
  } else {
    passwordSignUp = password;
  }

  //  CTSSignupState* signupState = [[CTSSignupState alloc] initWithEmail:email
  //                                                               mobile:mobile
  //                                                             password:password];
  //
  //  long index = [self addDataToCacheAtAutoIndex:signupState];

  [self requestSignUpOauthToken];
}






- (void)requestSignUpOauthToken {
  ENTRY_LOG
  wasSignupCalled = YES;

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
         requestId:SignupOauthTokenReqId
           headers:nil
        parameters:MLC_OAUTH_TOKEN_SIGNUP_QUERY_MAPPING
              json:nil
        httpMethod:POST];

  [restCore requestAsyncServer:request];

  EXIT_LOG
}

- (void)requestSignUpOauthTokenCompletionHandler:(ASAsyncSignUpOauthTokenCallBack)callback {
    ENTRY_LOG
    
    [self addCallback:callback forRequestId:SignupOauthAsynTokenReqId];
    
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:SignupOauthAsynTokenReqId
                                   headers:nil
                                   parameters:MLC_OAUTH_TOKEN_SIGNUP_QUERY_MAPPING
                                   json:nil
                                   httpMethod:POST];
    
    [restCore requestAsyncServer:request];
    
    EXIT_LOG
}


-(void)requestSignupUser:(CTSUserDetails *)user password:(NSString *)pasword mobileVerified:(BOOL)isMarkMobileVerifed emailVerified:(BOOL)isMarkEmailVerified completionHandler:(ASSignupNewCallBack)callback{
    //verify the user object
    [self addCallback:callback forRequestId:SignupNewReqId];
    
    if(!pasword){
        pasword = @"";
    }
    
    
    
    
    if ( [CTSUtility validateEmail:user.email] == NO) {
        [self newSignupHelper:[CTSError getErrorForCode:EmailNotValid]];
        return;
    }
    
    user.mobileNo = [CTSUtility mobileNumberToTenDigitIfValid:user.mobileNo];
    if (user.mobileNo == nil) {
        [self newSignupHelper:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }
    
    
    [self requestSignUpOauthTokenCompletionHandler:^(NSError *error) {
        if(error == nil){
            NSDictionary *parameters = @{MLC_MLC_SIGNUP_NEW_QUERY_EMAIL:user.email,
                                         MLC_MLC_SIGNUP_NEW_QUERY_MOBILE:user.mobileNo,
                                         MLC_MLC_SIGNUP_NEW_QUERY_FIRSTNAME:user.firstName,
                                         MLC_MLC_SIGNUP_NEW_QUERY_LASTNAME:user.lastName,
                                         MLC_MLC_SIGNUP_NEW_QUERY_SOURCE_TYPE:[CTSUtility fetchSigninId:keystore],
                                         MLC_MLC_SIGNUP_NEW_QUERY_PASSWORD:pasword,
                                         MLC_MLC_SIGNUP_NEW_QUERY_MOBILE_VERIFIED:[CTSUtility toStringBool:isMarkMobileVerifed],
                                         MLC_MLC_SIGNUP_NEW_QUERY_EMAIL_VERIFIED:[CTSUtility toStringBool:isMarkEmailVerified]
                                         };
            
            CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                           initWithPath:MLC_SIGNUP_NEW_PATH
                                           requestId:SignupNewReqId
                                           headers:[CTSUtility readSignupTokenAsHeader]
                                           parameters:parameters
                                           json:nil
                                           httpMethod:POST];
            [restCore requestAsyncServer:request];
            
        }
        else {
            [self newSignupHelper:error];
        }
    }];
}

//
//-(void)requestVerification:(NSString *)mobile code:(NSString *)otp completionHandler:(ASOtpVerificationCallback)callback{
//    [self addCallback:callback forRequestId:OTPVerificationRequestId];
//    
//    
//    mobile = [CTSUtility mobileNumberToTenDigitIfValid:mobile];
//    if (!mobile) {
//        [self otpVerificationHelper:NO error:[CTSError getErrorForCode:MobileNotValid]];
//        return;
//    }
//    
//    
//    OauthStatus* oauthStatus = [CTSOauthManager fetchBindSigninTokenStatus];
//    NSString* oauthToken = oauthStatus.oauthToken;
//    
//    
//    
//    
//    if (oauthStatus.error != nil) {
//        oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
//        oauthToken = oauthStatus.oauthToken;
//    }
//    
//    
//    if (oauthStatus.error != nil || oauthToken == nil) {
//        [self otpVerificationHelper:nil error:oauthStatus.error];
//        
//    }
//    
//    NSDictionary* parameters = @{
//                                 MLC_OTP_VER_QUERY_OTP : otp,
//                                 MLC_OTP_VER_QUERY_MOBILE : mobile
//                                 };
//    
//    
//    
//    
//    
//    CTSRestCoreRequest* request =
//    [[CTSRestCoreRequest alloc] initWithPath:MLC_MOBILE_VERIFICATION_CODE_OAUTH_PATH
//                                   requestId:OTPVerificationRequestId
//                                     headers:nil
//                                  parameters:parameters
//                                        json:nil
//                                  httpMethod:POST];
//    
//    [restCore requestAsyncServer:request];
//    
//    
//}





-(void)requestMobileVerificationWithCode:(NSString *)otp completionHandler:(ASOtpVerificationCallback)callback{
    [self addCallback:callback forRequestId:MobileVerificationRequestId];
 
    
    OauthStatus* oauthStatus = [CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypeAny];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil || oauthToken == nil) {
        [self mobileVerificationHelper:NO error:oauthStatus.error];
        
    }
    

    
    
    NSString *jsonString =[NSString stringWithFormat:@"{\"%@\":\"%@\"}",MLC_MOBILE_VERIFICATION_CODE_OAUTH_QUERY_MOBILE, otp];

    
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_MOBILE_VERIFICATION_CODE_OAUTH_PATH
                                   requestId:MobileVerificationRequestId
                                     headers:[CTSUtility readOauthTokenAsHeader:oauthStatus.oauthToken]
                                  parameters:nil
                                        json:jsonString
                                  httpMethod:POST];
    
    [restCore requestAsyncServer:request];
    
    
}

-(void)requestVerificationCodeRegenerate:(NSString *)mobile completionHandler:(ASOtpRegenerationCallback)callback{
    [self addCallback:callback forRequestId:MobVerCodeRegenerationRequestId];
    mobile = [CTSUtility mobileNumberToTenDigitIfValid:mobile];
    
    if (!mobile) {
        [self mobVerCodeRegenerationHelper:nil error:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }
    
    
    
    OauthStatus* oauthStatus = [CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypeAny];
    NSString* oauthToken = oauthStatus.oauthToken;
    
      if (oauthStatus.error != nil || oauthToken == nil) {
        [self mobVerCodeRegenerationHelper:nil error:oauthStatus.error];
        
    }
    

    
    
    NSString *jsonString =[NSString stringWithFormat:@"{\"%@\":\"%@\"}",MLC_OTP_REGENERATE_QUERY_MOBILE, mobile];

    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OTP_REGENERATE_WITH_OAUTH_PATH
                                   requestId:MobVerCodeRegenerationRequestId
                                     headers:[CTSUtility readOauthTokenAsHeader:oauthStatus.oauthToken]
                                  parameters:nil
                                        json:jsonString
                                  httpMethod:MLC_OTP_REGENERATE_TYPE];
    
    [restCore requestAsyncServer:request];
    
}
//6hs1


-(void)requestGenerateOTPFor:(NSString *)entity completionHandler:(ASGenerateOtpCallBack)callback{
    [self addCallback:callback forRequestId:GenerateOTPReqId];
    
    NSString *otpType = @"mobile";
    
    if([CTSUtility isEmail:entity]){
        otpType = @"email";
    }
    
    
    if ( [CTSUtility isEmail:entity] == YES  && [CTSUtility validateEmail:entity] == NO) {
        [self otpGenerateHelper:nil error:[CTSError getErrorForCode:EmailNotValid]];
        return;
    }
    
    if([otpType isEqualToString:@"mobile"]){
        entity = [CTSUtility mobileNumberToTenDigitIfValid:entity];
        if (  [CTSUtility isEmail:entity] == NO  &&  entity == nil) {
            [self otpGenerateHelper:nil
                              error:[CTSError getErrorForCode:MobileNotValid]];
            return;
        }
    }
    
    NSDictionary* parameters = @{
                                 MLC_OTP_SIGNIN_QUERY_SOURCE:[CTSUtility fetchSigninId:keystore],
                                 MLC_OTP_SIGNIN_QUERY_OTP_TYPE:otpType,
                                 MLC_OTP_SIGNIN_PATH_IDENTITY:entity
                                 };
    
    
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OTP_SIGNIN_PATH
                                   requestId:GenerateOTPReqId
                                     headers:MLC_OAUTH_TOKEN_SIGNUP_QUERY_MAPPING
                                  parameters:nil
                                        json:[CTSUtility toJson:parameters]
                                  httpMethod:POST];
    
    [restCore requestAsyncServer:request];
    
    
}


- (void)requestSigninWithUsername:(NSString*)userNameArg
                         password:(NSString*)password
                completionHandler:(ASSigninCallBack)callBack {
  /**
   *  flow sigin in
   check oauth expiry time if oauth token is expired call for refresh token and
   send refresh token
   if refresh token has error then proceed for normal signup

   */

  [self addCallback:callBack forRequestId:SigninOauthTokenReqId];

    if(![CTSUtility validateEmail:userNameArg]){
    
        [self signinHelperUsername:userNameArg oauth:nil error:[CTSError errorForStatusCode:EmailNotValid]];
        return;
    
    }
    
    [CTSUtility saveToDisk:userNameArg as:CTS_SIGNIN_USER_EMAIL];
     userNameArg = userNameArg.lowercaseString;
    userNameSignIn = userNameArg;
    passwordSignin = password;

    
    
  NSDictionary* parameters = @{
    MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : [CTSUtility fetchSigninId:keystore],
    MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : [CTSUtility fetchSigninSecret:keystore],
    MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_SIGNIN_GRANT_TYPE,
    MLC_OAUTH_TOKEN_SIGNIN_QUERY_PASSWORD : password,
    MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME : userNameArg
  };

  CTSRestCoreRequest* request =
      [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                     requestId:SigninOauthTokenReqId
                                       headers:nil
                                    parameters:parameters
                                          json:nil
                                    httpMethod:POST];

  [restCore requestAsyncServer:request];
}


- (void)requestSigninWithUsername:(NSString*)userNameArg
                         otp:(NSString*)otp
                completionHandler:(ASOtpSigninCallBack)callBack {
    /**
     *  flow sigin in
     check oauth expiry time if oauth token is expired call for refresh token and
     send refresh token
     if refresh token has error then proceed for normal signup
     
     */
    
    [self addCallback:callBack forRequestId:OtpSignInReqId];
    
    
    userNameArg = userNameArg.lowercaseString;
    userNameSignIn = userNameArg;
    passwordSignin = otp;
    
    
    
    NSDictionary* parameters = @{
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : [CTSUtility fetchSigninId:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : [CTSUtility fetchSigninSecret:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_SIGNIN_GRANT_TYPE_OTP,
                                 MLC_OAUTH_TOKEN_SIGNIN_QUERY_PASSWORD : otp,
                                 MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME : userNameArg
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:OtpSignInReqId
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:POST];
    
    [restCore requestAsyncServer:request];
}

-(void)requestPrepaidSignIn:(NSString *)username password:(NSString *)passoword passwordType:(PasswordType)type compltionHandler:(ASCitrusSigninCallBack)callBack{
    [self addCallback:callBack forRequestId:SigninPasswordPrepaidReqId];

    
    
    
    
    NSDictionary* parameters = @{
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : [CTSUtility fetchSigninId:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : [CTSUtility fetchSigninSecret:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : [CTSUtility grantTypeFor:type],
                                 MLC_OAUTH_TOKEN_SIGNIN_QUERY_PASSWORD : passoword,
                                 MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME : username,
                                 };
   // MLC_SCOPE : MLC_PREPAID_SCOPE

    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:SigninPasswordPrepaidReqId
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:POST];
    
    [restCore requestAsyncServer:request];

}


-(void)requestCitrusLinkSignInWithPassoword:(NSString *)password passwordType:(PasswordType)type completionHandler:(ASCitrusSigninCallBack)callback{


    CTSResponse *linkUseResponse = [self fetchCachedDataForKey:CACHE_KEY_CITRUS_LINK];
    
    if (callback == nil) {
        [self citrusLinkSigninWithError:[CTSError getErrorForCode:CompletionHandlerNotFound] callback:callback];
        return;
    }
    if(linkUseResponse == nil){
        [self citrusLinkSigninWithError:[CTSError getErrorForCode:CitrusLinkResponseNotFound] callback:callback];
        return;
    }
    
    
    //    (OLD SIGNIN> case 1 || 6 || 2 || 7  && passwordType == OTP)
    //
    //
    //    (OLD SIGNIN> case 1 || 6 || 2 || 7 || 5 || 8 && passwordType == PASSWORD)
    //
    //
    //    (VERIFY_SIGNIN > case 3 || 4 || 5 || 10 || 11 || 12 || && passwordType == OTP)
    //
    //    (EOTP signin > 8 || 9 && password type == OTP)
    
    
    NSString *mobile = [linkUseResponse.responseData valueForKey:@"mobile"];
    NSString *email = [linkUseResponse.responseData valueForKey:@"email"];
    NSString *uuid = [linkUseResponse.responseData valueForKey:@"uuid"];
    NSString *requestMobile = [linkUseResponse.responseData valueForKey:@"requestedMobile"];
    int linkUserCase = [linkUseResponse apiResponseCode];
    
    LogTrace(@" linkUserCase %d",linkUserCase);
    
    if(type == PasswordTypeOtp){
        if(linkUserCase == 1 || linkUserCase == 6 || linkUserCase == 2 ||linkUserCase == 7){
            LogTrace(@" old sigin, otp ");

            
            [self requestPrepaidSignIn:mobile password:password passwordType:PasswordTypeOtp compltionHandler:^(NSError *error) {
                [self citrusLinkSigninWithError:error callback:callback];
                return;
                
            }];
        }
        else if(linkUserCase == 3 || linkUserCase == 4 || linkUserCase == 5 || linkUserCase == 10 || linkUserCase == 11 || linkUserCase == 12){
            LogTrace(@" verify and sigin, otp ");

            [self requestVerifyAndSigninUUID:uuid verificationCode:password callback:^(NSError *error) {
                [self citrusLinkSigninWithError:error callback:callback];
                return;
            }];
        }
        else if(linkUserCase == 8 || linkUserCase == 9){
            LogTrace(@" Update mobile sigin, e-otp ");

            [self requestEotpSignInUpdateEmail:email password:password passwordType:PasswordTypeOtp requestedMobile:requestMobile callback:^(CTSEotpVerSigninResp *response, NSError *error) {
                [self citrusLinkSigninWithError:error callback:callback];
                return ;
            }];
        }
        else{
            [self citrusLinkSigninWithError:[CTSError getErrorForCode:PasswordTypeNotAllowed] callback:callback];
            return;
        }
    }
    else if(type == PasswordTypePassword){
        
        if(linkUserCase == 1 || linkUserCase == 6 || linkUserCase ==2  ||linkUserCase == 5){
            LogTrace(@" old sigin, password ");
            [self requestPrepaidSignIn:email password:password passwordType:PasswordTypePassword compltionHandler:^(NSError *error) {
                [self citrusLinkSigninWithError:error callback:callback];
                return ;
            }];
        }
        else if (linkUserCase == 8){
            LogTrace(@" Update mobile sigin, password ");
            [self requestEotpSignInUpdateEmail:email password:password passwordType:PasswordTypePassword requestedMobile:requestMobile callback:^(CTSEotpVerSigninResp *response, NSError *error) {
                [self citrusLinkSigninWithError:error callback:callback];
                return ;
            }];
        }
        else {
            [self citrusLinkSigninWithError:[CTSError getErrorForCode:PasswordTypeNotAllowed] callback:callback];
            return;
        
        }
        
    }
    else{
        [self citrusLinkSigninWithError:[CTSError getErrorForCode:UnknownPasswordType] callback:callback];
        return;
        
    }
}



-(void)requestEotpSignInUpdateEmail:(NSString *)email password:(NSString *)password passwordType:(PasswordType)type requestedMobile:(NSString *)mobile  callback:(ASUpdateMobileSigninCallback)callback{
    
    //email, verification, mobile verification
    
    
    
    NSDictionary* parameters = @{
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : [CTSUtility fetchSigninId:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : [CTSUtility fetchSigninSecret:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : [CTSUtility grantTypeFor:type],
                                 MLC_OAUTH_TOKEN_SIGNIN_QUERY_PASSWORD : password,
                                 MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME : email,
                                 MLC_REQUESTED_MOBILE:mobile
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_EOTP_SIGNIN_VERIFY_MOBILE_PATH
                                   requestId:-1
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:POST];
    
    [restCore requestAsyncServer:request completion:^(CTSRestCoreResponse *response) {
        
        NSError* error = response.error;
        JSONModelError* jsonError;
        CTSEotpVerSigninResp* signinResp = nil;
        if (error == nil) {
             signinResp = [[CTSEotpVerSigninResp alloc] initWithString:response.responseString error:&jsonError];
            [signinResp logProperties];
            if(jsonError){
                error = jsonError;
            }
            else {
                [self saveOauthTokens:signinResp.oAuth2AccessToken];
            }
        }
        callback(signinResp,error);
    }];
}


-(void)requestVerifyAndSigninUUID:(NSString *)uuid verificationCode:(NSString *)password callback:(ASCitrusSigninCallBack)callback{
    
    

    OauthStatus *signupToken = [CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypeSignUp];

    
//    NSDictionary* parameters = @{
//                                 MLC_VERIFY_SIGNIN_VER:password,
//                                 MLC_VERIFY_SIGNIN_IDENTITY:uuid,
//                                 };
    
    //Vikas
    NSDictionary* parameters = @{
                                 MLC_VERIFY_SIGNIN_VER:password,
                                 MLC_VERIFY_SIGNIN_IDENTITY:uuid,
                                 MLC_VERIFY_CLIENT_ID:[CTSUtility fetchSigninId:keystore],
                                 MLC_VERIFY_CLIENT_SECRET:[CTSUtility fetchSigninSecret:keystore],
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_VERIFY_SIGNIN_PATH
                                   requestId:-1
                                     headers:[CTSUtility readOauthTokenAsHeader:signupToken.oauthToken]
                                  parameters:nil //[CTSUtility readOauthTokenAsHeader:signupToken.oauthToken]
                                        json:[CTSUtility toJson:parameters]
                                  httpMethod:POST];
    
    
    [restCore requestAsyncServer:request completion:^(CTSRestCoreResponse *response) {
        
         NSError* errorSignIn = response.error;
        JSONModelError* jsonError;
        if (errorSignIn == nil) {
            CTSOauthTokenRes* resultObject =
            [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                               error:&jsonError];
            if(jsonError == nil){
            [self saveOauthTokens:resultObject];
            }
            else{
                errorSignIn = jsonError;
            }

        }
        callback(errorSignIn);
    }];



}


-(void)requestRefreshOauthTokenCallback:(ASErrorCallback )callback{
    
    NSString *refreshToken = [CTSOauthManager readRefreshToken ];
    if(refreshToken == nil){
        callback([CTSError getErrorForCode:NoRefreshToken]);
        return;
    
    }
    NSDictionary* parameters = @{
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : [CTSUtility fetchSigninId:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : [CTSUtility fetchSigninSecret:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_OAUTH_REFRESH_QUERY_REFRESH_TOKEN,
                                 MLC_OAUTH_REFRESH_QUERY_REFRESH_TOKEN : [CTSOauthManager readRefreshToken]
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:-1
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:POST];
    
    
    
    
    [restCore requestAsyncServer:request completion:^(CTSRestCoreResponse *response) {
        NSError* error = response.error;
        JSONModelError* jsonError;
        CTSOauthTokenRes* resultObject = [[CTSOauthTokenRes alloc] initWithString:response.responseString error:&jsonError];
        if(jsonError == nil){
            [self saveOauthTokens:resultObject];
        }
        else{
           error = jsonError;
        }

        callback(error);
    }];
    
    
    
    
}


-(void)saveOauthTokens:(CTSOauthTokenRes *)tokenObj{
    CTSOauthTokenRes *prepaidAuthToken = tokenObj.prepaidPayToken;
    tokenObj.prepaidPayToken = nil;
    [CTSOauthManager saveToken:tokenObj privilege:TokenPrivilegeTypeSignin];
    LogTrace(@"normal signin token %@ ",[CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypeSignin].oauthToken);

    [CTSOauthManager saveToken:prepaidAuthToken privilege:TokenPrivilegeTypePrepaidSignin];
    LogTrace(@" prepiad signin token %@ ",[CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypePrepaidSignin].oauthToken);
}

-(void)requestBindSignin:(NSString *)userName completionHandler:(ASBindSignIn)callback{
    [self addCallback:callback forRequestId:BindSigninAsyncReqId];
    
    userName = userName.lowercaseString;
    
    if ( [CTSUtility isEmail:userName] == YES  && [CTSUtility validateEmail:userName] == NO) {
        [self bindSigninAsyncHelperError:[CTSError getErrorForCode:EmailNotValid]];
        return;
    }
    else if( [CTSUtility isEmail:userName] == NO){
        userName = [CTSUtility mobileNumberToTenDigitIfValid:userName];
        if ( userName == nil) {
            [self bindSigninAsyncHelperError:[CTSError getErrorForCode:MobileNotValid]];
            return;
        }
    }
    
    NSDictionary* parameters = @{
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : [CTSUtility fetchSigninId:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : [CTSUtility fetchSigninSecret:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_BIND_SIGNIN_GRANT_TYPE,
                                 MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME : userName
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:BindSigninAsyncReqId
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:POST];
    
    [restCore requestAsyncServer:request];
    
    
}

-(void)requestTokenValidityWithCompletionHandler:(ASTokenValidityCallback)callback{
    [self addCallback:callback forRequestId:TokenValidityReqId];
    
    NSString *prepaidToken = [CTSOauthManager readPrepaidSigninOauthTokenWithExpiryCheck];
    
    OauthStatus *status =[CTSOauthManager fetchSignupTokenStatus:keystore];
    
    //TODO: validation of tokens

    
    
    NSDictionary *headers = @{
                              MLC_TOKEN_VALIDATION_AUTH:[CTSUtility readAsBearer:status.oauthToken],
                              MLC_TOKEN_VALIDATION_OWNER_AUTH: [CTSUtility readAsBearer:prepaidToken],
                              MLC_TOKEN_VALIDATION_OWNER_SCOPE:MLC_PREPAID_SCOPE
                              };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_TOKEN_VALIDATION_PATH
                                   requestId:TokenValidityReqId
                                     headers:headers
                                  parameters:nil
                                        json:nil
                                  httpMethod:GET];
    
    [restCore requestAsyncServer:request];
 }


-(void)requestUpdatePrepaidTokenCompletionHandler:(ASErrorCallback)callback{
    
    [self addCallback:callback forRequestId:TokenValidityUpdateReqId];
    
    CTSOauthTokenRes *prepaidToken = [CTSOauthManager readPrepaidSigninOuthData];
    if(prepaidToken == nil){
        [self tokenExpiryUpdateHelperError:[CTSError getErrorForCode:NoSigninData]];
        return;
    }
    
    [self requestTokenValidityWithCompletionHandler:^(CTSTokenValidityRes *res, NSError *error) {
        
        if(error == nil){
            NSDate *oldExpiryDate = [prepaidToken.tokenSaveDate dateByAddingTimeInterval:prepaidToken.tokenExpiryTime];
            
            LogTrace(@"old prepaid expiry date: %@",oldExpiryDate);
            
            long diffrence = [res.expirationDate timeIntervalSinceDate:oldExpiryDate];
            
            prepaidToken.tokenExpiryTime = prepaidToken.tokenExpiryTime + diffrence;
            
            oldExpiryDate = [prepaidToken.tokenSaveDate dateByAddingTimeInterval:prepaidToken.tokenExpiryTime];
            
            LogTrace(@"new prepaid expiry date: %@",oldExpiryDate);
            
            [CTSOauthManager savePrepaidSigninOauthData:prepaidToken];
            
            [self tokenExpiryUpdateHelperError:nil];
        }
        else{
            [self tokenExpiryUpdateHelperError:error];
        }
    }];
}



-(void)requestCitrusLink:(NSString *)email mobile:(NSString *)mobile completion:(ASCitrusLinkCallback)callback{

    if (email.length > 0) {
        if (![CTSUtility validateEmail:email]) {
            callback(nil,[CTSError getErrorForCode:EmailNotValid]);
            return;
        }
    }
    
//    mobile = [CTSUtility mobileNumberToTenDigitIfValid:mobile];
//    if (!mobile) {
//        callback(nil,[CTSError getErrorForCode:MobileNotValid]);
//        return;
//    }
    if (![CTSUtility validateMobile:mobile]) {
        callback(nil,[CTSError getErrorForCode:MobileNotValid]);
        return;
    }
    
    [self removeCachedLinkData];
    
    //email mobile validation
    
    OauthStatus *signupToken = [CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypeSignUp];
    
    email = email.lowercaseString;
    
    
    NSDictionary* parameters = nil;
    if (![email isEqualToString:@""]) {
        parameters = @{
                       MLC_MLC_SIGNUP_NEW_QUERY_EMAIL : email,
                       MLC_MLC_SIGNUP_NEW_QUERY_MOBILE : mobile,
                       };
    }
    else {
        parameters = @{
                       MLC_MLC_SIGNUP_NEW_QUERY_MOBILE : mobile,
                       };
        
    }
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_LINK_PATH
                                   requestId:-1
                                     headers:[CTSUtility readOauthTokenAsHeader:signupToken.oauthToken]
                                  parameters:nil
                                        json:[CTSUtility toJson:parameters]
                                  httpMethod:POST];
    
  [restCore requestAsyncServer:request completion:^(CTSRestCoreResponse *response) {
      
      NSError* error = response.error;
      JSONModelError* jsonError;
      CTSResponse *genResponse;
      CTSCitrusLinkRes *citrusLinkResponse = nil;
      if(!error){
          genResponse =[[CTSResponse alloc] initWithString:response.responseString error:&jsonError];
          if(jsonError){
              error = jsonError;
          }
          else{
              [[CTSDataCache sharedCache] cacheData:genResponse key:CACHE_KEY_CITRUS_LINK];
             citrusLinkResponse = [[CTSCitrusLinkRes alloc] initWithResponse:genResponse];
               CTSResponse *citrusResponse = [self fetchCachedDataForKey:CACHE_KEY_CITRUS_LINK];
              LogTrace(@"citrusResponse %@",citrusResponse);
        }
      }
      callback(citrusLinkResponse,error);
  }];
}



-(void)requestBindSigninUsername:(NSString *)email{
    
    email = email.lowercaseString;

    NSDictionary* parameters = @{
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : [CTSUtility fetchSigninId:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : [CTSUtility fetchSigninSecret:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_BIND_SIGNIN_GRANT_TYPE,
                                 MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME : email
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:BindSigninRequestId
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:POST];
    
    [restCore requestAsyncServer:request];


}



-(void)requestBindSigninUsername:(NSString *)email completion:(ASErrorCallback)callback{
    
    email = email.lowercaseString;
    
    NSDictionary* parameters = @{
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : [CTSUtility fetchSigninId:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : [CTSUtility fetchSigninSecret:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_BIND_SIGNIN_GRANT_TYPE,
                                 MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME : email
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:BindSigninRequestId
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:POST];
    
    [restCore requestAsyncServer:request];
    
    [restCore requestAsyncServer:request completion:^(CTSRestCoreResponse *response) {
        NSError* error = response.error;
        JSONModelError* jsonError;
        if (error == nil) {
            CTSOauthTokenRes* resultObject =
            [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                               error:&jsonError];
            [resultObject logProperties];
            //[CTSOauthManager saveBindSignInOauth:resultObject];
            [CTSOauthManager saveToken:resultObject privilege:TokenPrivilegeTypeBind];
            if(jsonError){
                error = jsonError;
            }
        }
        callback(error);
    }];
    
    
    
}



-(void)requestSetPassword:(NSString *)password userName:(NSString *)userName completionHandler:(ASSetPassword)callback{

    userName = userName.lowercaseString;

    
    [self addCallback:callback forRequestId:SetPasswordReqId];
    
    [self requestChangePasswordUserName:userName oldPassword:[self generateBigIntegerString:userName] newPassword:password completionHandler:^(NSError *error) {
        [self setPasswordHelper:error];
    }];
    
    
}


- (void)usePassword:(NSString*)password
     hashedUsername:(NSString*)hashedUsername {
  ENTRY_LOG

  NSString* oauthToken = [CTSOauthManager readPasswordSigninOauthTokenWithExpiryCheck];
  if (oauthToken == nil) {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readPasswordSigninOauthToken]
                         error:[CTSError getErrorForCode:OauthTokenExpired]];
  }

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_CHANGE_PASSWORD_REQ_PATH
         requestId:SignupChangePasswordReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
        parameters:@{
          MLC_CHANGE_PASSWORD_QUERY_OLD_PWD : hashedUsername,
          MLC_CHANGE_PASSWORD_QUERY_NEW_PWD : password
        } json:nil
        httpMethod:PUT];

  [restCore requestAsyncServer:request];
  EXIT_LOG
}

- (void)requestChangePasswordUserName:(NSString*)userName
                          oldPassword:(NSString*)oldPassword
                          newPassword:(NSString*)newPassword
                    completionHandler:(ASChangePassword)callback {
  ENTRY_LOG
  [self addCallback:callback forRequestId:ChangePasswordReqId];

    OauthStatus* oauthStatus = [CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypeAnyPasswordSignin];
  if (oauthStatus.error != nil) {
    [self changePasswordHelper:oauthStatus.error];
  }

    userName = userName.lowercaseString;

    
  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_CHANGE_PASSWORD_REQ_PATH
         requestId:ChangePasswordReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthStatus.oauthToken]
        parameters:@{
          MLC_CHANGE_PASSWORD_QUERY_OLD_PWD : oldPassword,
          MLC_CHANGE_PASSWORD_QUERY_NEW_PWD : newPassword
        } json:nil
        httpMethod:PUT];

  [restCore requestAsyncServer:request];
  EXIT_LOG
}

- (void)requestIsUserCitrusMemberUsername:(NSString*)email
                        completionHandler:
                            (ASIsUserCitrusMemberCallback)callback {
  [self addCallback:callback forRequestId:IsUserCitrusMemberReqId];
  if (![CTSUtility validateEmail:email]) {
    [self isUserCitrusMemberHelper:NO
                             error:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }

    OauthStatus* oauthStatus = [CTSOauthManager fetchSignupTokenStatus:keystore];

  if (oauthStatus.error != nil) {
    [self isUserCitrusMemberHelper:NO error:oauthStatus.error];
  }
    
    email = email.lowercaseString;


  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_IS_MEMBER_REQ_PATH
         requestId:IsUserCitrusMemberReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthStatus.oauthToken]
        parameters:@{
          MLC_IS_MEMBER_QUERY_EMAIL : email
        } json:nil
        httpMethod:MLC_IS_MEMBER_REQ_TYPE];

  [restCore requestAsyncServer:request];
}



- (void)requestBindUsername:(NSString*)email
                     mobile:(NSString *)mobile
          completionHandler:
(ASBindUserCallback)callback{
    [self addCallback:callback forRequestId:BindUserRequestId];
    
    if (![CTSUtility validateEmail:email]) {
        [self bindUserHelperUsername:email
                                 error:[CTSError getErrorForCode:EmailNotValid]];
        return;
    }
    
    if (![CTSUtility validateMobile:mobile]) {
        [self bindUserHelperUsername:nil error:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }
    
    
    email = email.lowercaseString;

    userNameBind = email;
    mobileBind = mobile;

    
    //get signup oauth token
    [self requestBindOauthToken];

    
    //call for bind
    //call for signin

}



- (void)requestMobileBindUsername:(NSString*)email
                           mobile:(NSString *)mobile
                completionHandler:
(ASBindUserCallback)callback{
    [self addCallback:callback forRequestId:BindMobileReqId];
    
    if (![CTSUtility validateEmail:email]) {
        [self bindByMobileHelper:mobile 
                               error:[CTSError getErrorForCode:EmailNotValid]];
        return;
    }
    mobile = [CTSUtility mobileNumberToTenDigitIfValid:mobile];
    if (!mobile) {
        [self bindUserHelperUsername:email
                               error:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }
    
    email = email.lowercaseString;


    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSignupTokenStatus:keystore];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_BIND_USER_MOBILE_REQ_PATH
                                   requestId:BindMobileReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:@{
                                                MLC_BIND_USER_QUERY_EMAIL : email,
                                                MLC_BIND_USER_QUERY_MOBILE : mobile
                                                } json:nil
                                   httpMethod:MLC_BIND_USER_REQ_TYPE];
    
    [restCore requestAsyncServer:request];






}


- (void)requestBindOauthToken {
    ENTRY_LOG
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:BindOauthTokenRequestId
                                   headers:nil
                                   parameters:MLC_OAUTH_TOKEN_SIGNUP_QUERY_MAPPING
                                   json:nil
                                   httpMethod:POST];
    
    [restCore requestAsyncServer:request];
    
    EXIT_LOG
}





- (BOOL)signOut {
  [CTSOauthManager resetPasswordSigninOauthData];
  [CTSOauthManager resetBindSiginOauthData];
  [CTSOauthManager resetSignupToken];
  [CTSUtility deleteSigninCookie];
  [CTSOauthManager resetPrepaidSigninToken];
  return YES;
}


-(BOOL)isUserBound{

    NSString* bindToken = [CTSOauthManager readBindSigninOauthTokenWithExpiryCheck];
    if(bindToken == nil){
        return NO;
    }
    return YES;

}

- (BOOL)isAnyoneSignedIn {
  NSString* signInOauthToken = [CTSOauthManager readPasswordSigninOauthTokenWithExpiryCheck];
    if (signInOauthToken == nil){
        LogTrace(@"signInOauthToken Expired");
    return NO;
    }
    if([CTSUtility isUserCookieValid] == NO){
        LogTrace(@"Cookie Invalid");
        return NO;
    }
    return YES;
}

- (BOOL)isLoggedIn {
//    NSString* signInOauthToken = [CTSOauthManager readPasswordSigninOauthTokenWithExpiryCheck];
//    if (signInOauthToken == nil){
//        LogTrace(@"signInOauthToken Expired");
//        return NO;
//    }
    NSString *prepaidSigninToken = [CTSOauthManager readPrepaidSigninOauthTokenWithExpiryCheck];
    if(prepaidSigninToken == nil){
        LogTrace(@"prepaid signin token Expired");
        return NO;
    
    }
    return YES;
}

- (BOOL)canLoadCitrusCash{
        NSString* signInOauthToken = [CTSOauthManager readPasswordSigninOauthTokenWithExpiryCheck];
        if (signInOauthToken == nil){
            LogTrace(@"signInOauthToken Expired");
            return NO;
        }
    return YES;
}





-(void)requestCitrusPaySignin:(NSString *)userName  password:(NSString*)password
            completionHandler:(ASCitrusSigninCallBack)callBack{

    [self addCallback:callBack forRequestId:CitruPaySigniInReqId];
    userName = userName.lowercaseString;

    
    
//validate username
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_CITRUS_PAY_AUTH_COOKIE_PATH
                                   requestId:CitruPaySigniInReqId
                                   headers:nil
                                   parameters:@{
                                                MLC_CITRUS_PAY_AUTH_COOKIE_EMAIL:userName,
                                                MLC_CITRUS_PAY_AUTH_COOKIE_PASSWORD:password,
                                                MLC_CITRUS_PAY_AUTH_COOKIE_RMCOOKIE:@"true"
                                            }
                                   json:nil
                                   httpMethod:POST];
    
    [restCore requestAsyncServerDelegation:request];
    

}


-(void)requestLink:(CTSUserDetails *)user completionHandler:(ASLinkCallback )callback{
    //accept mobile and email.
    //    Get Member Info (present in cube and tiny own sdk)
    //    if Mobile Present
    //        > Ask For Send M-OTP(not yet present) > (user will receive the otp) > RESPONSE : SIGN_IN_WITH_OTP
    //        if Mobile not Present and email present
    //            > Ask For Send E-OTP > (user will receive the eotp) > RESPONSE: SIGN_IN_WITH_EOTP
    //            Both Absent
    //            >  RESPONSE: FRESH_SIGNUP >
    
    
    
    //
    //Inputs:
    //
    //    email (mandatory)
    //    firstName (optional)
    //    lastName (optional)
    //    mobileNo (mandatory)
    //
    //
    //Output:
    //
    //
    
    
    
    [self addCallback:callback forRequestId:LinkReqId];
    
    //validations
    
    
    if (![CTSUtility validateEmail:user.email]) {
        [self linkHelper:nil error:[CTSError getErrorForCode:EmailNotValid]];
        return;
    }
    
    
    user.mobileNo = [CTSUtility mobileNumberToTenDigitIfValid:user.mobileNo];
    if (!user.mobileNo) {
        [self linkHelper:nil
                       error:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }

    
    
    
    CTSProfileLayer *profileLayer = [CitrusPaymentSDK fetchSharedProfileLayer];
    [profileLayer requestMemberInfoMobile:user.mobileNo email:user.email withCompletionHandler:^(CTSNewContactProfile *profile, NSError *error) {
        if(error){
            //reply with failure
            LogTrace(@"++++++++++++++++++++ Member Info Fetch Failed ");
            [self linkHelper:nil error:error];
            
        }else{
            LogTrace(@"++++++++++++++++++++ Member Info Fetched ");
            
            if(profile.responseData.profileByMobile){
                LogTrace(@"++++++++++++++++++++ Mobile Found ");
                
                //if Mob present    : (SDK invokes RequesMOtp) > User can now signin with motp or pwd
                
                [self requestGenerateOTPFor:profile.responseData.profileByMobile.mobile completionHandler:^(CTSResponse *response, NSError *error) {
                    LogTrace(@"++++++++++++++++++++ Asked to send the M otp ");
                    
                    if(error){
                        LogTrace(@"++++++++++++++++++++ ERROR in  M otp ");
                        
                        [self linkHelper:nil error:error];
                    }else{
                        //do link for wallet access
                        [self requestBindSignin:user.mobileNo completionHandler:^(NSError *error) {
                            [self linkHelper:[[CTSLinkRes alloc] initWith:LinkUserStatusMotpSigIn entity:profile.responseData.profileByMobile.mobile] error:nil];
                        }];
                    }
                }];
            }
            else if(profile.responseData.profileByEmail){
                //if Mob absent, Only Email present    : (SDK invokes RequesEOtp) > User can now signin with eotp or pwd
                LogTrace(@"++++++++++++++++++++ Email Found ");
                
                [self requestGenerateOTPFor:profile.responseData.profileByEmail.email completionHandler:^(CTSResponse *response,NSError *error) {
                    LogTrace(@"++++++++++++++++++++ Asked to send the E otp ");
                    
                    if(error){
                        LogTrace(@"++++++++++++++++++++ ERROR in  E otp ");
                        [self linkHelper:nil error:error];
                        
                    }else{
                        //do link for wallet access
                        [self requestBindSignin:user.email completionHandler:^(NSError *error) {
                            [self linkHelper:[[CTSLinkRes alloc] initWith:LinkUserStatusEotpSignIn entity:profile.responseData.profileByEmail.email] error:nil];
                        }];

                    }
                }];
            }
            else{
                //if Email Mobile Absent  : (SDK SignsUp the user) > User receives the Verification code > now app should proceed to verification call from SDK
                LogTrace(@"++++++++++++++++++++ Mobile Email Both Absent ");
                
                [self requestSignupUser:user password:nil mobileVerified:NO emailVerified:NO completionHandler:^(NSError *error) {
                    LogTrace(@"++++++++++++++++++++ Asked to Signup ");
                    if(error){
                        [self linkHelper:nil error:error];
                    }
                    else{
                        //do link for wallet access
                        [self requestBindSignin:user.email completionHandler:^(NSError *error) {
                            [self linkHelper:[[CTSLinkRes alloc] initWith:LinkUserStatusSignup entity:user.mobileNo] error:nil];
                        }];
                    }
                }];
            }
        }
    }];
}




-(void)requestLink:(CTSUserDetails *)user forceVerification:(BOOL)isForceVer completionHandler:(ASLinkCallback )callback{
    
    
    [self addCallback:callback forRequestId:LinkForceMobVerReqId];
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSignupTokenStatus:keystore];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    
    
    
    
    //validate username
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_LINK_FORCE_VER_PATH
                                   requestId:LinkForceMobVerReqId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:nil
                                   json:[CTSUtility toJson:@{
                                                              MLC_LINK_FORCE_VER_QUERY_EMAIL:user.email,
                                                              MLC_LINK_FORCE_VER_QUERY_MOBILE:user.mobileNo,
                                                              MLC_LINK_FORCE_VER_QUERY_FORCE_VERI:[CTSUtility toStringBool:isForceVer]
                                                              }]

                                   httpMethod:POST];
    
    [restCore requestAsyncServer:request];
}


-(void)requestLinkTrustedUser:(CTSUserDetails *)user completionHandler:(ASLinkUserCallBack )callback{
    //get user info
    //if email, mobile exists > call link
    //if email only exitist > mobile bind
    //if mobile only exitist > mobile bind
    //new user directly go for link
    
    
    [self addCallback:callback forRequestId:LinkTrustedReqId];
    
    CTSProfileLayer *profileLayer = [CitrusPaymentSDK fetchSharedProfileLayer];
    [profileLayer requestMemberInfoMobile:user.mobileNo email:user.email withCompletionHandler:^(CTSNewContactProfile *profile, NSError *error) {
        
        if(error){
            LogTrace(@"requestMemberInfoMobile error %@  ",error);
            [self linkTrustedUserHelper:nil error:error];
        }
        else{
            if(profile.responseData.profileByEmail &&  profile.responseData.profileByMobile == nil){
                //let the link happen
                LogTrace(@" mobile not found and email found ");
                [self requestMobileBindUsername:user.email mobile:user.mobileNo completionHandler:^(NSString *userName, NSError *error) {
                    LogTrace(@" doing mobile bind %@",userName);
                    LogTrace(@"mobile bind  error %@",error);
                    if(error){
                        [self linkTrustedUserHelper:nil error:error];
                    }
                    else{
                        [self requestLinkUser:user.email mobile:user.mobileNo completionHandler:^(CTSLinkUserRes *linkUserRes, NSError *error) {
                            [self linkTrustedUserHelper:linkUserRes error:error];
                        }];
                    }
                }];
            }
            else {
                [self requestLinkUser:user.email mobile:user.mobileNo completionHandler:^(CTSLinkUserRes *linkUserRes, NSError *error) {
                    [self linkTrustedUserHelper:linkUserRes error:error];
                    if(error == nil && profile.responseData.profileByEmail == nil &&  profile.responseData.profileByMobile == nil){
                        //adds mobile for new user
                        [self requestMobileBindUsername:user.email mobile:user.mobileNo completionHandler:^(NSString *userName, NSError *error) {
                        }];
                    }
                }];
            }
        }
    }];
}




-(void)requestLinkUser:(NSString *)email mobile:(NSString *)mobile completionHandler:(ASLinkUserCallBack)callBack
{
    
    
    [self addCallback:callBack forRequestId:LinkUserReqId];
//call bind
    //yes > set user password
    //password already set
    
    
    
    
    
    //implementtaion
    //verify the email and mobile
    isInLink = YES;
    
    if (![CTSUtility validateEmail:email]) {
        [self linkUserHelper:nil error:[CTSError getErrorForCode:EmailNotValid]];
        return;
    }
    if (![CTSUtility validateMobile:mobile]) {
        [self linkUserHelper:nil error:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }
    
    email = email.lowercaseString;

    //
    __block NSString *blockEmail = email;
    
    [self requestBindUsername:email mobile:mobile completionHandler:^(NSString *userName, NSError *error) {
        if(error){
        // return error
            [self linkUserHelper:nil error:error];
        
        }
        else if(userName){
            //TODO: check error
            
            [self
             requestSigninWithUsername:blockEmail
             password:[self generateBigIntegerString:blockEmail]
             completionHandler:^(NSString *userName, NSString *token, NSError *error) {
                 if(error && [self isBadCredentials:error]){
                     [self linkUserHelper:[[CTSLinkUserRes alloc] initPasswordAlreadySet] error:nil];

                 }
                 else {
                     [self linkUserHelper:[[CTSLinkUserRes alloc] initPasswordAlreadyNotSet] error:nil];
                     
                }
             }];
            
        }
    }];
   
}

-(NSString *)requestSignInOauthToken{
    return [CTSOauthManager readPasswordSigninOauthToken];
}


- (void)accessConsumerPortalWithParentViewController:(UIViewController *)controller
                               withCompletionHandler:(ASConsumerPortalCallBack)callback{
    
    [self addCallback:callback forRequestId:ConsumerPortalRequestId];
    
    OauthStatus* oauthStatus = [CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypeAnyPasswordSignin];
    if (oauthStatus.error != nil) {
        [self consumerPortalHelperWithRequest:nil withError:oauthStatus.error andParentViewController:nil];
        return;
    }
    
    NSMutableURLRequest *request;
    if ([[CTSUtility fetchFromEnvironment:BASE_URL] isEqualToString:PRODUCTION_BASEURL]) {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:CONSUMER_PORTAL_PRODUCTION_BASEURL]];
    }else{
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:CONSUMER_PORTAL_STAGING_BASEURL]];
    }

    [request addValue:oauthStatus.oauthToken forHTTPHeaderField:MLC_ACCESS_CONSUMER_PORTAL_TOKEN_KEY];
    
    [self consumerPortalHelperWithRequest:request withError:nil andParentViewController:controller];
}

-(void)consumerPortalHelperWithRequest:(NSMutableURLRequest *)request
                             withError:(NSError *)error
               andParentViewController:(UIViewController *)controller{
    
    ASConsumerPortalCallBack callback = [self retrieveAndRemoveCallbackForReqId:ConsumerPortalRequestId];
    
    if(callback != nil){
        CTSPaymentWebViewController *paymentWebViewController = [[CTSPaymentWebViewController alloc] init];
        paymentWebViewController.consumerPortalRequest = request;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:paymentWebViewController];
        [controller presentViewController:navigationController animated:NO completion:nil];
        callback(error);
    }
}

#pragma mark - pseudo password generator methods
- (NSString*)generatePseudoRandomPassword {
  // Build the password using C strings - for speed
  int length = 7;
  char* cPassword = calloc(length + 1, sizeof(char));
  char* ptr = cPassword;

  cPassword[length - 1] = '\0';

  char* lettersAlphabet = "abcdefghijklmnopqrstuvwxyz";
  ptr = appendRandom(ptr, lettersAlphabet, 2);

  char* capitalsAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  ptr = appendRandom(ptr, capitalsAlphabet, 2);

  char* digitsAlphabet = "0123456789";
  ptr = appendRandom(ptr, digitsAlphabet, 2);

  char* symbolsAlphabet = "!@#$%*[];?()";
  ptr = appendRandom(ptr, symbolsAlphabet, 1);

  // Shuffle the string!
  for (int i = 0; i < length; i++) {
    int r = arc4random() % length;
    char temp = cPassword[i];
    cPassword[i] = cPassword[r];
    cPassword[r] = temp;
  }
  return [NSString stringWithCString:cPassword encoding:NSUTF8StringEncoding];
}

char* appendRandom(char* str, char* alphabet, int amount) {
  for (int i = 0; i < amount; i++) {
    int r = arc4random() % strlen(alphabet);
    *str = alphabet[r];
    str++;
  }

  return str;
}

- (void)generator:(int)seed {
  seedState = seed;
}

- (int)nextInt:(int)max {
  seedState = 7 * seedState % 3001;
  return (seedState - 1) % max;
}
- (char)nextLetter {
  int n = [self nextInt:52];
  return (char)(n + ((n < 26) ? 'A' : 'a' - 26));
}
static NSData* digest(NSData* data,
                      unsigned char* (*cc_digest)(const void*,
                                                  CC_LONG,
                                                  unsigned char*),
                      CC_LONG digestLength) {
  unsigned char md[digestLength];
  (void)cc_digest([data bytes], (unsigned int)[data length], md);
  return [NSData dataWithBytes:md length:digestLength];
}

- (NSData*)md5:(NSString*)email {
  NSData* data = [email dataUsingEncoding:NSASCIIStringEncoding];
  return digest(data, CC_MD5, CC_MD5_DIGEST_LENGTH);
}

- (NSArray*)copyOfRange:(NSArray*)original from:(int)from to:(int)to {
  int newLength = to - from;
  NSArray* destination;
  if (newLength < 0) {
  } else {
    // int copy[newLength];
    destination = [original subarrayWithRange:NSMakeRange(from, newLength)];
  }
  return destination;
}
- (int)genrateSeed:(NSString*)data {
  NSMutableArray* array = [[NSMutableArray alloc] init];
  NSData* hashed = [self md5:data];
  NSUInteger len = [hashed length];
  Byte* byteData = (Byte*)malloc(len);
  [hashed getBytes:byteData length:len];

  int result1[16];
  for (int i = 0; i < 16; i++) {
    Byte b = byteData[i];  // 0xDC;
    result1[i] = (b & 0x80) > 0 ? b - 0xFF - 1 : b;
    [array addObject:[NSNumber numberWithInt:result1[i]]];
  }

  NSArray* val = [self copyOfRange:array
                              from:(unsigned int)[array count] - 3
                                to:(unsigned int)[array count]];
  NSData* arrayData = [NSKeyedArchiver archivedDataWithRootObject:val];
  LogTrace(@"%@", arrayData);
  int x = 0;
  for (int i = 0; i < [val count]; i++) {
    int z = [[val objectAtIndex:(val.count - 1 - i)] intValue];
    if (z < 0) {
      z = z + 256;
    }
    z = z << (8 * i);
    x = x + z;
    LogTrace(@"%d", x);
  }
  return x;
}
- (NSString*)generateBigIntegerString:(NSString*)email {
    LogTrace(@"email %@",email);
  int ran = [self genrateSeed:email];

  [self generator:ran];
  NSMutableString* large_CSV_String = [[NSMutableString alloc] init];
  for (int i = 0; i < 8; i++) {
    // Add something from the key?? Your format here.
    [large_CSV_String appendFormat:@"%c", [self nextLetter]];
  }
  LogTrace(@"random password:%@", large_CSV_String);
  return large_CSV_String;
}


#pragma mark - main class methods
enum {
    SignupOauthTokenReqId,
    SigninOauthTokenReqId,
    SignupStageOneReqId,
    SignupChangePasswordReqId,
    ChangePasswordReqId,
    RequestForPasswordResetReqId,
    IsUserCitrusMemberReqId,
    BindOauthTokenRequestId,
    BindUserRequestId,
    BindSigninRequestId,
    CitruPaySigniInReqId,
    LinkUserReqId,
    SetPasswordReqId,
    SignupOauthAsynTokenReqId,
    SignupNewReqId,
    MobileVerificationRequestId,
    MobVerCodeRegenerationRequestId,
    GenerateOTPReqId,
    LinkReqId,
    BindSigninAsyncReqId,
    OtpSignInReqId,
    LinkForceMobVerReqId,
    BindMobileReqId,
    LinkTrustedReqId,
    SigninPasswordPrepaidReqId,
    ConsumerPortalRequestId,
    TokenValidityReqId,
    TokenValidityUpdateReqId
};
- (instancetype)init {
    NSDictionary* dict = @{
                           toNSString(SignupOauthTokenReqId) : toSelector(handleReqSignupOauthToken
                                                                          :),
                           toNSString(SigninOauthTokenReqId) : toSelector(handleReqSigninOauthToken
                                                                          :),
                           toNSString(SignupStageOneReqId) : toSelector(handleReqSignupStageOneComplete
                                                                        :),
                           toNSString(SignupChangePasswordReqId) : toSelector(handleReqUsePassword
                                                                              :),
                           toNSString(RequestForPasswordResetReqId) :
                               toSelector(handleReqRequestForPasswordReset
                                          :),
                           toNSString(ChangePasswordReqId) : toSelector(handleReqChangePassword
                                                                        :),
                           toNSString(IsUserCitrusMemberReqId) : toSelector(handleIsUserCitrusMember
                                                                            :),
                           toNSString(BindOauthTokenRequestId) : toSelector(handleBindOauthToken
                                                                            :),
                           toNSString(BindUserRequestId) : toSelector(handleBindUser
                                                                      :),
                           toNSString(BindSigninRequestId) : toSelector(handleBindSignIn
                                                                        :),
                           toNSString(CitruPaySigniInReqId) : toSelector(handleCitrusPaySignin
                                                                         :),
                           toNSString(SignupOauthAsynTokenReqId) : toSelector(handleSignupAsyncOauthToken
                                                                              :),
                           toNSString(SignupNewReqId) : toSelector(handleNewSignup
                                                                   :),
                           toNSString(MobileVerificationRequestId) : toSelector(handleMobileVerfication:
                                                                                ),
                           toNSString(MobVerCodeRegenerationRequestId):toSelector(handleMobVerCodeRegeneration:)
                           ,
                           toNSString(GenerateOTPReqId):toSelector(handleOTPGeneration:),
                           toNSString(BindSigninAsyncReqId):toSelector(handleBindSignInAsync
                                                                       :),
                           toNSString(OtpSignInReqId):toSelector(handleOtpSignIn
                                                                 :),
                           toNSString(LinkForceMobVerReqId):toSelector(handleLinkUserForceVer:),
                           toNSString(BindMobileReqId):toSelector(handleBindByMobile:),
                           toNSString(SigninPasswordPrepaidReqId):toSelector(handleSigninPasswordPrepaid:),
                           toNSString(TokenValidityReqId):toSelector(handleTokenValidity:)
                           
                           };
    
    NSString *baseUrl = [self fetchBaseUrl];
    
    self =
    [super initWithRequestSelectorMapping:dict baseUrl:baseUrl];
    
    CTSKeyStore *keyStore = [CTSUtility fetchCachedKeyStore];
    if(keyStore){
        [self setKeyStore:keyStore];
    }
    
    return self;
}


+(CTSAuthLayer*)fetchSharedAuthLayer {
    static CTSAuthLayer *sharedAuthLayer = nil;
    @synchronized(self) {
        if (sharedAuthLayer == nil)
            sharedAuthLayer = [CTSAuthLayer new];
    }
    return sharedAuthLayer;
}

- (instancetype)initWithKeyStore:(CTSKeyStore *)keystoreArg{
    CTSAuthLayer *auth = [CTSAuthLayer new];
    [auth setKeyStore:keystoreArg];
    return auth;
}

#pragma mark - handlers


-(void)handleLinkUserForceVer:(CTSRestCoreResponse *)response{

    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSResponse *genResponse;
    CTSLinkRes *linkResponse = nil;

    if(!error){
        linkResponse = [[CTSLinkRes alloc] init];

        genResponse =[[CTSResponse alloc] initWithString:response.responseString error:&jsonError];
        int responseCode = [genResponse apiResponseCode];
        switch (responseCode) {
            case 1:
                linkResponse.linkUserStatus = LinkUserStatusMotpSigIn;
                break;
            case 2:
                linkResponse.linkUserStatus = LinkUserStatusEotpSignIn;

                break;
            case 3:
                linkResponse.linkUserStatus = LinkUserStatusForceMobVerEotpSignin;

                break;
            case 4:
                linkResponse.linkUserStatus = LinkUserStatusSignup;

                break;
            default:
                break;
        }
        linkResponse.message = genResponse.responseMessage;
        
        
    }
    
    [self linkUserForceVerHelper:linkResponse error:error];
    
    
}

-(void)handleBindByMobile:(CTSRestCoreResponse *)response{
    
    NSError* error = response.error;
    NSString *username = nil;
    // signup flow
    if (error == nil) {
        
        NSData *dataJson = [response.responseString dataUsingEncoding:NSUTF8StringEncoding ];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataJson options:kNilOptions error:&error];
        if(!error)
        username = [dict objectForKey:MLC_BIND_USER_MOBILE_RESPONSE_JSON_KEY];
    }

    [self bindByMobileHelper:username error:error];
    return;


}

-(void)handleBindOauthToken:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    // signup flow
    if (error == nil) {
        CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
        [CTSOauthManager saveSignupToken:resultObject.accessToken];
        [self requestInternalBindUserName:userNameBind mobile:mobileBind];
    } else {
        [self bindUserHelperUsername:userNameBind error:error];
        return;
    }

    //if success
    //save singup oauth token
    //call for bind
    //else
    //call bind helper with error
    
    
    
    
}


-(void)handleBindUser:(CTSRestCoreResponse*)response{
    
    NSError* error = response.error;
    // signup flow
    if (error == nil) {
        [self requestBindSigninUsername:userNameBind ];
    } else {
        [self bindUserHelperUsername:userNameBind error:error];
        return;
    }

    //if success call
    //call for sing in
    //else
    //call bind helper
    
    
    
}

-(void)handleBindSignIn:(CTSRestCoreResponse *)response{

    //if no error
    //save singin token
    
    //call helper for binduser
    
    NSError* error = response.error;
    JSONModelError* jsonError;
    // signup flow
    if (error == nil) {
        CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
        [resultObject logProperties];
        //[CTSOauthManager saveBindSignInOauth:resultObject];
        [CTSOauthManager saveToken:resultObject privilege:TokenPrivilegeTypeBind];
        }
    [self bindUserHelperUsername:userNameBind error:error];
    
}


-(void)handleBindSignInAsync:(CTSRestCoreResponse *)response{
    NSError* errorSignIn = response.error;
    JSONModelError* jsonError;
    if(errorSignIn == nil){
        CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
        [resultObject logProperties];
        [CTSOauthManager saveToken:resultObject privilege:TokenPrivilegeTypeBind];
    }
    if(errorSignIn == nil){
        CTSProfileLayer *profileLayer = [CitrusPaymentSDK fetchSharedProfileLayer];
        [profileLayer requestActivatePrepaidAccount:^(BOOL isActivated, NSError *error) {
            [self bindSigninAsyncHelperError:errorSignIn];
        }];
    }
    else{
        [self bindSigninAsyncHelperError:errorSignIn];
    }
}


- (void)handleReqSignupOauthToken:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  // signup flow
  if (error == nil) {
    CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
    [CTSOauthManager saveSignupToken:resultObject.accessToken];

    [self requestInternalSignupMobile:mobileSignUp email:userNameSignup];
  } else {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readPasswordSigninOauthToken]
                         error:error];
    return;
  }
}






- (void)handleReqChangePassword:(CTSRestCoreResponse*)response {
  [self changePasswordHelper:response.error];
}

//OLD IMPLEMENTATION BEFORE PREPAID FLOW
//- (void)handleReqSigninOauthToken:(CTSRestCoreResponse*)response {
//  NSError* error = response.error;
//  JSONModelError* jsonError;
//  // signup flow
//  if (error == nil) {
//    CTSOauthTokenRes* resultObject =
//        [[CTSOauthTokenRes alloc] initWithString:response.responseString
//                                           error:&jsonError];
//    [resultObject logProperties];
//    [CTSOauthManager saveOauthData:resultObject];
//    if (wasSignupCalled == YES) {
//      // in case of sign up flow
//
//      [self usePassword:passwordSignUp
//          hashedUsername:[self generateBigIntegerString:userNameSignup]];
//      wasSignupCalled = NO;
//    } else {
//      // in case of sign in flow
//
//      [self signinHelperUsername:userNameSignIn
//                           oauth:[CTSOauthManager readOauthToken]
//                           error:error];
//    }
//  } else {
//    if (wasSignupCalled == YES) {
//      // in case of sign up flow
//      [self signupHelperUsername:userNameSignup
//                           oauth:[CTSOauthManager readOauthToken]
//                           error:error];
//    } else {
//      // in case of sign in flow
//
//      [self signinHelperUsername:userNameSignIn
//                           oauth:[CTSOauthManager readOauthToken]
//                           error:error];
//    }
//  }
//}




- (void)handleReqSigninOauthToken:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    JSONModelError* jsonError;
    // signup flow
    if (error == nil) {
        CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
        [resultObject logProperties];
        CTSOauthTokenRes *prepaidAuthToken = resultObject.prepaidPayToken;
        resultObject.prepaidPayToken = nil;
       // [CTSOauthManager savePasswordSigninOauthData:resultObject];
       // [CTSOauthManager savePrepaidSigninOauthData:prepaidAuthToken];
        
        
        [CTSOauthManager saveToken:resultObject privilege:TokenPrivilegeTypeSignin];
        [CTSOauthManager saveToken:prepaidAuthToken privilege:TokenPrivilegeTypePrepaidSignin];

        
        if (wasSignupCalled == YES) {
            // in case of sign up flow_ not being used for prepaid
            
            [self usePassword:passwordSignUp
               hashedUsername:[self generateBigIntegerString:userNameSignup]];
            wasSignupCalled = NO;
        } else {
            [self proceedForTokensCall];

//            if(!isInLink){
//                [self proceedForTokensCall];
//            }
//            else {
//                [self signinHelperUsername:userNameSignIn
//                                     oauth:nil
//                                     error:error];
//            }
        }
    } else {
        if (wasSignupCalled == YES) {
            // in case of sign up flow
            [self signupHelperUsername:userNameSignup
                                 oauth:[CTSOauthManager readPasswordSigninOauthToken]
                                 error:error];
        } else {
            // in case of sign in flow
            
            [self signinHelperUsername:userNameSignIn
                                 oauth:[CTSOauthManager readPasswordSigninOauthToken]
                                 error:error];
        }
    }
}



-(void)handleOtpSignIn:(CTSRestCoreResponse*)response{
    __block NSError* errorSignIn = response.error;
    JSONModelError* jsonError;
    // signup flow
    if (errorSignIn == nil) {
        CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
        [resultObject logProperties];
        [CTSOauthManager savePasswordSigninOauthData:resultObject];
    }
    if(errorSignIn == nil){
        CTSProfileLayer *profileLayer = [CitrusPaymentSDK fetchSharedProfileLayer];
        [profileLayer requestActivatePrepaidAccount:^(BOOL isActivated, NSError *error) {
            [self otpSignInHelperError:errorSignIn];
        }];
    }
    else{
        [self otpSignInHelperError:errorSignIn];
    }
}


-(void)proceedForTokensCall{
    
    CTSProfileLayer *profileLayer = [CitrusPaymentSDK fetchSharedProfileLayer];
    [profileLayer requestActivatePrepaidAccount:^(BOOL isActivated, NSError *error) {
        //if get balance is succesfull
        //get coockie
        LogTrace(@" GetBalance Successful ");
        LogTrace(@"isActivated %d",isActivated);
        LogTrace(@"error %@",error);
        if(YES){
            [self requestCitrusPaySignin:userNameSignIn password:passwordSignin completionHandler:^(NSError *error) {
                LogTrace(@" requestCitrusPaySignin ");
                [self signinHelperUsername:userNameSignIn
                                     oauth:[CTSOauthManager readPasswordSigninOauthToken]
                                     error:error];
            }];

        }
        else{
            LogTrace(@" GetBalance Failed ");
            
            [self signinHelperUsername:userNameSignIn
                                 oauth:[CTSOauthManager readPasswordSigninOauthToken]
                                 error:error];
            
        }
    }];
    

}



- (void)handleReqSignupStageOneComplete:(CTSRestCoreResponse*)response {
  NSError* error = response.error;

  // change password
  //[self usePassword:TEST_PASSWORD for:SET_FIRSTTIME_PASSWORD];

  // get singn in oauth token for password use use hashed email
  // use it for sending the change password so that the password is set(for
  // old password use username)

  // always use this acess token

  if (error == nil) {
    // signup flow - now sign in

    [self
        requestSigninWithUsername:userNameSignup
                         password:[self generateBigIntegerString:userNameSignup]
                completionHandler:nil];

    //    [self requestSigninWithUsername:userNameSignup
    //                           password:passwordSignUp
    //                  completionHandler:nil];

  } else {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readPasswordSigninOauthToken]
                         error:error];
  }
}

- (void)handleReqUsePassword:(CTSRestCoreResponse*)response {
  LogTrace(@"password changed ");

  [self signupHelperUsername:userNameSignup
                       oauth:[CTSOauthManager readPasswordSigninOauthToken]
                       error:response.error];
}

- (void)handleReqRequestForPasswordReset:(CTSRestCoreResponse*)response {
  LogTrace(@"password change requested");
  [self resetPasswordHelper:response.error];
}

- (void)handleIsUserCitrusMember:(CTSRestCoreResponse*)response {
  if (response.error == nil) {
    [self isUserCitrusMemberHelper:[CTSUtility toBool:response.responseString]
                             error:nil];

  } else {
    [self isUserCitrusMemberHelper:NO error:response.error];
  }
}


-(void)handleCitrusPaySignin:(CTSRestCoreResponse *)response{
    [self citrusPaySigninHelper:(NSError *)response.data];
}

-(void)handleSignupAsyncOauthToken:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    // signup flow
    if (error == nil) {
        CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
        [CTSOauthManager saveSignupToken:resultObject.accessToken];
        
    }
    
    
    [self signupAsyncOauthTokenHelperError:error];

}

-(void)handleNewSignup:(CTSRestCoreResponse *)response{
    [self newSignupHelper:(NSError *)response.error];
}

-(void)handleMobileVerfication:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSResponse *genResponse;
    BOOL isVerified = NO;
    if(!error){
        genResponse =[[CTSResponse alloc] initWithString:response.responseString error:&jsonError];
        if(jsonError  == nil){
            error = [CTSError convertCTSResToErrorIfNeeded:genResponse];
        }
        else {
            error = jsonError;
        }
        if(error){
            genResponse = nil;
        }
    }
    if(error == nil){
    
        isVerified = YES;
    }
    
    [self mobileVerificationHelper:isVerified error:error];
    
    
    
    
}

-(void)handleMobVerCodeRegeneration:(CTSRestCoreResponse*)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSResponse *genResponse;
    if(!error){
        genResponse =[[CTSResponse alloc] initWithString:response.responseString error:&jsonError];
        if(jsonError  == nil){
            error = [CTSError convertCTSResToErrorIfNeeded:genResponse];
        }
        else {
            error = jsonError;
        }
        if(error){
            genResponse = nil;
        }
    }
    
    [self mobVerCodeRegenerationHelper:genResponse error:error];
    
}

-(void)handleOTPGeneration:(CTSRestCoreResponse*)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSResponse *genResponse;
    if(!error){
        genResponse =[[CTSResponse alloc] initWithString:response.responseString error:&jsonError];
        if(jsonError  == nil){
        error = [CTSError convertCTSResToErrorIfNeeded:genResponse];
        }
        else {
            error = jsonError;
        }
        if(error){
            genResponse = nil;
        }
    }
    
    
    
    
    [self otpGenerateHelper:genResponse error:error];
}


-(void)handleSigninPasswordPrepaid:(CTSRestCoreResponse *)response{
    __block NSError* errorSignIn = response.error;
    JSONModelError* jsonError;
    if (errorSignIn == nil) {
        CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
//        CTSOauthTokenRes *prepaidAuthToken = resultObject.prepaidPayToken;
//        resultObject.prepaidPayToken = nil;
//        [resultObject logProperties];
//        [CTSOauthManager savePasswordSigninOauthData:resultObject];
//        [CTSOauthManager savePrepaidSigninOauthData:prepaidAuthToken];
        
        [self saveOauthTokens:resultObject];

        
        
    }
        [self signinPasswordPrepaidHelper :errorSignIn];
}


-(void)handleTokenValidity:(CTSRestCoreResponse *)response{
    __block NSError* errorSignIn = response.error;
    JSONModelError* jsonError;
    CTSTokenValidityRes *tokenValidityRes = nil;
    // signup flow
    if (errorSignIn == nil) {
        tokenValidityRes = [[CTSTokenValidityRes alloc] initWithString:response.responseString error:&jsonError];
        errorSignIn = jsonError;
        
        if(tokenValidityRes){
        
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE MMM dd hh:mm:ss z yyyy"];
            tokenValidityRes.expirationDate = [dateFormatter dateFromString:tokenValidityRes.expiration];
        }

    }

    [self tokenValidity:tokenValidityRes error:errorSignIn];
}




#pragma mark - helper methods

-(void)linkUserForceVerHelper:(CTSLinkRes *)linkResponse error:(NSError *)error{
    ASLinkCallback callback = [self retrieveAndRemoveCallbackForReqId:LinkForceMobVerReqId];
    if(callback){
        callback(linkResponse,error);
    }
}


- (void)signinHelperUsername:(NSString*)username
                       oauth:(NSString*)token
                       error:(NSError*)error {
  ASSigninCallBack callBack =
      [self retrieveAndRemoveCallbackForReqId:SigninOauthTokenReqId];

    userNameSignIn = @"";
    passwordSignin = @"";

    
  if (error != nil && isInLink == NO) {
    //[CTSOauthManager resetOauthData];
  }

  if (callBack != nil) {
    callBack(username, token, error);
  } else {
    [delegate auth:self
        didSigninUsername:username
               oauthToken:token
                    error:error];
  }
}

- (void)signupHelperUsername:(NSString*)username
                       oauth:(NSString*)token
                       error:(NSError*)error {
  ASSigninCallBack callBack =
      [self retrieveAndRemoveCallbackForReqId:SignupOauthTokenReqId];

  wasSignupCalled = NO;

  if (error != nil && isInLink == NO) {
    [CTSOauthManager resetPasswordSigninOauthData];
  }

  if (callBack != nil) {
    callBack(username, token, error);
  } else {
    [delegate auth:self
        didSignupUsername:username
               oauthToken:token
                    error:error];
  }

  [self resetSignupCredentials];
}

- (void)changePasswordHelper:(NSError*)error {
  ASChangePassword callback =
      [self retrieveAndRemoveCallbackForReqId:ChangePasswordReqId];

  if (callback != nil) {
    callback(error);
  } else {
    [delegate auth:self didChangePasswordError:error];
  }
}


- (void)setPasswordHelper:(NSError*)error {
    ASSetPassword callback =
    [self retrieveAndRemoveCallbackForReqId:SetPasswordReqId];
        if (callback != nil) {
        callback(error);
    } else {
        [delegate auth:self didSetPasswordError:error];
    }
}

- (void)isUserCitrusMemberHelper:(BOOL)isMember error:(NSError*)error {
  ASIsUserCitrusMemberCallback callback =
      [self retrieveAndRemoveCallbackForReqId:IsUserCitrusMemberReqId];
  if (callback != nil) {
    callback(isMember, error);
  } else {
    [delegate auth:self didCheckIsUserCitrusMember:isMember error:error];
  }
}

- (void)resetPasswordHelper:(NSError*)error {
  ASResetPasswordCallback callback =
      [self retrieveAndRemoveCallbackForReqId:RequestForPasswordResetReqId];
  if (callback != nil) {
    callback(error);
  } else {
    [delegate auth:self didRequestForResetPassword:error];
  }
}


- (void)bindUserHelperUsername:(NSString *)userName error:(NSError*)error {
    ASBindUserCallback callback =
    [self retrieveAndRemoveCallbackForReqId:BindUserRequestId];
    if (callback != nil) {
        callback(userName,error);
    } else {
        [delegate auth:self didBindUser:userName error:error];
    }
    [self resetBindData];
}


-(void)bindSigninAsyncHelperError:(NSError *)error{
    ASBindSignIn callback = [self retrieveAndRemoveCallbackForReqId:BindSigninAsyncReqId];
    callback(error);

}


-(void)citrusPaySigninHelper:(NSError *)error{
    ASCitrusSigninCallBack callback =
    [self retrieveAndRemoveCallbackForReqId:CitruPaySigniInReqId];
    if (callback != nil) {
        callback(error);
    } else {
        [delegate auth:self didCitrusSigninInerror:error];
    }

}



-(void)linkUserHelper:(CTSLinkUserRes *)linkUserRes error:(NSError *)error{
    
    [self resetLinkData];
    
    ASLinkUserCallBack callback = [self retrieveAndRemoveCallbackForReqId:LinkUserReqId];
    if(callback != nil){
        callback(linkUserRes,error);
    }
    else{
        [delegate auth:self didLinkUser:linkUserRes error:error];
    
    }
}


-(void)linkTrustedUserHelper:(CTSLinkUserRes *)linkUserRes error:(NSError *)error{
    
    ASLinkUserCallBack callback = [self retrieveAndRemoveCallbackForReqId:LinkTrustedReqId];
    if(callback != nil){
        callback(linkUserRes,error);
    }
}

-(void)signupAsyncOauthTokenHelperError:(NSError *)error{
    ASAsyncSignUpOauthTokenCallBack callback = [self retrieveAndRemoveCallbackForReqId:SignupOauthAsynTokenReqId];
    callback(error);
}

-(void)newSignupHelper:(NSError *)error{
    ASSignupNewCallBack callback = [self retrieveAndRemoveCallbackForReqId:SignupNewReqId];
    
    if(callback != nil){
        callback(error);
    }
    else{
        [delegate auth:self didSignup:error];
    }


}

-(void)mobileVerificationHelper:(BOOL)isVerified error:(NSError *)error{
    ASOtpVerificationCallback callback = [self retrieveAndRemoveCallbackForReqId:MobileVerificationRequestId];
    if(callback != nil){
        callback(isVerified,error);
    }
    else{
        [delegate auth:self didVerifyOTP:isVerified error:error];
    }
    
}


-(void)mobVerCodeRegenerationHelper:(CTSResponse *)response error:(NSError *)error{
    ASOtpRegenerationCallback callback = [self retrieveAndRemoveCallbackForReqId:MobVerCodeRegenerationRequestId];
    if(callback != nil){
        callback(response,error);
    }
    else{
        [delegate auth:self didGenerateVerificationCode:response error:error];
    }
}


-(void)otpGenerateHelper:(CTSResponse *)response error:(NSError *)error{
    ASGenerateOtpCallBack callback = [self retrieveAndRemoveCallbackForReqId:GenerateOTPReqId];
    if(callback != nil){
        callback(response,error);
    }
    else{
        [delegate auth:self didGenerateOTPWithError:error];
    }

}

-(void)linkHelper:(CTSLinkRes *)response error:(NSError *)error{
    ASLinkCallback callback = [self retrieveAndRemoveCallbackForReqId:LinkReqId];
    if(callback != nil){
        callback(response,error);
    }
    else{
        [delegate auth:self didLink:response error:error];
    }
}


-(void)otpSignInHelperError:(NSError *)error{
    ASOtpSigninCallBack callback = [self retrieveAndRemoveCallbackForReqId:OtpSignInReqId];
    if(callback != nil){
        callback(error);
    }else {
        [delegate auth:self didSignInWithOtpError:error];
    }


}

-(void)bindByMobileHelper:(NSString *)username error:(NSError *)error{

    ASBindUserCallback callback = [self retrieveAndRemoveCallbackForReqId:BindMobileReqId];
    if(callback !=nil){
        callback(username,error);
    
    }
}

-(void)signinPasswordPrepaidHelper:(NSError *)error{
    ASCitrusSigninCallBack callback = [self retrieveAndRemoveCallbackForReqId:SigninPasswordPrepaidReqId];
    if(callback != nil){
        callback(error);
    }
}


-(void)tokenValidity:(CTSTokenValidityRes *)tokenValidity error:(NSError *)error{
    ASTokenValidityCallback callback = [self retrieveAndRemoveCallbackForReqId:TokenValidityReqId];
    if (callback != nil) {
        callback(tokenValidity,error);
    }

}

-(void)tokenExpiryUpdateHelperError:(NSError *)error{
    ASErrorCallback callback = [self retrieveAndRemoveCallbackForReqId:TokenValidityUpdateReqId];
    if (callback != nil) {
        callback(error);
    }

}

-(void)citrusLinkSigninWithError:(NSError *)error callback:(ASCitrusSigninCallBack)callback{
    
    if(error == nil){
       OauthStatus* tokenStatus = [CTSOauthManager tokenWithPrivilege:TokenPrivilegeTypePrepaidSignin];
        if(tokenStatus.oauthToken == nil && error == nil){
            //error = [CTSError getErrorForCode:NoNewPrepaidPrelivilage];
            LogError(@"Your Keys Do not Have Citrus Wallet Privilege, Please Contact Citrus Support");
        }
        
        CTSProfileLayer *profile = [CitrusPaymentSDK fetchSharedProfileLayer];
        [profile requestActivateAndGetBalance:nil];
        
        CTSResponse *linkUseResponse = [self fetchCachedDataForKey:CACHE_KEY_CITRUS_LINK];
        NSString *email = [linkUseResponse.responseData valueForKey:@"email"];
        [self requestBindSignin:email completionHandler:^(NSError *error) {
            LogTrace(@" implicit bind singin error %@ ",error);
        }];
        
        [self removeCachedLinkData];
    }
    
    
    callback(error);
}

-(void)removeCachedLinkData{
    [self fetchAndRemovedCachedDataForKey:CACHE_KEY_CITRUS_LINK];
}


#pragma mark - housekeeping methods
-(BOOL)isBadCredentials:(NSError *)error{
    
    if([CTSUtility string:[error localizedDescription] containsString:@"Bad credentials"]){
    
        return YES;
    }
    return NO;

}
-(void)resetLinkData{
    isInLink = NO;
}

- (void)resetBindData {
    userNameBind = @"";
    mobileBind = @"";
}

-(void)resetSignIn{
   userNameSignIn = @"";
   passwordSignin = @"";
}

- (void)resetSignupCredentials {
  userNameSignup = @"";
  mobileSignUp = @"";
  passwordSignUp = @"";
}



@end
