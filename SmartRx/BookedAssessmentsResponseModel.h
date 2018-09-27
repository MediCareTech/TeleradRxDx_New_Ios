//
//  BookedAssessmentsResponseModel.h
//  SmartRx
//
//  Created by Gowtham on 02/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookedAssessmentsResponseModel : NSObject
@property(nonatomic,strong) NSString *assessmentName;
@property(nonatomic,strong) NSString *date;
@property(nonatomic,strong) NSString *sharedNotes;
@property(nonatomic,strong) NSArray *questions;

@end
