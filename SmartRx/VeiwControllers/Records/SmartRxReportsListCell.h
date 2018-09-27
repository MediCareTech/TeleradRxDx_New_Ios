//
//  SmartRxReportsListCell.h
//  SmartRx
//
//  Created by Gowtham on 11/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellDelegate <NSObject>

-(void)clickOnImageButton:(NSIndexPath *)indexpath;

@end

@interface SmartRxReportsListCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *reportTypeLabel;
@property(nonatomic,weak) IBOutlet UILabel *descriptionLabel;
@property(nonatomic,weak) IBOutlet UILabel *addedByLabel;
@property(nonatomic,weak) IBOutlet UILabel *dateLabel;
@property(nonatomic,weak) IBOutlet UIButton *imageButton;
@property(nonatomic,strong) NSIndexPath *cellId;

@property(nonatomic,weak) id <CellDelegate> delagte;

-(IBAction)clickOnImageButton:(id)sender;

@end
