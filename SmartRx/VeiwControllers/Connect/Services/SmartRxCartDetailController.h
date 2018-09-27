//
//  SmartRxCartDetailController.h
//  SmartRx
//
//  Created by Gowtham on 14/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ServicesResponseModel.h"


@protocol CancelButtonDelegate <NSObject>

-(void)hideTheDetailView;

@end


@interface SmartRxCartDetailController : UIViewController

@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,weak) IBOutlet UIView *view1;


@property(nonatomic,weak) id<CancelButtonDelegate> buttonDelegate;

-(void)reloadTableView:(ServicesResponseModel *)selectedModel;

-(IBAction)clickOnCancelButton:(id)sender;

@end
