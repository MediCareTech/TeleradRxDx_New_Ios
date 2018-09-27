//
//  WebViewViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 09/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewViewController : UIViewController <UIWebViewDelegate>
{
    NSString* redirectURL;
    UIActivityIndicatorView* indicator;
    
}
@property(nonatomic,strong) NSString *redirectURL;

@end
