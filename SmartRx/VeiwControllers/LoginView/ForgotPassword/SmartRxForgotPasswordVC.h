//
//  SmartRxForgotPasswordVC.h
//  SmartRx
//
//  Created by PaceWisdom on 21/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxForgotPasswordVC : UIViewController<MBProgressHUDDelegate,UITextFieldDelegate,UIAlertViewDelegate,loginDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtMobileNum;
@property (weak, nonatomic) IBOutlet UITextField *txtDob;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPass;
@property (assign, nonatomic) NSString *strTitle;
@property (strong, nonatomic) UIDatePicker *datePickerView;

- (IBAction)sendPasswordBtnClicked:(id)sender;
- (IBAction)hideKeyBoard:(id)sender;

@end
