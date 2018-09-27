//
//  CTSCitrusLinkRes.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 11/9/15.
//  Copyright © 2015 Citrus. All rights reserved.
//

#import "CTSCitrusLinkRes.h"
//(OLD SIGNIN> case 1 || 6 || 2 || 7  && passwordType == OTP)
//
//
//(OLD SIGNIN> case 1 || 6 || 2 || 7 || 5 || 8 && passwordType == PASSWORD)
//
//
//    (VERIFY_SIGNIN > case 3 || 4 || 5 || 10 || 11 || 12 || && passwordType == OTP)
//
//(EOTP signin > 8 || 9 && password type == OTP)

#define MOTP_PASSWORD_MSG @"Please Signin with OTP sent on mobile number %@ or Citrus Password"
#define EOTP_PASSWORD_MSG @"Please Signin with OTP sent on email id %@ or Citrus Password"
#define MOTP_MSG @"Please Signin with OTP sent on mobile number %@"
#define EOTP_MSG @"Please Signin with OTP sent on email id %@"


@implementation CTSCitrusLinkRes
@synthesize linkedMobile,siginType,userMessage,linkedEmail;
- (instancetype)initWithResponse:(CTSResponse *)response
{
    self = [super init];
    if (self) {
        int responseCode = [response apiResponseCode];
        linkedMobile = [response.responseData objectForKey:@"mobile"];
        linkedEmail = [response.responseData objectForKey:@"email"];

        switch (responseCode) {
            case 1:
                siginType = CitrusSiginTypeMOtpOrPassword;
                userMessage = [NSString stringWithFormat:MOTP_PASSWORD_MSG,linkedMobile];
                break;
            case 2:
                siginType = CitrusSiginTypeMOtp;
                userMessage = [NSString stringWithFormat:MOTP_MSG,linkedMobile];
                break;
            case 3:
                siginType = CitrusSiginTypeMOtp;
                userMessage = [NSString stringWithFormat:MOTP_MSG,linkedMobile];
                break;
            case 4:
                siginType = CitrusSiginTypeMOtp;
                userMessage = [NSString stringWithFormat:MOTP_MSG,linkedMobile];
                break;
            case 5:
                siginType = CitrusSiginTypeMOtpOrPassword;
                userMessage = [NSString stringWithFormat:MOTP_PASSWORD_MSG,linkedMobile];
                break;
            case 6:
                siginType = CitrusSiginTypeMOtpOrPassword;
                userMessage = [NSString stringWithFormat:MOTP_PASSWORD_MSG,linkedMobile];
                break;
            case 7:
                siginType = CitrusSiginTypeMOtp;
                userMessage = [NSString stringWithFormat:MOTP_MSG,linkedMobile];
                break;
            case 8:
                siginType = CitrusSiginTypeEOtpOrPassword;
                userMessage = [NSString stringWithFormat:EOTP_PASSWORD_MSG,linkedEmail];
                break;
            case 9:
                siginType = CitrusSiginTypeEOtp;
                userMessage = [NSString stringWithFormat:EOTP_MSG,linkedEmail];
                break;
            case 10:
                siginType = CitrusSiginTypeMOtp;
                userMessage = [NSString stringWithFormat:MOTP_MSG,linkedMobile];
                break;
            case 11:
                siginType = CitrusSiginTypeMOtp;
                userMessage = [NSString stringWithFormat:MOTP_MSG,linkedMobile];
                break;
            case 12:
                siginType = CitrusSiginTypeMOtp;
                userMessage = [NSString stringWithFormat:MOTP_MSG,linkedMobile];
                break;
            default:
                break;
        }
    }
    return self;
}

@end
