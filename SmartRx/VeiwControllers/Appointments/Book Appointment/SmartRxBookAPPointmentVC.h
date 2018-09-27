//
//  SmartRxBookAPPointmentVC.h
//  SmartRx
//
//  Created by PaceWisdom on 12/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxAppointmentsVC.h"
@interface SmartRxBookAPPointmentVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate,MBProgressHUDDelegate,UITextViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,loginDelegate,UITextFieldDelegate>
{
//    UIActionSheet *pickerAction;
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
    UITextField *cellTextfield;
    NSString *strSpecId;
    NSString *strSlelectedDocID;
}

@property(nonatomic,strong) NSString *scheduleType;


@property (strong, nonatomic) UIView *actionSheet;
@property (retain, nonatomic) UIPickerView *usersPickerView;
@property (nonatomic, retain) NSMutableDictionary *getAppointmentDoctorDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnRegular;
@property (weak, nonatomic) IBOutlet UIButton *btnEconsult;
@property (weak, nonatomic) IBOutlet UIButton *btnBookApp;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UITableView *tblDoctorsList;
@property (weak, nonatomic) IBOutlet UITextField *textDoctorName;
@property (weak, nonatomic) IBOutlet UITextField *textDate;
@property (weak, nonatomic) IBOutlet UITextField *textTime;
@property (weak, nonatomic) IBOutlet UITextField *textLocation;
@property (weak, nonatomic) IBOutlet UITextField *textSpeciality;
@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UITextField *textMobile;
@property (weak, nonatomic) IBOutlet UITextField *textDoctorAddress;

@property (weak, nonatomic) IBOutlet UIView *paymentView;
@property (weak, nonatomic) IBOutlet UIView *promocodeView;
@property (weak, nonatomic) IBOutlet UIView *payOptionView;
@property (weak, nonatomic) IBOutlet UIView *payChoiceView;
@property (weak, nonatomic) IBOutlet UILabel *consultationActualCost;
@property (weak, nonatomic) IBOutlet UILabel *consultationDiscountedCost;
@property (weak, nonatomic) IBOutlet UILabel *consultationFeeText;
@property (strong, nonatomic) IBOutlet UIImageView *closeImage;
@property (strong, nonatomic) IBOutlet UIButton *payLaterBtn;
@property (strong, nonatomic) IBOutlet UIButton *payNowBtn;
@property (weak, nonatomic) IBOutlet UITextField *promoCodeText;
@property (weak, nonatomic) IBOutlet UIButton *promoApplyBtn;
@property (strong, nonatomic) IBOutlet UIImageView *payNowImage;
@property (strong, nonatomic) IBOutlet UIImageView *paylaterImage;


@property (weak, nonatomic) IBOutlet UIImageView *imgTxtViwPecil;
@property (weak, nonatomic) IBOutlet UILabel *lblTxtView;
@property (weak, nonatomic) IBOutlet UITextView *textReason;

@property (weak, nonatomic) IBOutlet UIButton *chooseCity;

@property (strong, nonatomic) NSMutableDictionary *doctorAppointmentDetails;
@property(nonatomic,strong) NSArray *usersList;
@property(nonatomic,strong) NSArray *locationsArray;
@property(nonatomic,strong) NSArray *patientLocationsArray;
@property(nonatomic,strong) NSArray *specialtiArray;
@property(nonatomic,strong) NSArray *doctorArray;
@property(nonatomic,strong) NSArray *timeSlotsArray;
@property(nonatomic,strong) NSArray *selectedDoctorAddressArray;
@property(nonatomic,strong) NSArray *filteredDoctorArray;
@property(nonatomic,strong) NSArray *tableArray;
@property (strong, nonatomic) NSMutableArray *arrDoctorsList;
@property (strong, nonatomic) NSMutableArray *arrSpeclist;
@property (strong, nonatomic) NSMutableArray *arrSpecAndDocResponse;
@property (strong, nonatomic) NSMutableArray *arrLoadTbl;
@property (strong, nonatomic) NSArray *arrLocations;
@property (strong, nonatomic) NSMutableArray *arrAppTime;
@property (strong, nonatomic) NSDictionary *dictResponse;
@property (weak, nonatomic) IBOutlet UIView *viewForPicker;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIButton *btnDonePIcker;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (strong, nonatomic) NSDictionary *dictAppTimes;
@property (strong, nonatomic) NSArray *arrAppTimeIds;
@property (assign, nonatomic) NSString *strTitle;

@property (strong, nonatomic) NSMutableDictionary *packageResponse;
@property (retain, nonatomic) NSMutableDictionary *paymentResponseDictionary;

+ (id)sharedManagerAppointment;
- (IBAction)donePikerBtnClicked:(id)sender;
- (IBAction)bookAppoinmentClicked:(id)sender;
- (IBAction)timeBtnClicked:(id)sender;
- (IBAction)dateBtnClicked:(id)sender;
- (IBAction)eConsultBtnClicked:(id)sender;
- (IBAction)regularBtnClicked:(id)sender;
- (IBAction)selectLocationBtnClicked:(id)sender;
- (IBAction)selectSpecBtnClicked:(id)sender;
- (IBAction)selectDocBtnClicked:(id)sender;
- (IBAction)hideKeyboardBtnClicked:(id)sender;

@end
