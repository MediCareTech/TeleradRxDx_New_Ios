//
//  SmartRxServiceDetailController.h
//  SmartRx
//
//  Created by Gowtham on 13/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServicesResponseModel.h"

@protocol ButtonDelegate <NSObject>

-(void)cancelButtonClicked;

-(void)submitButtonClicked:(ServicesResponseModel *)model;

@end

@interface SmartRxServiceDetailController : UIViewController

@property(nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,weak) id<ButtonDelegate> buttonDelegate;

-(void)reloadTableView:(ServicesResponseModel *)selectedModel;

-(IBAction)clickOnCancelButton:(id)sender;
-(IBAction)clickOnSubmitButton:(id)sender;

@end
