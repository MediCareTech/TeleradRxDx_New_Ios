//
//  SmartRxTextFieldLeftImage.m
//  SmartRx
//
//  Created by Anil Kumar on 23/01/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import "SmartRxTextFieldLeftImage.h"

@implementation SmartRxTextFieldLeftImage

- (id)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.clipsToBounds = YES;
        [self setLeftViewMode:UITextFieldViewModeAlways];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self setLeftViewMode:UITextFieldViewModeAlways];
    }
    return self;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    
    CGRect textRect = [super leftViewRectForBounds:bounds];
    textRect.origin.x += 5;
//    textRect.origin.y += 3;    
    return textRect;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect textRect = [super textRectForBounds:bounds];
    textRect.origin.x += 2;
    return textRect;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
