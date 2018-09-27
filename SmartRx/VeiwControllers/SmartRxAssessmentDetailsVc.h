//
//  SmartRxAssessmentDetailsVc.h
//  SmartRx
//
//  Created by Gowtham on 02/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookedAssessmentsResponseModel.h"
#import "AssesmmentsQuestionResponseModel.h"

@interface SmartRxAssessmentDetailsVc : UIViewController

@property(nonatomic,strong) BookedAssessmentsResponseModel *selectedAssessment;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *noAppsLbl;

@end
