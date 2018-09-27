//
//  CustomPreViewItem.h
//  SmartRx
//
//  Created by SmartRx-iOS on 26/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>
@import QuickLook;

@interface CustomPreViewItem : NSObject<QLPreviewItem>

@property(readonly, nullable, nonatomic) NSURL    *previewItemURL;
@property(readonly, nullable, nonatomic) NSString *previewItemTitle;

- (instancetype)initPreviewURL:(NSURL *)docURL
                     WithTitle:(NSString *)title;
@end
