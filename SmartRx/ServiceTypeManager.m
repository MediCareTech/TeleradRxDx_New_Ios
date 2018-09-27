//
//  ServiceTypeManager.m
//  SmartRx
//
//  Created by Gowtham on 14/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "ServiceTypeManager.h"

static ServiceTypeManager *handler = nil;


@implementation ServiceTypeManager



+(id)sharedManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[ServiceTypeManager alloc] init];
    });
    return handler;
    
    
}
-(NSString *)getSelectedServiceType:(NSString *)type{

    NSString *serviceType = @"";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.id contains[cd] %@",type];
           NSArray *filteredArr = [self.serviceArray filteredArrayUsingPredicate:predicate];
    if (filteredArr.count) {
        NSDictionary *dict = filteredArr[0];
        
        
        serviceType =  dict[@"name"];
    }



    return serviceType;
}


@end
