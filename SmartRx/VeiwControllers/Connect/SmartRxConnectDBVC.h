//
//  SmartRxConnectDBVC.h
//  SmartRx
//
//  Created by PaceWisdom on 09/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxConnectDBVC : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *btnFeedback;
@property (strong, nonatomic) IBOutlet UIButton *btnInquiry;
@property (strong, nonatomic) IBOutlet UIButton *btnQPrevious;
@property (strong, nonatomic) IBOutlet UIButton *btnQNew;
@property (strong, nonatomic) NSString *strQuid;
@property (nonatomic) NSInteger numberOfQustns;

- (IBAction)feedbackBtnClicked:(id)sender;
- (IBAction)inquiryBtnClicked:(id)sender;
- (IBAction)previousQBtnClicked:(id)sender;
- (IBAction)newQBtnClicked:(id)sender;
- (IBAction)callBackBtnClicked:(id)sender;
- (IBAction)contctUsbtnClicked:(id)sender;
@end
