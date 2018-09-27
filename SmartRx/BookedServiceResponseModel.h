//
//  BookedServiceResponseModel.h
//  SmartRx
//
//  Created by Gowtham on 05/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookedServiceResponseModel : NSObject

@property(nonatomic,strong) NSString *serviceId;
@property(nonatomic,strong) NSString *serviceName;
@property(nonatomic,strong) NSString *serviceDescription;
@property(nonatomic,strong) NSString *servicePrice;
@property(nonatomic,strong) NSString *serviceDiscountprice;
@property(nonatomic,strong) NSString *instructions;
@property(nonatomic,strong) NSString *providerName;
@property(nonatomic,strong) NSString *serviceType;
@property(nonatomic,strong) NSString *providerId;
@property(nonatomic,strong) NSString *scheduledDate;
@property(nonatomic,strong) NSString *scheduledTime;
@property(nonatomic,strong) NSString *bookingStatus;
@property(nonatomic,strong) NSString *bookingRecNo;
@property(nonatomic,strong) NSString *locationName;
@property(nonatomic,strong) NSString *locationType;
@property(nonatomic,strong) NSString *paymentStatus;

@property(nonatomic,assign) BOOL isScheduled;




@end
