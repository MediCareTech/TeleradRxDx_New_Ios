//
//  NetworkChecking.h
//  EpubTestingsqlite
//
//  Created by Sadath Hussain on 18/03/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Reachability;
@interface NetworkChecking : NSObject
{
    Reachability *hostReach;
    BOOL networkAvailable;
}
- (BOOL)reachable;
- (BOOL)isNetWorkAvailable;
- (void)reachabilityChanged:(NSNotification *)notification;
- (void)updateInterfaceWithReachability:(Reachability *)currentReachability;
- (void)addReachabilityCheck;

@end
