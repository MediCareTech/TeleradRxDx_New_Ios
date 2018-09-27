//
//  SmartRxAssessmentQuestionsVc.h
//  SmartRx
//
//  Created by Gowtham on 23/01/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssessmentsResponseModel.h"

@interface SmartRxAssessmentQuestionsVc : UIViewController<UIWebViewDelegate>
@property(nonatomic,strong) AssessmentsResponseModel *selectedAssessment;

@property(nonatomic,weak) IBOutlet UIWebView *webView;

@end
