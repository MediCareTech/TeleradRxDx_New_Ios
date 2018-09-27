//
//  SmartRxEconsultSpecialityVC.h
//  SmartRx
//
//  Created by Manju Basha on 25/03/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxEconsultSpecialityVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *specialityButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *eConsultMethodBtn;
- (IBAction)specialityButtonClicked:(id)sender;
- (IBAction)dateButtonClicked:(id)sender;
- (IBAction)timeButtonClicked:(id)sender;
- (IBAction)eConsultMethodBtnClicked:(id)sender;
@end
