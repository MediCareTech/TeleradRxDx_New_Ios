//
//  SmartRxTipsDetailVC.h
//  SmartRx
//
//  Created by SmartRx-iOS on 18/04/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxTipsDetailVC : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)  NSDictionary *selectedTip;

@property(nonatomic,weak) IBOutlet UITableView *tableView;


@end
