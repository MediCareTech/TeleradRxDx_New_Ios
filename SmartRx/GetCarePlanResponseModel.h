//
//  GetCarePlanResponseModel.h
//  SmartRx
//
//  Created by SmartRx-iOS on 15/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetCarePlanResponseModel : NSObject

@property(nonatomic,strong) NSString *carePlanName;
@property(nonatomic,strong) NSString *recno;
@property(nonatomic,strong) NSArray *membershipArray;

@end
