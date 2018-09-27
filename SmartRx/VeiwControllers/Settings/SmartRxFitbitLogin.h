//
//  SmartRxFitbitLogin.h
//  SmartRx
//
//  Created by SmartRx-iOS on 04/04/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  FitbitUpdateDelegate<NSObject>

-(void)fitbitUpdate;
@end

@interface SmartRxFitbitLogin : UIViewController

@property(nonatomic,weak) IBOutlet UIWebView *webView;

@property(nonatomic,weak) id<FitbitUpdateDelegate>  delegate;

@end
