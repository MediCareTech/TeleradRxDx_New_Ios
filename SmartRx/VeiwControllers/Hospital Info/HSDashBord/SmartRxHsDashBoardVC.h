//
//  SmartRxHsDashBoardVC.h
//  SmartRx
//
//  Created by PaceWisdom on 09/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxHsDashBoardVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btnIP;
@property (weak, nonatomic) IBOutlet UIButton *btnHS;
@property (weak, nonatomic) IBOutlet UIButton *btnFindDoctors;
@property (weak, nonatomic) IBOutlet UIButton *btnFeedback;
@property (weak, nonatomic) IBOutlet UIButton *btnInquiry;
- (IBAction)inquiryBtnClicked:(id)sender;
- (IBAction)findDoctorsBtnClicked:(id)sender;
- (IBAction)specilalitiesBtnClicked:(id)sender;
- (IBAction)ipBtnClicked:(id)sender;
- (IBAction)contctUsbtnClicked:(id)sender;
- (IBAction)feedbackBtnClicked:(id)sender;
- (IBAction)servicesClicked:(id)sender;
- (IBAction)aboutUsClicked:(id)sender;
@end
