//
//  SmartRxSessionClass.m
//  SmartRx
//
//  Created by Anil Kumar on 12/03/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import "SmartRxSessionClass.h"
#import "SmartRxAppDelegate.h"

//NSString *kApiKey = @"45095882";
//NSString *kSessionId = @"";
//// Replace with your generated token
//NSString *kToken = @"";

@implementation SmartRxSessionClass

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    self.viewType = 2;
//    kSessionId = self.sessionId;
//    
//    
//    // configure video container view
//    
//    // initialize constants
//    //    allStreams = [[NSMutableDictionary alloc] init];
//    //    allSubscribers = [[NSMutableDictionary alloc] init];
//    //    allConnectionsIds = [[NSMutableArray alloc] init];
//    //    backgroundConnectedStreams = [[NSMutableArray alloc] init];
//    if (!allStreams)
//        allStreams = [[NSMutableDictionary alloc] init];
//    if (!allSubscribers)
//        allSubscribers = [[NSMutableDictionary alloc] init];
//    if (!allConnectionsIds)
//        allConnectionsIds = [[NSMutableArray alloc] init];
//    if(!backgroundConnectedStreams)
//        backgroundConnectedStreams = [[NSMutableArray alloc] init];
//    
//    // set up look of the page
//    [self.navigationController setNavigationBarHidden:NO];
//    
//    self.navigationItem.hidesBackButton = YES;
//    
//    // listen to taps around the screen, and hide/show overlay views
//    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(viewTapped:)];
//    tgr.delegate = self;
//    [self.view addGestureRecognizer:tgr];
//    
//    
//    [self setupPublisher];
//    
//    
//    // application background/foreground monitoring for publish/subscribe video
//    // toggling
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(enteringBackgroundMode:)
//     name:UIApplicationWillResignActiveNotification
//     object:nil];
//    
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(leavingBackgroundMode:)
//     name:UIApplicationDidBecomeActiveNotification
//     object:nil];
//    
//    if (((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).stream)
//        [self createSubscriber:streamReceived];
//    
//    NSLog(@"Into viewdidload and type : %d", self.viewType);
//}
//- (void)enteringBackgroundMode:(NSNotification*)notification
//{
//    _publisher.publishVideo = NO;
//    _currentSubscriber.subscribeToVideo = NO;
//}
//
//- (void)leavingBackgroundMode:(NSNotification*)notification
//{
//    _publisher.publishVideo = YES;
//    _currentSubscriber.subscribeToVideo = YES;
//    
//    //now subscribe to any background connected streams
//    for (OTStream *stream in backgroundConnectedStreams)
//    {
//        // create subscriber
//        OTSubscriber *subscriber = [[OTSubscriber alloc]
//                                    initWithStream:stream delegate:self];
//        // subscribe now
//        OTError *error = nil;
//        [_session subscribe:subscriber error:&error];
//        if (error)
//        {
//            [self showAlert:[error localizedDescription]];
//        }
//    }
//    [backgroundConnectedStreams removeAllObjects];
//}
//
//- (BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//}
//
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    
//    // current subscriber
//    int currentPage = (int)(self.videoContainerView.contentOffset.x /
//                            self.videoContainerView.frame.size.width);
//    
//    if (currentPage < [allConnectionsIds count]) {
//        // show current scrolled subscriber
//        NSString *connectionId = [allConnectionsIds objectAtIndex:currentPage];
//        NSLog(@"show as current subscriber %@",connectionId);
//        [self showAsCurrentSubscriber:[allSubscribers
//                                       objectForKey:connectionId]];
//    }
//    [self resetArrowsStates];
//}
//
//- (void)showAsCurrentSubscriber:(OTSubscriber *)subscriber
//{
//    // scroll view tapping bug
//    if(subscriber == _currentSubscriber)
//        return;
//    
//    // unsubscribe currently running video
//    _currentSubscriber.subscribeToVideo = NO;
//    
//    // update as current subscriber
//    _currentSubscriber = subscriber;
//    self.userNameLabel.text = _currentSubscriber.stream.name;
//    
//    // subscribe to new subscriber
//    _currentSubscriber.subscribeToVideo = YES;
//    ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).subscriber = _currentSubscriber;
//    self.audioSubUnsubButton.selected = !_currentSubscriber.subscribeToAudio;
//}
//
//- (void)setupSession
//{
//    if (!allStreams)
//        allStreams = [[NSMutableDictionary alloc] init];
//    if (!allSubscribers)
//        allSubscribers = [[NSMutableDictionary alloc] init];
//    if (!allConnectionsIds)
//        allConnectionsIds = [[NSMutableArray alloc] init];
//    if(!backgroundConnectedStreams)
//        backgroundConnectedStreams = [[NSMutableArray alloc] init];
//    
//    self.viewType = 1;
//    NSLog(@"Into session setup and type : %d", self.viewType);
//    kToken = self.token;
//    kSessionId = self.sessionId;
//    //setup one time session
//    if (_session) {
//        _session = nil;
//    }
//    
//    _session = [[OTSession alloc] initWithApiKey:kApiKey
//                                       sessionId:kSessionId
//                                        delegate:self];
//    [_session connectWithToken:kToken error:nil];
//    
//    //    [self setupPublisher];
//    
//}
//
//- (void)setupPublisher
//{
//    NSLog(@"Into setupPublisher and type : %d", self.viewType);
//    
//    // create one time publisher and style publisher
//    _publisher = [[OTPublisher alloc] initWithDelegate:self];
//    
//    // set name of the publisher
//    [_publisher setName:self.publisherName];
//    
//    [self willAnimateRotationToInterfaceOrientation:
//     [[UIApplication sharedApplication] statusBarOrientation] duration:1.0];
//    
//    [self.view addSubview:_publisher.view];
//    
//    // add pan gesture to publisher
//    UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(handlePan:)];
//    [_publisher.view addGestureRecognizer:pgr];
//    pgr.delegate = self;
//    _publisher.view.userInteractionEnabled = YES;
//    
//    OTError *error;
//    [_session publish:_publisher error:&error];
//    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"publisherExists"];
//    if (error)
//    {
//        [self showAlert:[error localizedDescription]];
//        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"publisherExists"];
//    }
//    [self.spinningWheel stopAnimating];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer
//{
//    NSLog(@"Into handle pan and type : %d", self.viewType);
//    CGPoint translation = [recognizer translationInView:_publisher.view];
//    CGRect recognizerFrame = recognizer.view.frame;
//    recognizerFrame.origin.x += translation.x;
//    recognizerFrame.origin.y += translation.y;
//    
//    
//    if (CGRectContainsRect(self.view.bounds, recognizerFrame)) {
//        recognizer.view.frame = recognizerFrame;
//    }
//    else {
//        if (recognizerFrame.origin.y < self.view.bounds.origin.y) {
//            recognizerFrame.origin.y = 0;
//        }
//        else if (recognizerFrame.origin.y + recognizerFrame.size.height > self.view.bounds.size.height) {
//            recognizerFrame.origin.y = self.view.bounds.size.height - recognizerFrame.size.height;
//        }
//        
//        if (recognizerFrame.origin.x < self.view.bounds.origin.x) {
//            recognizerFrame.origin.x = 0;
//        }
//        else if (recognizerFrame.origin.x + recognizerFrame.size.width > self.view.bounds.size.width) {
//            recognizerFrame.origin.x = self.view.bounds.size.width - recognizerFrame.size.width;
//        }
//    }
//    [recognizer setTranslation:CGPointMake(0, 0) inView:_publisher.view];
//}
//
//
//- (void)handleArrowTap:(UIPanGestureRecognizer *)recognizer
//{
//    NSLog(@"Into handleArrowTap and type : %d", self.viewType);
//    if (!_currentSubscriber && ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).subscriber)
//        _currentSubscriber = ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).subscriber;
//    
//    CGPoint touchPoint = [recognizer locationInView:self.leftArrowImgView];
//    if ([self.leftArrowImgView pointInside:touchPoint withEvent:nil])
//    {
//        
//        int currentPage = (int)(self.videoContainerView.contentOffset.x /
//                                self.videoContainerView.frame.size.width) ;
//        
//        OTSubscriber *nextSubscriber = [allSubscribers objectForKey:
//                                        [allConnectionsIds objectAtIndex:currentPage - 1]];
//        
//        [self showAsCurrentSubscriber:nextSubscriber];
//        
//        [self.videoContainerView setContentOffset:
//         CGPointMake(_currentSubscriber.view.frame.origin.x, 0) animated:YES];
//        
//        
//    } else {
//        
//        int currentPage = (int)(self.videoContainerView.contentOffset.x /
//                                self.videoContainerView.frame.size.width) ;
//        
//        OTSubscriber *nextSubscriber = [allSubscribers objectForKey:
//                                        [allConnectionsIds objectAtIndex:currentPage + 1]];
//        
//        [self showAsCurrentSubscriber:nextSubscriber];
//        
//        [self.videoContainerView setContentOffset:
//         CGPointMake(_currentSubscriber.view.frame.origin.x, 0) animated:YES];
//        
//    }
//    
//    [self resetArrowsStates];
//}
//
//
//#pragma mark - OpenTok Session
//- (void)session:(OTSession *)session connectionDestroyed:(OTConnection *)connection
//{
//    NSLog(@"Into connectionDestroyed and type : %d", self.viewType);
//    [self.eConsultDelegate setImageForOffline];
//}
//
//- (void)session:(OTSession *)session
//connectionCreated:(OTConnection *)connection
//{
//    
//    NSLog(@"addConnection: %@ and type : %d", connection, self.viewType);
//    [self.eConsultDelegate setImageForOnline];
//}
//
//- (void)sessionDidConnect:(OTSession *)session
//{
//    NSLog(@"sessionDidConnect %@ and type : %d", session.sessionId, self.viewType);
//    //Forces the application to not let the iPhone go to sleep.
//    [UIApplication sharedApplication].idleTimerDisabled = YES;
//    ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).session = _session;
//    // now publish
//    //    OTError *error;
//    //    [_session publish:_publisher error:&error];
//    //    if (error)
//    //    {
//    //        [self showAlert:[error localizedDescription]];
//    //    }
//    //    [self.spinningWheel stopAnimating];
//}
//
//- (void)reArrangeSubscribers
//{
//    NSLog(@"Into reArrangeSubscribers and type : %d", self.viewType);
//    CGFloat containerWidth = CGRectGetWidth(self.videoContainerView.bounds);
//    CGFloat containerHeight = CGRectGetHeight(self.videoContainerView.bounds);
//    int count = [allConnectionsIds count];
//    
//    // arrange all subscribers horizontally one by one.
//    for (int i = 0; i < [allConnectionsIds count]; i++)
//    {
//        OTSubscriber *subscriber = [allSubscribers
//                                    valueForKey:[allConnectionsIds
//                                                 objectAtIndex:i]];
//        subscriber.view.tag = i;
//        [subscriber.view setFrame:
//         CGRectMake(i * CGRectGetWidth(self.videoContainerView.bounds),
//                    0,
//                    containerWidth,
//                    containerHeight)];
//        [self.videoContainerView addSubview:subscriber.view];
//    }
//    
//    [self.videoContainerView setContentSize:
//     CGSizeMake(self.videoContainerView.frame.size.width * (count ),
//                self.videoContainerView.frame.size.height - 18)];
//    [self.videoContainerView setContentOffset:
//     CGPointMake(_currentSubscriber.view.frame.origin.x, 0) animated:YES];
//}
//
//- (void)sessionDidDisconnect:(OTSession *)session
//{
//    NSLog(@"Into sessionDidDisconnect and type : %d", self.viewType);
//    // remove all subscriber views fro  m video container
//    for (int i = 0; i < [allConnectionsIds count]; i++)
//    {
//        OTSubscriber *subscriber = [allSubscribers valueForKey:
//                                    [allConnectionsIds objectAtIndex:i]];
//        [subscriber.view removeFromSuperview];
//    }
//    
//    [_publisher.view removeFromSuperview];
//    
//    [allSubscribers removeAllObjects];
//    [allConnectionsIds removeAllObjects];
//    [allStreams removeAllObjects];
//    
//    _currentSubscriber = nil;
//    ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).subscriber = nil;
//    _publisher = nil;
//    
//    if (self.archiveStatusImgView.isAnimating)
//    {
//        [self stopArchiveAnimation];
//    }
//    
//    if([self.navigationController.viewControllers indexOfObject:self] !=
//       NSNotFound)
//    {
//        [self dismissViewControllerAnimated:YES completion:^{
//            for (UIViewController *controller in [self.navigationController viewControllers])
//            {
//                if ([controller isKindOfClass:[SmartRxeConsultVC class]])
//                {
//                    [self.navigationController popToViewController:controller animated:YES];
//                }
//            }
//        }];
//        
//    }
//    
//    //Allows the iPhone to go to sleep if there is not touch activity.
//    [UIApplication sharedApplication].idleTimerDisabled = NO;
//}
//
//- (void)    session:(OTSession *)session
//    streamDestroyed:(OTStream *)stream
//{
//    NSLog(@"Into streamDestroyed and type : %d ", self.viewType);
//    //    NSLog(@"streamDestroyed %@", stream.connection.connectionId);
//    
//    // unsubscribe first
//    OTSubscriber *subscriber = [allSubscribers objectForKey:
//                                stream.connection.connectionId];
//    
//    //    OTError *error = nil;
//    //	[_session unsubscribe:subscriber error:&error];
//    //    if (error)
//    //    {
//    //        [self showAlert:[error localizedDescription]];
//    //    }
//    
//    // remove from superview
//    [subscriber.view removeFromSuperview];
//    
//    [allSubscribers removeObjectForKey:stream.connection.connectionId];
//    [allConnectionsIds removeObject:stream.connection.connectionId];
//    
//    _currentSubscriber = nil;
//    ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).subscriber = nil;
//    [self reArrangeSubscribers];
//    
//    // show first subscriber
//    if ([allConnectionsIds count] > 0) {
//        NSString *firstConnection = [allConnectionsIds objectAtIndex:0];
//        [self showAsCurrentSubscriber:[allSubscribers
//                                       objectForKey:firstConnection]];
//    }
//    [self resetArrowsStates];
//}
//
//- (void)createSubscriber:(OTStream *)stream
//{
//    streamReceived = nil;
//    //    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"publisherExists"];
//    //    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    if ([[UIApplication sharedApplication] applicationState] ==
//        UIApplicationStateBackground ||
//        [[UIApplication sharedApplication] applicationState] ==
//        UIApplicationStateInactive)
//    {
//        [backgroundConnectedStreams addObject:stream];
//    }
//    else
//    {
//        // create subscriber
//        OTSubscriber *subscriber = [[OTSubscriber alloc]
//                                    initWithStream:stream delegate:self];
//        NSLog(@"Into create subscriber and type : %d ", self.viewType);
//        // subscribe now
//        OTError *error = nil;
//        [_session subscribe:subscriber error:&error];
//        if (error)
//        {
//            [self showAlert:[error localizedDescription]];
//        }
//    }
//    
//}
//
//- (void)subscriberDidConnectToStream:(OTSubscriberKit *)subscriber
//{
//    NSLog(@"Into subscriberDidConnectToStream and type : %d ", self.viewType);
//    NSLog(@"subscriberDidConnectToStream %@", subscriber.stream.name);
//    
//    // create subscriber
//    OTSubscriber *sub = (OTSubscriber *)subscriber;
//    [allSubscribers setObject:subscriber forKey:sub.stream.connection.connectionId];
//    [allConnectionsIds addObject:sub.stream.connection.connectionId];
//    
//    // set subscriber position and size
//    CGFloat containerWidth = CGRectGetWidth(self.videoContainerView.bounds);
//    CGFloat containerHeight = CGRectGetHeight(self.videoContainerView.bounds);
//    int count = [allConnectionsIds count] - 1;
//    [sub.view setFrame:
//     CGRectMake(count *
//                CGRectGetWidth(self.videoContainerView.bounds),
//                0,
//                containerWidth,
//                containerHeight)];
//    
//    sub.view.tag = count;
//    
//    // add to video container view
//    [self.videoContainerView insertSubview:sub.view
//                              belowSubview:_publisher.view];
//    
//    
//    // default subscribe video to the first subscriber only
//    if (!_currentSubscriber) {
//        [self showAsCurrentSubscriber:(OTSubscriber *)subscriber];
//    } else {
//        subscriber.subscribeToVideo = NO;
//    }
//    
//    // set scrollview content width based on number of subscribers connected.
//    [self.videoContainerView setContentSize:
//     CGSizeMake(self.videoContainerView.frame.size.width * (count + 1),
//                self.videoContainerView.frame.size.height - 18)];
//    
//    [allStreams setObject:sub.stream forKey:sub.stream.connection.connectionId];
//    
//    [self resetArrowsStates];
//}
//
//- (void) session:(OTSession *)mySession streamCreated:(OTStream *)stream
//{
//    if (!allStreams)
//        allStreams = [[NSMutableDictionary alloc] init];
//    if (!allSubscribers)
//        allSubscribers = [[NSMutableDictionary alloc] init];
//    if (!allConnectionsIds)
//        allConnectionsIds = [[NSMutableArray alloc] init];
//    if(!backgroundConnectedStreams)
//        backgroundConnectedStreams = [[NSMutableArray alloc] init];
//    
//    
//    NSLog(@"Into Stream created and type : %d", self.viewType);
//    // create remote subscriber
//    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"publisherExists"];
//    if ([str isEqualToString:@"YES"])
//        [self createSubscriber:stream];
//    else
//        ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).stream = stream;
//}
//
//- (void)session:(OTSession *)session didFailWithError:(OTError *)error
//{
//    NSLog(@"sessionDidFail");
//    [self showAlert:
//     [NSString stringWithFormat:@"There was an error connecting to session %@",
//      error.localizedDescription]];
//    [self endCall:nil];
//}
//
//- (void)publisher:(OTPublisher *)publisher didFailWithError:(OTError *)error
//{
//    NSLog(@"publisher didFailWithError %@", error);
//    [self showAlert:[NSString stringWithFormat:
//                     @"There was an error publishing."]];
//    [self endCall:nil];
//}
//
//- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error
//{
//    NSLog(@"subscriber could not connect to stream");
//}
//
//#pragma mark - Helper Methods
//- (void)endCall:(UIButton *)button
//{
//    
//    if (_session && _session.sessionConnectionStatus ==
//        OTSessionConnectionStatusConnected) {
//        // disconnect session
//        NSLog(@"disconnecting....");
//        [_session disconnect:nil];
//        return;
//    } else
//    {
//        //all other cases just go back to home screen.
//        if([self.navigationController.viewControllers indexOfObject:self] !=
//           NSNotFound)
//        {
//            [self dismissViewControllerAnimated:YES completion:^{
//                for (UIViewController *controller in [self.navigationController viewControllers])
//                {
//                    if ([controller isKindOfClass:[SmartRxeConsultVC class]])
//                    {
//                        [self.navigationController popToViewController:controller animated:YES];
//                    }
//                }
//            }];
//        }
//    }
//}
//
//- (void)showAlert:(NSString *)string
//{
//    // show alertview on main UI
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"Message from video session"
//                              message:string
//                              delegate:self
//                              cancelButtonTitle:@"OK"
//                              otherButtonTitles:nil];
//        [alert show];
//    });
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//#pragma mark - Other Interactions
//- (IBAction)toggleAudioSubscribe:(id)sender
//{
//    if (_currentSubscriber.subscribeToAudio == YES) {
//        _currentSubscriber.subscribeToAudio = NO;
//        self.audioSubUnsubButton.selected = YES;
//    } else {
//        _currentSubscriber.subscribeToAudio = YES;
//        self.audioSubUnsubButton.selected = NO;
//    }
//}
//
//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter]
//     removeObserver:self
//     name:UIApplicationWillResignActiveNotification
//     object:nil];
//    
//    [[NSNotificationCenter defaultCenter]
//     removeObserver:self
//     name:UIApplicationDidBecomeActiveNotification
//     object:nil];
//}
//
//- (IBAction)toggleCameraPosition:(id)sender
//{
//    if (_publisher.cameraPosition == AVCaptureDevicePositionBack) {
//        _publisher.cameraPosition = AVCaptureDevicePositionFront;
//        self.cameraToggleButton.selected = NO;
//        self.cameraToggleButton.highlighted = NO;
//    } else if (_publisher.cameraPosition == AVCaptureDevicePositionFront) {
//        _publisher.cameraPosition = AVCaptureDevicePositionBack;
//        self.cameraToggleButton.selected = YES;
//        self.cameraToggleButton.highlighted = YES;
//    }
//}
//
//- (IBAction)toggleAudioPublish:(id)sender
//{
//    if (_publisher.publishAudio == YES) {
//        _publisher.publishAudio = NO;
//        self.audioPubUnpubButton.selected = YES;
//    } else {
//        _publisher.publishAudio = YES;
//        self.audioPubUnpubButton.selected = NO;
//    }
//}
//
//- (void)startArchiveAnimation
//{
//    
//    if (self.archiveOverlay.hidden)
//    {
//        self.archiveOverlay.hidden = NO;
//        CGRect frame = _publisher.view.frame;
//        frame.origin.y -= ARCHIVE_BAR_HEIGHT;
//        _publisher.view.frame = frame;
//    }
//    BOOL isInFullScreen = [[[self topOverlayView].layer
//                            valueForKey:APP_IN_FULL_SCREEN] boolValue];
//    
//    //show UI if it is in full screen
//    if (isInFullScreen)
//    {
//        [self viewTapped:[self.view.gestureRecognizers objectAtIndex:0]];
//    }
//    
//    
//    // set animation images
//    self.archiveStatusLbl.text = @"Archiving call";
//    UIImage *imageOne = [UIImage imageNamed:@"archiving_on-10.png"];
//    UIImage *imageTwo = [UIImage imageNamed:@"archiving_pulse-Small.png"];
//    NSArray *imagesArray =
//    [NSArray arrayWithObjects:imageOne, imageTwo, nil];
//    self.archiveStatusImgView.animationImages = imagesArray;
//    self.archiveStatusImgView.animationDuration = 1.0f;
//    self.archiveStatusImgView.animationRepeatCount = 0;
//    [self.archiveStatusImgView startAnimating];
//    
//}
//
//- (void)stopArchiveAnimation
//{
//    [self.archiveStatusImgView stopAnimating];
//    self.archiveStatusLbl.text = @"Archiving off";
//    self.archiveStatusImgView.image =
//    [UIImage imageNamed:@"archiving-off-15.png"];
//}
//
//- (void)     session:(OTSession*)session
//archiveStartedWithId:(NSString*)archiveId
//                name:(NSString*)name
//{
//    [self startArchiveAnimation];
//}
//
//- (void)     session:(OTSession*)session
//archiveStoppedWithId:(NSString*)archiveId
//{
//    NSLog(@"stopping session archiving");
//    [self stopArchiveAnimation];
//    
//}
//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

@end
