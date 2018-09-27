//
//  SmartRxEHRVC.h
//  CareBridge
//
//  Created by Gowtham on 27/07/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxEHRVC : UIViewController<UITableViewDataSource,UITableViewDelegate,loginDelegate>
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *ehrArray;
@property (nonatomic, retain) NSArray *ehrImages;
@property (nonatomic, retain) NSArray *ehrDetailsArray;


@end
