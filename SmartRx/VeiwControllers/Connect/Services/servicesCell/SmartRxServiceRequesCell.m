//
//  SmartRxServiceRequesCell.m
//  SmartRx
//
//  Created by Gowtham on 22/08/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxServiceRequesCell.h"

@implementation SmartRxServiceRequesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)awakeFromNib {
}
-(void)layoutSubviews{
    self.imagePath.frame = CGRectMake(8,  self.requestData.frame.size.height+19, self.imagePath.frame.size.width, self.imagePath.frame.size.height);
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    self.requestData.frame = CGRectMake(self.requestData.frame.origin.x, self.requestData.frame.origin.y, viewSize.width-96, self.requestData.frame.size.height);
    self.imagePath.frame = CGRectMake(8,  self.requestData.frame.size.height+19, self.imagePath.frame.size.width, self.imagePath.frame.size.height);
    
    
    [self layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)setCellData:(NSDictionary *)arrayRequestData row:(NSInteger)rowIndex
{
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    
    //replyMsg//comments
    self.requestData.text = [arrayRequestData objectForKey:@"comments"];
    [self.requestData sizeToFit];
    self.requestData.numberOfLines = 10000;
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, 300,21)];
    //created
    lblHeight.text = [arrayRequestData objectForKey:@"created"];
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    CGSize maximumLabelSize = CGSizeMake(300,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    float yheight;
    if ([arrayRequestData[@"filepath"] isEqualToString:@""]) {
        self.viewBtn.hidden = YES;
        self.downloadBtn.hidden = YES;
        self.dividerLine.hidden = YES;
        yheight = self.requestData.frame.origin.y+self.requestData.frame.size.height+10;
        //self.imagePath.frame = CGRectMake(0, 0, 0, 0);
    } else {
        self.viewBtn.hidden = NO;
        self.downloadBtn.hidden = NO;
        self.dividerLine.hidden = NO;
        yheight = self.imagePath.frame.origin.y+self.imagePath.frame.size.height+10;
    }
    self.requestPostedBy.frame = CGRectMake(self.requestPostedBy.frame.origin.x,self.contentView.frame.size.height-expectedLabelSize.height-10, self.requestPostedBy.frame.size.width, expectedLabelSize.height);
    
    self.requestPostedBy.text = [arrayRequestData objectForKey:@"created"];
    
    
    
    
    NSString *splitString;
    //    [self.strImage rangeOfString:@"patient"].location != NSNotFound
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(containsString:)])
    {
        if ([[arrayRequestData objectForKey:@"filepath"] containsString:@"patient/data/pat_uploaded_files/"])
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrayRequestData objectForKey:@"content_images"] containsString:@"admin/data/servicefiles/"])
            splitString = @"admin/data/servicefiles/";
    }
    else
    {
        if ([[arrayRequestData objectForKey:@"filepath"] rangeOfString:@"patient/data/pat_uploaded_files/"].location != NSNotFound)
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrayRequestData objectForKey:@"content_images"] rangeOfString:@"admin/data/servicefiles/"].location != NSNotFound)
            splitString = @"admin/data/servicefiles/";
        
    }
    NSArray *arrImg = [[arrayRequestData objectForKey:@"filepath"] componentsSeparatedByString:@"/"];
    NSArray *arrImgs = [arrImg[arrImg.count-1] componentsSeparatedByString:@"_"];
    self.imagePath.text = [arrImgs objectAtIndex:arrImgs.count-1];//[NSString stringWithFormat:@"%@", [arrImg objectAtIndex:1]];
    //self.imagePath.frame = CGRectMake(8, self.requestData.frame.size.height+19, self.requestData.frame.size.width, self.imagePath.frame.size.height);
    self.downloadBtn.tag = rowIndex;
    self.viewBtn.tag = rowIndex;
    
}
-(IBAction)clickOnViewButton:(id)sender{
    
    NSDictionary *arrAppDetails = self.arrImages[((UIButton *)sender).tag];
    
    NSString *splitString;
    //    [self.strImage rangeOfString:@"patient"].location != NSNotFound
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(containsString:)])
    {
        if ([[arrAppDetails objectForKey:@"filepath"] containsString:@"patient/data/pat_uploaded_files/"])
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrAppDetails objectForKey:@"filepath"] containsString:@"admin/data/servicefiles/"])
            splitString = @"admin/data/servicefiles/";
    }
    else
    {
        if ([[arrAppDetails objectForKey:@"filepath"] rangeOfString:@"patient/data/pat_uploaded_files/"].location != NSNotFound)
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrAppDetails objectForKey:@"filepath"] rangeOfString:@"admin/data/servicefiles/"].location != NSNotFound)
            splitString = @"admin/data/servicefiles/";
        
    }
    NSArray *arrImg = [[arrAppDetails objectForKey:@"filepath"] componentsSeparatedByString:@","];
    
    NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
    // NSArray *arrExtensionType = [[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"content_images"] componentsSeparatedByString:@"."];
    
    NSArray *arrExtensionType = [[arrImg objectAtIndex:0] componentsSeparatedByString:@"."];
    if ([arrExtensionType count] && [arrFileType containsObject:arrExtensionType[([arrExtensionType count]-1)]]) {
        [self.imgDelagate openQrlImage:arrImg[0]];
    }else
        [self.imgDelagate showImage:arrImg[0]];
    
}
-(IBAction)clickOnDownloadButton:(id)sender{
    NSDictionary *arrAppDetails = self.arrImages[((UIButton *)sender).tag];
    
    NSString *splitString;
    //    [self.strImage rangeOfString:@"patient"].location != NSNotFound
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(containsString:)])
    {
        if ([[arrAppDetails objectForKey:@"filepath"] containsString:@"patient/data/pat_uploaded_files/"])
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrAppDetails objectForKey:@"content_images"] containsString:@"admin/data/servicefiles/"])
            splitString = @"admin/data/servicefiles/";
    }
    else
    {
        if ([[arrAppDetails objectForKey:@"filepath"] rangeOfString:@"patient/data/pat_uploaded_files/"].location != NSNotFound)
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrAppDetails objectForKey:@"content_images"] rangeOfString:@"admin/data/servicefiles/"].location != NSNotFound)
            splitString = @"admin/data/servicefiles/";
        
    }
    NSArray *arrImg = [[arrAppDetails objectForKey:@"filepath"] componentsSeparatedByString:@","];
    
    NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
    // NSArray *arrExtensionType = [[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"content_images"] componentsSeparatedByString:@"."];
    
    NSArray *arrExtensionType = [[arrImg objectAtIndex:0] componentsSeparatedByString:@"."];
    
    if ([arrExtensionType count] && [arrFileType containsObject:arrExtensionType[([arrExtensionType count]-1)]]) {
        [self.imgDelagate openQrlImage:arrImg[0]];
    }else
        [self.imgDelagate showImage:arrImg[0]];
}

@end
