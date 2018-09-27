//
//  CTSLinkRes.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 20/05/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "CTSLinkRes.h"

@implementation CTSLinkRes
- (instancetype)initWith:(LinkUserStatus)status entity:(NSString *)entity
{
    self = [super init];
    if (self) {
        switch (status) {
                
            case LinkUserStatusEotpSignIn:
                _linkUserStatus = status;
                _message = [NSString stringWithFormat:@" OTP Sent on %@, Please Signin Using OTP or Citrus Password",entity];
                break;
            case LinkUserStatusMotpSigIn:
                _linkUserStatus = status;
                _message = [NSString stringWithFormat:@" OTP Sent on %@, Please Signin Using OTP or Citrus Password",entity];
                break;
            case LinkUserStatusSignup:
                _linkUserStatus = status;
                _message = [NSString stringWithFormat:@" You are Now Registered, Please Verify Your Mobile Number %@",entity];
                break;
            default:
                break;
        }
    }
    return self;
}
@end
