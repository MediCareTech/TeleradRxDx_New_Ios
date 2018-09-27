//
//  AssignedManagedCareplanResponse.h
//  SmartRx
//
//  Created by SmartRx-iOS on 14/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssignedManagedCareplanServiceResponse.h"

@interface AssignedManagedCareplanResponse : NSObject

@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *packageName;
@property(nonatomic,strong) NSString *membership;
@property(nonatomic,strong) NSString *recno;
@property(nonatomic,strong) NSString *packageId;
@property(nonatomic,strong) NSString *patid;
@property(nonatomic,strong) NSString *detailedAssessments;
@property(nonatomic,strong) NSString *detailedAssessmentsAvailable;
@property(nonatomic,strong) NSString *econsults;
@property(nonatomic,strong) NSString *econsultsAvailable;
@property(nonatomic,strong) NSString *healthCoachFollowUps;
@property(nonatomic,strong) NSString *healthCoachFollowUpsAvailable;
@property(nonatomic,strong) NSString *careplans;
@property(nonatomic,strong) NSString *careplansAvailable;
@property(nonatomic,strong) NSString *customisedHealthPlan;
@property(nonatomic,strong) NSString *careManagerAssistance;
@property(nonatomic,strong) NSString *ChatWithCareTeam;
@property(nonatomic,strong) NSString *continuousMonitoring;
@property(nonatomic,strong) NSString *newsletters;
@property(nonatomic,strong) NSString *secondOpinion;
@property(nonatomic,strong) NSString *secondOpinionAvailable;
@property(nonatomic,strong) NSString *miniHealthCheck;
@property(nonatomic,strong) NSString *miniHealthCheckAvailable;
@property(nonatomic,strong) NSString *expireDate;
@property(nonatomic,strong) NSString *oldPrice;
@property(nonatomic,strong) NSString *packageType;
@property(nonatomic,strong) NSString *membershipType;
@property(nonatomic,strong) NSString *autoCampaign;

@property(nonatomic,strong) NSArray *serviceDetailsArray;
@property(nonatomic,strong) NSArray *carePlansArray;

@end
