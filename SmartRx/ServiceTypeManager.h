//
//  ServiceTypeManager.h
//  SmartRx
//
//  Created by Gowtham on 14/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceTypeManager : NSObject

@property(nonatomic,strong) NSArray *serviceArray;

+(id)sharedManager;

-(NSString *)getSelectedServiceType:(NSString *)type;

@end
