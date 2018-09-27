//
//  SmartRxAddFamilyHistoryVC.h
//  CareBridge
//
//  Created by Gowtham on 09/10/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, TableViewTtype) {
    RelationshiptableView,
    ConditionTableView,
    
};
@interface SmartRxAddFamilyHistoryVC : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
}
@property(nonatomic,assign) TableViewTtype tableViewType;

@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) UIView *actionSheet;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UITextField *ageTF;
@property(nonatomic,weak) IBOutlet UILabel *relationshipLbl;
@property(nonatomic,weak) IBOutlet UILabel *conditionLbl;
@property(nonatomic,weak) IBOutlet UIButton *aliveBtn;

@end
