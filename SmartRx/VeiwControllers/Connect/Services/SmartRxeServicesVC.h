//
//  SmartRxeServicesVC.h
//  SmartRx
//
//  Created by Manju Basha on 19/10/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxeServicesVC : UIViewController<UITableViewDataSource,UITableViewDelegate,loginDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableServicesList;
@property (weak, nonatomic) IBOutlet UILabel *lblNoServ;
@property (readwrite, nonatomic) BOOL fromFindDoctorsORDashboard;
@property (retain, nonatomic) NSMutableArray *arrServices;
@end
