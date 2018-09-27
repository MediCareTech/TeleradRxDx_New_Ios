//
//  SmartRxQuestionsNewVC.h
//  SmartRx
//
//  Created by PaceWisdom on 04/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxQuestionsPreviousVC : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,loginDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblQuestionNew;
@property (strong, nonatomic) NSArray *arrQuestions;
@property (weak, nonatomic) IBOutlet UILabel *lblNoQes;
@property (nonatomic) NSInteger numberOfQuestions;
@property (nonatomic, strong) NSString *strQuid;

@end
