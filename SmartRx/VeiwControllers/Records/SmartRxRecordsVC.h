//
//  SmartRxRecordsVC.h
//  SmartRx
//
//  Created by PaceWisdom on 08/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxCommonClass.h"
#import "SmartRxReportsListCell.h"

@interface SmartRxRecordsVC : UIViewController<UITableViewDataSource,UITableViewDelegate,loginDelegate,MBProgressHUDDelegate,CellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblRecords;
@property (strong, nonatomic) NSArray *arrRecords, *arrRecordId;
@property (strong, nonatomic) NSMutableArray *arrEstimatedHeight, *arrSerialized;
@property (strong, nonatomic) NSMutableDictionary * dicSerialized;
@property(nonatomic,strong) NSArray *recordsArray;

@property (nonatomic, strong) NSString *pdfPath;
@property (weak, nonatomic) IBOutlet UIButton *btnReports;
@property (weak, nonatomic) IBOutlet UIButton *btnPHR;
@property (weak, nonatomic) IBOutlet UIButton *btnOther;
@property (weak, nonatomic) IBOutlet UILabel *lblNoRecords;
- (IBAction)otherBtnClicked:(id)sender;
- (IBAction)phrBtnClicked:(id)sender;
- (IBAction)reportBtnClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;

@end
