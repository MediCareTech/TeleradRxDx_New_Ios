//
//  SmartRxSelectDocLocation.h
//  SmartRx
//
//  Created by Anil Kumar on 14/10/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxSelectDocLocation : UIViewController<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblFindDoctorLocations;
@property (strong, nonatomic) NSArray *arrLocations;
@property (strong, nonatomic) NSMutableArray *arrLoadTbl;
@property (strong, nonatomic) NSMutableArray *arrSpeclist;
@property (strong, nonatomic) NSMutableArray *arrSpecAndDocResponse;
@property (strong, nonatomic) NSDictionary *dictResponse;
@property (readwrite, nonatomic) BOOL fromServices;
@property (readwrite, nonatomic) BOOL fromAboutUs;
@end
