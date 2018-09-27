//
//  SmartRxViewController.h
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxViewController : UIViewController
- (IBAction)messageButtonClicked:(id)sender;
- (IBAction)hospitalInfoClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblMessageCount;
- (IBAction)logoutButtonClicked:(id)sender;

@end
