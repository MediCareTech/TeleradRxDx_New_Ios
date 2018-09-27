//
//  SmartRxFindDoctorsVC.h
//  SmartRx
//
//  Created by PaceWisdom on 09/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxFindDoctorsVC : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,UIAlertViewDelegate,UISearchDisplayDelegate>
@property (strong, nonatomic) NSMutableArray *arrDoctors;
@property (retain, nonatomic) NSString *locationName, *locationId;
@property (nonatomic, assign) NSString *strSpecId;
@property (weak, nonatomic) IBOutlet UITableView *tblFindDoctors;
@property (retain, nonatomic) NSMutableArray *dictDoctorDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblNoDoctors;
@property (strong, nonatomic) NSMutableArray *dictResponse;
@property (strong, nonatomic) NSMutableDictionary *responseDictionary;
@property (strong, nonatomic) NSMutableDictionary *doctorDict;
@property (strong, nonatomic) NSMutableDictionary *searchDoctorDict;
@property (strong, nonatomic) NSMutableArray *selectSpecialityArray;
@property (strong, nonatomic) NSMutableArray *specialityArray;
@property (strong, nonatomic) NSMutableArray *deleteRowsList;
@property (nonatomic, strong) NSMutableArray *searchResult;
@end
