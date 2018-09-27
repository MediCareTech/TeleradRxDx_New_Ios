//
//  EconsultMedicationResponseModel.h
//  SmartRx
//
//  Created by SmartRx-iOS on 26/04/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EconsultMedicationResponseModel : NSObject

@property(nonatomic,strong) NSString *medicationDetails;
@property(nonatomic,strong) NSString *date;
@property(nonatomic,strong) NSString *drugName;
@property(nonatomic,strong) NSString *quantity;
@property(nonatomic,strong) NSString *morning;
@property(nonatomic,strong) NSString *afternoon;
@property(nonatomic,strong) NSString *evening;
@property(nonatomic,strong) NSString *night;
@property(nonatomic,strong) NSString *dose;
@property(nonatomic,strong) NSString *medicationId;
@property(nonatomic,strong) NSString *consumptionTime;

@end
