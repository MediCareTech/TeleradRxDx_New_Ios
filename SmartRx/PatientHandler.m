//
//  PatientHandler.m
//  SmartRx
//
//  Created by SmartRx-iOS on 06/03/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "PatientHandler.h"

@implementation PatientHandler
+ (id)sharedInstance {
    static PatientHandler *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}
@end
