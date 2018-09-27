//
//  NSString+DateConvertion.m
//  SmartRx
//
//  Created by PaceWisdom on 17/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "NSString+DateConvertion.h"

@implementation NSString (DateConvertion)

+(NSString *)convertStringToDate:(NSString *)strDate
{

    NSString *strSetTime=nil;
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [format setTimeZone:gmt];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    NSDate *serverDate = [format dateFromString:strDate];

    NSDate* sourceDate = [NSDate date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    

    
  //  NSString *formattedDate = [format stringFromDate:currentDate];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSMonthCalendarUnit|NSYearCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                       fromDate:serverDate
                                       toDate:destinationDate
                                       options:0];
    NSInteger years = [ageComponents year];
    NSInteger monts = [ageComponents month];
    NSInteger days = [ageComponents day];
    NSInteger hours = [ageComponents hour];
    NSInteger minute = [ageComponents minute];
    NSInteger second = [ageComponents second];
   
    if (years !=0 || monts!=0 || days > 5)
    {
        [format setDateFormat:@"dd-MMM"];
        strSetTime=[format stringFromDate:serverDate];
    }
    else{
        if (years == 0 && monts == 0 && days == 0 && hours == 0 && minute == 0 && second!=0)
        {
            strSetTime=@"few Secs ago";
        }
        else if (years == 0 && monts == 0 && days == 0 && hours == 0 && minute != 0)
        {
            strSetTime=[NSString stringWithFormat:@"%ld Min ago",(long)minute];
            if ([strSetTime isEqualToString:@"-1 Min ago"] || minute < 0)
            {
                strSetTime=@"few Secs Ago";
            }
            else if ([strSetTime isEqualToString:@"1 Min ago"])
            {
                strSetTime=[NSString stringWithFormat:@"%ld Min ago",(long)minute];
            }
            else
            {
                
                if (minute < 0)
                    strSetTime=@"few Secs Ago";
                else
                    strSetTime=[NSString stringWithFormat:@"%ld Mins ago",(long)minute];
            }
        }
        else if (years == 0 && monts == 0 && days == 0 && hours != 0 )
        {
            if (hours == 1)
            {
                 strSetTime=[NSString stringWithFormat:@"%ld Hour ago",(long)hours];
            }
            else{
                 strSetTime=[NSString stringWithFormat:@"%ld Hours ago",(long)hours];
            }
           
        }
        else if (years == 0 && monts == 0 && days <= 5 )
        {
            if (days == 1)
            {
               strSetTime=@"Yesterday";//[NSString stringWithFormat:@"%ld Day ago",(long)days];
            }
            else{
                strSetTime=[NSString stringWithFormat:@"%ld Days ago",(long)days];
            }
            
        }
    }
    return strSetTime;
}
+(NSString *)timeFormating:(NSString *)dateStr funcName:(NSString *)functionName;
{
    NSLog(@"Date string received : %@", dateStr);
    NSString *strFormatedDate=nil;
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone systemTimeZone];
    [format setTimeZone:gmt];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    if ([functionName isEqualToString:@"servicesBooking"])
        [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *serverDate = [format dateFromString:dateStr];
    [format setDateFormat:@"dd-MMM h:mm:SS a"];
    strFormatedDate=[format stringFromDate:serverDate];
    
    
    
   // NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd-MMM"];
    [format setDateFormat:@"dd-MMM-yy"];
    if([functionName isEqualToString:@"dataTVC"])
    {
        [format setDateFormat:@"dd-MMM"];
    }
    else if ([functionName isEqualToString:@"details"] || [functionName isEqualToString:@"servicesBooking"])
    {
        [format setDateFormat:@"dd-MMM-yy"];
    }
     NSString *theDate = [format stringFromDate:serverDate];
    //NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"hh:mm a"];
   
    NSString *theTime = [[format stringFromDate:serverDate] uppercaseString];
    NSLog(@"\n"
          "theDate: |%@| \n"
          "theTime: |%@| \n"
          , theDate, theTime);
    
    
    if ([functionName isEqualToString:@"details"] || [functionName isEqualToString:@"servicesBooking"])
    {
        return [NSString stringWithFormat:@"%@",theDate];
    }
    return [NSString stringWithFormat:@"%@ %@",theDate,theTime];//strFormatedDate;
}
+(NSDate *)stringToDate:(NSString *)dateStr
{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [format setTimeZone:gmt];
    [format setDateFormat:@"dd-MM-yyy"];
    NSDate *serverDate = [format dateFromString:dateStr];
    return serverDate;
}

+(void)comparingTwoDates:(NSString *)date tim:(NSString *)time
{
    NSString *strDate=[NSString stringWithFormat:@"%@%@",date,time];
    
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [format setTimeZone:gmt];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    NSDate *serverDate = [format dateFromString:strDate];
    
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    if ([serverDate compare:destinationDate] == NSOrderedAscending)
    {
        
    }
    if ([serverDate compare:destinationDate] == NSOrderedDescending)
    {
        
    }
    
}

@end
