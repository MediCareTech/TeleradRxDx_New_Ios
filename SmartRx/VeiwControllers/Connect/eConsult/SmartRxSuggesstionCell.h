//
//  SmartRxSuggesstionCell.h
//  SmartRx
//
//  Created by Manju Basha on 25/04/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowImageInMainView <NSObject>

@optional
-(void)ShowImageInMainView:(NSString *)imagePath;
-(void)openQlPreview:(NSString *)fileUrl;

@end


@interface SmartRxSuggesstionCell : UITableViewCell
@property (retain, nonatomic) NSArray *arrImages;
@property (weak, nonatomic) IBOutlet UILabel *suggestionImageName;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (assign, nonatomic) NSInteger startCountForCell;
@property (weak, nonatomic) NSArray *imageArr;
@property (weak, nonatomic) id <ShowImageInMainView> delegateImg;

- (void)setCellData:(NSArray *)arrAppDetails row:(NSInteger)rowIndex;
- (IBAction)viewBtnClicked:(id)sender;
- (IBAction)downloadBtnClicked:(id)sender;

@end
