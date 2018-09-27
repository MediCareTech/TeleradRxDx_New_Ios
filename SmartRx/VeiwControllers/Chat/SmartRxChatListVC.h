//
//  SmartRxChatListVC.h
//  SmartRx
//
//  Created by SmartRx-iOS on 21/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxChatListVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *noAppsLbl;
@property(nonatomic,weak) IBOutlet UIView *floatingView;
@end
