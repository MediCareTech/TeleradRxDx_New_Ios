//
//  SmartRxServiceDetailCell.h
//  SmartRx
//
//  Created by Gowtham on 22/08/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ImageDisplayDelegate <NSObject>

@optional
-(void)showImage:(NSString *)imagePath;
-(void)openQrlImage:(NSString *)fileUrl;

@end
@interface SmartRxServiceDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *requestData;
@property (weak, nonatomic) IBOutlet UILabel *requestPostedBy;
@property (weak, nonatomic) IBOutlet UILabel *imagePath;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;
@property (weak, nonatomic) IBOutlet UIView *dividerLine;

@property (weak, nonatomic) id <ImageDisplayDelegate> imgDelagate;

@property(nonatomic,strong) NSArray *arrImages;
- (void)setCellData:(NSArray *)arrayRequestData row:(NSInteger)rowIndex;

-(IBAction)clickOnViewButton:(id)sender;
-(IBAction)clickOnDownloadButton:(id)sender;
@end
