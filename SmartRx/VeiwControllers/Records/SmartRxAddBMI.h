//
//  SmartRxAddBMI.h
//  SmartRx
//
//  Created by Anil Kumar on 16/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxAddBMI : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource,loginDelegate,MBProgressHUDDelegate, UITextFieldDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *heightTextField;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (retain, nonatomic) UITextField *currentTextField;
@property (retain, nonatomic) UIPickerView *heightPicker;
@property (retain, nonatomic) UIPickerView *weightPicker;
@property (retain, nonatomic) UIDatePicker *datePicker;
@property (retain, nonatomic) UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIButton *heightButton;
@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (strong, nonatomic) UIButton *currentButton;
@property (strong, nonatomic) UIView *actionSheet;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;

@property (nonatomic, retain) NSMutableDictionary *phrDetailsDictionary;

@property (nonatomic, readwrite)  NSUInteger selectedHeightSecondComponent, selectedWeightFirstComponent, selectedWeightSecondComponent;
@property (nonatomic, readwrite) float selectedHeightFirstComponent;
@property (nonatomic, readwrite) NSUInteger firstPickerNoOfComponents;
@property (nonatomic, readwrite) NSUInteger secondPickerNoOfComponents;
@property (nonatomic, readwrite) NSInteger firstPickerNumberOfRowsInComponent;
@property (nonatomic, readwrite) NSInteger secondPickerNumberOfRowsInComponent;
@property (nonatomic, readwrite) BOOL heightIsCm;
@property (nonatomic, readwrite) BOOL weightFirstTime, heightFirstTime;
@property (nonatomic, readwrite) int feetRowCount;
@property (nonatomic, retain) NSMutableArray *feetMeasures;
@property (nonatomic, retain) NSMutableDictionary *firstPickerselectedArray;
@property (nonatomic, retain) NSMutableDictionary *secondPickerselectedArray;
@property (nonatomic, retain) NSMutableArray *firstPickerComponentOneArray;
@property (nonatomic, retain) NSMutableArray *secondPickerComponentOneArray;
@property (nonatomic, readwrite) NSUInteger phrID;
@property (nonatomic, retain) NSString *addOrUpdateButtonText;
@property (weak, nonatomic) IBOutlet UIButton *addOrUpdatebutton;
@property (nonatomic, readwrite) int unitType1, unitType2;

@property (weak, nonatomic) IBOutlet UIView *viwResult;
@property (weak, nonatomic) IBOutlet UIImageView *imgResultBacGrnd;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolViwResult;
@property (weak, nonatomic) IBOutlet UILabel *lblBMI;
@property (weak, nonatomic) IBOutlet UIView *viwExcellent;
@property (weak, nonatomic) IBOutlet UIView *viwNeedToImporve;
@property (weak, nonatomic) IBOutlet UIImageView *imgTxtBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imgResultPointer;
@property (weak, nonatomic) IBOutlet UILabel *lblNeedImprovment;

- (IBAction)okBtnClickedToCloseResultView:(id)sender;
- (IBAction)hideResultView:(id)sender;
- (IBAction)makeRequestToAddPhrBMIDetails:(id)sender;
- (IBAction)updateBackBtnClicked;
- (IBAction)heightBtnClicked:(id)sender;
- (IBAction)weightBtnClicked:(id)sender;
- (IBAction)dateBtnClicked:(id)sender;
- (IBAction)timeBtnClicked:(id)sender;
@end
