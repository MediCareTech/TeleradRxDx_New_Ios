//
//  SmartRxRegisterVC.h
//  SmartRx
//
//  Created by PaceWisdom on 30/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "appConstants.h"
@interface SmartRxRegisterVC : UIViewController<MBProgressHUDDelegate,UITextFieldDelegate,UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSArray *genderArray;
    UIPickerView *genderPickerView;
    UIToolbar *pickerButtonBar;
    UIButton *doneButton;
    UIButton *nextButton;
    UIBarButtonItem *pickerDoneItemButton;
    UIBarButtonItem *pickerNextItemButton;
    UIBarButtonItem *pickerTitleSpaceButton;
    UIDatePicker *DOBPickerView;
   UI_PICKER_TYPE                  currentPickerShown;
    BOOL                             isGenderPickerShown;
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
    UITextField *currentTextfied;
    NSString *strDoctorId;
}

@property (strong, nonatomic) NSArray *arrDocList;
@property (strong, nonatomic) NSArray *arrGender;
@property (strong, nonatomic) NSArray *arrLoadCell;
@property (strong, nonatomic) NSString *strCID;
@property (strong, nonatomic) NSString *strMobilNumber;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtMobile;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtDOB;
@property (weak, nonatomic) IBOutlet UITextField *txtGender;
@property (weak, nonatomic) IBOutlet UITextField *txtDoctor;
@property (weak, nonatomic) IBOutlet UITextField *txtLocation;
//@property (strong, nonatomic) IBOutlet UITableView *tblDoctors;
@property (weak, nonatomic) IBOutlet UIButton *btnTerms;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *commonPicker;
@property (strong, nonatomic) NSArray *arrLocations;
@property (strong, nonatomic) NSMutableArray *arrSpeclist;
@property (strong, nonatomic) NSMutableArray *arrSpecAndDocResponse;
@property (strong, nonatomic) NSDictionary *dictResponse;


- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)termsBtnClicked:(id)sender;
- (IBAction)hideKeyboard:(id)sender;
- (IBAction)resignKeyboard:(id)sender;
- (IBAction)registerBtnClicked:(id)sender;
- (IBAction)cancelBtnClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)termsAndConditionsBtnClicked:(id)sender;
- (IBAction)dobBtnClicked:(id)sender;
- (IBAction)genderBtnClicked:(id)sender;
- (IBAction)selectDocBtnClicked:(id)sender;
- (IBAction)selectLocationBtnClicked:(id)sender;

@end
