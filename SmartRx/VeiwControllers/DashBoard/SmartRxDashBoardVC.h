//
//  SmartRxDashBoardVC.h
//  SmartRx
//
//  Created by PaceWisdom on 08/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIImagePager.h"

@interface SmartRxDashBoardVC : UIViewController<MBProgressHUDDelegate,UIAlertViewDelegate,loginDelegate, UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, KIImagePagerDelegate, KIImagePagerDataSource>
@property (weak, nonatomic) IBOutlet KIImagePager *imagePager;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIImageView *divider;
@property (strong, nonatomic) NSArray *arrMsgs;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnEmergency;
@property (weak, nonatomic) IBOutlet UIButton *btnMyRecords;
@property (weak, nonatomic) IBOutlet UIButton *btnMessages;
@property (weak, nonatomic) IBOutlet UIButton *btnHospitalSer;
@property (weak, nonatomic) IBOutlet UIButton *btnAppointments;
@property (weak, nonatomic) IBOutlet UIButton *btnCarePlans;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblMsgs;
@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblAppCount;
@property (weak, nonatomic) IBOutlet UIImageView *imgViwKeyLogin;
@property (weak, nonatomic) IBOutlet UILabel *lblLoginTitle;
@property (nonatomic, copy) NSDictionary *titleTextAttributes;
@property (weak, nonatomic) IBOutlet UITableView *tblMenu;
@property (weak, nonatomic) IBOutlet UIView *viwMenu;
@property (weak, nonatomic) IBOutlet UIView *viewReset;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *retypePassword;
@property (weak, nonatomic) IBOutlet UIButton *resetPwdButton;
@property (weak, nonatomic) IBOutlet UIButton *termsOfUseAgreeBtn;
@property (strong, nonatomic) NSArray *arrMenu;
@property (strong, nonatomic) NSArray *arrMenuImages;
@property (readwrite, nonatomic) NSInteger acceptAgreement;
@property (weak, nonatomic) IBOutlet UIView *termOfUseSelectedView;
@property (weak, nonatomic) IBOutlet UIView *privacySelectedView;
@property (weak, nonatomic) IBOutlet UIView *disclaimerSelectedView;
@property (weak, nonatomic) IBOutlet UIButton *termOfUseBtn;
@property (weak, nonatomic) IBOutlet UIButton *privacyBtn;
@property (weak, nonatomic) IBOutlet UIButton *disclaimerBtn;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *termsOfUseView;
@property (assign, nonatomic) NSString *strTitle;
@property (nonatomic) NSInteger numberOfMsgs;
@property (weak, nonatomic) IBOutlet UIView *viwCallCareTeam;
@property (strong, nonatomic) NSMutableArray *arrCallCareTeam;
@property (weak, nonatomic) IBOutlet UITableView *tblCallCareTeam;
@property (weak, nonatomic) IBOutlet UIImageView *imgBackMsgLbl;

- (IBAction)callCareCancelBtnClicked:(id)sender;
- (IBAction)emergencyBtnClicked:(id)sender;
- (IBAction)termsOfUseBtnClicked:(id)sender;
- (IBAction)privacyBtnClicked:(id)sender;
- (IBAction)disclaimerBtnClicked:(id)sender;
- (IBAction)agreeBtnClicked:(id)sender;
- (IBAction)hideMenuBtnClicked:(id)sender;
- (IBAction)menuBtnClicked:(id)sender;
- (IBAction)connectBtnClicked:(id)sender;
- (IBAction)carePlansBtnClicked:(id)sender;
- (IBAction)appointmentsBtnClicked:(id)sender;
- (IBAction)hsBtnClicked:(id)sender;
- (IBAction)messagesBtnClicked:(id)sender;
- (IBAction)myRecordsBtnClicked:(id)sender;
- (IBAction)loginBtnClicked:(id)sender;


- (IBAction)profileBtnClicked:(id)sender;
- (IBAction)resetPwdClicked:(id)sender;
- (IBAction)resetPwdCancelClicked:(id)sender;


@end
