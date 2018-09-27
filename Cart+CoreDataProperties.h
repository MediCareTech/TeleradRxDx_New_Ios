//
//  Cart+CoreDataProperties.h
//  SmartRx
//
//  Created by Gowtham on 20/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Cart.h"

NS_ASSUME_NONNULL_BEGIN

@interface Cart (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *serviceType;
@property (nullable, nonatomic, retain) NSString *providerServiceId;
@property (nullable, nonatomic, retain) NSString *scheduledDate;
@property (nullable, nonatomic, retain) NSString *scheduledTime;
@property (nullable, nonatomic, retain) NSString *servicePrice;
@property (nullable, nonatomic, retain) NSString *bookingLocationId;
@property (nullable, nonatomic, retain) NSString *serviceName;
@property (nullable, nonatomic, retain) NSString *providerName;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSNumber *isScheduled;


@end

NS_ASSUME_NONNULL_END
