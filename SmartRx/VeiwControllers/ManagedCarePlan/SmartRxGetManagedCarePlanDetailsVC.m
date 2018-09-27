//
//  SmartRxGetManagedCarePlanDetailsVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 15/05/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxGetManagedCarePlanDetailsVC.h"
#import "GetCarePlanDetailsCell.h"
#import "GetCarePlanDetailsResponseModel.h"
#import "GetCarePlanDetailsResponseModel.h"
#import "MembershipTypesResponseModel.h"
#import "GetCarePlanBuyCell.h"
#import "SmartRxGetManagedCarePlanServiceDetailsVC.h"

@interface SmartRxGetManagedCarePlanDetailsVC ()<CellDelegate>
{
    MembershipTypesResponseModel *gold;
    MembershipTypesResponseModel *silver;
    MembershipTypesResponseModel *platinum;
}
@property(nonatomic,strong) NSArray *titlesArray;
@property(nonatomic,strong) NSArray *tableArray;
@end

@implementation SmartRxGetManagedCarePlanDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scrollView setContentSize:CGSizeMake(500, 0)];
    self.titlesArray = [NSArray arrayWithObjects:@"Managed Care Program",@"Detailed Assessments",@"Health Coach Follow ups(phone/email/chat/sms)",@"Care plans",@"Care manager assistance",@"Chat with care team",@"Continuous monitoring",@"Weekly & monthly newsletters, Health recipes & Stress busters",@"E-Consult",@"Second Opinion",@"Mini Health Check",@"Diagnostic / Lab Tests",@"Price",@"", nil];
    
    [self dataSetUp];
}
-(void)dataSetUp{
    
    for (MembershipTypesResponseModel  *model in self.selectedCarePlan.membershipArray) {
        if ([model.name containsString:@"Silver"]) {
            silver = model;
        }else if ([model.name containsString:@"Gold"]) {
            gold = model;
        }else if ([model.name containsString:@"Platinum"]) {
            platinum = model;
        }
        
    }

    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    
    for (int i = 0 ; i < self.titlesArray.count ; i++) {
        
        GetCarePlanDetailsResponseModel * model = [[GetCarePlanDetailsResponseModel alloc]init];
        if([self.titlesArray[i] isEqualToString:@"Managed Care Program"]){
          
          model =  [self modelCreation:@"Managed Care Program" silverModel:silver.managedCareProgram GoldModel:gold.managedCareProgram platinumModel:platinum.managedCareProgram];
            
        }else if([self.titlesArray[i] isEqualToString:@"Detailed Assessments"]){

            model =  [self modelCreation:@"Detailed Assessments" silverModel:silver.detailedAssessments GoldModel:gold.detailedAssessments platinumModel:platinum.detailedAssessments];
            
        }else if([self.titlesArray[i] isEqualToString:@"Health Coach Follow ups(phone/email/chat/sms)"]){
            model =  [self modelCreation:@"Health Coach Follow ups(phone/email/chat/sms)" silverModel:silver.healthCoachFollowUps GoldModel:gold.healthCoachFollowUps platinumModel:platinum.healthCoachFollowUps];
            
        }else if([self.titlesArray[i] isEqualToString:@"Care plans"]){
            model =  [self modelCreation:@"Care plans" silverModel:silver.careplans GoldModel:gold.careplans platinumModel:platinum.careplans];
            
        }else if([self.titlesArray[i] isEqualToString:@"Customised health plan"]){
            
            model =  [self modelCreation:@"Customised health plan" silverModel:[self boolCreation:silver.customisedHealthPlan] GoldModel:[self boolCreation:gold.customisedHealthPlan] platinumModel:[self boolCreation:platinum.customisedHealthPlan]];
            
        }else if([self.titlesArray[i] isEqualToString:@"Care manager assistance"]){
            model =  [self modelCreation:@"Care manager assistance" silverModel:[self boolCreation:silver.careManagerAssistance] GoldModel:[self boolCreation:gold.careManagerAssistance] platinumModel:[self boolCreation:platinum.careManagerAssistance]];
        }else if([self.titlesArray[i] isEqualToString:@"Chat with care team"]){
            model =  [self modelCreation:@"Chat with care team" silverModel:[self boolCreation:silver.ChatWithCareTeam] GoldModel:[self boolCreation:gold.ChatWithCareTeam] platinumModel:[self boolCreation:platinum.ChatWithCareTeam]];
        }else if([self.titlesArray[i] isEqualToString:@"Continuous monitoring"]){
           model =  [self modelCreation:@"Continuous monitoring" silverModel:[self boolCreation:silver.continuousMonitoring] GoldModel:[self boolCreation:gold.continuousMonitoring] platinumModel:[self boolCreation:platinum.continuousMonitoring]];
            
        }else if([self.titlesArray[i] isEqualToString:@"Weekly & monthly newsletters, Health recipes & Stress busters"]){
            model =  [self modelCreation:@"Weekly & monthly newsletters, Health recipes & Stress busters" silverModel:[self boolCreation:silver.newsletters] GoldModel:[self boolCreation:gold.newsletters] platinumModel:[self boolCreation:platinum.newsletters]];
            
        }else if([self.titlesArray[i] isEqualToString:@"E-Consult"]){
            model =  [self modelCreation:@"E-Consult" silverModel:silver.econsults GoldModel:gold.econsults platinumModel:platinum.econsults];
            
        }else if([self.titlesArray[i] isEqualToString:@"Second Opinion"]){
            model =  [self modelCreation:@"Second Opinion" silverModel:silver.secondOpinion GoldModel:gold.secondOpinion platinumModel:platinum.secondOpinion];
            
        }else if([self.titlesArray[i] isEqualToString:@"Mini Health Check"]){
            model =  [self modelCreation:@"Mini Health Check" silverModel:silver.miniHealthCheck GoldModel:gold.miniHealthCheck platinumModel:platinum.miniHealthCheck];
            
        }else if([self.titlesArray[i] isEqualToString:@"Diagnostic / Lab Tests"]){
            model =  [self modelCreation:@"Diagnostic / Lab Tests" silverModel:@"Show" GoldModel:@"Show" platinumModel:@"Show"];
            
        }else if([self.titlesArray[i] isEqualToString:@"Price"]){
            model =  [self modelCreation:@"Price" silverModel:silver.price GoldModel:gold.price platinumModel:platinum.price];
            
        }else if([self.titlesArray[i] isEqualToString:@""]){
            NSString *silverStr= @"-";
            NSString *goldStr= @"-";
            NSString *platinumStr= @"-";
            if (silver != nil) {
                silverStr = @"Buy";
            }
            if (gold != nil) {
                goldStr = @"Buy";
            }if (platinum != nil) {
                platinumStr = @"Buy";
            }
            model =  [self modelCreation:@"" silverModel:silverStr GoldModel:goldStr platinumModel:platinumStr];
            
        }
        [tempArr addObject:model];
        
    }
    self.tableArray = [tempArr copy];
    dispatch_async(dispatch_get_main_queue(),^{
        [self.tableView reloadData];
    });
}
-(GetCarePlanDetailsResponseModel *)modelCreation:(NSString *)propertyName silverModel:(NSString *)silerStr GoldModel:(NSString *)goldStr platinumModel:(NSString *)platinumStr{
    
    GetCarePlanDetailsResponseModel * model = [[GetCarePlanDetailsResponseModel alloc]init];
    model.CareProgramProperty = propertyName;
    
    if (silver != nil) {
        model.silver = silerStr;
    }else {
        model.silver = @"-";
    }
    if (gold != nil) {
        model.gold = goldStr;
    }else {
        model.gold = @"-";
    }if (platinum != nil) {

        model.platinum = platinumStr;
    }else {

        model.platinum = @"-";
    }
    
    return model;
}
-(NSString *)boolCreation:(NSString *)boolStr{
    NSString *str ;
    if ([boolStr integerValue] == 1) {
        str = @"Yes";
    }else {
        str = @"No";
    }
    return str;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - cell delegate methods
-(void)silverButtonClicked:(NSIndexPath *)indexPath{
    if (indexPath.row == self.tableArray.count-3) {
        MembershipTypesResponseModel *model = [self getSelectedMembership:@"Silver"];
        NSLog(@"selected......:%@",model.serviceDetailsArray);
        //getCareplanServiceDetailsVc
        if (model.serviceDetailsArray.count) {
            [self movieToServiceDetails:model.serviceDetailsArray];
        }

    }else if(indexPath.row == self.tableArray.count-1 && silver != nil){
        NSLog(@"silverButtonClicked:%ld",(long)indexPath.row);
    }
    
}
-(void)goldButtonClicked:(NSIndexPath *)indexPath{
    
    if (indexPath.row == self.tableArray.count-3) {
        MembershipTypesResponseModel *model = [self getSelectedMembership:@"Gold"];
        NSLog(@"selected......:%@",model.price);
        if (model.serviceDetailsArray.count) {
            [self movieToServiceDetails:model.serviceDetailsArray];
        }
    }else if(indexPath.row == self.tableArray.count-1 && gold != nil){
        NSLog(@"clickOnGoldBtn:%ld",(long)indexPath.row);

    }

}
-(void)platinumButtonClicked:(NSIndexPath *)indexPath{
    if (indexPath.row == self.tableArray.count-3) {
        MembershipTypesResponseModel *model = [self getSelectedMembership:@"Platinum"];
        NSLog(@"selected......:%@",model.price);
        if (model.serviceDetailsArray.count) {
            [self movieToServiceDetails:model.serviceDetailsArray];
        }

    }else if(indexPath.row == self.tableArray.count-1 && platinum != nil){
        NSLog(@"platinumButtonClicked");

    }

}
-(MembershipTypesResponseModel *)getSelectedMembership:(NSString *)selectedType{
    
    MembershipTypesResponseModel *selectedModel;
    for (MembershipTypesResponseModel  *model in self.selectedCarePlan.membershipArray) {
        if ([model.name containsString:selectedType]) {
            selectedModel = model;
            return model;
        }
        
    }
    return selectedModel;
}
-(void)movieToServiceDetails:(NSArray *)serviceArr{
    
    [self performSegueWithIdentifier:@"getCareplanServiceDetailsVc" sender:serviceArr];

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
   GetCarePlanDetailsResponseModel * model = self.tableArray[indexPath.row];
   CGFloat height = [self estimatedHeight:model.CareProgramProperty];
    return height;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GetCarePlanDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    GetCarePlanDetailsResponseModel * model = self.tableArray[indexPath.row];

    if ([model.CareProgramProperty isEqualToString:@"Diagnostic / Lab Tests"] || [model.CareProgramProperty isEqualToString:@""] ) {
        GetCarePlanBuyCell *buyCell = [tableView dequeueReusableCellWithIdentifier:@"buyCell"];
        buyCell.cellDelegate = self;
        buyCell.cellId = indexPath;
        buyCell.careProgramProperty.text = model.CareProgramProperty;
        [buyCell.silverBtn setTitle:model.silver forState:UIControlStateNormal];
        [buyCell.goldBtn setTitle:model.gold forState:UIControlStateNormal];
        [buyCell.platinumBtn setTitle:model.platinum forState:UIControlStateNormal];
        return buyCell;
   

    }else{
    cell.careProgramProperty.text = model.CareProgramProperty;
    cell.careProgramProperty.numberOfLines = 5;
    cell.silver.text = model.silver;
    cell.gold.text = model.gold;
    cell.platinum.text = model.platinum;
    cell.silver.numberOfLines = 5;
    cell.gold.numberOfLines = 5;
    cell.platinum.numberOfLines = 5;

   if ([model.CareProgramProperty isEqualToString:@"Diagnostic / Lab Tests"]) {
       cell.silver.textColor = [UIColor redColor];
       cell.gold.textColor = [UIColor redColor];
       cell.platinum.textColor = [UIColor redColor];
   }
}
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"getCareplanServiceDetailsVc"]) {
        SmartRxGetManagedCarePlanServiceDetailsVC *controller = segue.destinationViewController;
        controller.serviceArray = sender;
    }
}


@end
