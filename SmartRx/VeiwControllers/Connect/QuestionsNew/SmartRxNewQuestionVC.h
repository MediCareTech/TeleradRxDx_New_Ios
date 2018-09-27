//
//  SmartRxNewQuestionVC.h
//  SmartRx
//
//  Created by PaceWisdom on 05/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxNewQuestionVC : UIViewController<UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,loginDelegate,UIAlertViewDelegate,ImageSelected>

@property (weak, nonatomic) IBOutlet UILabel *lblAttach;
@property (weak, nonatomic) IBOutlet UIImageView *imgViwPlus;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (strong, nonatomic) NSMutableArray *arrDoctorList;
@property (strong, nonatomic) NSMutableArray *arrDocorRefId;
@property (strong, nonatomic) NSString *strRefId;
@property (weak, nonatomic) IBOutlet UITextField *txtfldDoctor;
@property (weak, nonatomic) IBOutlet UITextField *txtFldSubject;
@property (weak, nonatomic) IBOutlet UITextView *txtViewQuestion;
@property (weak, nonatomic) IBOutlet UIImageView *imgViwPhoto;
@property (weak, nonatomic) IBOutlet UITableView *tblDoctors;
@property (weak, nonatomic) IBOutlet UILabel *lblAskQuestion;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIImageView *imgTxtView;
@property (strong, nonatomic) NSDictionary *dictDocList;
- (IBAction)browseBtnClicked:(id)sender;
- (IBAction)submitBtnClicked:(id)sender;
- (IBAction)cancelBtnClicked:(id)sender;
- (IBAction)selectDocBtnClicked:(id)sender;

@end
