//
//  CTSDyPResponse.m
//  CTS iOS Sdk
//
//  Created by Yadnesh on 7/27/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "CTSDyPResponse.h"

@implementation CTSDyPResponse
-(BOOL)isError{
    if(_resultCode > 0){
        return YES;
    }
    return NO;
}

@end
