//
//  SmartRxMessageDetailsVC.m
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxMessageDetailsVC.h"
#import "SmartRxDashBoardVC.h"
#import "NSString+DateConvertion.h"
#import "SmartRxCarePlaneDetailsVC.h"
#import "SmartRxMessageViewController.h"
@interface SmartRxMessageDetailsVC ()
{
    NSString *alerttxt;
}
@end

@implementation SmartRxMessageDetailsVC

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
    [self navigationBackButton];
    alerttxt=[NSString stringWithFormat:@"%@", [self.dictMsgDetails objectForKey:@"alerttxt"]];
    [self estimatedHeight];
    if ([self.dictMsgDetails objectForKey:@"postop_rectype"])
    {
        if([[self.dictMsgDetails objectForKey:@"postop_rectype"]integerValue] > 0)
        {
            [self.imgMessage setImage:[UIImage imageNamed:@"c.png"]];
            self.lblSenderName.text = @"Care Alert";
            [self.indexZeroBtn setBackgroundImage:[UIImage imageNamed:@"view_msgdetail.png"] forState:UIControlStateNormal];
            [self.indexOneBtn setBackgroundImage:[UIImage imageNamed:@"ignore_msgdetail.png"] forState:UIControlStateNormal];
        }
        else
        {
            self.imgMessage.image = [UIImage imageNamed:@"m.png"];
            self.lblSenderName.text = @"Care Message";
            if ([[self.dictMsgDetails objectForKeyedSubscript:@"status"] isEqualToString:@"2"])
            {
                if([[self.dictMsgDetails objectForKey:@"dcw_type"]integerValue] == 1 || [[self.dictMsgDetails objectForKey:@"dcw_type"]integerValue] == 2)
                {
                    [self.indexZeroBtn setBackgroundImage:[UIImage imageNamed:@"book_msgdetail.png"] forState:UIControlStateNormal];
                }
                else
                    [self.indexZeroBtn setBackgroundImage:[UIImage imageNamed:@"task_complt_msgdetails.png"] forState:UIControlStateNormal];
            }
            else
            {
                if([[self.dictMsgDetails objectForKey:@"dcw_type"]integerValue] == 1 || [[self.dictMsgDetails objectForKey:@"dcw_type"]integerValue] == 2)
                {
                    [self.indexZeroBtn setBackgroundImage:[UIImage imageNamed:@"book_msgdetail.png"] forState:UIControlStateNormal];
                }
                else
                    [self.indexZeroBtn setBackgroundImage:[UIImage imageNamed:@"done_msgdetail.png"] forState:UIControlStateNormal];

            }
            
            [self.indexOneBtn setBackgroundImage:[UIImage imageNamed:@"ignore_msgdetail.png"] forState:UIControlStateNormal];
            
        }
    }
    //book_msgdetail@2x
    if([[self.dictMsgDetails objectForKey:@"operation"] integerValue] == 2)
    {
        self.lblSenderName.text = @"Promotions";
    }
    
    self.lblDateTime.text=[NSString timeFormating:[self.dictMsgDetails objectForKey:@"updateddate"] funcName:@"messagedetails"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark - Calculating Label Height

-(void)setLblYPostionAndHeight:(CGFloat )height{
    self.lblMessage.frame = CGRectMake(self.lblMessage.frame.origin.x, self.lblMessage.frame.origin.y, self.lblMessage.frame.size.width, height);
    
    self.lblMessage.text= [self convertHTML:alerttxt]; //[self.dictMsgDetails objectForKey:@"msg"];
    self.lblMessage.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    self.lblMessage.numberOfLines=10000;
    
    self.lblDateTime.frame=CGRectMake(self.lblDateTime.frame.origin.x, self.lblMessage.frame.origin.y+self.lblMessage.frame.size.height,  self.lblDateTime.frame.size.width, self.lblDateTime.frame.size.height);
}
-(NSString *)convertHTML :(NSString *)html {
    
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    return html;
}
-(void)estimatedHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(2, 0, 320,21)];
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    CGSize maximumLabelSize = CGSizeMake(296,9999);
    CGSize expectedLabelSize;
    
    expectedLabelSize = [[self convertHTML:alerttxt]  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    [self setLblYPostionAndHeight:expectedLabelSize.height+20];
}
-(void)indexZeroBtnClicked:(id)sender
{
    //    if (![[[_arrMsgDetails objectAtIndex:selectedIndex]objectForKey:@"status"] isEqualToString:@"2"])
    //    {
    ////            [self loadTrackers:path];
    //    }
    if ([self.dictMsgDetails objectForKey:@"postop_rectype"])
    {
        if([[self.dictMsgDetails objectForKey:@"postop_rectype"]integerValue] > 0)
        {
            [self makeRequestToUpdateMsgStatus:[self.dictMsgDetails objectForKey:@"recno"]statusVal:2];
            NSDictionary *dicttemp=[NSDictionary dictionaryWithObjectsAndKeys:[self.dictMsgDetails objectForKey:@"postop_rectype"],@"postop_rectype",[self.dictMsgDetails objectForKey:@"postopid"],@"postopid",[self.dictMsgDetails objectForKey:@"recno"],@"recno",[self.dictMsgDetails objectForKey:@"status"],@"status", nil];
            [self performSegueWithIdentifier:@"MsgDetailToCarePlanID" sender:dicttemp];
            
        }
        else
        {
            if([[self.dictMsgDetails objectForKey:@"dcw_type"]integerValue] == 1)
            {
                [self performSegueWithIdentifier:@"servFromMsg" sender:nil];
            }
            else if ([[self.dictMsgDetails objectForKey:@"dcw_type"]integerValue] == 2)
            {
                [self performSegueWithIdentifier:@"econFromMsg" sender:nil];
            }
            else if ([[self.dictMsgDetails objectForKey:@"status"] integerValue] >= 1)
                [self makeRequestToUpdateMsgStatus:[self.dictMsgDetails objectForKey:@"recno"] statusVal:2];
        }
    }
    else
    {
        if([[self.dictMsgDetails objectForKey:@"dcw_type"]integerValue] == 1)
        {
            [self performSegueWithIdentifier:@"servFromMsg" sender:nil];
        }
        else if ([[self.dictMsgDetails objectForKey:@"dcw_type"]integerValue] == 2)
        {
                [self performSegueWithIdentifier:@"econFromMsg" sender:nil];            
        }
        else if ([[self.dictMsgDetails objectForKey:@"status"] integerValue] >= 1)
            [self makeRequestToUpdateMsgStatus:[self.dictMsgDetails objectForKey:@"recno"] statusVal:2];
    }
}
-(void)indexOneBtnClicked:(id)sender
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"This message will be deleted" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    alertView.tag = 2020;
    [alertView show];
}

- (void)makeRequestToUpdateMsgStatus:(NSString *)msgID statusVal:(int)status
{
    //    if (![HUD isHidden]) {
    //        [HUD hide:YES];
    //    }
    //    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"sessionid=%@&msgid=%@&status=%d",sectionId,msgID,status];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mupmsgstatus"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 24 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"fromMsgDetails"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if ([self.dictMsgDetails objectForKey:@"postop_rectype"])
                if(![[self.dictMsgDetails objectForKey:@"postop_rectype"]integerValue] > 0)
                    [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
    }];
    
}
#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2020 && buttonIndex == 1)
    {
        [self makeRequestToUpdateMsgStatus:[self.dictMsgDetails objectForKey:@"recno"]statusVal:-1];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MsgDetailToCarePlanID"])
    {
        ((SmartRxCarePlaneDetailsVC *)segue.destinationViewController).strRectype=[sender objectForKey:@"postop_rectype"];
        ((SmartRxCarePlaneDetailsVC *)segue.destinationViewController).strTitle=[sender objectForKey:@"title"];
        ((SmartRxCarePlaneDetailsVC *)segue.destinationViewController).strOpId=[sender objectForKey:@"postopid"];
        
        //        if (![[sender objectForKey:@"status"] isEqualToString:@"2"])
        //        {
        //            ((SmartRxCarePlaneDetailsVC *)segue.destinationViewController).strQid=[sender objectForKey:@"recno"];
        //        }
    }
}

@end
