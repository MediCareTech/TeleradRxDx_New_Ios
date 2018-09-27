//
//  SmartRxMyLocationVC.h
//  SmartRx
//
//  Created by Gowtham on 14/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationCell.h"

@interface SmartRxMyLocationVC : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,CellDelegate>

@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *errorLabel;


@end
