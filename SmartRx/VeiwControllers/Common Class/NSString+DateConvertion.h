//
//  NSString+DateConvertion.h
//  SmartRx
//
//  Created by PaceWisdom on 17/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DateConvertion)
+(NSString *)convertStringToDate:(NSString *)strDate;
+(NSDate *)stringToDate:(NSString *)dateStr;
+(NSString *)timeFormating:(NSString *)dateStr funcName:(NSString *)functionName;
+(void)comparingTwoDates:(NSString *)date tim:(NSString *)time;
@end
