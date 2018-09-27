//
//  MediaVC.h
//  SmartRx
//
//  Created by SmartRx-iOS on 21/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaVC : UIViewController<UIWebViewDelegate,MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) NSString *webUrl;
@property (assign, nonatomic) NSString *strImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)dismissBtnClicked:(id)sender;
@end
