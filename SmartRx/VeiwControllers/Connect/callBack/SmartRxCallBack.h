//
//  SmartRxCallBack.h
//  SmartRx
//
//  Created by Anil Kumar on 23/01/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxTextFieldLeftImage.h"
@interface SmartRxCallBack : UIViewController <UITextViewDelegate, UITextFieldDelegate, MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet SmartRxTextFieldLeftImage *nameTextField;
@property (weak, nonatomic) IBOutlet SmartRxTextFieldLeftImage *phoneTextField;
@property (strong, nonatomic) NSArray *arrLocations;
@property (strong, nonatomic) NSArray *timeArray;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (assign, nonatomic) NSString *strTitle;
@property (weak, nonatomic) IBOutlet UITextView *reasonTextView;
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (strong, nonatomic) NSArray *arrLoadCell;
@property (weak, nonatomic) IBOutlet UIPickerView *commonPicker;
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
- (void)homeBtnClicked:(id)sender;
- (void)backBtnClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)timerButtonClicked:(id)sender;
- (IBAction)locationButtonClicked:(id)sender;
- (IBAction)callBackBtnClicked:(id)sender;

@end
