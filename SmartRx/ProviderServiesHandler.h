//
//  ProviderServiesHandler.h
//  SmartRx
//
//  Created by Gowtham on 10/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProviderServiesHandler : NSObject
@property(nonatomic,strong) NSArray *providerServicesArr;
+ (id)sharedInstance;
@end
