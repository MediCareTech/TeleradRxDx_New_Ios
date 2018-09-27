//
//  ChatHistoryResponseModel.h
//  SmartRx
//
//  Created by SmartRx-iOS on 22/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatHistoryResponseModel : NSObject
@property(nonatomic,strong) NSString *doctorName;
@property(nonatomic,strong) NSString *doctorId;
@property(nonatomic,strong) NSString *doctorProfilePic;
@property(nonatomic,strong) NSString *roomId;
@property(nonatomic,strong) NSString *lastMessageTime;

@end
