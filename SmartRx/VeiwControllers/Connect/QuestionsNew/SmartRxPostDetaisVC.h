//
//  SmartRxPostDetaisVC.h
//  SmartRx
//
//  Created by PaceWisdom on 05/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxPostDetaisVC : UIViewController<UIActionSheetDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,MBProgressHUDDelegate,loginDelegate,ImageSelected>

@property (strong, nonatomic) NSString *strRating;
@property (strong, nonatomic) NSDictionary *dictMsgDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UITextView *txtViewReply;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnPostReply;
@property (weak, nonatomic) IBOutlet UIButton *btnMark;
@property (weak, nonatomic) IBOutletCollection(UIButton) NSArray *btnRating;
@property (weak, nonatomic) IBOutlet UILabel *lblAttach;
@property (weak, nonatomic) IBOutlet UIImageView *imgViwPlus;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (weak, nonatomic) IBOutlet UITextView *txtviwComments;
@property (weak, nonatomic) IBOutlet UIView *viwRatings;
- (IBAction)browseBtnClicked:(id)sender;
- (IBAction)submitButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)markBtnClicked:(id)sender;
- (IBAction)ratingBtnClicked:(id)sender;
- (IBAction)dismisKeybordBtnClicked:(id)sender;
@end
