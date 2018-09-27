//
//  SmartRxBookServicesController.h
//  SmartRx
//
//  Created by Gowtham on 12/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxServiceDetailController.h"
#import "SmartRxBookServiceCell.h"
#import "SmartRxFilterViewController.h"

@interface SmartRxBookServicesController : UIViewController<MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,CellDelegate,ButtonDelegate,UITextFieldDelegate,FilterDelegate,UIPickerViewDataSource,UIPickerViewDelegate>


@property(nonatomic,strong) NSString *selectedServiceId;
@property(nonatomic,strong) NSString *selectedProviderId;
@property(nonatomic,weak) IBOutlet UIImageView *searchImage;
@property(nonatomic,weak) IBOutlet UITextField *patientnameTF;
@property(nonatomic,weak) IBOutlet UITextField *searchTF;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *errorLabel;


@property(nonatomic,weak) IBOutlet UIView *detailContainerView;

@property(nonatomic,strong) SmartRxServiceDetailController *detailController;
@property (nonatomic, strong) UIToolbar *pickerToolbar;

@property (retain, nonatomic) UIPickerView *patientsPicker;
@property(nonatomic,strong) UIView *actionSheet;


@end
