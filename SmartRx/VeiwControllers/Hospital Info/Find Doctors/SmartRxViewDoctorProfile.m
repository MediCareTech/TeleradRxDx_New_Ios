//
//  SmartRxViewDoctorProfile.m
//  SmartRx
//
//  Created by Anil Kumar on 15/10/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxViewDoctorProfile.h"
#import "SmartRxDashBoardVC.h"
#import "SmartRxBookAPPointmentVC.h"
#import "UIImageView+WebCache.h"
#import "SmartRxBookeConsultVC.h"

@interface SmartRxViewDoctorProfile ()
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    NSString *strRegisterCall;
    NSMutableArray *sectionTitlesArray;
    CGFloat viewWidth, viewHeight;
    CGSize viewSize;
}

@end
@implementation SmartRxViewDoctorProfile

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

- (IBAction)bookAppointmentButtonClicked:(id)sender
{
    self.doctorArray = [self.doctorArray mutableCopy];
    [self.doctorArray setObject:self.locationName forKey:@"locname"];
    [self.doctorArray setObject:self.locationId forKey:@"locid"];
    [self performSegueWithIdentifier:@"doctorBookAppointment" sender:self.doctorArray];
}

- (IBAction)bookEconsultButtonClicked:(id)sender
{
    self.doctorArray = [self.doctorArray mutableCopy];
    [self.doctorArray setObject:self.locationName forKey:@"locname"];
    [self.doctorArray setObject:self.locationId forKey:@"locid"];
    [self performSegueWithIdentifier:@"docProfileEconsult" sender:self.doctorArray];
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [self navigationBackButton];
    
    viewSize=[[UIScreen mainScreen]bounds].size;
    viewWidth = CGRectGetWidth(self.view.frame);
    viewHeight = CGRectGetHeight(self.view.frame);
    sectionTitlesArray = [[NSMutableArray alloc] init];
    sectionTitlesArray = [@[@"About",@"Profile"] mutableCopy];
    self.strTitle = [self.doctorArray objectForKey:@"deptname"];
    self.navigationItem.title=self.strTitle;
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    self.doctorName.text = [self.doctorArray objectForKey:@"dispname"];
    if ([self.doctorArray[@"qualification"] isKindOfClass:[NSString class]]) {
        self.qualification.text  = [self.doctorArray objectForKey:@"qualification"];

    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        if ([[self.doctorArray objectForKey:@"enable_econsult"] integerValue] == 1)
            self.econsultButton.hidden = NO;
        else
        {
            self.econsultButton.hidden = YES;
            self.appointmentButton.frame = CGRectMake((viewWidth/2)-(self.appointmentButton.frame.size.width/2), self.appointmentButton.frame.origin.y, self.appointmentButton.frame.size.width, self.appointmentButton.frame.size.height);
        }
        if ([[self.doctorArray objectForKey:@"enable_appointment"] integerValue] == 1)
            self.appointmentButton.hidden = NO;
        else
        {
            self.appointmentButton.hidden = YES;
            self.econsultButton.frame = CGRectMake((viewWidth/2)-(self.econsultButton.frame.size.width/2), self.econsultButton.frame.origin.y, self.econsultButton.frame.size.width, self.econsultButton.frame.size.height);
        }
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fromEconsultToDocProfile"] boolValue])
        {
            self.econsultButton.hidden = YES;
            self.appointmentButton.hidden = YES;
        }
            
    }
    else
    {
        self.econsultButton.hidden = YES;
        if ([[self.doctorArray objectForKey:@"enable_appointment"] integerValue] == 1)
        {
            self.appointmentButton.hidden = NO;
            self.appointmentButton.frame = CGRectMake((viewWidth/2)-(self.appointmentButton.frame.size.width/2), self.appointmentButton.frame.origin.y, self.appointmentButton.frame.size.width, self.appointmentButton.frame.size.height);
        }
        else
        {
            self.appointmentButton.hidden = YES;
        }
        
    }
    
    if ([self.doctorArray objectForKey:@"profilepic"] != [NSNull null])
    {
        NSString *sample = [NSString stringWithFormat:@"%s/%@",kAdminBaseUrl,[self.doctorArray objectForKey:@"profilepic"]];
        NSString *theURL = [sample stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.doctorDP.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:theURL]]];
    }
    else
    {
        self.doctorDP.image = [UIImage imageNamed:@"doctor_dp_bg.jpg"];
    }
    NSString *webText = [[self.doctorArray objectForKey:@"doc_details"] stringByAppendingString:@"<p style=\"padding:0px 0px 5px 5px;\">&nbsp<br/></p><p style=\"padding:0px 0px 5px 5px;\">&nbsp<br/></p>"];
    [self.doctorDetails loadHTMLString:webText baseURL:nil];
    self.doctorDetails.scrollView.bounces = NO;
    self.doctorDP.layer.cornerRadius = self.doctorDP.frame.size.height / 2;
    self.doctorDP.layer.masksToBounds = YES;
    self.doctorDP.layer.borderWidth = 2;
    self.doctorDP.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.doctorDP.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.doctorDP.layer setShadowOpacity:0.8];
    [self.doctorDP.layer setShadowRadius:3.0];
    [self.doctorDP.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    self.econsultButton.hidden = YES;
    self.appointmentButton.hidden = YES;
    [self makeSegmentView];
}

- (void)makeSegmentView
{
    // Tying up the segmented control to a scroll view
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 1)];
    topBorder.backgroundColor = [UIColor lightGrayColor];
    
    self.segmentedControl4 = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 1, viewWidth, 40)];
    self.segmentedControl4.sectionTitles = sectionTitlesArray;
    
    self.segmentedControl4.selectedSegmentIndex = 0;
    self.segmentedControl4.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    self.segmentedControl4.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor],  UITextAttributeFont:[UIFont systemFontOfSize:15]};//@{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.segmentedControl4.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:7.0/255.0 green:92.0/255.0 blue:176.0/255.0 alpha:1]};//@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]};
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
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, viewWidth, 800)];
    //    self.scrollView.backgroundColor = [UIColor lightGrayColor];
    // colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1];// colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(viewWidth * [self.segmentedControl4.sectionTitles count], 1);
    self.scrollView.delegate = self;
    //    [self.scrollView scrollRectToVisible:CGRectMake(viewWidth*4,0, viewWidth, 400) animated:NO];
    [self.segmentView addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.aboutView];
    [self.scrollView addSubview:self.backgroudView];
    
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
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

#pragma mark - prepareForSegue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"doctorBookAppointment"])
    {
        ((SmartRxBookAPPointmentVC *)segue.destinationViewController).doctorAppointmentDetails = [[NSMutableDictionary alloc] init];
        ((SmartRxBookAPPointmentVC *)segue.destinationViewController).doctorAppointmentDetails = sender;
        ((SmartRxBookAPPointmentVC *)segue.destinationViewController).dictResponse = self.dictResponse;
    }
    else if ([segue.identifier isEqualToString:@"docProfileEconsult"])
    {
//        SmartRxBookeConsultVC
        ((SmartRxBookeConsultVC *)segue.destinationViewController).doctorEconsultDetail = [[NSMutableDictionary alloc] init];
        ((SmartRxBookeConsultVC *)segue.destinationViewController).doctorEconsultDetail = sender;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //
}
@end
