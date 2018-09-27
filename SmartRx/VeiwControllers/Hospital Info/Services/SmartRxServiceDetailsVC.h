//
//  SmartRxServiceDetailsVC.h
//  SmartRx
//
//  Created by Anil Kumar on 05/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxServiceDetailsVC : UIViewController<MBProgressHUDDelegate>
@property (strong, nonatomic) NSMutableArray *dictResponse;
@property (strong, nonatomic) NSMutableDictionary *dictData;
@property (weak, nonatomic) IBOutlet UILabel *specialityName;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *tabIndicationView;
@property (weak, nonatomic) IBOutlet UIImageView *serviceImage;
@property (readwrite, nonatomic) BOOL fromAboutUs;
@property (assign, nonatomic) NSString *strTitle;

- (IBAction)specialityButton:(id)sender;
@end
