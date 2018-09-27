//
//  SmartRxCartDetailController.m
//  SmartRx
//
//  Created by Gowtham on 14/06/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxCartDetailController.h"

@interface SmartRxCartDetailController ()

@property(nonatomic,strong) ServicesResponseModel *selectedService;


@end

@implementation SmartRxCartDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView setTableFooterView:[UIView new]];
   
}



-(void)reloadTableView:(ServicesResponseModel *)selectedModel{
    self.selectedService = selectedModel;
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
        
        UILabel *serviceNameLbl = [cell viewWithTag:100];
        serviceNameLbl.text = self.selectedService.serviceName;
        
    } else if (indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"priceCell"];
        
        UILabel *yourPriceLbl = [cell viewWithTag:110];
        UILabel *originalPriceLbl = [cell viewWithTag:111];
        UILabel *originalPriceLblText = [cell viewWithTag:112];
        NSString *rupee = @"Rs.";
        
        if (self.selectedService.servicediscountprice) {
            
            if (![self.selectedService.serviceprice isEqualToString:self.selectedService.servicediscountprice]) {
                
                originalPriceLblText.hidden = NO;
                originalPriceLbl.hidden = NO;
                NSString *discountPrice = [NSString stringWithFormat:@"%@%@",rupee,self.selectedService.servicediscountprice];
                yourPriceLbl.text = discountPrice;
                yourPriceLbl.hidden = NO;
                
                UILabel *originalPriceLbl = [cell viewWithTag:111];
                NSString *originalPrice = [NSString stringWithFormat:@"%@%@",rupee,self.selectedService.serviceprice];
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:originalPrice];
                [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                        value:@2
                                        range:NSMakeRange(0, [attributeString length])];
                
                
                
                originalPriceLbl.attributedText = attributeString;
                
                
            } else {
                originalPriceLblText.hidden = YES;
                yourPriceLbl.text = self.selectedService.serviceprice;
                originalPriceLbl.hidden = YES;
            }
        } else {
            
            yourPriceLbl.text = self.selectedService.serviceprice;
            originalPriceLblText.hidden = YES;
            originalPriceLbl.hidden = YES;
        }
        
    } else if (indexPath.row == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionCell"];
        
        UILabel *descriptionTitle = [cell viewWithTag:121];
        descriptionTitle.text = @"Description";
        
        UILabel *descriptionLbl = [cell viewWithTag:120];
        
        if ([self.selectedService.serviceDescription isKindOfClass:[NSString class]]) {
            descriptionLbl.attributedText =[self getPlainText:self.selectedService.serviceDescription];
            descriptionLbl.numberOfLines = 1000;
        } else {
            descriptionLbl.text = @"";
        }
        
        
        
    } else if (indexPath.row == 3){
        cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionCell"];
        
        UILabel *descriptionTitle = [cell viewWithTag:121];
        descriptionTitle.text = @"Instructions";
        
        UILabel *instructionLbl = [cell viewWithTag:120];
        instructionLbl.attributedText =[self getPlainText:self.selectedService.instructions];
        instructionLbl.numberOfLines = 1000;
        
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight;
    
    if (indexPath.row == 0) {
        cellHeight = 44.0f;
    } else if (indexPath.row == 1){
        cellHeight = 105.0f;
    } else if(indexPath.row == 2) {
        
        if ([self.selectedService.serviceDescription isKindOfClass:[NSString class]]){
            NSMutableAttributedString *str = [self getPlainText:self.selectedService.serviceDescription];
            cellHeight = [self estimatedHeight:str.string];
            
        }
        else {
            cellHeight = 67.00f;
            
        }
        
    } else if(indexPath.row == 3) {
        NSMutableAttributedString *str = [self getPlainText:self.selectedService.instructions];
        cellHeight = [self estimatedHeight:str.string];

    } else {
        cellHeight = 0.0f;
    }
    
    return cellHeight;
}
-(CGFloat)estimatedHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, 300,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    //    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(300,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    CGFloat heightLbl=expectedLabelSize.height;
    
    heightLbl = heightLbl+ 43;
    
    return heightLbl;
    
}
-(NSMutableAttributedString *)getPlainText:(NSString *)htmlString{
    
    NSError *err = nil;
    
    NSAttributedString *attributeStr = [[NSAttributedString alloc]initWithData: [htmlString dataUsingEncoding:NSUnicodeStringEncoding]options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }documentAttributes: nil error: &err];
    
    
    NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithAttributedString:attributeStr];
    
    NSRange range = (NSRange){0,[newString length]};
    
    [newString enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        
        UIFont *replacementFont =  [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        [newString addAttribute:NSFontAttributeName value:replacementFont range:range];
        
    }];
    if (newString.string.length == 4) {
        return [[NSMutableAttributedString alloc]initWithString:@""];
    }
    return newString;
    
}

-(IBAction)clickOnCancelButton:(id)sender{
    
    [self.buttonDelegate hideTheDetailView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
