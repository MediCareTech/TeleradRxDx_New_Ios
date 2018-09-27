//
//  SmartRxViewDoctorProfile.h
//  SmartRx
//
//  Created by Anil Kumar on 15/10/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"

@interface SmartRxViewDoctorProfile : UIViewController<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate>
@property (strong, nonatomic) NSMutableDictionary *doctorArray;
@property (weak, nonatomic) IBOutlet UILabel *doctorName;
@property (weak, nonatomic) IBOutlet UILabel *qualification;
@property (retain, nonatomic) NSString *locationName, *locationId;
@property (weak, nonatomic) IBOutlet UIWebView *doctorDetails;
@property (weak, nonatomic) IBOutlet UIImageView *doctorDP;
@property (strong, nonatomic) NSMutableArray *dictResponse;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIView *aboutView;
@property (weak, nonatomic) IBOutlet UIView *backgroudView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl4;
@property (retain, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *econsultButton;
@property (weak, nonatomic) IBOutlet UIButton *appointmentButton;
@property (assign, nonatomic) NSString *strTitle;
- (IBAction)bookAppointmentButtonClicked:(id)sender;
- (IBAction)bookEconsultButtonClicked:(id)sender;
@end
