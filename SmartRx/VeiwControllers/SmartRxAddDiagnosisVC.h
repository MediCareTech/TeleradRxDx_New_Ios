//
//  SmartRxAddDiagnosisVC.h
//  CareBridge
//
//  Created by Gowtham on 09/10/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DiagnosisDelegate <NSObject>

-(void)selectedDiagnosis:(NSDictionary *)diagnosisDict;

@end
@interface SmartRxAddDiagnosisVC : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
}
@property(nonatomic,strong) NSString *fromViewController;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) UIView *actionSheet;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UITextField *diagnosisTF;
@property(nonatomic,weak) IBOutlet UILabel *observedDate;
@property(nonatomic,weak) id<DiagnosisDelegate> delegate;

@end
