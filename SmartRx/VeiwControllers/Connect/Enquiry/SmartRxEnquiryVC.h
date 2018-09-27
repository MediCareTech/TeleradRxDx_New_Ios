//
//  SmartRxEnquiryVC.h
//  SmartRx
//
//  Created by PaceWisdom on 11/07/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxEnquiryVC : UIViewController<UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate,UIAlertViewDelegate,ImageSelected,loginDelegate,UITableViewDataSource,UITableViewDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIImageView *imgViwPlus;
@property (weak, nonatomic) IBOutlet UIImageView *imgPencial;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (weak, nonatomic) IBOutlet UIButton *btnAttachImag;
@property (weak, nonatomic) IBOutlet UITextField *txtFldTitle;
@property (weak, nonatomic) IBOutlet UITextView *txtViewFeedback;
@property (weak, nonatomic) IBOutlet UITextField *txtFldAddFile;
@property (weak, nonatomic) IBOutlet UITextField *txtSelectype;
@property (weak, nonatomic) IBOutlet UIButton *btnBrowse;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UITableView *tblEnquiryTypes;
@property (weak, nonatomic) IBOutlet UIButton *imgPlus;
@property (weak, nonatomic) IBOutlet UILabel *lblAttach;
@property (strong, nonatomic) NSArray *arrEnquiryTypes;
@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UITextField *textMobile;

- (IBAction)submitBtnClicked:(id)sender;
- (IBAction)attachImageBtnClicked:(id)sender;
- (IBAction)titleBtnClicked:(id)sender;
- (IBAction)hideKeyboardBtnClicked:(id)sender;
@end
