//
//  SmartRxReportImageVC.h
//  SmartRx
//
//  Created by PaceWisdom on 25/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SmartRxReportImageVC : UIViewController<UIWebViewDelegate,MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) NSString *webUrl;
@property (assign, nonatomic) NSString *strImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)dismissBtnClicked:(id)sender;

@end
