//
//  SmartRxAddHealthIssuesVC.h
//  CareBridge
//
//  Created by Gowtham on 09/10/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxAddHealthIssuesVC : UIViewController
{
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
}
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) UIView *actionSheet;
@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,weak) IBOutlet UITextField *healthIssueTF;
@property(nonatomic,weak) IBOutlet UILabel *startDateLbl;
@property(nonatomic,weak) IBOutlet UILabel *endDateLbl;
@end
