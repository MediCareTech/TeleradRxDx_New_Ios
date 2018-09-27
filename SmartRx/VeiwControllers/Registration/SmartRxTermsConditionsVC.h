//
//  SmartRxTermsConditionsVC.h
//  SmartRx
//
//  Created by PaceWisdom on 09/07/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxTermsConditionsVC : UIViewController<UIWebViewDelegate,MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)backButtonCliked:(id)sender;

@end
