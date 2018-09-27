//
//  SmartRxServicesVC.h
//  SmartRx
//
//  Created by PaceWisdom on 23/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxServicesVC : UIViewController<MBProgressHUDDelegate, UITableViewDataSource, UITableViewDelegate>
@property (assign, nonatomic) NSString *strTitle;
@property (weak, nonatomic) IBOutlet UIWebView *webViewService;
@property (weak, nonatomic) IBOutlet UITableView *tableServices;
@property (strong, nonatomic) NSMutableArray *dictResponse;
@property (strong, nonatomic) NSMutableArray *arrSpecAndDocResponse;

- (void)makeRequestForServices:(NSString *)serviceId;
- (void)homeBtnClicked:(id)sender;
- (void)backBtnClicked:(id)sender;
@end
