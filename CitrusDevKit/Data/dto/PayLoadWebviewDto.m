//
//  PayLoadWebviewDto.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 10/06/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "PayLoadWebviewDto.h"

@implementation PayLoadWebviewDto
- (instancetype)initWithUrl:(NSString *)url reqId:(int)reqId returnUrl:(NSString *)returnUrl
{
    self = [super init];
    if (self) {
        _url = url;
        _reqId = reqId;
        _returnUrl = returnUrl;
    }
    return self;
}
@end
