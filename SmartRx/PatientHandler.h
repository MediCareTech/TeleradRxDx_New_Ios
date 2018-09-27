//
//  PatientHandler.h
//  SmartRx
//
//  Created by SmartRx-iOS on 06/03/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PatientHandler : NSObject

@property(nonatomic,strong) NSString *patientName;
@property(nonatomic,strong) NSString *patientId;
@property(nonatomic,strong) NSString *chatRomm;
@property(nonatomic,strong) NSString *userTtype;
+ (id)sharedInstance;

@end
