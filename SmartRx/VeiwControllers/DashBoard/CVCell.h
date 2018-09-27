//
//  CVCell.h
//  CollectionViewExample
//
//  Created by Manju Basha on 06/07/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UIImageView *backGrndImage;
@property (strong, nonatomic) IBOutlet UIImageView *tileImg;
@property (strong, nonatomic) IBOutlet UIButton *msgCount;
@end
