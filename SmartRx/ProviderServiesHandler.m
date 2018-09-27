//
//  ProviderServiesHandler.m
//  SmartRx
//
//  Created by Gowtham on 10/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "ProviderServiesHandler.h"

@implementation ProviderServiesHandler
+ (id)sharedInstance {
    static ProviderServiesHandler *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

@end
