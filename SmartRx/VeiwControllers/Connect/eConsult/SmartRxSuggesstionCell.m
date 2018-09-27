//
//  SmartRxSuggesstionCell.m
//  SmartRx
//
//  Created by Manju Basha on 25/04/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxSuggesstionCell.h"

@implementation SmartRxSuggesstionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)setCellData:(NSDictionary *)arrAppDetails row:(NSInteger)rowIndex
{
    
    NSString *splitString;
//    [self.strImage rangeOfString:@"patient"].location != NSNotFound
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(containsString:)])
    {
        if ([[arrAppDetails objectForKey:@"content_images"] containsString:@"patient/data/pat_uploaded_files/"])
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrAppDetails objectForKey:@"content_images"] containsString:@"admin/data/servicefiles/"])
            splitString = @"admin/data/servicefiles/";
    }
    else
    {
        if ([[arrAppDetails objectForKey:@"content_images"] rangeOfString:@"patient/data/pat_uploaded_files/"].location != NSNotFound)
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrAppDetails objectForKey:@"content_images"] rangeOfString:@"admin/data/servicefiles/"].location != NSNotFound)
            splitString = @"admin/data/servicefiles/";
            
    }
    NSArray *arrImg = [[arrAppDetails objectForKey:@"content_images"] componentsSeparatedByString:splitString];
    NSArray *arrImages = [arrImg[1] componentsSeparatedByString:@"_"];
    self.suggestionImageName.text = [arrImages objectAtIndex:arrImages.count-1];//[NSString stringWithFormat:@"%@", [arrImg objectAtIndex:1]];
    self.downloadBtn.tag = rowIndex;
    self.viewBtn.tag = rowIndex;
}

- (IBAction)viewBtnClicked:(id)sender {
    
    
    NSDictionary *arrAppDetails = self.arrImages[((UIButton *)sender).tag];
    
    NSString *splitString;
    //    [self.strImage rangeOfString:@"patient"].location != NSNotFound
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(containsString:)])
    {
        if ([[arrAppDetails objectForKey:@"content_images"] containsString:@"patient/data/pat_uploaded_files/"])
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrAppDetails objectForKey:@"content_images"] containsString:@"admin/data/servicefiles/"])
            splitString = @"admin/data/servicefiles/";
    }
    else
    {
        if ([[arrAppDetails objectForKey:@"content_images"] rangeOfString:@"patient/data/pat_uploaded_files/"].location != NSNotFound)
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrAppDetails objectForKey:@"content_images"] rangeOfString:@"admin/data/servicefiles/"].location != NSNotFound)
            splitString = @"admin/data/servicefiles/";
        
    }
    NSArray *arrImg = [[arrAppDetails objectForKey:@"content_images"] componentsSeparatedByString:@","];
    
    NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
   // NSArray *arrExtensionType = [[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"content_images"] componentsSeparatedByString:@"."];
    
     NSArray *arrExtensionType = [[arrImg objectAtIndex:0] componentsSeparatedByString:@"."];
    if ([arrExtensionType count] && [arrFileType containsObject:arrExtensionType[([arrExtensionType count]-1)]]) {
        [self.delegateImg openQlPreview:arrImg[0]];
    }else
        [self.delegateImg ShowImageInMainView:arrImg[0]];
}

- (IBAction)downloadBtnClicked:(id)sender
{
    
    
//    NSDictionary *arrAppDetails = self.arrImages[((UIButton *)sender).tag];
//    
//    NSArray *arrImg = [[arrAppDetails objectForKey:@"content_images"] componentsSeparatedByString:@","];
//    
//    NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
//  NSArray *arrExtensionType = [[arrImg objectAtIndex:1] componentsSeparatedByString:@"."];
    
    
    NSDictionary *arrAppDetails = self.arrImages[((UIButton *)sender).tag];
    
    NSString *splitString;
    //    [self.strImage rangeOfString:@"patient"].location != NSNotFound
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(containsString:)])
    {
        if ([[arrAppDetails objectForKey:@"content_images"] containsString:@"patient/data/pat_uploaded_files/"])
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrAppDetails objectForKey:@"content_images"] containsString:@"admin/data/servicefiles/"])
            splitString = @"admin/data/servicefiles/";
    }
    else
    {
        if ([[arrAppDetails objectForKey:@"content_images"] rangeOfString:@"patient/data/pat_uploaded_files/"].location != NSNotFound)
            splitString = @"patient/data/pat_uploaded_files/";
        else if ([[arrAppDetails objectForKey:@"content_images"] rangeOfString:@"admin/data/servicefiles/"].location != NSNotFound)
            splitString = @"admin/data/servicefiles/";
        
    }
    NSArray *arrImg = [[arrAppDetails objectForKey:@"content_images"] componentsSeparatedByString:@","];
    
    NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
    // NSArray *arrExtensionType = [[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"content_images"] componentsSeparatedByString:@"."];
    
    NSArray *arrExtensionType = [[arrImg objectAtIndex:0] componentsSeparatedByString:@"."];
    
    if ([arrExtensionType count] && [arrFileType containsObject:arrExtensionType[([arrExtensionType count]-1)]]) {
        [self.delegateImg openQlPreview:arrImg[0]];
    }else
        [self.delegateImg ShowImageInMainView:arrImg[0]];}


@end
