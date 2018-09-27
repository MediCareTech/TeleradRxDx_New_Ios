//
//  NSObject+logProperties.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 04/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "NSObject+logProperties.h"
#import "NSObject+logProperties.h"
#import <objc/runtime.h>
#import "UserLogging.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation NSObject (logProperties)
- (void)logProperties {
  LogTrace(@"----------------------------------------------- Properties for "
           @"object %@",
           self);

  @autoreleasepool {
    unsigned int numberOfProperties = 0;
    objc_property_t* propertyArray =
        class_copyPropertyList([self class], &numberOfProperties);
    for (NSUInteger i = 0; i < numberOfProperties; i++) {
      objc_property_t property = propertyArray[i];
      NSString* name =
          [[NSString alloc] initWithUTF8String:property_getName(property)];
      LogTrace(@"Property %@ Value: %@", name, [self valueForKey:name]);
    }
    free(propertyArray);
  }
  LogTrace(@"-----------------------------------------------");
}
@end
