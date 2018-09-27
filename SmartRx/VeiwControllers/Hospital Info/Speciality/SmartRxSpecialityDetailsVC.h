//
//  SmartRxSpecialityDetailsVC.h
//  SmartRx
//
//  Created by PaceWisdom on 23/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxSpecialityDetailsVC : UIViewController
@property (nonatomic,assign) NSString *strDescription;
@property (weak, nonatomic) IBOutlet UIWebView *webViewDescription;

@end
