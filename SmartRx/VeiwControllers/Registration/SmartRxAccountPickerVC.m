//
//  SmartRxAccountPickerVC.m
//  SmartRx
//
//  Created by Manju Basha on 11/05/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxAccountPickerVC.h"
#import "UIImageView+WebCache.h"
#import "SmartRxAppDelegate.h"
@interface SmartRxAccountPickerVC ()

@end

@implementation SmartRxAccountPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBackButton];
    CGFloat viewWidth;
//    viewSize = [[UIScreen mainScreen]bounds].size;
    viewWidth = CGRectGetWidth(self.view.frame);
//    viewHeight = CGRectGetHeight(self.view.frame);
    self.accountTable.frame = CGRectMake(0, self.accountTable.frame.origin.y, viewWidth, self.accountTable.frame.size.height-57);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.responseDict count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"hospitalName"];
    
    self.accountTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //To customize the separatorLines
    UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, 43, self.accountTable.frame.size.width-1, 1)];
    separatorLine.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:separatorLine];
    
    // To bring the arrow mark on right end of each cell.
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
//    //To customize the separatorLines
//    UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, 60, self.accountTable.frame.size.width-1, 1)];
//    separatorLine.backgroundColor = [UIColor lightGrayColor];
//    [cell addSubview:separatorLine];
//    
//    // To bring the arrow mark on right end of each cell.
//    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSString *logoStr = @"";
    cell.tag =[[[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"custid"] integerValue];
    
    if ([[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"mlogo"] && [[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"mlogo"] != [NSNull null])
        logoStr = @"mlogo";
    else
        logoStr = @"logo";
    
//    cell.imageView.image = [UIImage imageNamed:@"smartIcon.png"];
//    UIImageView *imgViewIcon=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smartIcon.png"]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%s/%@",kAdminBaseUrl,[[self.responseDict objectAtIndex:indexPath.row] objectForKey:logoStr]]];
    UIImage *thumbnail = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
    if (thumbnail == nil) {
        //    thumbnail = [UIImage imageNamed:@"smartIcon.png"] ;
        thumbnail = [UIImage imageNamed:@"appLogo"] ;
    }
    CGSize itemSize = CGSizeMake(30, 30);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [thumbnail drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    if ([logoStr length]>0)
//    {
//        //change
//        [imgViewIcon  sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smartIcon.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
//            if (!error)
//            {
//                cell.imageView.frame = CGRectMake(0, 0, 30.0, 30.0);
//                cell.imageView.image = nil;
//                cell.imageView.image = imgViewIcon.image;
//            }
//        }];
//    }
    
//    cell.imageView.image = img;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog (@"Tag is %ld",(long)cell.tag);
    [[NSUserDefaults standardUserDefaults]setObject:[[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"custid"] forKey:@"cidd"];
    
    [[NSUserDefaults standardUserDefaults]setObject:[[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"custid"] forKey:@"cid"];
    NSString *strFrontDestNum=[[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"frontDeskNo" ];
    
    [[NSUserDefaults standardUserDefaults]setObject:strFrontDestNum forKey:@"EmNumber"];
    
    NSString *strHospName=[[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"hospitalName"];
    
    [[NSUserDefaults standardUserDefaults]setObject:strHospName forKey:@"HosName"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [[NSUserDefaults standardUserDefaults]setObject:[[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"hosid"] forKey:@"hosid"];
    [[NSUserDefaults standardUserDefaults] setObject:[[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"splash_screen"] forKey:@"splash_screen"];//logo
    if ([[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"mlogo"] && [[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"mlogo"] != [NSNull null])
            [[NSUserDefaults standardUserDefaults] setObject:[[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"mlogo"] forKey:@"logo"];
    else
        [[NSUserDefaults standardUserDefaults] setObject:[[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"logo"] forKey:@"logo"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    //change
    [((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/%@",kAdminBaseUrl,[[self.responseDict objectAtIndex:indexPath.row] objectForKey:@"splash_screen"]]] placeholderImage:[UIImage imageNamed:@"splash_iphone5@2x.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
        if (!error) {
            ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).imgSlpash = nil;
            ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).imgSlpash = image;
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"splash_iphone5@2x.png" forKey:@"splash_screen"];
            ((SmartRxAppDelegate *)[[UIApplication sharedApplication] delegate]).imgSlpash = nil;
        }
    }];
    [self performSegueWithIdentifier:@"loginID" sender:nil];
//    loginID
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
