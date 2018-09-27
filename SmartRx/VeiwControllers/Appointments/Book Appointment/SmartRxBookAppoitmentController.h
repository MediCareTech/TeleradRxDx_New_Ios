//
//  SmartRxBookAppoitmentController.h
//  TeleradRxdx
//
//  Created by Gowtham on 24/05/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SmartRxBookAppoitmentController : UIViewController<MBProgressHUDDelegate,UIWebViewDelegate>

@property(nonatomic,weak) IBOutlet UIWebView *webView;

@property (assign, nonatomic) NSString *strTitle;

@end
