//
//  DoctorsResponseModel.h
//  TeleradRxdx
//
//  Created by Gowtham on 25/05/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoctorsResponseModel : NSObject
@property(nonatomic,strong) NSString *recno;
@property(nonatomic,strong) NSString *doctorName;
@property(nonatomic,strong) NSString *profileImage;
@property(nonatomic,strong) NSString *specialityName;
@end
