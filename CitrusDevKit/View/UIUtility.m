//
//  UIUtility.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 24/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "UIUtility.h"
#import "CTSUtility.h"
#import "CTSError.h"
#import "CTSRestError.h"

#define LOADING_TITLE @"Please wait..."
#define ERROR_TITLE @"Error"
#define INFO_TITLE @"Information"

@implementation UIUtility
UIActivityIndicatorView* activityView;
UIAlertView* alertView;

/**
 *  show alertView with activity
 *
 *  @param alertView message
 *  @param show activity if YES
 */
+ (void)didPresentLoadingAlertView:(NSString *)message withActivity:(BOOL)activity
{
    if (activity) {
        alertView = [[UIAlertView alloc] initWithTitle:LOADING_TITLE
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil];
        
        activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [alertView setValue:activityView forKey:@"accessoryView"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityView startAnimating];
        });
        [alertView show];
    }
}

/**
 *  dismiss alertView with activity
 *
 *  @param shdismissow activity if YES
 */
+ (void)dismissLoadingAlertView:(BOOL)activity
{
    if (activity) {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [activityView stopAnimating];
    }
}

/** TODO
 *  dismiss alertView with error
 *
 *  @param alertView error
 */
+ (void)didPresentErrorAlertView:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CTSRestError *errorCTS = [[error userInfo] objectForKey:CITRUS_ERROR_DESCRIPTION_KEY];
        LogTrace(@" errorCTS type %@",errorCTS.type);
        LogTrace(@" errorCTS description %@",errorCTS.description);
        LogTrace(@" errorCTS responseString %@",errorCTS.serverResponse);
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:errorCTS.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    });
}


/**
 *  dismiss alertView with message
 *
 *  @param alertView message
 */
+ (void)didPresentInfoAlertView:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:INFO_TITLE message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    });
}


/**
 *  move and animate textField while tapping
 *
 *  @param for textField
 *  @param animate if YES
 *  @param move to UIView
 */
+ (void)animateTextField:(UITextField*)textField up:(BOOL)up toView:(UIView*)toView
{
    const float movementDuration = 0.5f;
    const int movementDistance = 80;
    int movement = (up ? - movementDistance : movementDistance);
    [UIView animateWithDuration:movementDuration
                     animations:^{
                         CGRect frame = toView.frame;
                         frame.origin.y = toView.frame.origin.y + movement;
                         toView.frame = frame;
                     }];
}

+(void)toastMessageOnScreen:(NSString *)string{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                        message:string
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [toast show];
        
        int duration = 60; // duration in seconds
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [toast dismissWithClickedButtonIndex:0 animated:YES];
        });
        
        
    });
    
}

@end
