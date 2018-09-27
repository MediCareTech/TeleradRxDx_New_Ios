//
//  MembershipTypesResponseModel.h
//  SmartRx
//
//  Created by SmartRx-iOS on 15/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "AssignedManagedCareplanResponse.h"

@interface MembershipTypesResponseModel : AssignedManagedCareplanResponse

@property(nonatomic,strong) NSString *managedCareProgram;
@property(nonatomic,strong) NSString *price;

@end
