//
//  SignUpViewController.m
//  PaymentSdk_GUI
//
//  Created by Vikas Singh on 8/26/15.
//  Copyright (c) 2015 Vikas Singh. All rights reserved.
//

#import "SignUpViewController.h"
#import "UIUtility.h"
#import "ResetPasswordViewController.h"
#import "SignInViewController.h"

@interface SignUpViewController (){

    CitrusSiginType signInType;
    NSString *responseMessage;
}

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.indicatorView.hidden = TRUE;
    self.signupButton.layer.cornerRadius = 4;
    
    switch (self.loginType) {
        case 0:{
            self.userNameTextField.hidden = FALSE;
            self.mobileTextField.hidden = FALSE;
        }
            break;
        case 1:{
            self.userNameTextField.hidden = TRUE;
            self.mobileTextField.hidden = FALSE;
        }
            break;
        case 2:{
            self.userNameTextField.hidden = FALSE;
            self.mobileTextField.hidden = FALSE;
        }
            break;
            
        default:
            break;
    }
    
    
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard:)];
    [self.view addGestureRecognizer:tapRecognizer];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods



// New Link User method - which is OTP based

-(IBAction)linkUser{
    
    [self.view endEditing:YES];
    self.indicatorView.hidden = FALSE;
    [self.indicatorView startAnimating];
    
    [authLayer requestCitrusLink:self.userNameTextField.text mobile:self.mobileTextField.text completion:^(CTSCitrusLinkRes *linkResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicatorView stopAnimating];
            self.indicatorView.hidden = TRUE;
        });
        if (error) {
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
        }
        else{
            // [UIUtility toastMessageOnScreen:linkResponse.userMessage];
            signInType = linkResponse.siginType;
            responseMessage = linkResponse.userMessage;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self performSegueWithIdentifier:@"SignInScreenIdentifier" sender:self];
            }];
        }
    }];
}

- (void)resignKeyboard:(UITapGestureRecognizer *)sender{
    
    [self.view endEditing:YES];
}

#pragma mark - StoryView Delegate Methods

// ++++++ this delegate method will used for new link user api +++++++
 
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"SignInScreenIdentifier"]){
        
        SignInViewController *viewController = (SignInViewController *)segue.destinationViewController;
        viewController.userName = self.userNameTextField.text;
        viewController.mobileNumber = self.mobileTextField.text;
        viewController.signinType = signInType;
        viewController.messageString = responseMessage;
    }
    
}



#pragma mark - Dealloc Methods
- (void) dealloc{
    self.userNameTextField = nil;
    self.mobileTextField = nil;
    self.signupButton = nil;
    self.indicatorView = nil;
}


@end
