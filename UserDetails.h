//
//  UserDetails.h
//  TeleradRxdx
//
//  Created by Gowtham on 24/05/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDetails : NSObject


+(void)setQikWellId:(NSString *)qikIdStr;

+(NSString *)getQikWellId;

+(void)setQikWellApi:(NSString *)qikWellApi;

+(NSString *)getQikWellApi;


@end
