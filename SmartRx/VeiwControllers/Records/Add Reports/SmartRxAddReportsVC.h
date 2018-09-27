//
//  SmartRxAddReportsVC.h
//  SmartRx
//
//  Created by PaceWisdom on 08/07/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxAddReportsVC : UIViewController<UITextFieldDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,loginDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,loginDelegate,ImageSelected,MBProgressHUDDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnCategory;
@property (weak, nonatomic) IBOutlet UITextField *txtCategory;
@property (weak, nonatomic) IBOutlet UITextView *txtViwDes;
@property (weak, nonatomic) IBOutlet UIImageView *imgReport;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlus;
@property (weak, nonatomic) IBOutlet UIButton *btnAddImage;
@property (weak, nonatomic) IBOutlet UILabel *lblAttachImag;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UITableView *tblCategory;
@property (strong, nonatomic) IBOutlet NSDictionary *dictCategory;
- (IBAction)addImageBtnClicked:(id)sender;
- (IBAction)addBtnClicked:(id)sender;
- (IBAction)categoryBtnClicked:(id)sender;
- (IBAction)hideKeyboardBtnClicked:(id)sender;
- (IBAction)selectCatBtnClicked:(id)sender;

@end
