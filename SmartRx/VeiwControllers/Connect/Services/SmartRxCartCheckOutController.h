//
//  SmartRxCartCheckOutController.h
//  SmartRx
//
//  Created by Gowtham on 20/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckOutCell.h"

@interface SmartRxCartCheckOutController : UIViewController<UITableViewDataSource,UITableViewDelegate,CellDelegate,MBProgressHUDDelegate,UITextFieldDelegate>


@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,weak) IBOutlet UITextField *promoCodeTf;
@property(nonatomic,weak) IBOutlet UIButton *payNowBtn;
@property(nonatomic,weak) IBOutlet UIButton *payLaterBtn;
@property(nonatomic,weak) IBOutlet UILabel *cartCountLbl;
@property(nonatomic,weak) IBOutlet UILabel *cartDiscountedPrice;
@property(nonatomic,weak) IBOutlet UILabel *cartOriginalPrice;
@property (weak, nonatomic) IBOutlet UIButton *promoApplyBtn;
@property (weak, nonatomic) IBOutlet UIImageView *closeImage;

@property (strong, nonatomic) NSMutableDictionary *packageResponse;
@property (retain, nonatomic) NSMutableDictionary *paymentResponseDictionary;


+ (id)sharedManagerBookServices;

@end
