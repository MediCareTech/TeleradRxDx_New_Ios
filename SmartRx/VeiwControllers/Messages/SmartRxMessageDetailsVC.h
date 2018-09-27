//
//  SmartRxMessageDetailsVC.h
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxMessageDetailsVC : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imgMessage;
@property (strong, nonatomic) IBOutlet UILabel *lblSenderName;
@property (strong, nonatomic) IBOutlet UILabel *lblMessage;
@property (strong, nonatomic) IBOutlet UILabel *lblDateTime;
@property (strong, nonatomic) IBOutlet UIButton *indexZeroBtn;
@property (strong, nonatomic) IBOutlet UIButton *indexOneBtn;
@property (nonatomic, assign) NSString *strMessage;
@property (nonatomic, strong) NSDictionary *dictMsgDetails;

- (IBAction)indexZeroBtnClicked:(id)sender;
- (IBAction)indexOneBtnClicked:(id)sender;
@end
