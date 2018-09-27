//
//  ConversationViewController.h
//  SphChatNew
//
//  Created by SmartRx-iOS on 06/02/18.
//  Copyright © 2018 SmartRx-iOS. All rights reserved.
//



#import "JSQMessagesViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "JSQMessages.h"
#import "ChatModel.h"
#import "ChatHistoryResponseModel.h"
#import "NSUserDefaults+Settings.h"

@import SocketIO;

#define BaseUrl @"https://chat.medcall.in:8100/download/"

@interface ConversationViewController : JSQMessagesViewController<UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIDocumentPickerDelegate>
@property (strong, nonatomic) ChatHistoryResponseModel *selectedChat;

@property (strong, nonatomic) ChatModel *chatData;

@property (nonatomic, strong) NSString *pdfPath;

@property(nonatomic,strong) NSString *doctorId;
@property(nonatomic,strong) NSString *roomName;
@property(nonatomic,strong) NSString *chatMessage;
@property(nonatomic,strong) NSString *patientName;
@property(nonatomic,strong) NSString *profilePicPath;
@property(nonatomic,strong) NSString *userType;
@property(nonatomic,strong) NSString *patientId;
@property(nonatomic,strong) NSString *doctorName;
@property(nonatomic,strong) NSString *doctorPic;

-(void)socketConnetion;
@end
