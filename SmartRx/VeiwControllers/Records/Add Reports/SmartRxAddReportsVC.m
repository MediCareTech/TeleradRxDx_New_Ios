//
//  SmartRxAddReportsVC.m
//  SmartRx
//
//  Created by PaceWisdom on 08/07/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxAddReportsVC.h"
#import "UIKit+AFNetworking.h"
#import "AFNetworking.h"
#import "SmartRxDashBoardVC.h"
#define kSuccessPosting 3456
#define kCatTextTag 5008
#define kKeyBoardHeight 276


@interface SmartRxAddReportsVC ()
{
    NSString *strCategory;
     MBProgressHUD *HUD;
    UIToolbar *numberToolbar;
    BOOL bIsImageAdded;
    CGSize viewSize;
    CGFloat height;
}

@end

@implementation SmartRxAddReportsVC

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


#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    viewSize=[UIScreen mainScreen].bounds.size;
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
    [self numberKeyBoardReturn];
    self.dictCategory=[[NSDictionary alloc]initWithObjectsAndKeys:@"Lab",@"1",@"Radiology",@"2",@"MI",@"3",@"Discharge summary",@"4",@"Prescriptions",@"5",@"Case sheet",@"6",@"Others",@"7", nil];
    self.txtCategory.text=@"Lab";
    strCategory=@"1";

    self.txtViwDes.layer.cornerRadius=0.0f;
    self.txtViwDes.layer.masksToBounds = YES;
    self.txtViwDes.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.txtViwDes.layer.borderWidth= 1.0f;
    
    self.tblCategory.layer.borderColor=[[UIColor darkGrayColor]CGColor];
    self.tblCategory.layer.cornerRadius=10.0f;
    self.tblCategory.layer.borderWidth=3.0f;
    self.tblCategory.hidden=YES;
    bIsImageAdded=NO;
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Request methods
-(void)makeRequestForAddReports
{

    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strSeccionName=[[NSUserDefaults standardUserDefaults]objectForKey:@"SessionName"];
    NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:sectionId,@"sessionid",strCategory,@"category",self.txtViwDes.text,@"files_desc",strSeccionName,@"session_name", nil];
    [self uploadImage:dictTemp];
}
#pragma mark - Action Method

-(void)backBtnClicked:(id)sender

{
    [self hideKeyboardBtnClicked:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)homeBtnClicked:(id)sender
{
    
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

- (IBAction)addImageBtnClicked:(id)sender
{
     [self showActionSheet:sender];
}
-(IBAction)showActionSheet:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

- (IBAction)addBtnClicked:(id)sender
{
    NSString *tempstring=self.txtViwDes.text;
    tempstring=[tempstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (!bIsImageAdded)
    {
        [self customAlertView:@"Attachment can not be empty" Message:@"" tag:0];
    }
   else if ([self.txtCategory.text length] <=0 )
    {
        [self customAlertView:@"Category should not be empty " Message:@"" tag:0];
    }
    else if (tempstring <= 0)
    {
        [self customAlertView:@"Description should not be empty " Message:@"" tag:0];
    }
    
    else{
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForAddReports];
        }
        else{
            [self customAlertView:@"Error" Message:@"Network not available" tag:0];
        }
    }
}

- (IBAction)categoryBtnClicked:(id)sender
{
    if ([self.txtViwDes isFirstResponder])
    {
        [self.txtViwDes resignFirstResponder];
        
    }
    self.tblCategory.hidden=NO;
}

- (IBAction)hideKeyboardBtnClicked:(id)sender
{
    if ([self.txtViwDes isFirstResponder])
    {
        [self.txtViwDes resignFirstResponder];
    }
    if (![self.tblCategory isHidden]) {
        self.tblCategory.hidden=YES;
    }
}



#pragma mark - Tableview delegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dictCategory count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"CatID";
    UITableViewCell *cell=(UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    cell.textLabel.textColor=[UIColor whiteColor];
    cell.textLabel.text=[self.dictCategory objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row+1]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    strCategory=[NSString stringWithFormat:@"%ld",indexPath.row+1];
    self.txtCategory.text=[self.dictCategory objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row+1]];
    self.tblCategory.hidden=YES;
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
    
    //self.imgReport.image=info[UIImagePickerControllerEditedImage];
    self.lblAttachImag.hidden=YES;
    self.imgPlus.hidden=YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    bIsImageAdded=YES;
    //self.imgReport.image=info[UIImagePickerControllerEditedImage];
    
    NSData *dataForPNGFile = UIImagePNGRepresentation(info[UIImagePickerControllerEditedImage]);
    NSLog(@"Size of Image(bytes):%lu",(unsigned long)[dataForPNGFile length]);
    
    
    [self compression:info[UIImagePickerControllerEditedImage]];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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
        //[self makeRequestForSendingFeedback];
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
   
    self.lblAttachImag.hidden=YES;
    self.imgPlus.hidden=YES;
    bIsImageAdded=YES;
    
//   NSData *dataForPNGFile = UIImageJPEGRepresentation(image, 0.2f);
//    NSLog(@"Size of Image(bytes):%lu",(unsigned long)[dataForPNGFile length]);
    
     //self.imgReport.image=[UIImage imageWithData:dataForPNGFile];
    [self compression:image];
}

-(void) uploadImage:(NSDictionary *)info
{
    
 
    NSData *imgDataaa = UIImageJPEGRepresentation(self.imgReport.image, 1); //1 it represents the quality of the image.
    NSLog(@"Comprison Size of Image(bytes):%lu",(unsigned long)[imgDataaa length]);
    
    CGSize newSize = CGSizeMake(320.0f, 480.0f);
    UIGraphicsBeginImageContext(newSize);
    [self.imgReport.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@kBaseUrl]];
    UIImage *image = newImage;//self.imgReport.image;//[info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(image);
    //NSString *gjhe = @"https://odev.smartrx.in/api/maddreports";
    
    NSString *strUrl=[NSString stringWithFormat:@"%s/maddreports",kBaseUrl];
    
     //NSString *strUrl=[NSString stringWithFormat:@"%@",gjhe];
    
    AFHTTPRequestOperation * op = [manager POST:strUrl parameters:info constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        
        
        [formData appendPartWithFileData:imageData name:@"patientfile[]" fileName:@"photo.JPG" mimeType:@"image/JPG"];
        [manager.requestSerializer setTimeoutInterval:30];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        if ([[responseObject objectForKey:@"authorized"]integerValue] == 0 && [[responseObject objectForKey:@"result"]integerValue] == 0)
        {
            NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
            if ([networkAvailabilityCheck reachable])
            {
                SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                smartLogin.loginDelegate=self;
                [smartLogin makeLoginRequest];
            }
            else{
                [self customAlertView:@"Error" Message:@"Network not aailable" tag:0];
            }
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([[responseObject objectForKey:@"fileupload"]intValue] == 1 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"result"]intValue] == 1)
                {
                    [self customAlertView:@"" Message:@"Your report has been added successfully" tag:kSuccessPosting];
                }
                else if ([[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"fileupload"]intValue] == 0 && [[responseObject objectForKey:@"result"]intValue] == 1)
                {
                    [self customAlertView:@"" Message:@"Report added successfully" tag:kSuccessPosting];
                }
                else if ([[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"fileupload"]intValue] == 0 && [[responseObject objectForKey:@"result"]intValue] == 0)
                {
                    [self customAlertView:@"" Message:@"Error while adding report, Please try again later." tag:0];
                }
                self.view.userInteractionEnabled = YES;
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [self customAlertView:@"'" Message:@"" tag:0];
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [op start];
}
#pragma mark -Alertview Delegate Method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kSuccessPosting  && buttonIndex == 0)
    {
        [self backBtnClicked:nil];
        //[self.navigationController popViewControllerAnimated:YES];
   }
}
#pragma mark -Textfield Delegate Method
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
//    if (textField.tag == kCatTextTag)
//    {
//        //[textField resignFirstResponder];
//        self.tblCategory.hidden=NO;
//    }
}
#pragma mark - TextView Delegate Methods
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (![self.tblCategory isHidden]) {
        self.tblCategory.hidden=YES;
    }
    height=viewSize.height - (textView.frame.origin.y+textView.frame.size.height);
    height=kKeyBoardHeight-height;
    if (height > 0)
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.x-height, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (height > 0)
    {
        [UIView animateWithDuration:0.2 animations:^{
           self.view.frame=CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
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
    self.txtViwDes.inputAccessoryView = numberToolbar;
}

-(void)retunWithNumberPad
{
    [self.txtViwDes resignFirstResponder];
}

//Image compression

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
    NSLog(@"Size of Image(bytes):%lu",(unsigned long)[imageData length]);
    
    [self.imgReport setImage:[UIImage imageWithData:imageData]];
    
   
}

@end
