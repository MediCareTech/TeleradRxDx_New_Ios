//
//  SmartRxAppDelegate.h
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Opentok/Opentok.h>
#import <QuartzCore/QuartzCore.h>
@import SocketIO;

@interface SmartRxAppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic)  SocketManager* socketManager;
@property(nonatomic)  SocketIOClient* socket;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *viewSlpash;
@property (strong, nonatomic) UIView *transSlpash;
@property (strong, nonatomic) UIImage *imgSlpash;
@property (strong, nonatomic) UIImageView *imgView;

@property (assign, nonatomic) NSInteger cartCount;

@property(nonatomic,assign) BOOL passwordStatus;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end
