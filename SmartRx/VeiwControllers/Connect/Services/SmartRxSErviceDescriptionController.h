//
//  SmartRxSErviceDescriptionController.h
//  SmartRx
//
//  Created by Gowtham on 05/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookedServiceResponseModel.h"

@protocol ButtonDelegate <NSObject>


-(void)submitButtonClicked:(BookedServiceResponseModel *)model;

@end

@interface SmartRxSErviceDescriptionController : UIViewController

@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,weak) id<ButtonDelegate> buttonDelegate;

@property(nonatomic,strong) BookedServiceResponseModel *selectedService;



@end
