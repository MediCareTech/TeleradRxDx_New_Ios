//
//  CTSValidator.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 30/06/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "CTSValidator.h"

@implementation CTSValidator
-(instancetype)sharedInstance{
    return nil;
}

-(NSError*)validateField:(NSString *)sring for:(NSArray *)validations{

//rad the validations from array
    //call the functions for the given validation field
    //validations will return CTSErrorCode
    //same Citrus Code is passed along with Field type to cts error clsaa
    //cts error class returns the error with custome description for the passed field type
    return nil;
}
//
-(NSError *)validateField:(NSString *)sring for:(NSArray *)validations forError:(CTSErrorCode)errorCode{

    return nil;
    
}
//
//
//
//-(CTSErrorCode)lengthMax255:(NSString *)param{
//
//}
//
//-(CTSErrorCode)lengthNonZero:(NSString *)param{
//    
//}
//
//-(CTSErrorCode)nonNil:(NSString *)param{
//    
//}
//
//-(CTSErrorCode)noSpecialChars:(NSString *)param{
//    
//}
//
//-(CTSErrorCode)noWhiteSpace:(NSString *)param{
//    
//}
//
//-(CTSErrorCode)noNumber:(NSString *)param{
//    
//}
//
//-(CTSErrorCode)noChars:(NSString *)param{
//    
//}
//
//-(CTSErrorCode)onlyNumber:(NSString *)param{
//    
//}
//
//-(CTSErrorCode)onlyChars:(NSString *)param{
//    
//}
//
//-(CTSErrorCode)onlyAlphaNumeric:(NSString *)param{
//    
//}
//
//-(CTSErrorCode)noOnlyWhiteSpaces:(NSString *)param{
//    
//}



@end
