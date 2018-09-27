//
//  SmartRxCarePlaneDetailsVC.h
//  SmartRx
//
//  Created by PaceWisdom on 09/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxCarePlaneDetailsVC : UIViewController<UIWebViewDelegate,MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webViewDetails;
@property (assign, nonatomic) NSString *strOpId;
@property (assign, nonatomic) NSString *strRectype;
@property (assign, nonatomic) NSString *strTitle;
@property (strong, nonatomic) NSString *strWebcontent;
@end
