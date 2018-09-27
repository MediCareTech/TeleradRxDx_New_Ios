//
//  CTSDPResponse.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 10/20/15.
//  Copyright © 2015 Citrus. All rights reserved.
//

#import "CTSDPResponse.h"

@implementation CTSDPResponse
-(BOOL)isError{
    if(_resultCode > 0){
        return YES;
    }
    return NO;
}
@end
