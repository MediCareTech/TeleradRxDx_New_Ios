//
//  ReportsResponseModel.h
//  SmartRx
//
//  Created by Gowtham on 11/07/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportsResponseModel : NSObject
@property(nonatomic,strong) NSString *date;
@property(nonatomic,strong) NSString *reportDescrption;
@property(nonatomic,strong) NSString *imagePath;
@property(nonatomic,strong) NSString *uploadedBy;
@property(nonatomic,strong) NSString *category;
@end
