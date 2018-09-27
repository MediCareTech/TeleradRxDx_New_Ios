//
//  SmartRxeConsultReportCell.h
//  SmartRx
//
//  Created by Anil Kumar on 25/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowImageInMainView <NSObject>

@optional
-(void)ShowImageInMainView:(NSString *)imagePath;
-(void)openQlPreview:(NSString *)fileUrl;

@end

@interface SmartRxeConsultReportCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSArray *arrImages;
@property (weak, nonatomic) IBOutlet UILabel *reportImageName;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (assign, nonatomic) NSInteger startCountForCell;
@property (weak, nonatomic) NSArray *imageArr;
@property (weak, nonatomic) id <ShowImageInMainView> delegateImg;

- (void)setCellData:(NSArray *)arrAppDetails row:(NSInteger)rowIndex;
- (IBAction)viewBtnClicked:(id)sender;
- (IBAction)downloadBtnClicked:(id)sender;

@end
