//
//  SmartRxBookServiceCell.h
//  SmartRx
//
//  Created by Gowtham on 12/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServicesResponseModel.h"
@protocol CellDelegate <NSObject>

-(void)cellSubmitButtonClicked:(NSIndexPath *)inddexPath;

@end


@interface SmartRxBookServiceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;

@property (weak, nonatomic) IBOutlet UIImageView *serviceTypeImage;

@property (weak, nonatomic) IBOutlet UILabel *serviceName;
@property (weak, nonatomic) IBOutlet UILabel *serviceOriginalPrice;
@property (weak, nonatomic) IBOutlet UILabel *serviceDiscountedPrice;
@property (weak, nonatomic) IBOutlet UILabel *serviceDescription;
@property (weak, nonatomic) IBOutlet UILabel *providerName;
@property(nonatomic,strong) NSIndexPath *cellId;

@property(nonatomic,strong) ServicesResponseModel *service;
@property(nonatomic,assign) id<CellDelegate> cellDelegate;

-(IBAction)clickOnSelectButton:(id)sender;

@end
