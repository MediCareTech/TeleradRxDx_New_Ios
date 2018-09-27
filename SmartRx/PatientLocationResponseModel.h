//
//  PatientLocationResponseModel.h
//  SmartRx
//
//  Created by Gowtham on 16/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PatientLocationResponseModel : NSObject

@property(nonatomic,strong) NSString *cityName;
@property(nonatomic,strong) NSString *cityId;
@property(nonatomic,strong) NSString *localityName;
@property(nonatomic,strong) NSString *localityId;
@property(nonatomic,strong) NSString *addressType;
@property(nonatomic,strong) NSString *zipcode;
@property(nonatomic,strong) NSString *address;
@property(nonatomic,strong) NSString *locationId;
@property(nonatomic,strong) NSString *zoneName;






@end
