//
//  SmartRxGetCarePlanVC.h
//  SmartRx
//
//  Created by Manju Basha on 25/05/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxTextFieldLeftImage.h"
@interface SmartRxGetCarePlanVC : UIViewController<UITableViewDelegate,UITableViewDataSource,loginDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
- (IBAction)topcarePlansClicked:(id)sender;
@property (weak, nonatomic)IBOutlet UIButton *topTenCarePlanBtn;
@property (weak, nonatomic)IBOutlet UITextField *searchField;
@property (weak, nonatomic)IBOutlet UILabel *noMatchLabel;
@property (weak, nonatomic)IBOutlet UILabel *orLabel;
@property (weak, nonatomic)IBOutlet UILabel *topOrLabel;
@property (weak, nonatomic) IBOutlet UITableView *careplanTableView;
@property (strong, nonatomic) IBOutlet UIImageView *closeImage;
@property (weak, nonatomic) IBOutlet UIView *userDetailView;
@property (weak, nonatomic) IBOutlet UIView *NextBtnView;
@property (weak, nonatomic) IBOutlet SmartRxTextFieldLeftImage *userNameText;
@property (weak, nonatomic) IBOutlet SmartRxTextFieldLeftImage *userMobileText;
@property (weak, nonatomic) IBOutlet SmartRxTextFieldLeftImage *userEmailText;
@property (weak, nonatomic) IBOutlet UILabel *carePlanCostText;
@property (weak, nonatomic) IBOutlet UILabel *carePlanActualCost;
@property (weak, nonatomic) IBOutlet UILabel *carePlanDiscountedCost;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (retain, nonatomic) NSMutableDictionary *paymentResponseDictionary;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *promoCodeText;
@property (weak, nonatomic) IBOutlet UIButton *promoApplyBtn;
- (IBAction)nextButtonClicked:(id)sender;
- (IBAction)promoApplyBtnClicked:(id)sender;
+ (id)sharedGetCarePlanVC;
@end
