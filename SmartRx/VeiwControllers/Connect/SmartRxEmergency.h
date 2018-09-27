//
//  SmartRxEmergency.h
//  SmartRx
//
//  Created by Manju Basha on 14/06/16.
//  Copyright © 2016 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "SmartRxDB.h"

#import <MessageUI/MessageUI.h>

@interface SmartRxEmergency : UIViewController<CLLocationManagerDelegate,MFMessageComposeViewControllerDelegate>
{
    CLLocationManager *_locationManager;
}

@property(nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UITextField *txtMobilenum;
@property (strong, nonatomic) IBOutlet UITextField *txtName;
@property (strong,nonatomic) NSString *LocationObtained;
@property (strong,nonatomic) NSString *HomeLocation;

@end
