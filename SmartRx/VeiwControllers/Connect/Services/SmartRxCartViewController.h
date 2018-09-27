//
//  SmartRxCartViewController.h
//  SmartRx
//
//  Created by Gowtham on 13/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxCartDetailController.h"

typedef NS_ENUM(NSUInteger, TableView) {
    TimeSlotsTable,
    LocationTable,
};


@interface SmartRxCartViewController : UIViewController<CancelButtonDelegate,MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
}

@property(nonatomic,assign) TableView tableViewType;

@property(nonatomic,weak) IBOutlet UIImageView *serviceTypeImage;
@property(nonatomic,weak) IBOutlet UILabel *serviceName;
@property(nonatomic,weak) IBOutlet UILabel *providerName;

@property(nonatomic,weak) IBOutlet UILabel *dicountPriceLbl;
@property(nonatomic,weak) IBOutlet UILabel *originalPriceLbl;
@property(nonatomic,weak) IBOutlet UIButton *checkOutBtn;

@property(nonatomic,weak) IBOutlet UILabel *descrptionLbl;
@property(nonatomic,weak) IBOutlet UILabel *typeLbl;
@property(nonatomic,weak) IBOutlet UILabel *freeTextType;
@property(nonatomic,weak) IBOutlet UIButton *addToCartBtn;

@property(nonatomic,weak) IBOutlet UILabel *locationType;
@property(nonatomic,weak) IBOutlet UIButton *addNewAddressBtn;
@property(nonatomic,weak) IBOutlet UITextField *locationTF;

@property(nonatomic,weak) IBOutlet UITextField *dateTF;
@property(nonatomic,weak) IBOutlet UITextField *timeTF;
@property(nonatomic,weak) IBOutlet UIView *subView;

@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UIButton *dateButton;
@property(nonatomic,weak) IBOutlet UIButton *timeButton;

@property(nonatomic,weak) IBOutlet UIImageView *dateImage;
@property(nonatomic,weak) IBOutlet UIImageView *timeImage;
@property(nonatomic,weak) IBOutlet UIImageView *dateBackgroundImage;
@property(nonatomic,weak) IBOutlet UIImageView *timeBackgroundImage;


@property(nonatomic,weak) IBOutlet UIView *detailContainerView;

@property(nonatomic,strong) ServicesResponseModel *selectedService;
@property(nonatomic,strong) SmartRxCartDetailController *detailController;


@property (strong, nonatomic) UIDatePicker *datePickerView;


@end
