//
//  SmartRxAboutUsVC.h
//  SmartRx
//
//  Created by Anil Kumar on 05/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxAboutUsVC : UIViewController<MBProgressHUDDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableAboutUs;
@property (strong, nonatomic) NSMutableArray *dictResponse;
@property (strong, nonatomic) NSMutableArray *dictResponseAbtUs;
@property (strong, nonatomic) NSMutableArray *tableCellData;
@end
