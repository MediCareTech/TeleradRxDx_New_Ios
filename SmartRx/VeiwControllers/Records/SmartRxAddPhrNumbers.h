//
//  SmartRxAddPhrNumbers.h
//  SmartRx
//
//  Created by Anil Kumar on 12/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxAddPhrNumbers : UIViewController<UITextFieldDelegate, loginDelegate,MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel1;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel2;
@property (nonatomic, retain) NSMutableDictionary *phrDetailsDictionary;
@property (nonatomic, readwrite) NSUInteger phrID;
@property (weak, nonatomic) IBOutlet UIButton *addOrUpdatebutton;
@property (strong, nonatomic) UIButton *currentButton;
@property (nonatomic, retain) NSString *addOrUpdateButtonText;
@property (retain, nonatomic) UIDatePicker *datePicker;
@property (assign, nonatomic) NSString *strTitle;

@property (retain, nonatomic) UIDatePicker *timePicker;
@property (strong, nonatomic) UIView *actionSheet;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;

@property (weak, nonatomic) IBOutlet UIView *viwResult;
@property (weak, nonatomic) IBOutlet UILabel *lblSysBpResult;
@property (weak, nonatomic) IBOutlet UILabel *lblDiastBpResult;
@property (weak, nonatomic) IBOutlet UIView *viewWarrning;
@property (weak, nonatomic) IBOutlet UIView *viwExcellent;
@property (weak, nonatomic) IBOutlet UIView *viwNeedImprove;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolViwResult;
@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imgSystolicResltIndctor;
@property (weak, nonatomic) IBOutlet UIImageView *imgDiastolicResltIndctor;
@property (weak, nonatomic) IBOutlet UIImageView *imgTextBacgrnd;
@property (weak, nonatomic) IBOutlet UIView *viwWarningImprovment;

- (IBAction)hideResultView:(id)sender;
- (IBAction)okBtnClickedToHideResultView:(id)sender;
- (IBAction)dateBtnClicked:(id)sender;
- (IBAction)timeBtnClicked:(id)sender;
- (IBAction)makeRequestToAddPhrNumDetails:(id)sender;
- (IBAction)updateBackButtontnClicked:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;

@end
