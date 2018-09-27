//
//  CTSResponse.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 21/05/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "CTSResponse.h"

@implementation CTSResponse
-(BOOL)isError{
    NSArray *separtedByHyphen = [_responseCode componentsSeparatedByString:@"-"];
    int responseCodeVal = [[separtedByHyphen lastObject] intValue];
    if(responseCodeVal > 0 ){
        return YES;
    }
    else{
        return NO;
    }

}

-(int)errorCode{
    NSArray *separtedByHyphen = [_responseCode componentsSeparatedByString:@"-"];

    NSString *errorCodeString = [NSString stringWithFormat:@"%@%@",[separtedByHyphen objectAtIndex:separtedByHyphen.count - 2 ],[separtedByHyphen objectAtIndex:separtedByHyphen.count - 1 ]];
   return [errorCodeString intValue];
}


-(int)apiResponseCode{
    NSArray *separtedByHyphen = [_responseCode componentsSeparatedByString:@"-"];
    int responseCodeVal = [[separtedByHyphen lastObject] intValue];
    return responseCodeVal;

}

@end
