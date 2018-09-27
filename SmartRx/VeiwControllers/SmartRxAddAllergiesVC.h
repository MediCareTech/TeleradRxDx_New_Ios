//
//  SmartRxAddAllergiesVC.h
//  CareBridge
//
//  Created by Gowtham on 09/10/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AllergyDelegate <NSObject>

-(void)selectedAllergy:(NSDictionary *)allergyDict;

@end

typedef NS_ENUM(NSUInteger, TableViewTtype) {
    AllergentableView,
    ReactionTableView,
    SeverityTableView,

};
@interface SmartRxAddAllergiesVC : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

{
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
}
@property(nonatomic,assign) TableViewTtype tableViewType;
@property(nonatomic,strong) NSString *fromViewController;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) UIView *actionSheet;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UITextField *descriptionTF;
@property(nonatomic,weak) IBOutlet UILabel *allergenLbl;
@property(nonatomic,weak) IBOutlet UILabel *severirtyLbl;
@property(nonatomic,weak) IBOutlet UILabel *reactionLbl;
@property(nonatomic,weak) IBOutlet UILabel *startDate;
@property(nonatomic,weak) IBOutlet UILabel *endDate;
@property(nonatomic,weak) id<AllergyDelegate> delegate;
@end
