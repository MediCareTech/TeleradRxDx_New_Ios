//
//  SmartRxDB.h
//  SmartRx
//
//  Created by Manju Basha on 07/12/15.
//  Copyright © 2015 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CartRequestModel.h"
#import "Cart+CoreDataProperties.h"

@interface SmartRxDB : NSObject
+ (id)sharedDBManager;

//login
-(void)clearDatbaseWhenUserLogout;
-(void)saveLoginData:(NSMutableDictionary *)response;
-(NSArray *)fetchLoginDetails;

//Profile
-(void)saveUserProfile:(NSMutableDictionary *)response;
-(NSArray *)profileDetails;

//Messages
-(void)saveMessages:(NSArray *)arrMsgDetails;
-(void)updateObjectInCoreData :(NSString *)messageId value:(NSString *)upDateValue;
-(void)deleteMsgFromCoreData :(NSString *)messageId;
-(NSArray *)fetchMessagesFromDataBase;

//Location
-(void)saveLocation:(NSArray *)arrLocationDetails;
-(NSArray *)fetchLocationsFromDataBase;

//Doctors
-(void)saveDoctor:(NSArray *)arrDoctorsDetails;
-(NSArray *)fetchDoctorsFromDataBase;

//Specialities
-(void)saveSpeciality:(NSArray *)arrSpecialityDetails;
-(NSArray *)fetchSpecialitiesFromDataBase;


//Econsult & Appointment
-(void)saveEconApt:(NSArray *)arrEconAptDetails;
-(NSArray *)fetchEconAptFromDataBase:(NSInteger)EconAptType;

-(void)saveEconReport:(NSArray *)arrEconReportDetails conid:(NSInteger)econID type:(NSString *)ReportType;
-(NSDictionary *)fetchEconReportFromDataBase:(NSInteger)eConid type:(NSString *)ReportType;
-(void)updateEconReportInCoreData :(NSArray *)upDateValue conid:(NSInteger)econID type:(NSString *)ReportType;

-(void)saveEconRequest:(NSArray *)arrEconRequestDetails conid:(NSInteger)econID type:(NSString *)RequestType;
-(NSDictionary *)fetchEconRequestFromDataBase:(NSInteger)eConid type:(NSString *)RequestType;;
-(void)updateEconRequestInCoreData :(NSArray *)upDateValue conid:(NSInteger)econID type:(NSString *)RequestType;;

//Services
-(void)saveServiceList:(NSArray *)arrServiceListDetails;
-(NSArray *)fetchServiceListFromDataBase;

// Question
-(NSArray *)fetchPreviousQuestionsFromDataBase;
-(void)savePreviousQuestionsInDataBase:(NSArray *)arrQuestions;

//Question Details
-(void)saveQuestionDetaislInDataBase:(NSDictionary *)quesDetails master:(NSDictionary *)dictMaster answers:(NSArray *)answers;
-(id)fetchQuestionDetaisFromDataBase:(NSDictionary *)dictQuestionDetails;

/******************PHR DATA******************/

-(void)savePHRData:(NSString *)PHRName details:(NSArray *)phrDetailsArr;
-(NSArray *)fetchPHRData:(NSString *)PHRName;

// cart
-(BOOL)saveCartData:(CartRequestModel *)cartModel;
-(NSArray *)fetchCartItems;
-(void)deleteCartItem:(Cart *)selectedItem;
-(void)deleteCartDataBase;

@end
