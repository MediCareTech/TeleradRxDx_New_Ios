//
//  UsersResponseModel.h
//  SmartRx
//
//  Created by Gowtham on 08/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsersResponseModel : NSObject

@property(nonatomic,strong)NSString *patientName;
@property(nonatomic,strong)NSString *patientId;

@property(nonatomic,strong)NSArray *arr;



@end
