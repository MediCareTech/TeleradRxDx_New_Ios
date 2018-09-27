//
//  SmartRxRecordTableCell.m
//  SmartRx
//
//  Created by PaceWisdom on 08/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxRecordTableCell.h"

@implementation SmartRxRecordTableCell

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

    // Configure the view for the selected state
}
-(void)setReportData:(NSArray *)arrReportData row:(NSInteger)index
{
    self.lblName.text=[[arrReportData objectAtIndex:index]objectForKey:@"dispname"];
    self.lblDescrption.text=[[arrReportData objectAtIndex:index]objectForKey:@"description"];
   // NSURL *urlImag=[NSURL URLWithString:[NSString stringWithFormat:@"%s/%@",kBaseUrlLabReport,[[arrReportData objectAtIndex:index]objectForKey:@"path"]]];
    //NSData *dataImag=[NSData dataWithContentsOfURL:urlImag];
    //self.imgViwReports.image=[UIImage imageWithData:dataImag];
    //[self.webView loadRequest:[NSURLRequest requestWithURL:urlImag]];
}

@end
