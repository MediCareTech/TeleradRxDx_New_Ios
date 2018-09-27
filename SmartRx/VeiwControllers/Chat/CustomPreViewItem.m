//
//  CustomPreViewItem.m
//  SmartRx
//
//  Created by SmartRx-iOS on 26/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "CustomPreViewItem.h"

@implementation CustomPreViewItem
- (instancetype)initPreviewURL:(NSURL *)docURL
                     WithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        _previewItemURL = [docURL copy];
        _previewItemTitle = [title copy];
    }
    return self;
}
@end
