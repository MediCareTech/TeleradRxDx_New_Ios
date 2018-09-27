//
//  UserDetails.m
//  TeleradRxdx
//
//  Created by Gowtham on 24/05/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "UserDetails.h"

@implementation UserDetails


+(void)setQikWellId:(NSString *)qikIdStr;{
    [self setDataToUserDefaults:@"qikWellId" data:qikIdStr];
}

+(NSString *)getQikWellId{
    return [self getDataFromDefaults:@"qikWellId"];
}
+(void)setQikWellApi:(NSString *)qikWellApi{
    [self setDataToUserDefaults:@"qikWellURL" data:qikWellApi];

}

+(NSString *)getQikWellApi{
    return [self getDataFromDefaults:@"qikWellURL"];
}
+(void)setDataToUserDefaults:(NSString *)key data:(NSString *)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}
+(NSString *)getDataFromDefaults:(NSString *)key{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:key];
    
}

@end
