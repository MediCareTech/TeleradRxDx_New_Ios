//
//  SmartRxImageTVC.h
//  SmartRx
//
//  Created by Pace on 15/07/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowImageInMainView <NSObject>

@optional
-(void)ShowImageInMainView:(NSString *)imagePath;
-(void)openQlPreview:(NSString *)fileUrl;

@end


@interface SmartRxImageTVC : UITableViewCell

@property (assign, nonatomic) NSInteger startCountForCell;
@property (weak, nonatomic) NSArray *imageArr;
@property (weak, nonatomic) id <ShowImageInMainView> delegateImg;

-(void)setImageToData:(NSArray *)arrImages startCount:(NSInteger)imageCount imgType:(BOOL)QA;
- (IBAction)imageBtnClicked:(id)sender;


@end
