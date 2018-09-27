//
//  SmartRxAppointmentDetailVC.h
//  SmartRx
//
//  Created by Gowtham on 12/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"
#import "SmartRxeConsultReportCell.h"
#import "SmartRxSuggesstionCell.h"
#import "SmartRxeConsultRequestCell.h"

@interface SmartRxAppointmentDetailVC : UIViewController<UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,loginDelegate,UIAlertViewDelegate,ImageSelected,UIGestureRecognizerDelegate,UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic,strong) NSString *scheduleType;

@property (strong, nonatomic) NSMutableDictionary *dictResponse;
@property (weak, nonatomic) IBOutlet UILabel *docName;
@property (weak, nonatomic) IBOutlet UILabel *eConsultDateTime;
@property (weak, nonatomic) IBOutlet UIImageView *eConsultStatusImage;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic) IBOutlet UILabel *econsultMethodLbl;
@property (weak, nonatomic) IBOutlet UILabel *paymentStatus;
@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIScrollView *suggestionScroll;
@property (retain, nonatomic) IBOutlet UIScrollView *symptomScroll;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIView *videoConsultView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl4;

@property (weak, nonatomic) IBOutlet UIButton *btnBF;
@property (weak, nonatomic) IBOutlet UIButton *btnAF;

@property (strong, nonatomic) UIView *currentView;
@property (retain, nonatomic) NSString *publisherName;

@property (weak, nonatomic) IBOutlet UIView *symptomsViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *symptomsContent;
@property (weak, nonatomic) IBOutlet UITextView *symptomsContentLabel;
@property (nonatomic, strong) NSString *pdfPath;
@property (assign, nonatomic) NSString *strTitle;

@property (weak, nonatomic) IBOutlet UIView *suggestionViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *suggestionContent;
@property (weak, nonatomic) IBOutlet UILabel *suggestionContentLabel;
@property (weak, nonatomic) IBOutlet UITableView *suggestionContentTable;

@property (weak, nonatomic) IBOutlet UIView *reportViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *reportContent;
@property (retain, nonatomic) IBOutlet UIScrollView *reportScroll;
@property (weak, nonatomic) IBOutlet UITableView *reportContentTable;

@property (weak, nonatomic) IBOutlet UIView *requestViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *requestContent;
@property (weak, nonatomic) IBOutlet UITableView *requestContentTable;


@property (weak, nonatomic) IBOutlet UIView *familyViewEdit;
@property (weak, nonatomic) IBOutlet UITextView *familyContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *familyContent;

@property (weak, nonatomic) IBOutlet UIView *medicationViewEdit;

@property (weak, nonatomic) IBOutlet UIView *updateMedicationView;
@property(nonatomic,weak) IBOutlet UITableView *medicationTable;
@property(nonatomic,weak) IBOutlet UITextField *drugNameTF;
@property(nonatomic,weak) IBOutlet UITextField *quantityTF;
@property(nonatomic,weak) IBOutlet UIButton *mBtn;
@property(nonatomic,weak) IBOutlet UIButton *noBtn;
@property(nonatomic,weak) IBOutlet UIButton *eBtn;
@property(nonatomic,weak) IBOutlet UIButton *nBtn;
@property(nonatomic,weak) IBOutlet UITextField *doseTF;
@property(nonatomic,weak) IBOutlet UIButton *saveBtn;

@property (weak, nonatomic) IBOutlet UIView *updateView;
@property (weak, nonatomic) IBOutlet UILabel *updateLbl;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UITextView *updateTextView;
@property (weak, nonatomic) IBOutlet UILabel *updateViewTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imgViwPhoto;

@property (strong, nonatomic) NSArray *arrayReportFiles;
@property (strong, nonatomic) NSArray *arrayDoctorSuggestionFiles;
@property (strong, nonatomic) NSArray *arrayData;
@property (strong, nonatomic) NSMutableArray *arrayRequestData;
@property (strong, nonatomic) NSArray *medicationArray;

@end
