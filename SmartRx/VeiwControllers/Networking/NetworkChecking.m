//
//  NetworkChecking.m
//  EpubTestingsqlite
//
//  Created by Sadath Hussain on 18/03/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "NetworkChecking.h"
#import "Reachability.h"
@implementation NetworkChecking


-(BOOL)reachable {
    Reachability *r = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}
- (void)updateInterfaceWithReachability:(Reachability *)currentReachability {
	
	if    (currentReachability == hostReach) {
		NetworkStatus networkStatus = [currentReachability currentReachabilityStatus];
		switch (networkStatus) {
				
			case NotReachable:
				networkAvailable = NO;
				break;
				
			case ReachableViaWiFi:
				networkAvailable = YES;
				break;
				
			default:
				networkAvailable = YES;
				break;
		}
	}
}

- (BOOL)isNetWorkAvailable {
	return networkAvailable;
}

//Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification *)notification {
	Reachability* currentReachabilityStatus = (Reachability  *)[notification object];
	NSParameterAssert([currentReachabilityStatus isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:currentReachabilityStatus];
}

-(void)addReachabilityCheck {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
	
	hostReach = [Reachability reachabilityForInternetConnection];
	[hostReach startNotifier];
	[self updateInterfaceWithReachability:hostReach];
	
	if (!networkAvailable) {
		//[Utility showUserAlertMessageWithTitle:@"Network Failure" andMessage:@"Network Error"];
	}
}
@end
