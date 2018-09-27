//
//  SmartRxMedicationVC.h
//  CareBridge
//
//  Created by Gowtham on 09/10/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MedicationDelegate <NSObject>

-(void)selectedMedication:(NSDictionary *)medicationDict;

@end
@interface SmartRxMedicationVC : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
}
@property(nonatomic,strong) NSString *fromViewController;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) UIView *actionSheet;
@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,weak) IBOutlet UITextField *drugNameTF;
@property(nonatomic,weak) IBOutlet UITextField *quantityTF;
@property(nonatomic,weak) IBOutlet UIButton *mBtn;
@property(nonatomic,weak) IBOutlet UIButton *noBtn;
@property(nonatomic,weak) IBOutlet UIButton *eBtn;
@property(nonatomic,weak) IBOutlet UIButton *nBtn;
@property(nonatomic,weak) IBOutlet UITextField *daysTF;
@property(nonatomic,weak) IBOutlet UILabel *startDate;
@property(nonatomic,weak) IBOutlet UILabel *endDate;
@property(nonatomic,weak) id<MedicationDelegate> delegate;

@end
