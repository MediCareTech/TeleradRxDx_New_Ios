//
//  SmartRxAccountPickerVC.h
//  SmartRx
//
//  Created by Manju Basha on 11/05/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxAccountPickerVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *accountTable;
@property (strong, nonatomic) NSMutableArray *responseDict;
@end
