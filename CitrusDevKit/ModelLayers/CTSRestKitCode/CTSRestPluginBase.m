//
//  CTSRestPluginBase.m
//  CTSRestKit
//
//  Created by Yadnesh Wankhede on 30/07/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "CTSRestPluginBase.h"
#import "CTSRestError.h"
#import "NSObject+logProperties.h"
#import "CTSOauthManager.h"
#import "CTSAuthLayerConstants.h"
#import "CTSUtility.h"
@implementation CTSRestPluginBase
-(CTSKeyStore *)keyStore{return nil;}
@synthesize requestBlockCallbackMap;
- (instancetype)initWithRequestSelectorMapping:(NSDictionary*)mapping
                                       baseUrl:(NSString*)baseUrl
                                      keyStore:(CTSKeyStore *)keyStoreArg{
    self = [super init];
    if (self) {
        ctsCache = [CTSDataCache sharedCache];
        restCore = [[CTSRestCore alloc] initWithBaseUrl:baseUrl];
        restCore.delegate = self;
        requestSelectorMap = mapping;
        keystore = keyStoreArg;
        requestBlockCallbackMap = [[NSMutableDictionary alloc] init];
        dataCache = [[NSMutableDictionary alloc] init];
        if (self != [CTSRestPluginBase class] &&
            ![self conformsToProtocol:@protocol(CTSRestCoreDelegate)]) {
            @throw
            [[NSException alloc] initWithName:@"UnImplimented Protocol"
                                       reason:@"CTSRestCoreDelegate - not adopted"
                                     userInfo:nil];
        }
    }
    return self;
}

- (instancetype)initWithRequestSelectorMapping:(NSDictionary*)mapping
                                       baseUrl:(NSString*)baseUrl
{
    return [self initWithRequestSelectorMapping:mapping baseUrl:baseUrl keyStore:nil];
}

-(void)setKeyStore:(CTSKeyStore *)keyStoreArg{
    keystore = keyStoreArg;
}

- (void)restCore:(CTSRestCore*)restCore
didReceiveResponse:(CTSRestCoreResponse*)response {
    SEL sel = [[requestSelectorMap
                valueForKey:toNSString(response.requestId)] pointerValue];
    
    if ([self respondsToSelector:sel]) {
        if (response.error != nil || [CTSUtility isErrorJson:response.responseString]) {
            response = [CTSUtility addJsonErrorToResponse:response];
        }
        
        [self performSelector:sel onThread:[NSThread mainThread] withObject:response waitUntilDone:YES];
    } else {
        @throw [[NSException alloc]
                initWithName:@"No Selector Found"
                reason:[NSString stringWithFormat:@"method %@ | NOT FOUND",
                        NSStringFromSelector(sel)]
                userInfo:nil];
    }
}



- (void)addCallback:(id)callBack forRequestId:(int)reqId {
    if (callBack != nil)
        [self.requestBlockCallbackMap setObject:[callBack copy]
                                         forKey:toNSString(reqId)];
}

- (id)retrieveAndRemoveCallbackForReqId:(int)reqId {
    id callback = [self.requestBlockCallbackMap objectForKey:toNSString(reqId)];
    [self.requestBlockCallbackMap removeObjectForKey:toNSString(reqId)];
    return callback;
}

- (void)cacheData:(id)object key:(NSString *)index {
    [[CTSDataCache sharedCache] cacheData:object key:index];
}
- (id)fetchCachedDataForKey:(NSString *)index {
    return [[CTSDataCache sharedCache] fetchCachedDataForKey:index];
}
- (id)fetchAndRemovedCachedDataForKey:(NSString *)index {
    return [[CTSDataCache sharedCache] fetchAndRemovedCachedDataForKey:index];
}

- (NSString *)fetchBaseUrl{
   return [CTSUtility fetchFromEnvironment:BASE_URL];
}



//- (long)addDataToCacheAtAutoIndex:(NSString *)object {
//    long index = [self getNewIndex];
//    [self cacheData:object key:index];
//    return index;
//}
//
//- (long)getNewIndex {
//    return cacheId++;
//}



@end
