//
//  SmartRxPaymentVC.h
//  SmartRx
//
//  Created by Manju Basha on 07/04/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"
#import "SmartRxTextFieldLeftImage.h"
#import "CitrusSdk.h"

@interface SmartRxPaymentVC : UIViewController<UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSString *costValue;
@property (nonatomic, strong) NSString *email;
@property (strong, nonatomic) NSMutableDictionary *packageResponse;
//@property (nonatomic, strong) HMSegmentedControl *segmentedControl4;
//@property (retain, nonatomic) SmartRxTextFieldLeftImage *debitEmailTextField;
//@property (retain, nonatomic) SmartRxTextFieldLeftImage *debitCardNumTextField;
//@property (retain, nonatomic) SmartRxTextFieldLeftImage *debitExpTextField;
//@property (retain, nonatomic) SmartRxTextFieldLeftImage *debitCvvTextField;
//@property (retain, nonatomic) SmartRxTextFieldLeftImage *debitAmountTextField;
//@property (retain, nonatomic) SmartRxTextFieldLeftImage *debitNameTextField;
//@property (retain, nonatomic) UIButton *debitPayBtn;
//
//@property (retain, nonatomic) SmartRxTextFieldLeftImage *creditEmailTextField;
//@property (retain, nonatomic) SmartRxTextFieldLeftImage *creditCardNumTextField;
//@property (retain, nonatomic) SmartRxTextFieldLeftImage *creditExpTextField;
//@property (retain, nonatomic) SmartRxTextFieldLeftImage *creditCvvTextField;
//@property (retain, nonatomic) SmartRxTextFieldLeftImage *creditAmountTextField;
//@property (retain, nonatomic) SmartRxTextFieldLeftImage *creditNameTextField;
//@property (retain, nonatomic) UIButton *creditPayBtn;


@property (nonatomic , strong) NSString *amount;
@property (assign) int landingScreen;

@property (nonatomic , strong) UITextField *cardNumberTextField;
@property (nonatomic , strong) UITextField *ownerNameTextField;
@property (nonatomic , strong) UITextField *emailIDTextField;
@property (nonatomic , strong) UITextField *expiryDateTextField;
@property (nonatomic , strong) UITextField *cvvTextField;
@property (nonatomic , strong) UIImageView *schemeTypeImageView;

@property (nonatomic , weak) IBOutlet UIButton *loadButton;

@property (nonatomic , weak) IBOutlet UITableView *ccddtableView;

@property (nonatomic , weak) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic , strong) CTSRuleInfo *ruleInfo;
@property (assign) DPRequestType dpType;
-(IBAction)loadOrPayMoney:(id)sender;
@end
