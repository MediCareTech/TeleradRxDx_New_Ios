//
//  SmartRxEditProfileVC.h
//  SmartRx
//
//  Created by PaceWisdom on 26/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxMapVC.h"

@interface SmartRxEditProfileVC : UIViewController<MBProgressHUDDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,loginDelegate,LocationDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtMobile;
@property (weak, nonatomic) IBOutlet UITextField *txtGender;
@property (weak, nonatomic) IBOutlet UITextField *txtDOB;
@property (weak, nonatomic) IBOutlet UITextField *txtDoctor;
@property (weak, nonatomic) IBOutlet UITextField *txtLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelDoctor;
@property (weak, nonatomic) IBOutlet UILabel *labelLocation;
@property (weak, nonatomic) IBOutlet UITextField *txtSettings;
@property (weak, nonatomic) IBOutlet UITextField *txtLocateMe;
@property (weak, nonatomic) IBOutlet UIButton *btnNo;
@property (weak, nonatomic) IBOutlet UIButton *btnYes;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdate;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) NSArray *arrDoctors;
@property (strong, nonatomic) NSDictionary *dictDocorRefId;
@property (strong, nonatomic) NSArray *arrGender;
@property (strong, nonatomic) NSArray *arrDataSetting;
@property (strong, nonatomic) NSArray *arrLoadTbl;
@property (weak, nonatomic) IBOutlet UITableView *tblDoctor;
@property (weak, nonatomic) IBOutlet UIButton *btnImagePIcker;

- (IBAction)imgaePickerBtnClicked:(id)sender;
- (IBAction)yesBtnClicked:(id)sender;
- (IBAction)noBtnClicked:(id)sender;
- (IBAction)updateBtnClicked:(id)sender;
- (IBAction)genderBtnClicked:(id)sender;
- (IBAction)dataBtnClicked:(id)sender;
- (IBAction)doctorBtnClicked:(id)sender;
- (IBAction)keyBoardHideBtnClicked:(id)sender;
- (IBAction)mobileBtnClicked:(id)sender;
- (IBAction)dobBtnClicked:(id)sender;
- (void)makeRequestForUserRegister; 

@end
