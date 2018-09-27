//
//  SmartRxNewQuestionVC.m
//  SmartRx
//
//  Created by PaceWisdom on 05/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxNewQuestionVC.h"

#define kDoctorTexttag 7000
#define kSubTexttag 7001
#define kKeyBoardHeight 276
#define KSuccessPosing 1500
#define kNoCreditsAlertTag 7800
#import "SmartRxDashBoardVC.h"
#import "UIKit+AFNetworking.h"
#import "AFNetworking.h"

@interface SmartRxNewQuestionVC ()
{
    MBProgressHUD *HUD;
    #define kKeyBoardHeight 276
    CGSize viewSize;
    CGFloat height;
    UIToolbar* numberToolbar;
    NSString *strFrontDeskNum;
}
@end

@implementation SmartRxNewQuestionVC

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
-(void)numberKeyBoardReturn
{
    
    
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(retunWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtViewQuestion.inputAccessoryView = numberToolbar;
}
-(void)retunWithNumberPad
{
    [self.txtViewQuestion resignFirstResponder];
}
-(void)loadDocList
{
   
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"])
    {
        [self.arrDoctorList addObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"]];
         [self.arrDocorRefId addObject:@"-1"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"refdocname"])
    {
       // [self.arrDoctorList addObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"refdocname"]];
        if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"refdocname"] isEqualToString:@"No Doctor(s) available"]) {
            [self.arrDoctorList addObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"refdocname"]];
        }
      
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"hosid"])
    {
        [self.arrDocorRefId addObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"hosid"]];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"referal_doc"])
    {
        [self.arrDocorRefId addObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"referal_doc"]];
    }
    NSLog(@"hikwgeori:%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"referal_doc"]);
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewSize=[UIScreen mainScreen].bounds.size;
    self.navigationItem.hidesBackButton=YES;
    [self numberKeyBoardReturn];
    self.dictDocList=[[NSDictionary alloc]init];
    self.arrDocorRefId=[[NSMutableArray alloc]init];
    self.arrDoctorList=[[NSMutableArray alloc]init];
    self.txtViewQuestion.layer.cornerRadius=0.0f;
    self.txtViewQuestion.layer.masksToBounds = YES;
    self.txtViewQuestion.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.txtViewQuestion.layer.borderWidth= 1.0f;
    [self loadDocList];
    [self navigationBackButton];
    self.tblDoctors.layer.borderColor=[[UIColor orangeColor]CGColor];
    self.tblDoctors.layer.cornerRadius=10.0f;
    self.tblDoctors.layer.borderWidth=3.0f;
    self.scrolView.contentSize=CGSizeMake(self.scrolView.frame.size.width, self.btnSubmit.frame.origin.y+self.btnSubmit.frame.size.height+200);
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"])
    {
        self.txtfldDoctor.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
        
        self.strRefId=@"-1";
    }
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
         //[self makeRequestForCreatdits];
    }
    else{
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }

   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Request Methods //mdocs


-(void)makeRequestForCreatdits
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *bodyText=nil;
    bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mpack"];//@"mdocs"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 25 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            //strRegisterCall=@"GetDoctor";
            //[self make];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                strFrontDeskNum=[response objectForKey:@"frontdesk"];
                if ([[response objectForKey:@"qa"]integerValue] == 0)
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"No credits available, Please call hospital to buy" delegate:self cancelButtonTitle:@"CALL" otherButtonTitles:@"CANCEL", nil];
                    [alert show];
                    alert.tag=kNoCreditsAlertTag;
                    alert=nil;
                    
                }
                
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}

-(void)makeRequestForPostNewQuestion
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }

    
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strSeccionName=[[NSUserDefaults standardUserDefaults]objectForKey:@"SessionName"];
    NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:sectionId,@"sessionid",self.strRefId,@"doclist",self.txtViewQuestion.text,@"question",strSeccionName,@"session_name",self.txtFldSubject.text,@"subj", nil];
    [self uploadImage:dictTemp];

    
    
 /*   [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSData *imageData = UIImageJPEGRepresentation(self.imgViwPhoto.image, 1.0);
    NSLog(@" image data = %@", imageData);
    
    NSUInteger dataLength = [imageData length];
    NSMutableString *strImgData = [NSMutableString stringWithCapacity:dataLength*2];
    const unsigned char *dataBytes = [imageData bytes];
    for (NSInteger idx = 0; idx < dataLength; ++idx) {
        [strImgData appendFormat:@"%02x", dataBytes[idx]];
    }
    
    //NSLog(@"\n\nimage data as string : %@\n\n", strImgData);
    
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&doclist=%@&question=%@&subj=%@&patientfile[]=%@",@"sessionid",sectionId,self.strRefId,self.txtViewQuestion.text,self.txtFldSubject.text,imageData];
    //NSLog(@"BODY TEXT = %@",bodyText);
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mnewqa"];
    
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText  method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.view.userInteractionEnabled = YES;
                
                if ([[response objectForKey:@"added"]intValue] == 1 && [[response objectForKey:@"authorized"]intValue] == 1 && [[response objectForKey:@"fileupload"]intValue] == 1 && [[response objectForKey:@"result"]intValue] == 1)
                {
                    [self customAlertView:@"" Message:@"Question Posted Successfully" tag:KSuccessPosing];
                    
                }
                else if ([[response objectForKey:@"added"]intValue] == 1 && [[response objectForKey:@"authorized"]intValue] == 1 && [[response objectForKey:@"fileupload"]intValue] == 0 && [[response objectForKey:@"result"]intValue] == 1)
                {
                    [self customAlertView:@"" Message:@"Question Posted Successfully " tag:KSuccessPosing];
                }
               
                else if ([[response objectForKey:@"added"]intValue] == 2 && [[response objectForKey:@"authorized"]intValue] == 1 && [[response objectForKey:@"result"]intValue] == 0)
                {
                    [self customAlertView:@"" Message:@"Patient doesnt have credits to ask qa" tag:0];
                }
                else if ([[response objectForKey:@"added"]intValue] == 0 && [[response objectForKey:@"authorized"]intValue] == 1 && [response objectForKey:@"fileupload"] == [NSNull null] && [[response objectForKey:@"result"]intValue] == 0)
                {
                    [self customAlertView:@"" Message:@"Adding both Data and File is Failed" tag:0];
                }
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"In Posting question" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }];*/
}

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
#pragma mark - Action Methods

-(void)backBtnClicked:(id)sender
{
    if ([self.txtViewQuestion isFirstResponder])
    {
        [self.txtViewQuestion resignFirstResponder];
    }
    if ([self.txtFldSubject isFirstResponder])
    {
        [self.txtFldSubject resignFirstResponder];
    }

    
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

- (IBAction)browseBtnClicked:(id)sender {
    [self showActionSheet:nil];
}

- (IBAction)submitBtnClicked:(id)sender {
    
    NSString *tempstring=self.txtViewQuestion.text;
    tempstring=[tempstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([self.txtfldDoctor.text length] == 0 )
    {
        [self customAlertView:@"Should select doctor" Message:@"" tag:0];
    }
    else if([self.txtFldSubject.text length] == 0 )
    {
        [self customAlertView:@"Subject should not empty" Message:@"" tag:0];
    }
    else if([tempstring length] <= 0 )
    {
         [self customAlertView:@"Question should not be empty" Message:@"" tag:0];
    }
    else
    {
     
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForPostNewQuestion];
        }
        else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }
    }
}
- (IBAction)cancelBtnClicked:(id)sender {
}

- (IBAction)selectDocBtnClicked:(id)sender
{
    if ([self.txtViewQuestion isFirstResponder])
    {
        [self.txtViewQuestion resignFirstResponder];
    }
    if ([self.txtFldSubject isFirstResponder])
    {
        [self.txtFldSubject resignFirstResponder];
    }
    self.tblDoctors.hidden=NO;
}

-(IBAction)showActionSheet:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}
#pragma mark - TableView Datasource/Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrDoctorList count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"DoctorListCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
   
        cell.textLabel.text=[self.arrDoctorList objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tblDoctors.hidden=YES;
    
    self.txtfldDoctor.text=[self.arrDoctorList objectAtIndex:indexPath.row];
    self.strRefId=[self.arrDocorRefId objectAtIndex:indexPath.row];
    self.tblDoctors.hidden=YES;
    
//    if (indexPath.row == 0)
//    {
//        self.txtfldDoctor.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
//        self.strRefId=@"-1";
//    }
//    else{
//    self.txtfldDoctor.text=[self.arrDoctorList objectAtIndex:indexPath.row-1];
//    NSArray *temp = [self.dictDocList allKeysForObject:self.txtfldDoctor.text];
//    self.strRefId=[temp objectAtIndex:0];//[self.dictDocList objectForKey:self.txtfldDoctor.text];
//    }
}

#pragma mark - Textfield Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.tag == kSubTexttag)
    {
        [self.txtViewQuestion becomeFirstResponder];
    }
    
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == kDoctorTexttag)
    {   [textField resignFirstResponder];
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            //[self makeRequestGetDoctors];
        }
        else{
            
            [self customAlertView:@"" Message:@"Network not available" tag:0];
            
        }
        
    }
    
    textField.text=@"";
}

#pragma mark - TextView Delegate method
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        //[textView resignFirstResponder];
    }
    return YES;
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    height=viewSize.height - (textView.frame.origin.y+textView.frame.size.height);
    height=kKeyBoardHeight-height;
    if (height > 0)
    {
        
    [UIView animateWithDuration:0.2 animations:^{
        
        self.scrolView.contentOffset=CGPointMake(self.scrolView.frame.origin.x, height);
    }];
    }
    self.lblAskQuestion.hidden=YES;
    self.imgTxtView.hidden=YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text length] == 0)
    {
        self.lblAskQuestion.hidden=NO;
        self.imgTxtView.hidden=NO;
    }
    if (height > 0)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrolView.contentOffset=CGPointMake(0, 0);
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
    //self.imgViwPhoto.image=info[UIImagePickerControllerEditedImage];
    [self compression:info[UIImagePickerControllerEditedImage]];
    self.lblAttach.hidden=YES;
    self.imgViwPlus.hidden=YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
-(void)imageSelected:(UIImage *)image{
    //self.imgViwPhoto.image=image;
    [self compression:image];
    self.lblAttach.hidden=YES;
    self.imgViwPlus.hidden=YES;
}
#pragma mark - AlertView Delegate Method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == KSuccessPosing && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
   else if (alertView.tag == kNoCreditsAlertTag && buttonIndex == 0)
    {
        [self emgCall];
    }
   else if(alertView.tag == kNoCreditsAlertTag && buttonIndex == 1)
   {
       [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)emgCall
{
    
    NSString *number = [NSString stringWithFormat:@"%@",strFrontDeskNum];
    NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@",number]];
    
    //check  Call Function available only in iphone
    if([[UIApplication sharedApplication] canOpenURL:callUrl])
    {
        [[UIApplication sharedApplication] openURL:callUrl];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ALERT" message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
       //[self makeRequestGetDoctors];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
        
    }

}
-(void)errorSectionId:(id)sender
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
}


-(void) uploadImage:(NSDictionary *)info
{
    
    CGSize newSize = CGSizeMake(320.0f, 480.0f);
    UIGraphicsBeginImageContext(newSize);
    [self.imgViwPhoto.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage;
    if (self.imgViwPhoto.image != nil)
    {
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    
    UIGraphicsEndImageContext();

    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@kBaseUrl]];
    UIImage *image =newImage; //self.imgViwPhoto.image;//[info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(image);
    
     NSString *strUrl=[NSString stringWithFormat:@"%s/mnewqa",kBaseUrl];
    
    AFHTTPRequestOperation * op = [manager POST:strUrl parameters:info constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        
        if ([imageData length] > 0)
        {
        [formData appendPartWithFileData:imageData name:@"patientfile[]" fileName:@"photo1.JPG" mimeType:@"image/JPG"];
        }
        [manager.requestSerializer setTimeoutInterval:30.0];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        if ([[responseObject objectForKey:@"authorized"]integerValue] == 0 && [[responseObject objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.view.userInteractionEnabled = YES;
                
                if ([[responseObject objectForKey:@"added"]intValue] == 1 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"fileupload"]intValue] == 1 && [[responseObject objectForKey:@"result"]intValue] == 1)
                {
                    [self customAlertView:@"" Message:@"Question posted successfully" tag:KSuccessPosing];
                    
                }
                else if ([[responseObject objectForKey:@"added"]intValue] == 1 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"fileupload"]intValue] == 0 && [[responseObject objectForKey:@"result"]intValue] == 1)
                {
                    [self customAlertView:@"" Message:@"Question posted successfully " tag:KSuccessPosing];
                }
                
                else if ([[responseObject objectForKey:@"added"]intValue] == 2 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [[responseObject objectForKey:@"result"]intValue] == 0)
                {
                    [self customAlertView:@"" Message:@"No credits available,please call hospital to buy" tag:0];
                }
                else if ([[responseObject objectForKey:@"added"]intValue] == 0 && [[responseObject objectForKey:@"authorized"]intValue] == 1 && [responseObject objectForKey:@"fileupload"] == [NSNull null] && [[responseObject objectForKey:@"result"]intValue] == 0)
                {
                    [self customAlertView:@"" Message:@"Could not post question, please try again later." tag:0];
                }
            });
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [op start];
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
    
    [self.imgViwPhoto setImage:[UIImage imageWithData:imageData]];
    
    
}

@end
