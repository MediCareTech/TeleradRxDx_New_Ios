//
//  SmartRxDataTVC.m
//  SmartRx
//
//  Created by Pace on 14/07/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxDataTVC.h"
#import "UIImageView+WebCache.h"
#import "NSString+DateConvertion.h"

@implementation SmartRxDataTVC

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

-(void)setDataForCell:(id)data
{
   _dictCategory=[[NSDictionary alloc]initWithObjectsAndKeys:@"Lab",@"1",@"Radiology",@"2",@"MI",@"3",@"Discharge summary",@"4",@"Prescriptions",@"5",@"Case sheet",@"6",@"Others",@"7", nil];
    self.lblTitle.text=[_dictCategory objectForKey:[data objectForKey:@"category"]];
    
    
    NSString *htmlString=[data objectForKey:@"description"];
    if ([htmlString isKindOfClass:[NSString class]]) {
        
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    
    self.lblDescription.text=[attrStr string];//[data objectForKey:@"description"];
    }
        self.lblByMe.hidden=NO;
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"] isEqualToString:[data objectForKey:@"uploaded_by"]])
        {
         self.lblByMe.text=@"By Me";
        }
        else{
            self.lblByMe.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
        }
        
    if([data objectForKey:@"uploaded_date"])
    {
         self.lblDate.text = [[[NSString timeFormating:[data objectForKey:@"uploaded_date"] funcName:@"dataTVC"] componentsSeparatedByString:@" "]objectAtIndex:0];
    }
   
}

@end
