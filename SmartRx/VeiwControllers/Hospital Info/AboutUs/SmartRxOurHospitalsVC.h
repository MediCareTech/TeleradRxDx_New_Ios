//
//  SmartRxOurHospitalsVC.h
//  SmartRx
//
//  Created by Anil Kumar on 06/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxOurHospitalsVC : UIViewController<MBProgressHUDDelegate>
@property (strong, nonatomic) NSMutableDictionary *dictData;
@property (weak, nonatomic) IBOutlet UILabel *locationName;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *tabIndicationView;
@property (weak, nonatomic) IBOutlet UIImageView *serviceImage;
- (IBAction)locationButtonClicked:(id)sender;
- (IBAction)callButtonClicked:(id)sender;
@end
