//
//  SmartRxTipsDetailVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 18/04/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxTipsDetailVC.h"
#import "UIImageView+WebCache.h"

@interface SmartRxTipsDetailVC ()

@end

@implementation SmartRxTipsDetailVC
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
   
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Tips";
    [self.tableView setTableFooterView:[UIView new]];
    [self navigationBackButton];
    //NSLog(@"selected tip.....:%@",self.selectedTip);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Action Methods

-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Methods

-(CGFloat)estimatedHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(8,16, self.view.frame.size.width-35,21)];
    lblHeight.text = strToCalCulateHeight;
    
    //[UIFont fontWithName:@"HelveticaNeue" size:15]
    lblHeight.font =  [UIFont systemFontOfSize:17];
    //    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width-35,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    CGFloat heightLbl=expectedLabelSize.height;
    
    heightLbl = heightLbl+ 60;
    
    return heightLbl;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat rowHeight = 44.0;
    if (indexPath.row == 0) {
        rowHeight = self.view.frame.size.width -100;
    }else if (indexPath.row == 1){
        rowHeight = [self estimatedHeight:self.selectedTip[@"description"]];
    }
    return rowHeight;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
        NSString *urlStr = [NSString stringWithFormat:@"%s%@",kBaseUrlQAImg,self.selectedTip[@"image"]];
        NSString *escapedString = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:escapedString];
        UIImageView *imageVw = (UIImageView *)[cell viewWithTag:100];
        [imageVw sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                
                imageVw.image = [UIImage imageNamed:@"BlankUser.jpg"];
                
            }
            else {
                imageVw.image = image;
            }
        }];

    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"dataCell"];
        cell.textLabel.text = self.selectedTip[@"description"];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.numberOfLines = 0;
        [cell.textLabel sizeToFit];

    }
    
    return cell;
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
