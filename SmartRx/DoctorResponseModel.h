//
//  DoctorResponseModel.h
//  SmartRx
//
//  Created by Gowtham on 08/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoctorResponseModel : NSObject

@property(nonatomic,strong)NSString *doctorName;
@property(nonatomic,strong)NSString *doctorspecilaty;
@property(nonatomic,strong)NSString *doctorId;
@property(nonatomic,strong)NSString *secondopinionAmount;
@property(nonatomic,strong)NSString *secondopinionAppAmount;
@property(nonatomic,strong)NSString *serviceAmount;
@property(nonatomic,strong)NSString *aServiceAmount;
@property(nonatomic,strong)NSString *defaultSecondOpinionAmount;
@property(nonatomic,strong)NSString *defaultSecondOpinionAppAmount;
@property(nonatomic,strong)NSString *aSecondopinionAmount;
@property(nonatomic,strong)NSString *aSecondopinionAppAmount;


@end
