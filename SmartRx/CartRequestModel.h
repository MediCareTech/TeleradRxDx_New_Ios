//
//  CartRequestModel.h
//  SmartRx
//
//  Created by Gowtham on 20/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CartRequestModel : NSObject

@property(nonatomic,strong) NSString *serviceName;
@property(nonatomic,strong) NSString *serviceType;
@property(nonatomic,strong) NSString *providerServiceId;
@property(nonatomic,strong) NSString *scheduledDate;
@property(nonatomic,strong) NSString *scheduledTime;
@property(nonatomic,strong) NSString *servicePrice;
@property(nonatomic,strong) NSString *bookingLocationId;
@property(nonatomic,strong) NSString *providerName;
@property(nonatomic,strong) NSString *userId;
@property(nonatomic,assign) BOOL isScheduled;



@end
