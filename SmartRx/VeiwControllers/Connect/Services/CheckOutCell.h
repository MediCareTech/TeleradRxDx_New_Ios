//
//  CheckOutCell.h
//  SmartRx
//
//  Created by Gowtham on 20/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellDelegate <NSObject>

-(void)deleteButtonClicked:(NSIndexPath *)indexpath;

@end

@interface CheckOutCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UIView *backgroundCardView;
@property(nonatomic,weak) IBOutlet UILabel *serviceNameLbl;
@property(nonatomic,weak) IBOutlet UILabel *timeLbl;
@property(nonatomic,weak) IBOutlet UILabel *dateLbl;
@property(nonatomic,weak) IBOutlet UILabel *providerNameLbl;
@property(nonatomic,weak) IBOutlet UILabel *priceLbl;
@property(nonatomic,weak) IBOutlet UILabel *timeTxtLbl;


@property(nonatomic,strong) NSIndexPath *cellId;
@property(nonatomic,weak) id<CellDelegate> delegate;

-(IBAction)clickOnDeleteButton:(id)sender;
@end
