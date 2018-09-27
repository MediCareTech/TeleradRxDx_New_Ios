//
//  AssignedManagedCareplanServiceResponse.h
//  SmartRx
//
//  Created by SmartRx-iOS on 14/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssignedManagedCareplanServiceResponse : NSObject

@property(nonatomic,strong) NSString *serviceName;
@property(nonatomic,strong) NSString *serviceTotal;
@property(nonatomic,strong) NSString *serviceAvailable;
@property(nonatomic,strong) NSString *serviceId;


@end
