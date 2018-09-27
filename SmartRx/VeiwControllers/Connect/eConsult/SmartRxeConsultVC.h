//
//  SmartRxeConsultVC.h
//  SmartRx
//
//  Created by Anil Kumar on 11/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSLCalendarView.h"

@interface SmartRxeConsultVC : UIViewController<UITableViewDataSource,UITableViewDelegate,loginDelegate,MBProgressHUDDelegate,UIAlertViewDelegate, UIWebViewDelegate>

//<DSLCalendarViewDelegate, MBProgressHUDDelegate>

@property(nonatomic,strong) NSString *scheduleType;

@property (nonatomic, weak) IBOutlet DSLCalendarView *calendarView;
@property (strong, nonatomic) NSMutableArray *arr_eConsult;
@property (weak, nonatomic) IBOutlet UITableView *tableConsult;
@property (weak, nonatomic) IBOutlet UIView *viwInfo;
@property (weak, nonatomic) IBOutlet UIWebView *infoWebView;
@property (weak, nonatomic) IBOutlet UILabel *lblNoApps;
@property (readwrite, nonatomic) BOOL fromFindDoctorsORDashboard;
@property (weak, nonatomic) IBOutlet UIView *bookeConsultView;
- (IBAction)bookEconsultClicked:(id)sender;
- (IBAction)okayInfoClicked:(id)sender;
@end
