//
//  LocationCell.h
//  SmartRx
//
//  Created by Gowtham on 14/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellDelegate <NSObject>

-(void)deleteButtonClicked:(NSIndexPath *)indexpath;

@end

@interface LocationCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *addressTypeLbl;
@property(nonatomic,weak) IBOutlet UILabel *addressLbl;
@property(nonatomic,weak) IBOutlet UILabel *cityLbl;
@property(nonatomic,strong) NSIndexPath *cellId;

@property(nonatomic,weak) id<CellDelegate> delegate;

-(IBAction)clckOnDeleteButton:(id)sender;
@end
