//
//  ServicesResponseModel.h
//  SmartRx
//
//  Created by Gowtham on 12/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServicesResponseModel : NSObject

@property(nonatomic,strong) NSString *serviceId;
@property(nonatomic,strong) NSString *serviceName;
@property(nonatomic,strong) NSString *serviceDescription;
@property(nonatomic,strong) NSString *serviceprice;
@property(nonatomic,strong) NSString *servicediscountprice;
@property(nonatomic,strong) NSString *imagePath;
@property(nonatomic,strong) NSString *instructions;
@property(nonatomic,strong) NSString *providerName;
@property(nonatomic,strong) NSString *serviceType;
@property(nonatomic,strong) NSString *providerId;
@property(nonatomic,strong) NSString *serviceLocation;
@property(nonatomic,strong) NSString *providerServiceId;
@property(nonatomic,assign) BOOL isScheduled;



@end
