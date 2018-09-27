//
//  SmartRxPHRDetailsVC.m
//  SmartRx
//
//  Created by Anil Kumar on 09/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxPHRDetailsVC.h"
#define BAR_POSITION @"POSITION"
#define BAR_HEIGHT @"HEIGHT"

@interface SmartRxPHRDetailsVC ()<ShowImageInMainView, QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
    
}

@end

@implementation SmartRxPHRDetailsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _responseReceived = NO;
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated
{
    
   
    
}
-(void)updateUI{
    if (self.tblPhrDetails == nil)
    {
        self.tblPhrDetails = [[UITableView alloc] initWithFrame:CGRectMake(0, 330, 320, 303)];
        self.tblPhrDetails.contentOffset = CGPointMake(0, -64);
        self.tblPhrDetails.delegate = self;
        self.tblPhrDetails.dataSource = self;
        [self.view addSubview:self.tblPhrDetails];
    }
    if(self.tblPhrDetails.delegate == nil)
        self.tblPhrDetails.delegate = self;
    if(self.tblPhrDetails.dataSource == nil)
        self.tblPhrDetails.dataSource = self;
    
    _dateGraphArray = [[NSMutableArray alloc]init];
    _valueGraphArray = [[NSMutableArray alloc]init];
    _value2GraphArray = [[NSMutableArray alloc]init];
    self.data = [[NSMutableArray alloc]init];
    self.data2 = [[NSMutableArray alloc]init];
    self.phrGraphArray = [[NSMutableArray alloc]init];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self addSpinnerView];
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
    self.hostingView.allowPinchScaling = YES;
    self.phrID = 0;
    _editClicked = NO;
    _pickerUINeeded = [[self.dictPhrDetails objectForKey:@"pickerUINeeded"] boolValue];
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFaq.tag=1;
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_add_report.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [self.dictPhrDetails setObject:@"Add" forKey:@"buttonTextString"];
    [self.dictPhrDetails removeObjectForKey:@"phrid"];
    [btnFaq addTarget:self action:@selector(addPhr:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
    
    self.compareTitleString = [self.dictPhrDetails objectForKey:@"testString"];
    
   
//    if (![HUD isHidden]) {
//        [HUD hide:YES];
//    }
}
-(void)viewWillAppear:(BOOL)animated{
     [self updateUI];
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
        [self makeRequestToGetPhrDetails];
    else
    {
        self.phrResponse = [[[SmartRxDB sharedDBManager] fetchPHRData:self.navigationItem.title] mutableCopy];
        [self processPHRResponse];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation Item methods
-(void)navigationBackButton
{
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
}

-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Spinner method
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}

-(void)sectionIdGenerated:(id)sender
{
    
}

#pragma mark - Add PHR Details

- (void)addPhr:(UIButton *)sender
{
    if(sender.tag==1 && _editClicked)
    {
        [self.dictPhrDetails setObject:@"Add" forKey:@"buttonTextString"];
        [self.dictPhrDetails removeObjectForKey:@"lastHeightValue"];
        [self.dictPhrDetails removeObjectForKey:@"lastHeightUnit"];
        [self.dictPhrDetails removeObjectForKey:@"phrid"];
        [self.dictPhrDetails removeObjectForKey:@"value2"];
        [self.dictPhrDetails removeObjectForKey:@"value"];
        [self.dictPhrDetails removeObjectForKey:@"heightComponent0"];
        [self.dictPhrDetails removeObjectForKey:@"heightComponent1"];
        [self.dictPhrDetails removeObjectForKey:@"weightComponent0"];
        [self.dictPhrDetails removeObjectForKey:@"weightComponent1"];
        [self.dictPhrDetails removeObjectForKey:@"component0"];
        [self.dictPhrDetails removeObjectForKey:@"component1"];
        [self.dictPhrDetails removeObjectForKey:@"component2"];
    }
    if (_pickerUINeeded)
        if ([self.navigationItem.title isEqualToString:@"BMI"])
        {
//            if ([self.phrResponse count])
//            {
//                [self.dictPhrDetails setObject:_lastHeightValue forKey:@"lastHeightValue"];
//                [self.dictPhrDetails setObject:_lastHeightUnit forKey:@"lastHeightUnit"];
//            }
            
            [self performSegueWithIdentifier:@"AddBMI" sender:self.dictPhrDetails];
        }
        else
            [self performSegueWithIdentifier:@"AddPHRDetails" sender:self.dictPhrDetails];
        else
            [self performSegueWithIdentifier:@"AddPHRDetailsNumbers" sender:self.dictPhrDetails];
    
}

#pragma mark - prepareForSegue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddPHRDetails"])
    {
        ((SmartRxAddPhrUIPicker *)segue.destinationViewController).navigationItem.title = [NSString stringWithFormat:@"Add %@",[sender objectForKey:@"Title"]];
        ((SmartRxAddPhrUIPicker *)segue.destinationViewController).phrDetailsDictionary = [NSMutableDictionary alloc];
        ((SmartRxAddPhrUIPicker *)segue.destinationViewController).phrDetailsDictionary = sender;
    }
    else if ([segue.identifier isEqualToString:@"AddPHRDetailsNumbers"])
    {
        ((SmartRxAddPhrNumbers *)segue.destinationViewController).navigationItem.title = [NSString stringWithFormat:@"Add %@",[sender objectForKey:@"Title"]];
        ((SmartRxAddPhrNumbers *)segue.destinationViewController).phrDetailsDictionary = [NSMutableDictionary alloc];
        ((SmartRxAddPhrNumbers *)segue.destinationViewController).phrDetailsDictionary = sender;
        
    }
    else if ([segue.identifier isEqualToString:@"AddBMI"])
    {
        ((SmartRxAddBMI *)segue.destinationViewController).navigationItem.title = [NSString stringWithFormat:@"%@",self.navigationItem.title];
        ((SmartRxAddBMI *)segue.destinationViewController).phrDetailsDictionary = [NSMutableDictionary alloc];
        ((SmartRxAddBMI *)segue.destinationViewController).phrDetailsDictionary = sender;
        
    }
}

-(void)makeRequestToGetPhrDetails
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    
    NSString *sessionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&type=%ld",@"sessionid",sessionId, (long)[[self.dictPhrDetails objectForKey:@"type"] integerValue]];
    // NSString *bodyText = [NSString stringWithFormat:@"%@=%@&type=%@",@"sessionid",sessionId,@"7"];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mgetphr"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"response.......:%@",response);
        self.phrResponse = [[NSMutableArray alloc] initWithArray:[response objectForKey:@"phr"]];
        if ([self.phrResponse count])
            [[SmartRxDB sharedDBManager] savePHRData:self.navigationItem.title details:self.phrResponse];
        
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
//                self.phrResponse = [[NSMutableArray alloc]init];
//                NSArray *tempArray = response[@"phr"];
//                for (NSDictionary *dict in tempArray) {
//                    if ([dict[@"height"] isKindOfClass:[NSString class]]) {
//                        [self.phrResponse addObject:dict];
//                    }
//                }
                [self processPHRResponse];
            });
        }
    } failureHandler:^(id response) {
        
        [self customAlertView:@"Error" Message:@"The request timed out. Loading Personal Health Record failed" tag:0];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        _responseReceived = YES;
        
    }];
}


-(void)processPHRResponse
{
    self.phrGraphArray = self.phrResponse;
    if([self.phrResponse count] >0)
    {
//        if ([self.navigationItem.title isEqualToString:@"BMI"])
//        {
//            _lastHeightValue = [[self.phrResponse objectAtIndex:0]  objectForKey:@"height"];
//            _lastHeightUnit = [[self.phrResponse objectAtIndex:0] objectForKey:@"height_unit"];
//        }
        self.view.userInteractionEnabled = YES;
        for (int i=0;i<[self.phrResponse count];i++)
        {
            NSString *str = [[self.phrResponse objectAtIndex:i] objectForKey:self.compareTitleString];
            if ([str isKindOfClass:[NSString class]]) {
            
            if([NSStringFromClass([[[self.phrResponse objectAtIndex:i] objectForKey:self.compareTitleString] class]) isEqualToString:@"__NSCFNumber"])
            {
                if ([[self.phrResponse objectAtIndex:i] objectForKey:self.compareTitleString] == 0)
                    [self.phrResponse removeObjectAtIndex:i];
            }
            else if ([[[self.phrResponse objectAtIndex:i] objectForKey:self.compareTitleString] length] <= 0 || [[[self.phrResponse objectAtIndex:i] objectForKey:self.compareTitleString] isEqualToString:@"0"])
            {
                [self.phrResponse removeObjectAtIndex:i];
                --i;
                
            }
            }
            
        }
        self.phrGraphArray = [self sortArrayBasedOndate:self.phrGraphArray];
        
        
        if(![self.navigationItem.title isEqualToString:@"Daily Activities"])
        {
            [self drawBarGraph];
        }
        else
        {
            if (self.tempTable != nil)
            {
                self.tblPhrDetails.frame = CGRectMake(0, 68, self.view.bounds.size.width, self.view.bounds.size.height);
                self.tempTable = nil;
            }
            else
                self.tblPhrDetails.frame = CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height);
        }
        NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"checked_date" ascending:YES];
        aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"checked_date" ascending:NO];
        [self.phrResponse sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
        self.tblPhrDetails.hidden = NO;
        [self.tblPhrDetails reloadData];
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }
    else
    {
        self.tempTable = [[UITableView alloc]init];
        self.tempTable.frame = self.tblPhrDetails.frame;
        self.tempTable.contentOffset = self.tblPhrDetails.contentOffset;
        [self.tblPhrDetails removeFromSuperview];
        self.tblPhrDetails = nil;
        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 320, 100)];
        if ([self.navigationItem.title isEqualToString:@"BMI"])
        {
            errorLabel.text = [NSString stringWithFormat:@"\u2022 No Health Records found. \n\u2022 Use (+) icon to add height and weight"];
        }
        else
        {
            errorLabel.text = [NSString stringWithFormat:@"\u2022 No Health Records found. \n\u2022 Use (+) icon to add %@",self.navigationItem.title];
        }
        
        errorLabel.numberOfLines = 10;
        [self.view addSubview:errorLabel];
       
    }
    _responseReceived = YES;

}
#pragma mark -Sort Array using date-Time Method
-(NSMutableArray *)sortArrayBasedOndate:(NSMutableArray *)arraytoSort
{
    NSDateFormatter *fmtDate = [[NSDateFormatter alloc] init];
    [fmtDate setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *fmtTime = [[NSDateFormatter alloc] init];
    [fmtTime setDateFormat:@"HH:mm"];
    
    NSComparator compareDates = ^(id string1, id string2)
    {
        NSDate *date1 = [fmtDate dateFromString:string1];
        NSDate *date2 = [fmtDate dateFromString:string2];
        
        return [date1 compare:date2];
    };
    
    NSComparator compareTimes = ^(id string1, id string2)
    {
        NSDate *time1 = [fmtTime dateFromString:string1];
        NSDate *time2 = [fmtTime dateFromString:string2];
        
        return [time1 compare:time2];
    };
    
    NSSortDescriptor * sortDesc1 = [[NSSortDescriptor alloc] initWithKey:@"start_date" ascending:YES comparator:compareDates];
    NSSortDescriptor * sortDesc2 = [NSSortDescriptor sortDescriptorWithKey:@"starts" ascending:YES comparator:compareTimes];
    [arraytoSort sortUsingDescriptors:@[sortDesc1, sortDesc2]];
    
    return arraytoSort;
}

#pragma mark -Alertview Delegate Method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self backBtnClicked:nil];
        //[self.navigationController popViewControllerAnimated:YES];
    }
    else if (buttonIndex == 1)
    {
        [self.dictPhrDetails setObject:@"Add" forKey:@"buttonTextString"];
        [self.dictPhrDetails removeObjectForKey:@"phrid"];
        [self addPhr:nil];
    }
}
#pragma mark - Table view data source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.phrResponse count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *unitString = @"";
    NSMutableDictionary *dictString = [[NSMutableDictionary alloc]init];
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    if([self.navigationItem.title isEqualToString:@"Blood Sugar"])
    {
        [dictString setObject:@"blood_sugar" forKey:@"valueString"];
        if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"sugar_unit"] integerValue] == 1)
        {
            unitString = @"mg/dl";
        }
        else
        {
            unitString = @"mmol/L";
        }
        _yAxisString = unitString;
        if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"sugar_check"] integerValue] == 1)
        {
            unitString = [unitString stringByAppendingString:@" - Fasting"];
            _yAxisString2 = @"Fasting";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"sugar_check"] integerValue] == 2)
        {
            unitString = [unitString stringByAppendingString:@" - Post Breakfast"];
            _yAxisString2 = @"Post Breakfast";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"sugar_check"] integerValue] == 3)
        {
            unitString = [unitString stringByAppendingString:@" - Before Lunch"];
            _yAxisString2 = @"Before Lunch";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"sugar_check"] integerValue] == 4)
        {
            unitString = [unitString stringByAppendingString:@" - Post Lunch"];
            _yAxisString2 = @"Post Lunch";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"sugar_check"] integerValue] == 5)
        {
            unitString = [unitString stringByAppendingString:@" - Before dinner"];
            _yAxisString2 = @"Before dinner";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"sugar_check"] integerValue] == 6)
        {
            unitString = [unitString stringByAppendingString:@" - Post Dinner"];
            _yAxisString2 = @"Post Dinner";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"sugar_check"] integerValue] == 7)
        {
            unitString = [unitString stringByAppendingString:@" - Random"];
            _yAxisString2 = @"Random";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"sugar_check"] integerValue] == 8)
        {
            unitString = [unitString stringByAppendingString:@" - Insulin"];
            _yAxisString2 = @"Insulin";
        }
        else
        {
            unitString = [unitString stringByAppendingString:@" - Basal Insulin"];
            _yAxisString2 = @"Basal Insulin";
        }
    }
    else if([self.navigationItem.title isEqualToString:@"Daily Activities"])
    {
        [dictString setObject:@"daily_activity" forKey:@"valueString"];
        if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"activity_type"] integerValue] ==1)
        {
            unitString = @"BriskWalk";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"activity_type"] integerValue] ==2)
        {
            unitString = @"Regular Walk";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"activity_type"] integerValue] ==3)
        {
            unitString = @"Jogging";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"activity_type"] integerValue] ==4)
        {
            unitString = @"Yoga";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"activity_type"] integerValue] ==5)
        {
            unitString = @"Aerobics";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"activity_type"] integerValue] ==6)
        {
            unitString = @"Swimming";
        }
        else if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"activity_type"] integerValue] ==7)
        {
            unitString = @"Cycling";
        }
        else
        {
            unitString = @"Others";
        }
    }
    else if ([self.navigationItem.title isEqualToString:@"Pulse"])
    {
        [dictString setObject:@"pulse" forKey:@"valueString"];
        unitString = [unitString stringByAppendingString:@" - BPM"];
    }
    else if ([self.navigationItem.title isEqualToString:@"Temperature"])
    {
        [dictString setObject:@"temperature" forKey:@"valueString"];
        unitString = [unitString stringByAppendingString:@"°F"];
    }
    
    
    if([self.navigationItem.title isEqualToString:@"Blood Pressure"])
    {
        //        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width-40, cell.textLabel.frame.size.height);
        NSString *bySystolicStr = [[self.phrResponse objectAtIndex:indexPath.row] objectForKey:@"bp_systolic"];
         NSString *diastolicStr = [[self.phrResponse objectAtIndex:indexPath.row] objectForKey:@"bp_disambiguation"];
        if (![bySystolicStr isKindOfClass:[NSString class]]) {
            bySystolicStr = @"0";
        }
        if (![diastolicStr isKindOfClass:[NSString class]]) {
            diastolicStr = @"0";
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"Systolic(BP)  : %@mm/hg\nDiastolic(BP) : %@mm/hg",bySystolicStr,diastolicStr];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
    }
    else if ([self.navigationItem.title isEqualToString:@"BMI"])
    {
        
        cell.textLabel.text = [NSString stringWithFormat:@"BMI - %@",[[self.phrResponse objectAtIndex:indexPath.row] objectForKey:@"bmi"]];
        
       // [dictString setObject:@"bmi" forKey:@"valueString"];
       // unitString = [unitString stringByAppendingString:@"BMI - "];
        
//        NSString *unitString2 = @"";
//        if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"height_unit"] integerValue] == 1)
//        {
//            unitString = @"Cm";
//        }
//        else
//        {
//            unitString = @"Ft";
//        }
//        
//        if ([[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"weight_unit"] integerValue] == 1)
//        {
//            unitString2 = @"Kg";
//        }
//        else
//        {
//            unitString2 = @"Lb";
//        }
//        cell.textLabel.text = [NSString stringWithFormat:@"Height : %@  %@\nWeight : %@  %@",[[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"height"],unitString, [[self.phrResponse objectAtIndex:indexPath.row]objectForKey:@"weight"],unitString2];
//        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        cell.textLabel.numberOfLines = 0;
//        cell.textLabel.font = [UIFont systemFontOfSize:14];
//        cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[[self.phrResponse objectAtIndex:indexPath.row] objectForKey:[dictString objectForKey:@"valueString"]],unitString];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
    }
    
    [cell.detailTextLabel setTextColor:[UIColor grayColor]];
    NSString *tempString = [NSString stringWithFormat:@"%@ %@",[[self.phrResponse objectAtIndex:indexPath.row] objectForKey:@"checked_date"],[[self.phrResponse objectAtIndex:indexPath.row] objectForKey:@"checked_time"]];
    NSString *dateString = [NSString timeFormating:tempString funcName:@""];
    _graphDateString = [NSString timeFormating:tempString funcName:@"details"];
    [cell.detailTextLabel setText:dateString];
    UIImage *image = [UIImage imageNamed:@"editsmall.png"];
    UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(self.tblPhrDetails.frame.size.width-54, 0, image.size.width+10, image.size.height+10)];
    [imageButton setImage:image forState:UIControlStateNormal];
    if ([[self.phrResponse objectAtIndex:indexPath.row] objectForKey:@"phrid"] != [NSNull null])
        self.phrID = [[[self.phrResponse objectAtIndex:indexPath.row] objectForKey:@"phrid"] integerValue];
    else
        self.phrID = 0;
    [imageButton setTag:self.phrID];
    [imageButton addTarget:self action:@selector(editPhrButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //[cell.contentView addSubview:imageButton];
    //    [cell bringSubviewToFront:cell.contentView];
    [cell.contentView setUserInteractionEnabled:YES];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"The row selected is : %d", indexPath.row);
}

- (IBAction)editPhrButtonClicked:(UIButton *)sender
{
    int i=0;
    _editClicked = YES;
    for(int k=0;k<[self.phrResponse count];k++)
    {
        if ([[self.phrResponse objectAtIndex:k] objectForKey:@"phrid"] != [NSNull null])
        {
            if (sender.tag == [[[self.phrResponse objectAtIndex:k] objectForKey:@"phrid"] integerValue]) {
                break;
            }
        }
        i++;
    }
    if([self.navigationItem.title isEqualToString:@"Blood Sugar"])
    {
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"blood_sugar"] forKey:@"component0"];
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"sugar_unit"] forKey:@"component1"];
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"sugar_check"] forKey:@"component2"];
    }
    else if([self.navigationItem.title isEqualToString:@"Daily Activities"])
    {
        NSArray *array = [[[self.phrResponse objectAtIndex:i]objectForKey:@"daily_activity"] componentsSeparatedByString:@" "];
        [self.dictPhrDetails setObject:[array objectAtIndex:0] forKey:@"component0"];
        [self.dictPhrDetails setObject:[array objectAtIndex:1] forKey:@"component1"];
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"activity_type"] forKey:@"component2"];
    }
    else if ([self.navigationItem.title isEqualToString:@"Pulse"])
    {
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"pulse"] forKey:@"value"];
    }
    else if ([self.navigationItem.title isEqualToString:@"Temperature"])
    {
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"temperature"] forKey:@"value"];
    }
    
    if([self.navigationItem.title isEqualToString:@"Blood Pressure"])
    {
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"bp_systolic"] forKey:@"value"];
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"bp_disambiguation"] forKey:@"value2"];
    }
    else if ([self.navigationItem.title isEqualToString:@"BMI"])
    {
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"height"] forKey:@"heightComponent0"];
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"height_unit"] forKey:@"heightComponent1"];
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"weight"] forKey:@"weightComponent0"];
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"weight_unit"] forKey:@"weightComponent1"];
    }
    
    
    if (sender.tag != 0)
    {
        [self.dictPhrDetails setObject:[NSString stringWithFormat:@"%d",sender.tag] forKey:@"phrid"];
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"checked_date"] forKey:@"checked_date"];
        [self.dictPhrDetails setObject:[[self.phrResponse objectAtIndex:i]objectForKey:@"checked_time"] forKey:@"checked_time"];
    }
    
    [self.dictPhrDetails setObject:@"Update" forKey:@"buttonTextString"];
    [self addPhr:nil];
}

- (void)drawBarGraph
{
    [self addSpinnerView];
    NSString *value = @"";
    NSString *value2 = nil;
    NSString *titleString = @"";
    NSString *plotIdentifier = @"";
    NSString *plotIdentifer2 = @"";
    if([self.navigationItem.title isEqualToString:@"Blood Pressure"])
    {
        value = @"bp_systolic";
        plotIdentifier = @"Systolic(BP)";
        value2 = @"bp_disambiguation";
        plotIdentifer2 = @"Diastolic(BP)";
    }
    else if ([self.navigationItem.title isEqualToString:@"Pulse"])
    {
        value = @"pulse";
        plotIdentifier =@"pulse";
    }
    else if ([self.navigationItem.title isEqualToString:@"Temperature"])
    {
        value = @"temperature";
    }
    else if([self.navigationItem.title isEqualToString:@"Blood Sugar"])
    {
        value = @"blood_sugar_mg";
        plotIdentifier = @"Fasting";
        value2 = @"sugar_check";
        plotIdentifer2 = @"Post Breakfast";
        
    } else if ([self.navigationItem.title isEqualToString:@"BMI"])
    {
        value = @"bmi";
        plotIdentifier = @"BMI";
    }
    int k=0;
    double height = 0.0;
    double position;
    int j=0;
    for (int i = ([self.phrGraphArray count]-1); i >= 0  ; i--)
    {
        NSString *tempString = [NSString stringWithFormat:@"%@ %@",[[self.phrResponse objectAtIndex:i] objectForKey:@"checked_date"],[[self.phrResponse objectAtIndex:i] objectForKey:@"checked_time"]];
        _graphDateString = [NSString timeFormating:tempString funcName:@"details"];
        if (j>0)
        {
            if (![_graphDateString isEqualToString:[_dateGraphArray objectAtIndex:j-1]])
            {
                position = k*30; //Bars will be 10 pts away from each other
                k++;
            }
        }
        if(k==0)
        {
            position = 1;
            k++;
        }
        //![self.navigationItem.title isEqualToString:@"BMI"] &&
        if( ![self.navigationItem.title isEqualToString:@"Blood Sugar"])
        {
            height = [[[self.phrGraphArray objectAtIndex:i] objectForKey:value]doubleValue];
        
            [_valueGraphArray addObject:[[self.phrGraphArray objectAtIndex:i] objectForKey:value]];
            //            NSString *tempString = [NSString stringWithFormat:@"%@ %@",[[self.phrResponse objectAtIndex:i] objectForKey:@"checked_date"],[[self.phrResponse objectAtIndex:i] objectForKey:@"checked_time"]];
            //            _graphDateString = [NSString timeFormating:tempString funcName:@"details"];
            [_dateGraphArray addObject:_graphDateString];
            NSDictionary *bar = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:position],BAR_POSITION,
                                 [NSNumber numberWithDouble:height],BAR_HEIGHT,
                                 nil];
            [self.data addObject:bar];
            if (value2 != nil)
            {
                
                NSString *hightStr = [[self.phrGraphArray objectAtIndex:i] objectForKey:value2];
                
                if (![hightStr isKindOfClass:[NSString class]]) {
                    hightStr = @"0";
                }
                
                
                    
                
                height = [hightStr doubleValue];
                NSDictionary *bar2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithDouble:position],BAR_POSITION,
                                      [NSNumber numberWithDouble:height],BAR_HEIGHT,
                                      nil];

                [_value2GraphArray addObject:hightStr];
                [self.data2 addObject:bar2];
                
            }
        }
        else if ([self.navigationItem.title isEqualToString:@"Blood Sugar"])
        {
            //            NSString *tempString = [NSString stringWithFormat:@"%@ %@",[[self.phrResponse objectAtIndex:i] objectForKey:@"checked_date"],[[self.phrResponse objectAtIndex:i] objectForKey:@"checked_time"]];
            //            _graphDateString = [NSString timeFormating:tempString funcName:@"details"];
            [_dateGraphArray addObject:_graphDateString];
            
            if (value2 != nil && [[[self.phrGraphArray objectAtIndex:i] objectForKey:value2] integerValue] != 1)
            {
                height = [[[self.phrGraphArray objectAtIndex:i] objectForKey:value]doubleValue];
                NSDictionary *bar2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithDouble:position],BAR_POSITION,
                                      [NSNumber numberWithDouble:height],BAR_HEIGHT,
                                      nil];
                [_value2GraphArray addObject:[[self.phrGraphArray objectAtIndex:i] objectForKey:value]];
                [self.data2 addObject:bar2];
            }
            else
            {
                height = [[[self.phrGraphArray objectAtIndex:i] objectForKey:value]doubleValue];
                [_valueGraphArray addObject:[[self.phrGraphArray objectAtIndex:i] objectForKey:value]];
                
                NSDictionary *bar = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithDouble:position],BAR_POSITION,
                                     [NSNumber numberWithDouble:height],BAR_HEIGHT,
                                     nil];
                [self.data addObject:bar];
            }
            
        }
        else
        {
            //            NSString *tempString = [NSString stringWithFormat:@"%@ %@",[[self.phrResponse objectAtIndex:i] objectForKey:@"checked_date"],[[self.phrResponse objectAtIndex:i] objectForKey:@"checked_time"]];
            //            _graphDateString = [NSString timeFormating:tempString funcName:@"details"];
            [_dateGraphArray addObject:_graphDateString];
            float heightVal = 0.0;
            
            if ([[[self.phrGraphArray objectAtIndex:i] objectForKey:@"height"] isKindOfClass:[NSString class]]) {

            heightVal = [[[self.phrGraphArray objectAtIndex:i] objectForKey:@"height"] floatValue];
            
            
            if([[[self.phrGraphArray objectAtIndex:i] objectForKey:@"height_unit"] integerValue] == 1)
            {
                heightVal = heightVal * 0.01;
            }
            else
            {
                heightVal = heightVal * 0.304;
            }
            } else {
                height = [@"" integerValue];
            }
            int weightVal = [[[self.phrGraphArray objectAtIndex:i] objectForKey:@"weight"] integerValue];
            if([[[self.phrGraphArray objectAtIndex:i] objectForKey:@"weight_unit"] integerValue] == 2)
            {
                weightVal = weightVal * 0.453;
            }
            height = weightVal / (heightVal * heightVal);
            [_valueGraphArray addObject:[[self.phrGraphArray objectAtIndex:i] objectForKey:@"weight"]];
            //[NSString stringWithFormat:@"%f",height]];
            NSDictionary *bar = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:position],BAR_POSITION,
                                 [NSNumber numberWithDouble:height],BAR_HEIGHT,
                                 nil];
            [self.data addObject:bar];
        }
        //        k++;
        j++;
    }
    
    NSArray *copy = [_dateGraphArray copy];
    NSInteger index = [copy count] - 1;
    for (id object in [copy reverseObjectEnumerator]) {
        if ([_dateGraphArray indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
            [_dateGraphArray removeObjectAtIndex:index];
        }
        index--;
    }
    
    _customTickLocations = [[NSMutableArray alloc] init];
    k=0;
    for (int i=0;i<[_dateGraphArray count];i++)
    {
        if (i==0) {
            [_customTickLocations addObject:@2];
            k=i;
        }
        else
        {
            [_customTickLocations addObject:@(k+30)];
            k=(k+30);
        }
        
    }
    
    
    // Create barChart from theme
    _hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 44, 320, 286)];
    [self.view addSubview:_hostingView];
    
    _graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [_graph applyTheme:theme];
    _hostingView.hostedGraph = _graph;
    _hostingView.allowPinchScaling = YES;
    _graph.title = titleString;
    
    _graph.backgroundColor = [UIColor clearColor].CGColor;
    _graph.backgroundColor = [UIColor clearColor].CGColor;
    _graph.plotAreaFrame.paddingLeft   = 30.0;
    _graph.plotAreaFrame.paddingBottom = 40.0;
    NSNumber *max = [_valueGraphArray valueForKeyPath:@"@max.intValue"];
    NSNumber *max2 = 0;
    if (value2 != nil)
    {
        max2 = [_value2GraphArray valueForKeyPath:@"@max.intValue"];
    }
    if ([max2 floatValue] > [max floatValue])
    {
        max = max2;
    }
    
    if ([max isLessThan:[NSNumber numberWithInt:100]])
    {
        max = [NSNumber numberWithInt:100];
    }
    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(200.0)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromFloat([max floatValue]+50)];
    _graphPlotConstant          = [[CPTPlotRange alloc] init];
    _graphPlotConstant          = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(200.0)];
    if([self.phrGraphArray count]>7)
        plotSpace.globalXRange      = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(400.0)];
    else
        plotSpace.globalXRange          = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(200.0)];
    
    plotSpace.globalYRange          = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromFloat([max floatValue]+50)];
    
    
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *)_graph.axisSet;
    CPTXYAxis *x                    = axisSet.xAxis;
    x.majorIntervalLength           = CPTDecimalFromDouble(150.0);
    x.minorTicksPerInterval         = 0;
    x.orthogonalCoordinateDecimal   = CPTDecimalFromDouble(2.0);
    x.delegate                      = self;
    x.visibleRange                  = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(300.0)];
    x.gridLinesRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(300.0)];
    x.axisConstraints               = [CPTConstraints constraintWithLowerOffset:0];
    
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength           = CPTDecimalFromDouble(100.0);
    y.minorTicksPerInterval         = 5;
    y.orthogonalCoordinateDecimal   = CPTDecimalFromDouble(2.0);
    y.delegate        = self;
    y.visibleRange    = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromFloat([max floatValue]+50)];
    y.gridLinesRange  = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromFloat([max floatValue]+50)];
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];
    CPTMutableTextStyle *textStyle  = [CPTMutableTextStyle textStyle];
    textStyle.fontName              = @"Helvetica";
    textStyle.fontSize              = 8;
    
    y.labelTextStyle = textStyle;
    
    
    CPTScatterPlot *boundLinePlot  = [[CPTScatterPlot alloc] init];
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit        = 1.0;
    lineStyle.lineWidth         = 3.0;
    lineStyle.lineColor         = [CPTColor colorWithComponentRed:39.0f/255.0f green:159.0f/255.0f blue:216.0f/255.0f alpha:1.0f];//[CPTColor blueColor];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.identifier    = @"Plot1";
   
    if (value2 != nil)
    {
        boundLinePlot.identifier    = plotIdentifier;
    }
    boundLinePlot.dataSource    = self;

    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor colorWithComponentRed:39.0f/255.0f green:159.0f/255.0f blue:216.0f/255.0f alpha:1.0f];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:39.0f/255.0f green:159.0f/255.0f blue:216.0f/255.0f alpha:1.0f]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(5.0, 5.0);
    
    if ([max isLessThanOrEqualTo:[NSNumber numberWithInt:140]])
    {
        y.majorIntervalLength           = CPTDecimalFromDouble(20.0);
        y.minorTicksPerInterval         = 1;
    }
    
    
    if ([self.data count] == 1 || [_dateGraphArray count] == 1)
    {
        x.orthogonalCoordinateDecimal   = CPTDecimalFromDouble(10.0);
        plotSymbol.size          = CGSizeMake(10.0, 10.0);
        plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor greenColor]];
    }
    if ([self.navigationItem.title isEqualToString:@"BMI"])
    {
        plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(10.0) length:CPTDecimalFromFloat(50.0)];
        y.majorIntervalLength           = CPTDecimalFromDouble(5.0);
        y.minorTicksPerInterval         = 1;
        y.orthogonalCoordinateDecimal   = CPTDecimalFromDouble(20.0);
    }
    boundLinePlot.plotSymbol = plotSymbol;
    [_graph addPlot:boundLinePlot];
    
    if (value2 != nil)
    {
        textStyle.fontSize              = 11;
        _graph.legend = [CPTLegend legendWithGraph:_graph];
        _graph.legend.textStyle = textStyle;
        _graph.legend.swatchSize = CGSizeMake(20.0, 5.0);
        
        // I had to setup number of Rows. Otherwise, on iOS7 CorePlot adds two rows. However, with two rows the titles are also cut-off.
        _graph.legend.numberOfRows = 1;
        
        CPTScatterPlot *boundLinePlot2  = [[CPTScatterPlot alloc] init];
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.miterLimit        = 1.0;
        //        lineStyle.dashPattern = @[@5.0, @5.0];
        lineStyle.lineWidth         = 3.0;
        lineStyle.lineColor         = [CPTColor blackColor];
        boundLinePlot2.dataLineStyle = lineStyle;
        boundLinePlot2.identifier    = plotIdentifer2;
        boundLinePlot2.dataSource    = self;
        
        CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor = [CPTColor blackColor];
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor blackColor]];
        plotSymbol.lineStyle     = symbolLineStyle;
        plotSymbol.size          = CGSizeMake(5.0, 5.0);
        
        if ([self.data2 count] == 1 || [_dateGraphArray count] == 1)
        {
            plotSymbol.size          = CGSizeMake(10.0, 10.0);
            plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor magentaColor]];
        }
        
        boundLinePlot2.plotSymbol = plotSymbol;
        
        
        
        [_graph addPlot:boundLinePlot2];
        
        _graph.legend = [CPTLegend legendWithGraph:_graph];
        _graph.legend.textStyle = textStyle;
        _graph.legend.swatchSize = CGSizeMake(23.0, 5.0);
        // I had to setup number of Rows. Otherwise, on iOS7 CorePlot adds two rows. However, with two rows the titles are also cut-off.
        _graph.legend.numberOfRows = 1;
    }
    [HUD hide:YES];
    [HUD removeFromSuperview];
}

#pragma mark -
#pragma mark Axis Delegate Methods

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    if (axis.coordinate == CPTCoordinateX)
    {
        CPTMutableTextStyle *textStyle  = [CPTMutableTextStyle textStyle];
        textStyle.fontName              = @"Helvetica";
        textStyle.fontSize              = 8;
        NSArray *xAxisLabels         = _dateGraphArray;
        NSMutableSet *xLocations = [NSMutableSet set];
        NSMutableSet *customLabels   = [NSMutableSet setWithCapacity:[xAxisLabels count]];
        for ( NSUInteger i = 0; i < [xAxisLabels count]; i++ )
        {
            
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%@",[xAxisLabels objectAtIndex:i]]  textStyle:textStyle];
            label.tickLocation = CPTDecimalFromInteger([[_customTickLocations objectAtIndex:i] integerValue]);
            label.rotation     = M_2_PI;
            label.offset = axis.majorTickLength;
            if (label) {
                [customLabels addObject:label];
                [xLocations addObject:[NSString stringWithFormat:@"%d",[[_customTickLocations objectAtIndex:i] integerValue]]];
            }
            label = nil;
            
        }
        axis.majorTickLocations = [NSSet setWithArray:_customTickLocations];
        
        axis.axisLabels = customLabels;
        
        return NO;
    }
    return YES;
}


#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ( [plot.identifier isEqual:@"Plot1"] || [plot.identifier isEqual:@"Systolic(BP)"] || [plot.identifier isEqual:@"Fasting"])
    {
        return [_valueGraphArray count];
    }
    else
    {
        return [_value2GraphArray count];
    }
    //    return [_dateGraphArray count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if ( [plot.identifier isEqual:@"Plot1"] || [plot.identifier isEqual:@"Systolic(BP)"] || [plot.identifier isEqual:@"Fasting"])
    {
        if (index<[self.data count])
        {
            NSDictionary *bar = [self.data objectAtIndex:index];
            if(fieldEnum == CPTBarPlotFieldBarLocation)
                return [bar valueForKey:BAR_POSITION];
            else if(fieldEnum ==CPTBarPlotFieldBarTip)
                return [bar valueForKey:BAR_HEIGHT];
        }
    }
    else
    {
        if(index<[self.data2 count])
        {
            NSDictionary *bar = [self.data2 objectAtIndex:index];
            if(fieldEnum == CPTBarPlotFieldBarLocation)
                return [bar valueForKey:BAR_POSITION];
            else if(fieldEnum ==CPTBarPlotFieldBarTip)
                return [bar valueForKey:BAR_HEIGHT];
        }
    }
    return [NSNumber numberWithFloat:0];
}

//#pragma mark Plot Space Delegate Methods
//
//-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
//{
//    //we don't actually want to call this, this was just left over from a poc
//    // Impose a limit on how far user can scroll in x
//    if ( coordinate == CPTCoordinateX ) {
//        if (newRange <= _graphPlotConstant)
//        {
//            CPTPlotRange *maxRange                    = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.0f) length:CPTDecimalFromFloat(200.0f)];
//            CPTMutablePlotRange *changedRange = [newRange mutableCopy];
//            [changedRange shiftEndToFitInRange:maxRange];
//            [changedRange shiftLocationToFitInRange:maxRange];
//            newRange = changedRange;
//
//            NSLog(@"HI");
//        }
//    }
//
//    return newRange;
//}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //    if (section==0 && [self.navigationItem.title isEqualToString:@"BMI"])
    //    {
    //        return @"Height History";
    //    }
    //    else if (section == 1)
    //    {
    //        return @"Weight History";
    //    }
    return [NSString stringWithFormat:@"%@ History",self.navigationItem.title];
}


#pragma mark - Custom Alert

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
