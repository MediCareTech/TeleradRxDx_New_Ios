//
//  SmartRxSessionClass.h
//  SmartRx
//
//  Created by Anil Kumar on 12/03/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Opentok/Opentok.h>
#import <QuartzCore/QuartzCore.h>

@interface SmartRxSessionClass : UIViewController
<OTSessionDelegate, OTPublisherDelegate, OTSubscriberKitDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>
{
    NSMutableDictionary *allStreams;
    NSMutableDictionary *allSubscribers;
    NSMutableArray *allConnectionsIds;
    NSMutableArray *backgroundConnectedStreams;
    
    OTSession *_session;
    OTPublisher *_publisher;
    OTSubscriber *_currentSubscriber;
    OTStream *streamReceived;
    CGPoint _startPosition;
    
    BOOL initialized;
    BOOL publisherInitialized;
}
@property (readwrite, nonatomic)    int viewType;
@property (retain, nonatomic)  OTPublisher *receivePublisher;
@property (retain, nonatomic)  OTSession *receiveSession;
@property (retain, nonatomic)  NSString *apiKey;
@property (retain, nonatomic)  NSString *sessionId;
@property (retain, nonatomic)  NSString *token;
@property (retain, nonatomic) NSTimer *overlayTimer;
@property (retain, nonatomic)  NSString *rid;
@property (retain, nonatomic)  NSString *publisherName;

- (void)setupSession;
+ (id)sharedConference;
- (void)endCall:(UIButton *)button;

@end
