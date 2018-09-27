//
//  SmartRxBookedServicesController.h
//  SmartRx
//
//  Created by Gowtham on 05/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookedServicesCell.h"
#import "SmartRxSErviceDescriptionController.h"

@interface SmartRxBookedServicesController : UIViewController<CellDelegate,UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,ButtonDelegate>

@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,strong) NSArray *bookedServiceArray;

@property(nonatomic,weak) IBOutlet UILabel *noServicesLabel;

@end
