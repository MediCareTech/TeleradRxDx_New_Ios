//
//  SmartRxServicesDetails.h
//  SmartRx
//
//  Created by Manju Basha on 19/10/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HMSegmentedControl.h"
#import "BookedServiceResponseModel.h"
#import "SmartRxServiceRequesCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SmartRxServicesDetails : UIViewController<UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,loginDelegate,UIAlertViewDelegate,ImageSelected, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate,ImageDisplayDelegate>
@property(nonatomic,strong)BookedServiceResponseModel *selectedService;
@property (strong, nonatomic) NSMutableDictionary *dictResponse;
@property (weak, nonatomic) IBOutlet UIImageView *serviceImage;
@property (weak, nonatomic) IBOutlet UIImageView *dateImage;
@property (weak, nonatomic) IBOutlet UILabel *packageName;
@property (weak, nonatomic) IBOutlet UILabel *serviceStatus;
@property (weak, nonatomic) IBOutlet UILabel *paymentStatus;
@property (weak, nonatomic) IBOutlet UILabel *servicesFee;
@property (weak, nonatomic) IBOutlet UILabel *servicesDateTime;
@property (weak, nonatomic) IBOutlet UILabel *priceLbl;


@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl4;

@property (retain, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) NSString *pdfPath;
@property (assign, nonatomic) NSString *strTitle;
@property (strong, nonatomic) UIView *currentView;

@property (retain, nonatomic) IBOutlet UIScrollView *suggestionScroll;
@property (weak, nonatomic) IBOutlet UIView *suggestionViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *suggestionContent;
@property (weak, nonatomic) IBOutlet UILabel *suggestionContentLabel;
@property (weak, nonatomic) IBOutlet UITableView *suggestionContentTable;

@property (weak, nonatomic) IBOutlet UIView *requestViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *requestContent;
@property (weak, nonatomic) IBOutlet UITableView *requestContentTable;

@property (strong, nonatomic) NSArray *arrayReportFiles;
@property (strong, nonatomic) NSArray *arrayDoctorSuggestionFiles;
@property (strong, nonatomic) NSArray *arrayData;
@property (strong, nonatomic) NSMutableArray *arrayRequestData;

@property (weak, nonatomic) IBOutlet UIView *updateView;
@property (weak, nonatomic) IBOutlet UILabel *updateLbl;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *filePath;
@property (weak, nonatomic) IBOutlet UITextView *updateTextView;
@property (weak, nonatomic) IBOutlet UILabel *updateViewTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imgViwPhoto;



+ (id)sharedManager;

- (IBAction)cancelBtnClicked:(id)sender;
- (IBAction)updateBtnClicked:(id)sender;
- (IBAction)suggestionBtnClicked:(id)sender;
- (IBAction)suggesstionEditClicked:(id)sender;
- (IBAction)requestBtnClicked:(id)sender;
- (IBAction)requestAddClicked:(id)sender;
-(IBAction)addFileButtonClicked:(id)sender;
@end
