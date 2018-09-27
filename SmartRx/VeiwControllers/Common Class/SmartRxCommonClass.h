//
//  SmartRxCommonClass.h
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@protocol loginDelegate <NSObject>
-(void)sectionIdGenerated:(id)sender;
-(void)errorSectionId:(id)sender;
@optional
-(void)logoutTheSession;

@end

@protocol ImageSelected <NSObject>

-(void)imageSelected:(UIImage *)image;

@end


@interface SmartRxCommonClass : NSObject<UIImagePickerControllerDelegate>

//TEST
#define kBaseUrl "https://dev.medcall.in/api"
#define kAdminBaseUrl  "https://dev.medcall.in/admin"
#define kBaseUrlLabReport "https://dev.medcall.in/"
#define kBaseProfileImage "https://dev.medcall.in/admin/"
#define kBaseUrlQAImg "https://dev.medcall.in"
#define CacheUrl @"dev.medcall.in"
#define FitbitUrl @"https://dev.medcall.in/fitbit_call_back.php";
#define BOOK_APPOITMENT_API  @"https://qikwell.com/widget_book/chain/d22e3bda-705c-11e3-85b3-1231391ccc72?"

//
//LIVE
//#define kBaseUrl "https://health.medcall.in/api"
//#define kAdminBaseUrl  "https://health.medcall.in/admin"
//#define kBaseUrlLabReport "https://health.medcall.in"
//#define kBaseProfileImage "https://health.medcall.in/admin/"
//#define kBaseUrlQAImg "https://health.medcall.in"
//#define CacheUrl @"health.medcall.in"
//#define FitbitUrl @"https://health.medcall.in/fitbit_call_back.php";
//#define BOOK_APPOITMENT_API  @"https://qikwell.com/widget_book/chain/d22e3bda-705c-11e3-85b3-1231391ccc72?"



//LIVE
//#define kBaseUrl "https://engage.smartrx.in/api"
//#define kAdminBaseUrl  "https://engage.smartrx.in/admin"
//#define kBaseUrlLabReport "https://engage.smartrx.in/patient/"
//#define kBaseProfileImage "https://engage.smartrx.in/admin/"
//#define kBaseUrlQAImg "https://engage.smartrx.in"



#define kBundleID "in.smartrx.patient"

@property (strong,nonatomic) id loginDelegate;
@property (assign, nonatomic) id < ImageSelected > imageDelegate;
-(void)openGallary:(UIViewController *)controller;
+ (id)sharedManager;
-(void)postOrGetData:(NSString *)UrlString postPar:(id )postParaDict method:(NSString *)methodType setHeader:(BOOL)header  successHandler:(void(^)(id response))successHandler failureHandler:(void(^)(id response))failureHandler;

-(void)postingImageWithText:(NSString *)urlString postData:(id)postParaDict camImg:(UIImage *)img successHandler:(void(^)(id response))successHandler failureHandler:(void(^)(id response))failureHandler;

-(void)requestGETFitbitData:(NSString *)strURL Token:(NSString *)token success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;

-(void)addEHR:(NSDictionary *)postDict successHandler:(void(^)(id response))successHandler failureHandler:(void(^)(id response))failureHandler;

-(void)makeLoginRequest;

-(void)setNavigationTitle:(NSString *)title controler:(UIViewController *)controller;


@end
