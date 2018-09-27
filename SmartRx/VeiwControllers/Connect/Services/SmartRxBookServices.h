//
//  SmartRxBookServices.h
//  SmartRx
//
//  Created by Manju Basha on 19/10/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKCalendarView.h"
#import "RadioButton.h"
#import "SmartRxTextFieldLeftImage.h"

@interface SmartRxBookServices : UIViewController <CKCalendarDelegate, MBProgressHUDDelegate, RadioButtonDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIPickerViewAccessibilityDelegate, UITextFieldDelegate>
//, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic)IBOutlet UIView *calendarContainer;
@property (nonatomic, weak)IBOutlet CKCalendarView *calendar;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSDate *minimumDate;
@property(nonatomic, strong) NSArray *disabledDates;
@property(nonatomic, strong) NSMutableArray *selectedDates;

@property (weak, nonatomic)IBOutlet UIView *dateTimeView;
@property (weak, nonatomic)IBOutlet UIView *paymentFullView;
@property (weak, nonatomic)IBOutlet UIView *payNowView;
@property (weak, nonatomic)IBOutlet UIView *radioOneView;
@property (weak, nonatomic)IBOutlet UIView *radioTwoView;
@property (weak, nonatomic)IBOutlet UIView *guestUserView;
@property (weak, nonatomic)IBOutlet UIView *loggedInUserView;

@property(nonatomic, strong)IBOutlet UILabel *payNowLabel;
@property(nonatomic, strong)IBOutlet UILabel *payLaterLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (readwrite, nonatomic) BOOL fromFindDoctors;
@property (weak, nonatomic) IBOutlet UIButton *serviceTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *packageTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) UIButton *currentButton;
@property (strong, nonatomic) RadioButton *payNow;
@property (strong, nonatomic) RadioButton *payLater;
@property (weak, nonatomic) IBOutlet UITextView *packageDescription;
@property (weak, nonatomic) IBOutlet SmartRxTextFieldLeftImage *nameTextField;
@property (weak, nonatomic) IBOutlet SmartRxTextFieldLeftImage *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *serviceTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel *packageTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *noteLbl;

@property (weak, nonatomic) IBOutlet UILabel *serviceFeeText;
@property (weak, nonatomic) IBOutlet UILabel *serviceActualCost;
@property (weak, nonatomic) IBOutlet UILabel *serviceDiscountedCost;
@property (strong, nonatomic) IBOutlet UIImageView *closeImage;

@property (strong, nonatomic) UIView *actionSheet;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (strong, nonatomic) NSMutableDictionary *doctorEconsultDetail;

@property (retain, nonatomic) UIPickerView *serviceTypePicker;
@property (retain, nonatomic) UIPickerView *packageTypePicker;
@property (retain, nonatomic) UIPickerView *timePicker;

@property (strong, nonatomic) NSMutableArray *arrServiceType;
@property (strong, nonatomic) NSMutableArray *arrPackageType;

@property (strong, nonatomic) NSMutableArray *dictResponse;
@property (strong, nonatomic) NSMutableDictionary *packageResponse;
@property (retain, nonatomic) NSMutableDictionary *paymentResponseDictionary;

@property (weak, nonatomic) IBOutlet UITextField *promoCodeText;
@property (weak, nonatomic) IBOutlet UIButton *promoApplyBtn;

+ (id)sharedManagerServices;
- (IBAction)serviceTypeButtonClicked:(id)sender;
- (IBAction)packageTypeButtonClicked:(id)sender;
- (IBAction)dateButtonClicked:(id)sender;
- (IBAction)timeButtonClicked:(id)sender;
- (IBAction)servicesBookBtnClicked:(id)sender;
- (IBAction)promoApplyBtnClicked:(id)sender;

@end

