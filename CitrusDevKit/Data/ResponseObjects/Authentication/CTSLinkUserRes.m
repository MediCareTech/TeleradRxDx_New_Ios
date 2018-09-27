//
//  CTSLinkUserRes.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 25/02/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "CTSLinkUserRes.h"
#import "CTSAuthLayerConstants.h"

@implementation CTSLinkUserRes
- (instancetype)initPasswordAlreadySet
{
    self = [super init];
    if (self) {
        _isPasswordAlreadySet = YES;
        _message = MLC_LINK_USER_PASSWORD_ALREADY_SET_MESSAGE;
    }
    return self;
}


- (instancetype)initPasswordAlreadyNotSet
{
    self = [super init];
    if (self) {
        _isPasswordAlreadySet = NO;
        _message = MLC_LINK_USER_PASSWORD_ALREADY_SET_NOT_MESSAGE;
    }
    return self;
}
@end
