//
//  GetCarePlanDetailsResponseModel.h
//  SmartRx
//
//  Created by SmartRx-iOS on 16/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetCarePlanDetailsResponseModel : NSObject

@property(nonatomic,strong) NSString *CareProgramProperty;
@property(nonatomic,strong) NSAttributedString *attributedCareProgram;
@property(nonatomic,strong) NSString *gold;
@property(nonatomic,strong) NSString *silver;
@property(nonatomic,strong) NSString *platinum;

@property(nonatomic,strong) NSString *quantity;


@end
