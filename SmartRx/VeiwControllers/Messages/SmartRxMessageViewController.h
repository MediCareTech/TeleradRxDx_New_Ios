//
//  SmartRxMessageViewController.h
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxCommonClass.h"
#import "SWTableViewCell.h"
#import "SmartRxMessageTVC.h"
@interface SmartRxMessageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,loginDelegate,MBProgressHUDDelegate, SWTableViewCellDelegate,swipeCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tblMessages;
@property (strong, nonatomic) NSMutableDictionary *dstMsgDetails;
@property (strong, nonatomic) NSArray *arrMsgDetails;
@property (strong, nonatomic) IBOutlet UIButton *btnMoreMsgs;
@property (strong, nonatomic) IBOutlet UILabel *lblmsgs;
@property (readwrite, nonatomic) BOOL fromDetails;
@property (nonatomic) NSInteger numberOfMsgs;
@property (nonatomic, assign) NSString *strLastMsgId;
- (IBAction)moreMsgBtnClicked:(id)sender;


@end
