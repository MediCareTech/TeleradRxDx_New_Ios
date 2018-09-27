//
//  UIImageView+ImageConvertion.m
//  Cohort
//
//  Created by PaceWisdom on 09/04/14.
//  Copyright (c) 2014 PaceWisdom. All rights reserved.
//

#import "UIImageView+ImageConvertion.h"

@implementation UIImageView (ImageConvertion)

+(NSData *)postImage :(UIImage *)image
{
    
    
    NSData *imageData = UIImageJPEGRepresentation(image, 100);
    NSString *boundary =@"0x0hHai1CanHazB0undar135";
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    //[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",[UIImageView currentDateandTime]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: application/x-www-form-urlencoded; name=\"profile_photo\"; filename=\"%@\"\r\n",@"patientfile.jpeg"] dataUsingEncoding:NSUTF8StringEncoding]];//form-data
    
    [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return body;
}

+ (NSString *)currentDateandTime
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMddyyyy_HHmmssSS"];
    NSString *dateString = [dateFormat stringFromDate:today];
    return dateString;
}

@end
