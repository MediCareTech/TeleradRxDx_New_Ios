//
//  SmartRxServicesDetails.m
//  SmartRx
//
//  Created by Manju Basha on 19/10/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxServicesDetails.h"
#import "NSString+DateConvertion.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxSuggesstionCell.h"
#import "UIKit+AFNetworking.h"
#import "AFNetworking.h"
#import <QuickLook/QuickLook.h>
#import "SmartRxReportImageVC.h"


@interface SmartRxServicesDetails ()<ShowImageInMainView, QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    MBProgressHUD *HUD;
    BOOL pdfSuccess;
    BOOL sessionDidConnect;
    CGFloat viewWidth, viewHeight;
    CGFloat heightLbl;
    CGSize viewSize;
    CGFloat height;
    UILabel *repLabel;
    UILabel *reqLabel;
    NSString *token;
    NSMutableArray *sectionTitlesArray;
    UILocalNotification *notification;
    UIAlertView *incomingAlert, *endAlert;
}
@end

@implementation SmartRxServicesDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBackButton];
    pdfSuccess = YES;

    [self.requestContentTable setTableFooterView:[UIView new]];
    [self.suggestionContentTable setTableFooterView:[UIView new]];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    sectionTitlesArray = [[NSMutableArray alloc] init];
    sectionTitlesArray = [@[@"Requests"] mutableCopy];
    viewSize=[[UIScreen mainScreen]bounds].size;
    viewWidth = CGRectGetWidth(self.view.frame);
    viewHeight = CGRectGetHeight(self.view.frame);
    viewSize=[[UIScreen mainScreen]bounds].size;
    viewWidth = CGRectGetWidth(self.view.frame);
    viewHeight = CGRectGetHeight(self.view.frame);
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    self.updateTextView.layer.cornerRadius=5.0f;
    self.updateTextView.layer.masksToBounds = YES;
    self.updateTextView.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.updateTextView.layer.borderWidth= 0.5f;
      
    NSString *dateStr = [NSString timeFormating:[self.dictResponse objectForKey:@"service_date"] funcName:@"servicesBooking"];
    
    
    self.servicesDateTime.text= [NSString stringWithFormat:@"%@ %@", dateStr, [self.dictResponse objectForKey:@"service_time"]];
    if (![self.selectedService.serviceDiscountprice isEqualToString:@"0"]){
        NSString *priceStr = [NSString stringWithFormat:@"Rs. %@",self.selectedService.serviceDiscountprice];
        self.priceLbl.text = priceStr;
    } else {
        self.priceLbl.text = @"Free";
    }
   
    if (self.selectedService.isScheduled == true) {
        NSString *dateStrr = [NSString stringWithFormat:@"%@, %@",self.selectedService.scheduledDate,self.selectedService.scheduledTime];
        self.servicesDateTime.text = dateStrr;
    } else {
        self.dateImage.frame = CGRectMake(0, 0, 0, 0);
        self.dateImage.hidden = YES;
        self.servicesDateTime.hidden = YES;
        self.servicesDateTime.frame = CGRectMake(0, 0, 0, 0);
    }
   
    
    self.packageName.text = self.selectedService.serviceName;
    self.serviceStatus.text = self.selectedService.bookingStatus;
    
    
    
    if ([[self.dictResponse objectForKey:@"appstatus"] integerValue] == 1)
    {
        self.serviceStatus.text = @":  Pending";
        self.serviceImage.image = [UIImage imageNamed:@"services_pending.png"];
    }
    else if ([[self.dictResponse objectForKey:@"appstatus"] integerValue] == 2)
    {
        self.serviceStatus.text = @":  Confirmed";
        self.serviceImage.image = [UIImage imageNamed:@"services_booked.png"];
    }
    else if ([[self.dictResponse objectForKey:@"appstatus"] integerValue] == 3)
    {
        self.serviceStatus.text = @":  Completed";
        self.serviceImage.image = [UIImage imageNamed:@"services_cancelled.png"];
    }
    else if ([[self.dictResponse objectForKey:@"appstatus"] integerValue] == 4)
    {
        self.serviceStatus.text = @":  Cancelled";
        self.serviceImage.image = [UIImage imageNamed:@"services_cancelled.png"];
    }
    
    if ([self.dictResponse objectForKey:@"suggestion"]  != [NSNull null] || [self.arrayReportFiles count] || [self.arrayDoctorSuggestionFiles count])
    {
        [sectionTitlesArray addObject:@"Reports & Notes"];
        self.suggestionContentLabel.text = [self.dictResponse objectForKey:@"doc_sugg"];
        [self estimatedHeight:[self.dictResponse objectForKey:@"doc_sugg"]];
        self.suggestionContentLabel.frame = CGRectMake(self.suggestionContentLabel.frame.origin.x, self.suggestionContentLabel.frame.origin.y, self.suggestionViewEdit.frame.size.width-20, heightLbl+self.suggestionContentLabel.frame.size.height);
        [self.suggestionContentLabel sizeToFit];
        [self.suggestionContentLabel setNumberOfLines:0];
        self.suggestionContentTable.frame = CGRectMake(self.suggestionContentTable.frame.origin.x, self.suggestionContentLabel.frame.origin.y + self.suggestionContentLabel.frame.size.height+10, self.suggestionContentTable.frame.size.width, self.suggestionContentTable.frame.size.height);
        if (heightLbl > 350)
        {
            [self.suggestionScroll setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.suggestionScroll.frame.size.height+heightLbl)];
            self.suggestionViewEdit.frame = CGRectMake(self.suggestionViewEdit.frame.origin.x, self.suggestionViewEdit.frame.origin.y, self.suggestionViewEdit.frame.size.width , self.suggestionViewEdit.frame.size.height+heightLbl);
        }
    }
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForReports];
        [self makeRequestForRequests];
    }
    else
    {
        NSDictionary *tempDict = [[SmartRxDB sharedDBManager] fetchEconReportFromDataBase:[[self.dictResponse objectForKey:@"recno"] integerValue] type:@"services"];
            [self processServiceReports:tempDict];
        NSDictionary *tempRequestDict = [[SmartRxDB sharedDBManager] fetchEconRequestFromDataBase:[[self.dictResponse objectForKey:@"recno"] integerValue] type:@"services"];
            [self processServiceRequests:tempRequestDict];
    }
    
    [self numberKeyBoardReturn];
    [self makeSegmentView];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    pdfSuccess = YES;

}

-(void)numberKeyBoardReturn
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    self.updateTextView.inputAccessoryView = doneToolbar;
}
- (void)makeSegmentView
{
    // Tying up the segmented control to a scroll view
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 1)];
    topBorder.backgroundColor = [UIColor lightGrayColor];
    
    self.segmentedControl4 = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 1, viewWidth, 40)];
    self.segmentedControl4.sectionTitles = sectionTitlesArray;
    
    self.segmentedControl4.selectedSegmentIndex = 0;
    self.segmentedControl4.backgroundColor = [UIColor whiteColor];
    
    self.segmentedControl4.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor],  UITextAttributeFont:[UIFont systemFontOfSize:15]};
    
    self.segmentedControl4.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:7.0/255.0 green:92.0/255.0 blue:176.0/255.0 alpha:1]};
    
    self.segmentedControl4.borderType = HMSegmentedControlBorderTypeRight;
    self.segmentedControl4.borderWidth = 1.0;
    self.segmentedControl4.borderColor = [UIColor lightGrayColor];
    
    self.segmentedControl4.selectionIndicatorColor = [UIColor colorWithRed:7.0/255.0 green:92.0/255.0 blue:176.0/255.0 alpha:1];
    self.segmentedControl4.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.segmentedControl4.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl4.tag = 3;
    
    __weak typeof(self) weakSelf = self;
    [self.segmentedControl4 setIndexChangeBlock:^(NSInteger index) {
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(viewWidth * index,  0, viewWidth, 200) animated:YES];
    }];
    
    [self.segmentView addSubview:topBorder];
    [self.segmentView addSubview:self.segmentedControl4];
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self.segmentedControl4.frame.size.height, viewWidth, 1)];
    bottomBorder.backgroundColor = [UIColor lightGrayColor];
    [self.segmentView addSubview:bottomBorder];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 41, viewWidth, 800)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(viewWidth * [self.segmentedControl4.sectionTitles count], 1);
    self.scrollView.delegate = self;
    [self.segmentView addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.requestViewEdit];
    [self.scrollView addSubview:self.suggestionViewEdit];
    [self.scrollView bringSubviewToFront:self.suggestionScroll];
}

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
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
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview Delegate/Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.suggestionContentTable)
        return [self.arrayDoctorSuggestionFiles count];
    else
        return [self.arrayRequestData count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.suggestionContentTable)
    {
        static NSString *cellIdentifier = @"suggestCell";
        SmartRxSuggesstionCell *cellReport = (SmartRxSuggesstionCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cellReport.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([self.arrayDoctorSuggestionFiles count])
        {
            cellReport.arrImages = self.arrayDoctorSuggestionFiles;
        }
        cellReport.delegateImg = self;
        [cellReport setCellData:[self.arrayDoctorSuggestionFiles objectAtIndex:indexPath.row] row:indexPath.row];
        //To customize the separatorLines
        UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cellReport.frame.size.height-1, self.suggestionContentTable.frame.size.width-1, 1)];
        separatorLine.backgroundColor = [UIColor lightGrayColor];
        
        [cellReport setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [cellReport addSubview:separatorLine];
        
        return cellReport;
    }
    else
    {
        static NSString *cellIdentifier = @"requestCell";
        SmartRxServiceRequesCell *cellRequest = (SmartRxServiceRequesCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cellRequest.selectionStyle = UITableViewCellSelectionStyleNone;

        cellRequest.imgDelagate = self;
        UIView *separatorLine;
        if (cellRequest == nil)
        {
            NSLog(@"failure");
            cellRequest = [[SmartRxServiceRequesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            separatorLine = [[UIView alloc] initWithFrame:CGRectZero];
            separatorLine.backgroundColor = [UIColor grayColor];
            separatorLine.tag = 100;
        //[cellRequest.contentView addSubview:separatorLine];
        }
        //separatorLine = (UIView *)[cellRequest.contentView viewWithTag:100];
        
      // separatorLine.frame = CGRectMake(0, cellRequest.frame.size.height-1, cellRequest.frame.size.width, 1);
        if ([self.arrayRequestData count])
        {
            cellRequest.arrImages = self.arrayRequestData;
        }
        [cellRequest setCellData:[self.arrayRequestData objectAtIndex:indexPath.row] row:indexPath.row];
         cellRequest.separatorInset = UIEdgeInsetsMake(0.f, cellRequest.bounds.size.width, 0.f, 0.f);
        [cellRequest setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cellRequest;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *arrAppDetails;
    NSString *imageKeyValue;
    if (tableView == self.suggestionContentTable)
    {
       arrAppDetails  = self.arrayDoctorSuggestionFiles[indexPath.row];
        imageKeyValue = @"content_images";
    }else{
         arrAppDetails  = self.arrayRequestData[indexPath.row];
        imageKeyValue = @"filepath";
    }
   
    
    NSString *splitString;
    //    [self.strImage rangeOfString:@"patient"].location != NSNotFound
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(containsString:)])
    {
        if ([[arrAppDetails objectForKey:imageKeyValue] containsString:@"patient/data/pat_uploaded_files/"])
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrAppDetails objectForKey:imageKeyValue] containsString:@"admin/data/servicefiles/"])
            splitString = @"admin/data/servicefiles/";
    }
    else
    {
        if ([[arrAppDetails objectForKey:imageKeyValue] rangeOfString:@"patient/data/pat_uploaded_files/"].location != NSNotFound)
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrAppDetails objectForKey:imageKeyValue] rangeOfString:@"admin/data/servicefiles/"].location != NSNotFound)
            splitString = @"admin/data/servicefiles/";
        
    }
    NSArray *arrImg = [[arrAppDetails objectForKey:imageKeyValue] componentsSeparatedByString:@","];
    if (![arrImg[0] isEqualToString:@""]) {
        NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
        // NSArray *arrExtensionType = [[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"content_images"] componentsSeparatedByString:@"."];
        
        NSArray *arrExtensionType = [[arrImg objectAtIndex:0] componentsSeparatedByString:@"."];
        if ([arrExtensionType count] && [arrFileType containsObject:arrExtensionType[([arrExtensionType count]-1)]]) {
            [self openFile:arrImg[0]];
        }else
            [self imgaeZooming:arrImg[0]];
    }
    

    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat estHeight = 35.0;
    if (tableView == self.requestContentTable)
    {
        estHeight = 0.0;
        [self estimatedHeight:[[self.arrayRequestData objectAtIndex:indexPath.row] objectForKey:@"comments"]];
        estHeight = estHeight+heightLbl;
        float rowHeight = 0.0f;
        if (![[[self.arrayRequestData objectAtIndex:indexPath.row] objectForKey:@"filepath"] isEqualToString:@""]) {
            rowHeight = 30.0f;
        }
        [self estimatedHeight:[[self.arrayRequestData objectAtIndex:indexPath.row] objectForKey:@"created"]];
            NSLog(@"Length 4");
        if ([[[self.arrayRequestData objectAtIndex:indexPath.row] objectForKey:@"comments"] length]>40)
            estHeight = estHeight+heightLbl+40+rowHeight;
        else
            estHeight = estHeight+heightLbl+30+rowHeight;
        
    }
    return estHeight;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:[UITableView class]] && [scrollView isPagingEnabled])
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = scrollView.contentOffset.x / pageWidth;
        
        [self.segmentedControl4 setSelectedSegmentIndex:page animated:YES];
    }
}
#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.imgViwPhoto.image=info[UIImagePickerControllerOriginalImage];
   // self.filePath.text = info[@"UIImagePickerControllerMediaType"];
    
    
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    // define the block to call when we get the asset based on the url (below)
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        NSLog(@"[imageRep filename] : %@", [imageRep filename]);
        self.filePath.text = imageRep.filename;
    };
    
    // get the asset library and fetch the asset based on the ref url (pass in block above)
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    if (refURL != nil) {
        [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
    } else {
        NSData *imageData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage],0.9);
        UIImage *image = [UIImage imageWithData:imageData];
        [assetslibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
            [assetslibrary assetForURL:assetURL resultBlock:resultblock failureBlock:nil];
        }];
    }
    
    
    [self compression:info[UIImagePickerControllerOriginalImage]];
    //[self makeRequestToAddReports];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
-(void)imageSelected:(UIImage *)image{
    
    //    self.imgViwPhoto.image=image;
    [self compression:image];
    //[self makeRequestToAddReports];
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
    
   // UIImage *selectedImage = [UIImage imageWithData:imageData];
}

#pragma mark - Action Methods

-(void)imgaeZooming:(NSString *)sender
{
    [self performSegueWithIdentifier:@"zoomImageID" sender:sender];
}

- (IBAction)cancelBtnClicked:(id)sender
{
    self.imgViwPhoto.image = nil;
    [self hideUpdateView];
}
-(IBAction)addFileButtonClicked:(id)sender{
    [self showActionSheet:nil];
}

- (IBAction)updateBtnClicked:(id)sender
{
    if (self.currentView == self.requestViewEdit)
    {
        if (self.imgViwPhoto.image == nil && self.updateTextView.text.length < 1 ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter something." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        } else {
            [self makeRequestToAddReports];
        }
        

        //[self makeRequestToAddRequest:self.updateTextView.text];
        [self hideUpdateView];
    }
}

- (IBAction)requestAddClicked:(id)sender
{
    self.currentView = self.requestViewEdit;
    self.updateTextView.text = nil;
    [self.updateBtn setTitle:@"Send" forState:UIControlStateNormal];
    self.updateViewTitle.text = @"Send Request";
    self.updateLbl.text = @"Type the request message";
    self.updateLbl.hidden = NO;
    [self showUpdateView];
}


-(IBAction)showActionSheet:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

-(void)estimatedHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, self.view.frame.size.width-96,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width-96,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    heightLbl=expectedLabelSize.height;
    //[self setLblYPostionAndHeight:expectedLabelSize.height+20];
}
- (void)takePhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}
#pragma mark - Action Sheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        NSLog(@"Camera Clicked");
        [self takePhoto];
        
    } else if (buttonIndex == 1)
    {
        NSLog(@"Gallery Clicked");
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = (id)self;
        
        [self presentViewController:picker animated:YES completion:nil];
        //[[SmartRxCommonClass sharedManager] openGallary:self];
    } else if (buttonIndex == 2) {
        NSLog(@"Cancel Clicked");
    }
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    //[self makeRequestForRequests];
}

#pragma mark Request Methods

- (void)makeRequestToAddRequest:(NSString *)requestText
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
            NSLog(@"Length 5");
    if (requestText.length)
    {
        NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
        NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@&message=%@&type=1",@"sessionid",sectionId,self.selectedService.bookingRecNo,requestText];
        NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mereqadd"];
        [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
            if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
            {
                SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                smartLogin.loginDelegate=self;
                [smartLogin makeLoginRequest];
                
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    self.view.userInteractionEnabled = YES;
                    if ([[response objectForKey:@"addreq"] integerValue] == 1)
                    {
                        if ([self.arrayRequestData count] >= 2)
                            [self.requestContentTable setContentSize:CGSizeMake(self.requestContentTable.contentSize.width, self.requestContentTable.contentSize.height+ 50 - [self tableView:self.requestContentTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] + [self tableView:self.requestContentTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]/2)];
                        [self makeRequestForRequests];
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Error in updating Symptoms please enter again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                        [alert show];
                    }
                    
                });
            }
        } failureHandler:^(id response) {
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Error in updating Symptoms please enter again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            [HUD hide:YES];
            [HUD removeFromSuperview];
            
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Request message cannot be empty." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }
}

- (void)makeRequestForRequests
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&member_service_id=%@&type=1",@"sessionid",sectionId,self.selectedService.bookingRecNo];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"messages/index"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        if (response == nil)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            
            //[[SmartRxDB sharedDBManager] saveEconRequest:response conid:[[self.dictResponse objectForKey:@"recno"] integerValue] type:@"services"];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                [self processServiceRequests:response];
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading reports failed please load the screen again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}

-(void)processServiceRequests:(NSArray *)response
{
    //self.arrayData = [response objectForKey:@"ecrequest"];
    self.arrayData =response;
    if ([self.arrayData count])
    {
        self.arrayRequestData = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in response) {
            NSString *str = [NSString stringWithFormat:@"%@\nBy %@",dict[@"created"],dict[@"user"][@"dispname"]];
            NSString *filePathStr;
            if ([dict[@"file_path"] isKindOfClass:[NSString class]]) {
                filePathStr = dict[@"file_path"];
                    } else {
                       filePathStr = @"";
                    }
            NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:filePathStr,@"filepath",str,@"created",dict[@"comments"],@"comments", nil];
            [self.arrayRequestData addObject:tempDict];
        }
        
//        int k=0;
//        for (int i=0; i<[self.arrayData count]/3; i++)
//        {
//            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//            [dict setObject:[self.arrayData objectAtIndex:k] forKey:@"replyMsg"];
//            k++;
//            
//            NSString *str = [NSString stringWithFormat:@"%@\nBy %@", [self.arrayData objectAtIndex:k+1], [self.arrayData objectAtIndex:k]];
//            [dict setObject:str forKey:@"replyTime"];
//            k += 2;
//            [self.arrayRequestData addObject:dict];
//        }
        reqLabel.hidden = YES;
        self.requestContentTable.hidden = NO;
        [self.requestContentTable reloadData];
        [self.requestContentTable setContentSize:CGSizeMake(self.requestContentTable.contentSize.width, self.requestContentTable.contentSize.height + [self tableView:self.requestContentTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] + [self tableView:self.requestContentTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]/2)];
        self.requestViewEdit.frame = CGRectMake(self.requestViewEdit.frame.origin.x, self.requestViewEdit.frame.origin.y, self.requestViewEdit.frame.size.width, self.requestContentTable.frame.size.height+40);
        
    }
    else
    {
        reqLabel = [[UILabel alloc] init];
        reqLabel.frame = CGRectMake(self.requestContentTable.frame.origin.x, self.requestContentTable.frame.origin.y, self.requestContentTable.frame.size.width, 30);
        reqLabel.font = [UIFont systemFontOfSize:15];
        reqLabel.text = @"No requests sent";
        reqLabel.hidden = NO;
        [self.requestViewEdit addSubview:reqLabel];
        self.requestViewEdit.frame = CGRectMake(self.requestViewEdit.frame.origin.x, self.requestViewEdit.frame.origin.y, self.requestViewEdit.frame.size.width, reqLabel.frame.size.height+40);
        
        self.requestContentTable.hidden = YES;
    }

}
- (void)makeRequestForReports
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    //NSString *bodyText = [NSString stringWithFormat:@"%@=%@&conid=%@",@"sessionid",sectionId,[self.dictResponse objectForKey:@"recno"]];
    //member_service_id
     NSString *bodyText = [NSString stringWithFormat:@"%@=%@&service_id=%@&type=SERVICE",@"sessionid",sectionId,self.selectedService.bookingRecNo];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"meflist"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"The response : %@", response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
          //  [[SmartRxDB sharedDBManager] saveEconReport:response conid:[self.selectedService.bookingRecNo integerValue] type:@"services"];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                [self processServiceReports:response];
            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading the files suggested by doctor failed please re-load the screen" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}
-(void)processServiceReports:(NSDictionary *)response
{
    //efiles
    //self.arrayDoctorSuggestionFiles = [response objectForKey:@"dfiles"];
    NSArray *tempAarray = [response objectForKey:@"dfiles"];
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in tempAarray) {
        NSArray *imagesArr = [dict[@"content_images"] componentsSeparatedByString:@","];
        if (imagesArr.count>1) {
            for (NSString *imageStr in imagesArr) {
                NSDictionary *dic= [NSDictionary dictionaryWithObjectsAndKeys:imageStr,@"content_images", nil];
                [tempArr addObject:dic];
            }
            
        }else {
            NSDictionary *dic= [NSDictionary dictionaryWithObjectsAndKeys:dict[@"content_images"],@"content_images", nil];
            [tempArr addObject:dic];
        }
    }
    self.arrayDoctorSuggestionFiles = [tempArr copy];
    if ([self.arrayDoctorSuggestionFiles count])
    {
        if (![sectionTitlesArray containsObject:@"Reports & Notes"])
        {
            [sectionTitlesArray addObject:@"Reports & Notes"];
            //        self.suggestionViewEdit.frame = CGRectMake(self.suggestionViewEdit.frame.origin.x, self.suggestionViewEdit.frame.origin.y, self.suggestionViewEdit.frame.size.width, heightLbl+40);
            self.suggestionContentLabel.frame = CGRectMake(self.suggestionContentLabel.frame.origin.x, self.suggestionContentLabel.frame.origin.y, self.suggestionContentLabel.frame.size.width, heightLbl);
            int heightneeded = self.segmentView.frame.size.height - (self.suggestionContentLabel.frame.origin.y + heightLbl);
            self.suggestionContentTable.frame = CGRectMake(0, self.suggestionContentLabel.frame.origin.y + heightLbl + 10, viewWidth, heightneeded-57);
            [self makeSegmentView];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.arrayDoctorSuggestionFiles count])
        {
            NSLog(@"Length 1");
            if ([self.suggestionContentLabel.text isEqualToString:@"No suggestions added"] || [self.dictResponse objectForKey:@"doc_sugg"]  == [NSNull null] || [self.dictResponse objectForKey:@"doc_sugg"] == nil || [[self.dictResponse objectForKey:@"doc_sugg"] length] == 0)
                self.suggestionContentLabel.hidden = YES;
            else
                self.suggestionContentLabel.hidden = NO;
            self.suggestionContentTable.hidden = NO;
            [self.suggestionContentTable setTableFooterView:[UIView new]];
            [self.suggestionContentTable reloadData];
            self.suggestionViewEdit.frame = CGRectMake(self.suggestionViewEdit.frame.origin.x, self.suggestionViewEdit.frame.origin.y, self.suggestionViewEdit.frame.size.width, self.suggestionViewEdit.frame.size.height + self.suggestionContentTable.frame.size.height+40);
            [self estimatedHeight:self.suggestionContentLabel.text];
            CGFloat tableHeight = 0.0f;
            for (int i = 0; i < [self.arrayDoctorSuggestionFiles count]; i ++) {
                tableHeight += [self tableView:self.suggestionContentTable heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            if ([self.suggestionContentLabel isHidden])
                self.suggestionContentTable.frame = CGRectMake(self.suggestionContentTable.frame.origin.x, self.suggestionContentLabel.frame.origin.y, self.suggestionContentTable.frame.size.width, tableHeight);
            else
                self.suggestionContentTable.frame = CGRectMake(self.suggestionContentTable.frame.origin.x, self.suggestionContentTable.frame.origin.y, self.suggestionContentTable.frame.size.width, tableHeight);
            
            if (tableHeight > self.suggestionViewEdit.frame.size.height)
            {
                self.suggestionViewEdit.frame = CGRectMake(self.suggestionViewEdit.frame.origin.x, self.suggestionViewEdit.frame.origin.y, self.suggestionViewEdit.frame.size.width , self.suggestionViewEdit.frame.size.height+heightLbl+tableHeight);
            }
            [self.suggestionScroll setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.suggestionContentLabel.frame.origin.y+self.suggestionContentLabel.frame.size.height+tableHeight+200)];
        }
        else
        {
            NSLog(@"Length 2");
            if ([self.suggestionContentLabel.text length] == 0 || self.suggestionContentLabel.text == nil)
            {
                self.suggestionContentLabel.text = @"No suggestions added";
                self.suggestionContentLabel.hidden = NO;
                [self estimatedHeight:[self.dictResponse objectForKey:@"doc_sugg"]];
                self.suggestionContentLabel.frame = CGRectMake(self.suggestionContentLabel.frame.origin.x, self.suggestionContentLabel.frame.origin.y, self.suggestionViewEdit.frame.size.width-20, heightLbl+self.suggestionContentLabel.frame.size.height);
                [self.suggestionContentLabel sizeToFit];
                [self.suggestionContentLabel setNumberOfLines:0];
                
            }
            
            self.suggestionContentTable.hidden = YES;
        }
        
    });

}
- (void)makeRequestToAddReports
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strSeccionName=[[NSUserDefaults standardUserDefaults]objectForKey:@"SessionName"];
    NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:sectionId,@"sessionid",self.selectedService.bookingRecNo,@"member_service_id",strSeccionName,@"session_name",self.updateTextView.text,@"comments", nil];
    [self uploadImage:dictTemp];
}
-(void)uploadImage:(NSDictionary *)info
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
    
    NSString *strUrl=[NSString stringWithFormat:@"%s/messages/create",kBaseUrl];
    
    AFHTTPRequestOperation * op = [manager POST:strUrl parameters:info constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        
        if ([imageData length] > 0)
        {
            //patientfile
            int r = arc4random_uniform(999999999);
            [formData appendPartWithFileData:imageData name:@"file" fileName:[NSString stringWithFormat:@"%d.JPG",r] mimeType:@"application/images"];
        }
        [manager.requestSerializer setTimeoutInterval:30.0];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        self.filePath.text = @"";
        if ([[responseObject objectForKey:@"authorized"]integerValue] == 0 && [[responseObject objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"ysudge:%@",responseObject);
                self.view.userInteractionEnabled = YES;
                self.imgViwPhoto.image = nil;
                [self makeRequestForRequests];
                
            });
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
         self.filePath.text = @"";
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
    
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [op start];
}
#pragma mark - Menu Methods
- (void)showUpdateView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.updateView.frame=CGRectMake(0,  self.updateView.frame.origin.y,  self.updateView.frame.size.width,  self.updateView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}
-(void)hideUpdateView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.updateView.frame=CGRectMake(viewSize.width,  self.updateView.frame.origin.y,  self.updateView.frame.size.width,  self.updateView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Textfield Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [textField resignFirstResponder];
    
    //return NO or YES, it doesn't matter
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.updateTextView)
    {
        if ([textView.text isEqualToString:@"No suggestions added"])
            self.updateTextView.text = nil;
    }
    self.updateLbl.hidden=YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"Length 3");
    if ([textView.text length] <=0)
    {
        self.updateLbl.hidden=NO;
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

- (void)doneButton:(id)sender {
    [self.updateTextView resignFirstResponder];
}

#pragma mark - Image Delegate
-(void)ShowImageInMainView:(NSString *)imagePath{
    [self imgaeZooming:imagePath];
}

-(void)openQlPreview:(NSString *)fileUrl{
    [self openFile:fileUrl];
}
-(void)showImage:(NSString *)imagePath{
     [self imgaeZooming:imagePath];
}
-(void)openQrlImage:(NSString *)fileUrl{
    [self openFile:fileUrl];
}
#pragma mark - Qlpreview
-(void)openFile:(NSString *)strFilePath{
    [self addSpinnerView];
    [HUD show:YES];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%s/%@",kBaseUrlLabReport,strFilePath]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        dispatch_async(dispatch_get_main_queue(),^{
            
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *fileComponents = [strFilePath componentsSeparatedByString:@"."];
        _pdfPath = [documentsDirectory stringByAppendingPathComponent:[@"file." stringByAppendingString:fileComponents[1]]];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        [data writeToFile:_pdfPath atomically:YES];
        
          BOOL success = [QLPreviewController canPreviewItem:[NSURL URLWithString:_pdfPath]];
            if (success) {
                QLPreviewController *previewer = [[QLPreviewController alloc] init];
                [previewer setDataSource:self];
                [previewer setCurrentPreviewItemIndex:0];
                [[self navigationController] presentViewController:previewer animated:YES completion:^{
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                }];
            } else {
                [HUD hide:YES];
                [HUD removeFromSuperview];
                pdfSuccess = NO;
                [self imgaeZooming:strFilePath];
 
            }
        
         });
    }];
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:_pdfPath];
}

-(void)previewControllerWillDismiss:(QLPreviewController *)controller{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:_pdfPath error:&error];
    if (success) {
        NSLog(@"deleted file");
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}
#pragma mark Prepare Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"zoomImageID"])
    {
        if (pdfSuccess) {
            ((SmartRxReportImageVC *)segue.destinationViewController).strImage = sender;
        } else {
            ((SmartRxReportImageVC *)segue.destinationViewController).webUrl = sender;
        }
        
    }
}

@end
