//
//  AssessmentsResponseModel.h
//  SmartRx
//
//  Created by Gowtham on 29/01/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssessmentsResponseModel : NSObject
@property(nonatomic,strong) NSString *trackerName;
@property(nonatomic,strong) NSString *trackerId;
@property(nonatomic,strong) NSString *monitorType;
@property(nonatomic,strong) NSString *assessmentType;


@end
