//
//  SmartRxAddSymptomsVC.h
//  CareBridge
//
//  Created by Gowtham on 09/10/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxAddSymptomsVC : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
}
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) UIView *actionSheet;
@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,weak) IBOutlet UITextField *symptomNameTF;
@property(nonatomic,weak) IBOutlet UILabel *observedDate;
@end
