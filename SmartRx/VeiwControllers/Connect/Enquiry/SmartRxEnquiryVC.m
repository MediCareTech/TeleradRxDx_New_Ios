//
//  SmartRxEnquiryVC.m
//  SmartRx
//
//  Created by PaceWisdom on 11/07/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxEnquiryVC.h"
#import "SmartRxCommonClass.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImageView+ImageConvertion.h"
#import "SmartRxDashBoardVC.h"

#import "UIKit+AFNetworking.h"
#import "AFNetworking.h"

#define kTitleTxtFldTag 6000
#define kFileTxtFldTag 6001
#define kSuccessPosting 345
#define kKeyBoardHeight 276

@interface SmartRxEnquiryVC ()
{
    MBProgressHUD *HUD;
    UIToolbar* numberToolbar;
    NSString *sectionId;
    CGSize viewSize;
    CGFloat height;
}

@end

@implementation SmartRxEnquiryVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)navigationBackButton
{
    self.navigationItem.hidesBackButton=YES;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"icn_back.png"];
    [backBtn setImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(-40, -2, 100, 40);
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    backButtonView.bounds = CGRectOffset(backButtonView.bounds, 0, -7);
    [backButtonView addSubview:backBtn];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_home.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [btnFaq addTarget:self action:@selector(homeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
}

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    viewSize=[UIScreen mainScreen].bounds.size;
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
    [self numberKeyBoardReturn];
    [self.scrolView setContentSize:CGSizeMake(self.scrolView.frame.size.width, self.btnSubmit.frame.origin.y+self.btnSubmit.frame.size.height+200)];
    self.tblEnquiryTypes.layer.borderColor=[[UIColor darkGrayColor]CGColor];
    self.tblEnquiryTypes.layer.cornerRadius=10.0f;
    self.tblEnquiryTypes.layer.borderWidth=3.0f;
    self.tblEnquiryTypes.hidden=YES;

    self.txtViewFeedback.layer.cornerRadius=0.0f;
    self.txtViewFeedback.layer.masksToBounds = YES;
    self.txtViewFeedback.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.txtViewFeedback.layer.borderWidth= 1.0f;
    
    
    self.arrEnquiryTypes=[[NSArray alloc]initWithObjects:@"Academic",@"Charitable Trust",@"Clinical",@"General",@"International Patients",@"Recruitment", nil];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UName"] length] >0)
    {
        self.textName.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"UName"];
        self.textMobile.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods
-(void)backBtnClicked:(id)sener
{
    [self hideKeyboardBtnClicked:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)homeBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}
- (IBAction)submitBtnClicked:(id)sender {
    [self hideKeyboardBtnClicked:nil];
    
    NSString *tempstring=self.txtViewFeedback.text;
    tempstring=[tempstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if ([self.textName.text length] <= 0 )
    {
        [self customAlertView:@"Please enter your name" Message:@"" tag:0];
    }
    else if ([self.textMobile.text length] <= 0)
    {
        [self customAlertView:@"Please enter your mobile number" Message:@"" tag:0];
    }
    else if ([self.textMobile.text length] > 10)
    {
        [self customAlertView:@"Mobile number cannot be more than 10 digits" Message:@"" tag:0];
    }
    else if ([self.textMobile.text length] < 10)
    {
        [self customAlertView:@"Mobile number can not be less than 10 digits." Message:@"" tag:0];
    }
    else if ([self.txtFldTitle.text length] <=0 )
    {
        [self customAlertView:@"Title should not be empty " Message:@"" tag:0];
    }
    else if ([tempstring length] <= 0)
    {
        [self customAlertView:@"Complaint should not be empty " Message:@"" tag:0];
    }
    else{
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForSendingEnquiry];
        }
        else{
            [self customAlertView:@"Error" Message:@"Network not available" tag:0];
        }
    }
    
}
- (IBAction)attachImageBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    [self showActionSheet:sender];
}

- (IBAction)titleBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
     self.tblEnquiryTypes.hidden=NO;
}

- (IBAction)hideKeyboardBtnClicked:(id)sender
{
    if ([self.txtViewFeedback isFirstResponder])
    {
        [self.txtViewFeedback resignFirstResponder];
    }
    if (![self.tblEnquiryTypes isHidden]) {
        self.tblEnquiryTypes.hidden=YES;
    }
}
-(IBAction)showActionSheet:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

#pragma mark - Requesting Method
-(void)makeRequestForSendingEnquiry
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strSeccionName=[[NSUserDefaults standardUserDefaults]objectForKey:@"SessionName"];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSDictionary *dictTemp=nil;
    if ([sectionId length] > 0)
    {
        dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:sectionId,@"sessionid",self.txtFldTitle.text,@"subj",self.txtViewFeedback.text,@"question",strSeccionName,@"session_name", self.textName.text, @"name", self.textMobile.text, @"mobile" ,nil];
    }
    else{
        dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"isopen",self.txtFldTitle.text,@"subj",self.txtViewFeedback.text,@"question",strCid,@"cid", self.textName.text, @"name", self.textMobile.text, @"mobile" ,nil];
        
    }
    
    [self uploadImage:dictTemp];
    
}

-(void)makeRequestForUserRegister
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    
    
    [self addSpinnerView];
    NSString *strMobile=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    NSString *strCode=[[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",strMobile];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"code",strCode]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mregister"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 19 %@",response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            [[NSUserDefaults standardUserDefaults]setObject:strCode forKey:@"code"];
            [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cidd"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [self performSegueWithIdentifier:@"RegisterID" sender:[response objectForKey:@"cid"]];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cid"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [self makeRequestForSendingEnquiry];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            
        });
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}

#pragma mark - Tableview Delegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrEnquiryTypes count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"CellEnquiry";
    UITableViewCell *cell=(UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    cell.textLabel.textColor=[UIColor whiteColor];
    cell.textLabel.text=[self.arrEnquiryTypes objectAtIndex:indexPath.row];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.txtFldTitle.text=[self.arrEnquiryTypes objectAtIndex:indexPath.row];
    self.tblEnquiryTypes.hidden=YES;
}
#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForSendingEnquiry];
    }
    else{
        [self customAlertView:@"Error" Message:@"Network not available" tag:0];
    }
}
-(void)errorSectionId:(id)sender
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
    self.view.userInteractionEnabled = YES;
}

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}
-(void)imageSelected:(UIImage *)image{
   // self.imgView.image=image;
    //UIImageView *imageView=nil;
    //imageView.image=image;
    [self compression:image];
    self.lblAttach.hidden=YES;
    self.imgViwPlus.hidden=YES;
}
#pragma mark - Textfiled Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}
#pragma mark - TextView Delegates

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.imgPencial.hidden=YES;
    self.lblType.hidden=YES;
    height=viewSize.height - (textView.frame.origin.y+textView.frame.size.height);
    height=kKeyBoardHeight-height;
    if (height > 0)
    {
        [UIView animateWithDuration:0.2 animations:^{
            
            self.scrolView.contentOffset=CGPointMake(self.scrolView.frame.origin.x, height);
        }];
    }

}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text length] <=0)
    {
        self.imgPencial.hidden=NO;
        self.lblType.hidden=NO;
        
    }
    if (height > 0)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrolView.contentOffset=CGPointMake(0, self.scrolView.contentOffset.y-height);
        }];
    }
    
}
- (void)textViewDidChange:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}
-(void)numberKeyBoardReturn
{
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(retunWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtViewFeedback.inputAccessoryView = numberToolbar;
}

-(void)retunWithNumberPad
{
    [self.txtViewFeedback resignFirstResponder];
}

#pragma mark - Custom Alert

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
#pragma mark - Action Sheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        NSLog(@"Camera Clicked");
        [self takePhoto];
        
    } else if (buttonIndex == 1)
    {
        NSLog(@"Gallary Clicked");
        [[SmartRxCommonClass sharedManager] openGallary:self];
    } else if (buttonIndex == 2) {
        NSLog(@"Cancel Clicked");
    }
}
- (void)takePhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}


#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //self.imgView.image=info[UIImagePickerControllerEditedImage];
    [self compression:info[UIImagePickerControllerEditedImage]];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.lblAttach.hidden=YES;
    self.imgViwPlus.hidden=YES;
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void) uploadImage:(NSDictionary *)info
{
    CGSize newSize = CGSizeMake(320.0f, 480.0f);
    UIGraphicsBeginImageContext(newSize);
    [self.imgView.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage;
    if (self.imgView.image != nil)
    {
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@kBaseUrl]];
    UIImage *image = newImage;//self.imgView.image;//[info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(image);
    
     NSString *strUrl=[NSString stringWithFormat:@"%s/mfeed",kBaseUrl];
    
    AFHTTPRequestOperation * op = [manager POST:strUrl parameters:info constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        
        if ([imageData length] > 0)
        {
        [formData appendPartWithFileData:imageData name:@"patientfile[]" fileName:@"photo1.JPG" mimeType:@"image/JPG"];
        }
        [manager.requestSerializer setTimeoutInterval:30.0];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        NSLog(@"Success: %@ ", responseObject);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
//        if ([[responseObject objectForKey:@"added"]intValue] == 0 && [[responseObject objectForKey:@"authorized"]intValue] == 1  && [[responseObject objectForKey:@"result"]intValue] == 0 && [sectionId length] == 0)
//        {
//            [self makeRequestForUserRegister];
//        }
//        else{
        
            if ([[responseObject objectForKey:@"authorized"]integerValue] == 0 && [[responseObject objectForKey:@"result"]integerValue] == 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@""])
            {
                NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
                if ([networkAvailabilityCheck reachable])
                {
                    SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                    smartLogin.loginDelegate=self;
                    [smartLogin makeLoginRequest];
                }
                else{
                    [self customAlertView:@"Error" Message:@"Network not available" tag:0];
                }
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([[responseObject objectForKey:@"added"]intValue] == 1 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"fileupload"]intValue] == 1 && [[responseObject objectForKey:@"result"]intValue] == 1)
                    {
                        [self customAlertView:@"" Message:@"Enquiry posted successfully" tag:kSuccessPosting];
                    }
                    else if ([[responseObject objectForKey:@"added"]intValue] == 1 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"fileupload"]intValue] == 0 && [[responseObject objectForKey:@"result"]intValue] == 1)
                    {
                        [self customAlertView:@"" Message:@"Enquiry posted successfully" tag:kSuccessPosting];
                    }
                    else if ([[responseObject objectForKey:@"added"]intValue] == 0 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"result"]intValue] == 0)
                    {
                        [self customAlertView:@"" Message:@"Could not Enquiry, please try again later." tag:0];
                    }
                    self.view.userInteractionEnabled = YES;
                });
            }
//        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [op start];
}
#pragma mark -Alertview Delegate Method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kSuccessPosting && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)compression:(UIImage *)image
{
    
    //compression of image
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.01f;
    int maxFileSize = 250*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(image,compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 10.9;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    //display image
    
    [self.imgView setImage:[UIImage imageWithData:imageData]];
    
    
}
@end
