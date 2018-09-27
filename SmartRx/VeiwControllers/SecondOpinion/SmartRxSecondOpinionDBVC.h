//
//  SmartRxSecondOpinionDBVC.h
//  SmartRx
//
//  Created by SmartRx-iOS on 24/04/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxSecondOpinionDBVC : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) NSString *fromVc;
@property(nonatomic,weak) IBOutlet UITableView *tableView;

@end
