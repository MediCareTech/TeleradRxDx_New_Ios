//
//  SmartRxPostDetaisVC.m
//  SmartRx
//
//  Created by PaceWisdom on 05/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxPostDetaisVC.h"
#import "SmartRxQuestionsPreviousVC.h"

#define kSuccessReplyAlertTag 4000
#define kReplyTextTag 4002
#define kCommentTextTag 4003
#define kKeyBoardHeight 276
#import "SmartRxDashBoardVC.h"
#import "NSString+DateConvertion.h"
#import "UIKit+AFNetworking.h"
#import "AFNetworking.h"



@interface SmartRxPostDetaisVC ()
{
    MBProgressHUD *HUD;
    CGSize viewSize;
    CGFloat height;
}

@end

@implementation SmartRxPostDetaisVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)numberKeyBoardReturn
{
    UIToolbar* numberToolbar;
    
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(retunWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtviwComments.inputAccessoryView = numberToolbar;
    self.txtViewReply.inputAccessoryView = numberToolbar;
}
-(void)retunWithNumberPad
{
    [self.txtviwComments resignFirstResponder];
    [self .txtViewReply resignFirstResponder];
}


-(void)navigationBackButton
{
    [self numberKeyBoardReturn];
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
    self.lblTitle.text=[self.dictMsgDetails objectForKey:@"title"];
    self.lblTime.text=[NSString timeFormating:[self.dictMsgDetails objectForKey:@"time"] funcName:@"postdetails"];
    self.btnMark.selected=NO;
    self.scrolView.contentSize=CGSizeMake(self.scrolView.frame.size.width,self.btnPostReply.frame.origin.y+self.btnPostReply.frame.size.height +200);
    [self.btnPostReply.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.btnPostReply setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if ([self.strRating length] > 0 &&  [self.strRating integerValue] != 0)
    {
        for (int i=2000; i<=[self.strRating integerValue]; i++)
        {
            UIButton *btn = (UIButton *)[self.view viewWithTag:i];
            [btn setBackgroundImage:[UIImage imageNamed:@"icn_star_sel.png"] forState:UIControlStateNormal];
        }
    }
    
    if ([[self.dictMsgDetails objectForKey:@"askrfeed"]integerValue] == 2)
    {
        self.imgView.image=[UIImage imageNamed:@"icn_chat_bubble.png"];
    }
    else
        self.imgView.image=[UIImage imageNamed:@"icn_question.png"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)makeRequestForReplyPost
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strSeccionName=[[NSUserDefaults standardUserDefaults]objectForKey:@"SessionName"];
    NSDictionary *dictTemp=nil;
    if (self.btnMark.selected)
    {
        dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:sectionId,@"sessionid",[self.dictMsgDetails objectForKeyedSubscript:@"qid"],@"qid",self.txtViewReply.text,@"reply",strSeccionName,@"session_name",@"1",@"close",self.strRating,@"value",self.txtviwComments.text,@"comments", nil];
    }
    else{
        dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:sectionId,@"sessionid",[self.dictMsgDetails objectForKeyedSubscript:@"qid"],@"qid",self.txtViewReply.text,@"reply",strSeccionName,@"session_name",@"0",@"close", nil];
    }
    [self uploadImage:dictTemp];
    
    
    
    
    //bodyText  = [NSString stringWithFormat:@"%@=%@&qid=%@&reply=%@&close=%@&patientfile[]=%@",@"sessionid",sectionId,[self.dictMsgDetails objectForKeyedSubscript:@"qid"],self.txtViewReply.text,@"0",imageData];
    
    
    /* [self addSpinnerView];
     NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
     NSData *imageData = UIImageJPEGRepresentation(self.imgViewPhoto.image, 1.0);
     NSLog(@" image data = %@", imageData);
     
     NSUInteger dataLength = [imageData length];
     NSMutableString *strImgData = [NSMutableString stringWithCapacity:dataLength*2];
     const unsigned char *dataBytes = [imageData bytes];
     for (NSInteger idx = 0; idx < dataLength; ++idx) {
     [strImgData appendFormat:@"%02x", dataBytes[idx]];
     }
     NSLog(@"\n\nimage data as string : %@\n\n", strImgData);
     NSString *bodyText;
     if (self.btnMark.selected)
     {
     bodyText  = [NSString stringWithFormat:@"%@=%@&qid=%@&reply=%@&close=%@&value=%@&comments=%@&patientfile[]=%@",@"sessionid",sectionId,[self.dictMsgDetails objectForKeyedSubscript:@"qid"],self.txtViewReply.text,@"1",self.strRating,self.txtviwComments.text,imageData];
     }
     else{
     bodyText  = [NSString stringWithFormat:@"%@=%@&qid=%@&reply=%@&close=%@&patientfile[]=%@",@"sessionid",sectionId,[self.dictMsgDetails objectForKeyedSubscript:@"qid"],self.txtViewReply.text,@"0",imageData];
     }
     
     NSLog(@"BODY TEXT = %@",bodyText);
     NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mreply"];
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
     else
     {
     if ([response objectForKey:@"result"] && [[response objectForKey:@"qstatus"]integerValue] == 2)
     {
     [self customAlertView:@"" Message:@"Added reply successfully" tag:kSuccessReplyAlertTag];
     }
     else if([response objectForKey:@"result"] && [[response objectForKey:@"qstatus"]integerValue] == 1)
     {
     [self customAlertView:@"" Message:@"Already question is completed" tag:0];
     }
     else if([response objectForKey:@"result"] && [[response objectForKey:@"qstatus"]integerValue] == 0)
     {
     [self customAlertView:@"" Message:@"No question available with that id" tag:0];
     }
     }
     } failureHandler:^(id response) {
     NSLog(@"failure %@",response);
     [HUD hide:YES];
     [HUD removeFromSuperview];
     }];*/
}

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}


#pragma mark - Action Methods

-(void)backBtnClicked:(id)sender
{
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

- (IBAction)submitButtonClicked:(id)sender
{
    if (![self.btnMark isSelected])    // Without mrikin answer
    {
        NSString *replyString=self.txtViewReply.text;
        replyString=[replyString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        if ([replyString length] > 0)
        {
            NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
            if ([networkAvailabilityCheck reachable])
            {
                [self makeRequestForReplyPost];
            }
            else{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                alertView=nil;
            }
        }
        else{
            [self customAlertView:@"" Message:@"Reply can not be empty" tag:0];
        }
    }
    else{   //If mark as a answered.
        
        NSString *replyString=self.txtViewReply.text;
        replyString=[replyString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *commentString=self.txtviwComments.text;
        commentString=[commentString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        if ([replyString length] == 0)
        {
            [self customAlertView:@"" Message:@"Reply can not be empty" tag:0];
        }
        else if ([commentString length] == 0)
        {
            [self customAlertView:@"" Message:@"Comments can not be empty" tag:0];
        }
        else{
            
            NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
            if ([networkAvailabilityCheck reachable])
            {
                [self makeRequestForReplyPost];
            }
            else{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                alertView=nil;
            }
            
        }
    }
}
- (IBAction)cancelButtonClicked:(id)sender
{
}

- (IBAction)markBtnClicked:(id)sender
{
    if ([self.btnMark isSelected])
    {
        self.viwRatings.hidden=YES;
        self.btnMark.selected=NO;
        self.btnPostReply.frame=CGRectMake(self.btnPostReply.frame.origin.x, self.imgViewPhoto.frame.origin.y+self.imgViewPhoto.frame.size.height +20, self.btnPostReply.frame.size.width, self.btnPostReply.frame.size.height);
        self.scrolView.contentSize=CGSizeMake(self.scrolView.frame.size.width,self.btnPostReply.frame.origin.y+self.btnPostReply.frame.size.height+100);
        
    }
    else{
        self.btnMark.selected=YES;
        self.viwRatings.hidden=NO;
        self.btnPostReply.frame=CGRectMake(self.btnPostReply.frame.origin.x, self.viwRatings.frame.origin.y+self.viwRatings.frame.size.height, self.btnPostReply.frame.size.width, self.btnPostReply.frame.size.height);
        self.scrolView.contentSize=CGSizeMake(self.scrolView.frame.size.width,self.btnPostReply.frame.origin.y+self.btnPostReply.frame.size.height +200);
    }
}

- (IBAction)ratingBtnClicked:(UIButton *)sender {
    for (int i=2001; i<=2005; i++)
    {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i];
        // btn.backgroundColor=[UIColor clearColor];
        [btn setBackgroundImage:[UIImage imageNamed:@"icn_star.png"] forState:UIControlStateNormal];
    }
    for (int i=2000; i<=sender.tag; i++)
    {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i];
        //btn.backgroundColor=[UIColor orangeColor];//icn_star_sel.png
        [btn setBackgroundImage:[UIImage imageNamed:@"icn_star_sel.png"] forState:UIControlStateNormal];
    }
    self.strRating=[NSString stringWithFormat:@"%ld",sender.tag-2000];
}

- (IBAction)dismisKeybordBtnClicked:(id)sender
{
    if ([self.txtViewReply isFirstResponder])
    {
        [self.txtViewReply resignFirstResponder];
    }
    if ([self.txtviwComments isFirstResponder])
    {
        [self.txtviwComments resignFirstResponder];
    }
    
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
    //    if (textView.tag == kCommentTextTag)
    //    {
    //        [UIView animateWithDuration:0.2 animations:^{
    //            self.scrolView.frame=CGRectMake(self.scrolView.frame.origin.x, self.scrolView.frame.origin.y-kKeyboarHeight, self.scrolView.frame.size.width, self.scrolView.frame.size.height);
    //        }];
    //
    //    }
    if (textView.tag == kCommentTextTag)
    {
        
        height=viewSize.height - (self.viwRatings.frame.origin.y);
        height=kKeyBoardHeight-height;
        [UIView animateWithDuration:0.2 animations:^{
            
            self.scrolView.contentOffset=CGPointMake(self.scrolView.frame.origin.x,self.scrolView.contentOffset.y +height);
        }];
    }
    else{
        height=viewSize.height - (textView.frame.origin.y+textView.frame.size.height);
        height=kKeyBoardHeight-height;
        [UIView animateWithDuration:0.2 animations:^{
            
            self.scrolView.contentOffset=CGPointMake(self.scrolView.frame.origin.x, height);
        }];
    }
    
    
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    //    if (textView.tag == kCommentTextTag)
    //    {
    //        [UIView animateWithDuration:0.2 animations:^{
    //            self.scrolView.frame=CGRectMake(self.scrolView.frame.origin.x, self.scrolView.frame.origin.y+kKeyboarHeight, self.scrolView.frame.size.width, self.scrolView.frame.size.height);
    //        }];
    //    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.scrolView.contentOffset=CGPointMake(0, 0);
    }];
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


-(IBAction)showActionSheet:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}
#pragma mark -Aaction sheet
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
    self.lblAttach.hidden=YES;
    self.imgViwPlus.hidden=YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
-(void)imageSelected:(UIImage *)image{
    
    //self.imgViewPhoto.image=image;
    [self compression:image];
    self.lblAttach.hidden=YES;
    self.imgViwPlus.hidden=YES;
}
#pragma mark - Custom Alert
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
#pragma mark - AlertView Delegate Method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kSuccessReplyAlertTag && buttonIndex == 0)
    {
        //[self.navigationController popViewControllerAnimated:YES];
        for (UIViewController *controller in [self.navigationController viewControllers])
        {
            if ([controller isKindOfClass:[SmartRxQuestionsPreviousVC class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
        
    }
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForReplyPost];
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
    [self.imgViewPhoto.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage;
    if (self.imgViewPhoto.image != nil)
    {
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    
    
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@kBaseUrl]];
    UIImage *image = newImage; //self.imgViewPhoto.image;//[info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *strUrl=[NSString stringWithFormat:@"%s/mreply",kBaseUrl];
    
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
        else
        {
            if ([responseObject objectForKey:@"result"] && [[responseObject objectForKey:@"qstatus"]integerValue] == 2)
            {
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"QuestionReply"];
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"NewQueAdded"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                [self customAlertView:@"" Message:@"Added reply successfully" tag:kSuccessReplyAlertTag];
            }
            else if([responseObject objectForKey:@"result"] && [[responseObject objectForKey:@"qstatus"]integerValue] == 1)
            {
                [self customAlertView:@"" Message:@"Already question is completed" tag:0];
            }
            else if([responseObject objectForKey:@"result"] && [[responseObject objectForKey:@"qstatus"]integerValue] == 0)
            {
                [self customAlertView:@"" Message:@"No question available with that id" tag:0];
            }
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
    
    [self.imgViewPhoto setImage:[UIImage imageWithData:imageData]];
    
    
}

@end
