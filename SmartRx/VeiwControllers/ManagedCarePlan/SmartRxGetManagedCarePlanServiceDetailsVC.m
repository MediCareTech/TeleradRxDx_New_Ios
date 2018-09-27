//
//  SmartRxGetManagedCarePlanServiceDetailsVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 17/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxGetManagedCarePlanServiceDetailsVC.h"
#import "GetManagedCarePlanServiceDetailsCell.h"
#import "AssignedManagedCareplanServiceResponse.h"

@interface SmartRxGetManagedCarePlanServiceDetailsVC ()

@end

@implementation SmartRxGetManagedCarePlanServiceDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setTableFooterView:[UIView new]];
    if (self.serviceArray.count < 1) {
        self.noAppsLbl.hidden = NO;
    }else{
        self.noAppsLbl.hidden = YES;
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Action Methods
-(IBAction)clickCloseBtn:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Tableview Delegate/Datasource Methods
-(CGFloat)estimatedHeight:(NSString *)strToCalCulateHeight
{
    CGSize size=[[UIScreen mainScreen]bounds].size;
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, self.view.frame.size.width-160,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    //    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width-160,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    CGFloat heightLbl=expectedLabelSize.height;
    
    heightLbl = heightLbl+ 40;
    
    return heightLbl;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AssignedManagedCareplanServiceResponse * model = self.serviceArray[indexPath.row];
    CGFloat height = [self estimatedHeight:model.serviceName];
    return height;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.serviceArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GetManagedCarePlanServiceDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    AssignedManagedCareplanServiceResponse * model = self.serviceArray[indexPath.row];
    
    cell.careProgramProperty.text = model.serviceName;
    cell.careProgramProperty.numberOfLines = 5;
    cell.careProgramTotal.text = [NSString stringWithFormat:@"%@",model.serviceTotal];
    
    
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
