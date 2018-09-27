//
//  SmartRxSpecialityVC.h
//  SmartRx
//
//  Created by PaceWisdom on 23/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxCommonClass.h"

@interface SmartRxSpecialityVC : UIViewController<UITableViewDataSource,UITableViewDelegate,loginDelegate,MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblSpeciality;
@property (strong, nonatomic) NSArray *arrTitles;
@property (assign, nonatomic) NSString *strDocOrSpec;

@end
