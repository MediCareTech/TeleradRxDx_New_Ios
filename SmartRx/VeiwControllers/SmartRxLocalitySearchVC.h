//
//  SmartRxLocalitySearchVC.h
//  SmartRx
//
//  Created by SmartRx-iOS on 09/08/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocaltyResponseModel.h"

@protocol Localtydelegate <NSObject>

-(void)selecedLocalty:(LocaltyResponseModel *)selectedLocaltyModel
;
@end

@interface SmartRxLocalitySearchVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property(nonatomic,strong) NSArray *localtyArray;
@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,assign) id<Localtydelegate> delegate;

@end
