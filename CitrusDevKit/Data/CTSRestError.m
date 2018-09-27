//
//  CTSRestError.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 29/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSRestError.h"

@implementation CTSRestError
@synthesize errorDescription, type, error, serverResponse, description,errorMessage,errorCode;
+ (JSONKeyMapper*)keyMapper {
  return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}
@end
