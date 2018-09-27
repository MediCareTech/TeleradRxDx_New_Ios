//
//  SmartRxGetManagedCarePlanVC.h
//  SmartRx
//
//  Created by SmartRx-iOS on 11/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SmartRxGetManagedCarePlanVC : UIViewController<MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UITableView *itemsTableView;
@property(nonatomic,weak) IBOutlet UILabel *noAppsLbl;
@property(nonatomic,weak) IBOutlet UIView *itemsSubView;

@property(nonatomic,weak) IBOutlet UIView *confirmationView;
@property(nonatomic,weak) IBOutlet UITextField *userNameTf;
@property (weak, nonatomic) IBOutlet UITextField *promoCodeText;
@property (weak, nonatomic) IBOutlet UIButton *promoApplyBtn;
@property (weak, nonatomic) IBOutlet UILabel *consultationFeeText;
@property (weak, nonatomic) IBOutlet UILabel *consultationActualCost;
@property (weak, nonatomic) IBOutlet UILabel *consultationDiscountedCost;
@property (weak, nonatomic) IBOutlet UIView *yesNoView;

@property (retain, nonatomic) UIPickerView *dependentsPickerView;
@property (strong, nonatomic) UIView *actionSheet;
@property (nonatomic, strong) UIToolbar *pickerToolbar;

@property (strong, nonatomic) NSMutableDictionary *packageResponse;
@property (retain, nonatomic) NSMutableDictionary *paymentResponseDictionary;

+ (id)sharedManagerCarePlanProgram;

@end
