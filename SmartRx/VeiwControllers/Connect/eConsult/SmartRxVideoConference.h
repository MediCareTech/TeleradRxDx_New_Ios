//
//  SmartRxVideoConference.h
//  SmartRx
//
//  Created by Anil Kumar on 04/03/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Opentok/Opentok.h>
#import <QuartzCore/QuartzCore.h>

@interface SmartRxVideoConference : UIViewController
//<OTSessionDelegate, OTPublisherDelegate, OTSubscriberKitDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>
//{
//    NSMutableDictionary *allStreams;
//    NSMutableDictionary *allSubscribers;
//    NSMutableArray *allConnectionsIds;
//    NSMutableArray *backgroundConnectedStreams;
//    
//    OTSession *_session;
//    OTPublisher *_publisher;
//    OTSubscriber *_currentSubscriber;
//    CGPoint _startPosition;
//    
//    BOOL initialized;
//}
//@property (retain, nonatomic)  NSString *apiKey;
//@property (retain, nonatomic)  NSString *sessionId;
//@property (retain, nonatomic)  NSString *token;
//@property (strong, nonatomic) IBOutlet UIScrollView *videoContainerView;
//@property (strong, nonatomic) IBOutlet UIView *bottomOverlayView;
//@property (strong, nonatomic) IBOutlet UIView *topOverlayView;
//@property (retain, nonatomic) IBOutlet UIButton *cameraToggleButton;
//@property (retain, nonatomic) IBOutlet UIButton *audioPubUnpubButton;
//@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
//@property (retain, nonatomic) NSTimer *overlayTimer;
//@property (retain, nonatomic) IBOutlet UIButton *audioSubUnsubButton;
//@property (retain, nonatomic) IBOutlet UIButton *endCallButton;
//@property (retain, nonatomic) IBOutlet UIView *micSeparator;
//@property (retain, nonatomic) IBOutlet UIView *cameraSeparator;
//@property (retain, nonatomic) IBOutlet UIView *archiveOverlay;
//@property (retain, nonatomic) IBOutlet UILabel *archiveStatusLbl;
//@property (retain, nonatomic) IBOutlet UIImageView *archiveStatusImgView;
//@property (retain, nonatomic)  NSString *rid;
//@property (retain, nonatomic)  NSString *publisherName;
//@property (retain, nonatomic) IBOutlet UIImageView *rightArrowImgView;
//@property (retain, nonatomic) IBOutlet UIImageView *leftArrowImgView;
//@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spinningWheel;
//
//- (IBAction)toggleAudioSubscribe:(id)sender;
//- (IBAction)toggleCameraPosition:(id)sender;
//- (IBAction)toggleAudioPublish:(id)sender;
//- (IBAction)endCallAction:(UIButton *)button;
@end
