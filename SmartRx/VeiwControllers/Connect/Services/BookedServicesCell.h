//
//  BookedServicesCell.h
//  SmartRx
//
//  Created by Gowtham on 05/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellDelegate <NSObject>

-(void)detailButtonClicked:(NSIndexPath *)indexpath;

@end


@interface BookedServicesCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UIView *backgroundCardView;
@property(nonatomic,weak) IBOutlet UILabel *serviceNameLbl;
@property(nonatomic,weak) IBOutlet UILabel *timeLbl;
@property(nonatomic,weak) IBOutlet UILabel *dateTextLbl;
@property(nonatomic,weak) IBOutlet UILabel *timeTextLbl;
@property(nonatomic,weak) IBOutlet UILabel *dateLbl;
@property(nonatomic,weak) IBOutlet UILabel *statusLbl;
@property(nonatomic,weak) IBOutlet UILabel *paymentTypeLbl;
@property(nonatomic,weak) IBOutlet UIButton *detailsButton;

@property(nonatomic,strong) NSIndexPath *cellId;
@property(nonatomic,weak) id<CellDelegate> delegate;

-(IBAction)clickOnDetailsButton:(id)sender;
@end
