//
//  GetCarePlanBuyCell.h
//  SmartRx
//
//  Created by SmartRx-iOS on 16/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellDelegate <NSObject>

-(void)silverButtonClicked:(NSIndexPath *)indexPath;
-(void)goldButtonClicked:(NSIndexPath *)indexPath;
-(void)platinumButtonClicked:(NSIndexPath *)indexPath;

@end

@interface GetCarePlanBuyCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *careProgramProperty;
@property(nonatomic,weak) IBOutlet UIButton *silverBtn;
@property(nonatomic,weak) IBOutlet UIButton *goldBtn;
@property(nonatomic,weak) IBOutlet UIButton *platinumBtn;

@property(nonatomic,strong) NSIndexPath *cellId;

@property(nonatomic,assign) id<CellDelegate> cellDelegate;

-(IBAction)clickOnSilverButton:(id)sender;
-(IBAction)clickOnGoldButton:(id)sender;
-(IBAction)clickOnPlatinumButton:(id)sender;

@end
