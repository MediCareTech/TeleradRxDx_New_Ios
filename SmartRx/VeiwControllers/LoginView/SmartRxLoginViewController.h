//
//  SmartRxLoginViewController.h
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxLoginViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtMobileNumber;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *hospitalNameLabel;
@property (strong, nonatomic) IBOutlet UIView *mobileGreyView;
@property (strong, nonatomic) NSString *strIsLogout;

- (IBAction)loginClicked:(id)sender;
- (IBAction)hideKeyBoard:(id)sender;
- (IBAction)registerBtnClicked:(id)sender;
- (IBAction)forgotBtnClicked:(id)sender;
- (IBAction)continueAsGuest:(id)sender;

@end
