//
//  CTSDataCache.m
//  CTS iOS Sdk
//
//  Created by Yadnesh on 8/31/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "CTSDataCache.h"

@implementation CTSDataCache
@synthesize cache;

+ (id)sharedCache {
    static CTSDataCache *sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[self alloc] init];
    });
    return sharedCache;
}

- (id)init {
    if (self = [super init]) {
        cache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)cacheData:(id)object key:(NSString *)index {
    [cache setValue:object forKey:index];
}
- (id)fetchCachedDataForKey:(NSString *)index {
    return [cache valueForKey:index];
}
- (id)fetchAndRemovedCachedDataForKey:(NSString *)index {
    id object = [self fetchCachedDataForKey:index];
    [cache removeObjectForKey:index];
    return object;
}


@end
