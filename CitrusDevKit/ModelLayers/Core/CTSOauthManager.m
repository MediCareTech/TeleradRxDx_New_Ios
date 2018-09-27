//
//  CTSOauthManager.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 21/07/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSOauthManager.h"
#import "CTSAuthLayerConstants.h"
#import "CTSError.h"
#import "CTSUtility.h"
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>
#import "CTSRestCore.h"

@implementation CTSOauthManager
- (instancetype)init {
  self = [super init];
  if (self) {
    //    < #statements # >
  }
  return self;
}

// check if oauth exitsts
// if null ask user to sign in
// if exits check for expiry
// if expired return authExpired
// if server tells to sign in ask user to sign in else procced

+ (void)savePrepaidSigninOauthData:(CTSOauthTokenRes*)object {
    object.tokenSaveDate = [NSDate date];
    NSData* encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:MLC_OAUTH_PREPAID_SIGNIN_KEY];
    [defaults synchronize];
}

+ (void)savePasswordSigninOauthData:(CTSOauthTokenRes*)object {
  object.tokenSaveDate = [NSDate date];
  NSData* encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:encodedObject forKey:MLC_OAUTH_PASSWORD_SIGNIN_KEY];
  [defaults synchronize];
}

+(void)saveBindSignInOauth:(CTSOauthTokenRes*)object{
    object.tokenSaveDate = [NSDate date];
    NSData* encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:MLC_OAUTH_BIND_SIGN_IN];
    [defaults synchronize];

}

+ (CTSOauthTokenRes*)readBindSignInOauthData {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData* encodedObject = [defaults objectForKey:MLC_OAUTH_BIND_SIGN_IN];
    CTSOauthTokenRes* object =
    [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    return object;
}

+ (CTSOauthTokenRes*)readPasswordSigninOuthData {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSData* encodedObject = [defaults objectForKey:MLC_OAUTH_PASSWORD_SIGNIN_KEY];
  CTSOauthTokenRes* object =
      [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];

  return object;
}

+ (CTSOauthTokenRes*)readPrepaidSigninOuthData {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData* encodedObject = [defaults objectForKey:MLC_OAUTH_PREPAID_SIGNIN_KEY];
    CTSOauthTokenRes* object =
    [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    return object;
}

/**
 *  reads oauth token from the navtive disk,
 *  @return returns oauth token
 *
 */
+ (NSString*)readPasswordSigninOauthToken {
  return [self readPasswordSigninOuthData].accessToken;
}

+ (NSString*)readPasswordSigninOauthTokenWithExpiryCheck {
  if (![self hasPasswordSignInOauthExpired]) {
    return [self readPasswordSigninOuthData].accessToken;
  } else {
    return nil;
  }
}

+ (NSString*)readBindSigninOauthTokenWithExpiryCheck {
    if (![self hasBindSigninOauthTokenExpired]) {
        return [self readBindSignInOauthData].accessToken;
    } else {
        return nil;
    }
}

+ (NSString*)readPrepaidSigninOauthTokenWithExpiryCheck {
    if (![self hasPrepaidSigninOauthTokenExpired]) {
        return [self readPrepaidSigninOuthData].accessToken;
    } else {
        return nil;
    }
}


+(NSString *)readBindSignInRefreshToken{
    CTSOauthTokenRes* oauthTokenRes = [CTSOauthManager readBindSignInOauthData];
    LogTrace(@" readRefreshToken %@ %@", oauthTokenRes, oauthTokenRes.refreshToken);
    return oauthTokenRes.refreshToken;

}

+(NSString *)readPrepaidSignInRefreshToken{
    CTSOauthTokenRes* oauthTokenRes = [CTSOauthManager readPrepaidSigninOuthData];
    LogTrace(@" readRefreshToken %@ %@", oauthTokenRes, oauthTokenRes.refreshToken);
    return oauthTokenRes.refreshToken;
    
}

+ (NSString*)readRefreshToken {
  CTSOauthTokenRes* oauthTokenRes = [CTSOauthManager readPasswordSigninOuthData];
  LogTrace(@" readRefreshToken %@ %@", oauthTokenRes, oauthTokenRes.refreshToken);
  return oauthTokenRes.refreshToken;
}

+ (void)resetPasswordSigninOauthData {
    [CTSUtility removeFromDisk:MLC_OAUTH_PASSWORD_SIGNIN_KEY];
}


+ (void)resetBindSiginOauthData {
    [CTSUtility removeFromDisk:MLC_OAUTH_BIND_SIGN_IN];
}

+ (BOOL)hasPasswordSignInOauthExpired {
    return  [self hasOauthExpired:[self readPasswordSigninOuthData]];

}

+(BOOL)hasBindSigninOauthTokenExpired{
   return  [self hasOauthExpired:[self readBindSignInOauthData]];
}

+(BOOL)hasPrepaidSigninOauthTokenExpired{
    return  [self hasOauthExpired:[self readPrepaidSigninOuthData]];
}

+ (BOOL)hasOauthExpired:(CTSOauthTokenRes*)oauthTokenRes {
  NSDate* tokenSaveDate = oauthTokenRes.tokenSaveDate;
  NSDate* todaysDate = [NSDate date];
  NSTimeInterval secondsBetween =
      [todaysDate timeIntervalSinceDate:tokenSaveDate];

  if (secondsBetween > oauthTokenRes.tokenExpiryTime) {
    return YES;
  } else {
    return NO;
  }
}

- (void)requestOauthTokenRefresh {
  // request for oauth refresh
}

+ (OauthStatus*)fetchPasswordSigninTokenStatus:(CTSKeyStore *)keySore {
  OauthStatus* oauthStatus = [[OauthStatus alloc] init];
  CTSOauthTokenRes* oauthTokenRes = [CTSOauthManager readPasswordSigninOuthData];
  if (oauthTokenRes == nil) {
    oauthStatus.error = [CTSError getErrorForCode:UserNotSignedIn];
    return oauthStatus;
  } else if ([CTSOauthManager hasOauthExpired:oauthTokenRes]) {
    // server call to refresh the token
      oauthTokenRes = [CTSOauthManager refreshOauthToken:keySore];
    if (oauthTokenRes == nil) {
      oauthStatus.error = [CTSError getErrorForCode:UserNotSignedIn];
      return oauthStatus;
    }
  }
  oauthStatus.oauthToken = oauthTokenRes.accessToken;

  return oauthStatus;
}

+ (OauthStatus*)fetchBindSigninTokenStatus:(CTSKeyStore *)keyStore {
    OauthStatus* oauthStatus = [[OauthStatus alloc] init];
    CTSOauthTokenRes* oauthTokenRes = [CTSOauthManager readBindSignInOauthData];
    if (oauthTokenRes == nil) {
        oauthStatus.error = [CTSError getErrorForCode:UserNotSignedIn];
        return oauthStatus;
    } else if ([CTSOauthManager hasOauthExpired:oauthTokenRes]) {
        // server call to refresh the token
        oauthTokenRes = [CTSOauthManager refreshBindSiginInOauthToken:keyStore];
        if (oauthTokenRes == nil) {
            oauthStatus.error = [CTSError getErrorForCode:UserNotSignedIn];
            return oauthStatus;
        }
    }
    oauthStatus.oauthToken = oauthTokenRes.accessToken;
    
    return oauthStatus;
}

+ (OauthStatus*)fetchPrepaidSigninTokenStatus{
    OauthStatus* oauthStatus = [[OauthStatus alloc] init];
    CTSOauthTokenRes* oauthTokenRes = [CTSOauthManager readPrepaidSigninOuthData];
    oauthStatus.oauthToken = oauthTokenRes.accessToken;
    if (oauthTokenRes == nil || [CTSOauthManager hasOauthExpired:oauthTokenRes]) {
        oauthStatus.error = [CTSError getErrorForCode:UserNotSignedIn];
    }
    return oauthStatus;
}


+ (void)saveSignupToken:(NSString*)token {
  [CTSUtility saveToDisk:token as:MLC_SIGNUP_ACCESS_OAUTH_TOKEN];
}

+(void)resetSignupToken{
    [CTSUtility removeFromDisk:MLC_SIGNUP_ACCESS_OAUTH_TOKEN];
}

+(void)resetPrepaidSigninToken{
    [CTSUtility removeFromDisk:MLC_OAUTH_PREPAID_SIGNIN_KEY];
}
+ (NSString*)readSignupToken {
  return [CTSUtility readFromDisk:MLC_SIGNUP_ACCESS_OAUTH_TOKEN];
}

+ (OauthStatus*)fetchSignupTokenStatus:(CTSKeyStore *)keyStore {
  OauthStatus* oauthTokenStatus = [[OauthStatus alloc] init];

  oauthTokenStatus.oauthToken = [CTSOauthManager readSignupToken];
  if (oauthTokenStatus.oauthToken == nil) {
      CTSOauthTokenRes* tokenResponse = [CTSOauthManager requestSignupOauthToken:keyStore];
    if (tokenResponse == nil) {
      oauthTokenStatus.error = [CTSError getErrorForCode:CantFetchSignupToken];
    } else {
      oauthTokenStatus.oauthToken = tokenResponse.accessToken;
    }
  }

  return oauthTokenStatus;
}

+ (CTSOauthTokenRes*)refreshOauthToken:(CTSKeyStore *)keyStore {
  NSDictionary* parameters = @{
    MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : [CTSUtility fetchSigninId:keyStore],
    MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : [CTSUtility fetchSigninSecret:keyStore],
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

  CTSRestCoreResponse* response =
      [CTSRestCore requestSyncServer:request withBaseUrl:[CTSUtility fetchFromEnvironment:BASE_URL]];

  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSOauthTokenRes* resultObject = nil;
  if (error == nil) {
    resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
    [CTSOauthManager savePasswordSigninOauthData:resultObject];
  }
  return resultObject;
}




+ (CTSOauthTokenRes*)refreshBindSiginInOauthToken:(CTSKeyStore *)keystore {
    NSDictionary* parameters = @{
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : [CTSUtility fetchSigninId:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : [CTSUtility fetchSigninSecret:keystore],
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_OAUTH_REFRESH_QUERY_REFRESH_TOKEN,
                                 MLC_OAUTH_REFRESH_QUERY_REFRESH_TOKEN : [CTSOauthManager readBindSignInRefreshToken]
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:-1
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:POST];
    
    CTSRestCoreResponse* response =
    [CTSRestCore requestSyncServer:request withBaseUrl:[CTSUtility fetchFromEnvironment:BASE_URL]];
    
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSOauthTokenRes* resultObject = nil;
    if (error == nil) {
        resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
        [CTSOauthManager saveBindSignInOauth:resultObject];
    }
    return resultObject;
}


+ (CTSOauthTokenRes*)requestSignupOauthToken:(CTSKeyStore *)keystore {
  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
         requestId:-1
           headers:nil
        parameters:MLC_OAUTH_TOKEN_SIGNUP_QUERY_MAPPING
              json:nil
        httpMethod:POST];

  CTSRestCoreResponse* response =
      [CTSRestCore requestSyncServer:request withBaseUrl:[CTSUtility fetchFromEnvironment:BASE_URL]];
  NSError* error = response.error;
  CTSOauthTokenRes* resultObject = nil;

  if (error == nil) {
    JSONModelError* jsonError;
    resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
    LogTrace(@"jsonError %@ ", jsonError);
    [CTSOauthManager saveSignupToken:resultObject.accessToken];
  }
  return resultObject;
}


+(OauthStatus *)tokenWithPrivilege:(TokenPrevilageType)type{
    
    CTSKeyStore *keyStore = [CTSUtility keyStore];
    OauthStatus *oauthStatus = [[OauthStatus alloc] init];
    
    if(keyStore == nil){
        oauthStatus.oauthToken = nil;
        oauthStatus.error = [CTSError getErrorForCode:KeyStoreNotSet];
        return oauthStatus;
    }
    
    OauthStatus *bindToken =  [self fetchBindSigninTokenStatus:keyStore];
    OauthStatus *singinToken =  [self fetchPasswordSigninTokenStatus:keyStore];
    OauthStatus *prepaidToken  = [self fetchPrepaidSigninTokenStatus];
    
    
    switch (type) {
        case TokenPrivilegeTypeBind:
                oauthStatus = bindToken;
            break;
        case TokenPrivilegeTypeSignin:
                oauthStatus = singinToken;
            break;
        case TokenPrivilegeTypePrepaidSignin:
                oauthStatus = prepaidToken;
            break;
        case TokenPrivilegeTypeSignUp:
            oauthStatus = [self fetchSignupTokenStatus:keyStore];
            break;
        case TokenPrivilegeTypeAny:
            if(bindToken.error == nil){
                oauthStatus = bindToken;
                break;
            }
            else if(singinToken.error == nil){
                oauthStatus = singinToken;
                break;
            }
            else {
                oauthStatus = prepaidToken;
                break;
            }
            break;
        case TokenPrivilegeTypeAnyPasswordSignin:
            if(singinToken.error == nil){
                oauthStatus = singinToken;
                break;
            }
            else{
                oauthStatus = prepaidToken;
                break;
            }
        default:
            break;
    }
    return oauthStatus;
    
}


+(void)saveToken:(CTSOauthTokenRes *)oauthToken privilege:(TokenPrevilageType)type{
    switch (type) {
        case TokenPrivilegeTypeBind:
            [self saveBindSignInOauth:oauthToken];
            break;
        case TokenPrivilegeTypeSignin:
            [self savePasswordSigninOauthData:oauthToken];
            break;
        case TokenPrivilegeTypePrepaidSignin:
            [self savePrepaidSigninOauthData:oauthToken];
            break;
        case TokenPrivilegeTypeSignUp:
            [self saveSignupToken:oauthToken.accessToken];
            break;
        default:
            break;
    }
}

@end
