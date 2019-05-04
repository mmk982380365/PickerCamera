//
//  INCameraCursor.m
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import "INCameraCursor.h"

@implementation INCameraCursor

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGContextAddRect(context, rect);
    
    CGContextMoveToPoint(context, width / 2.0, 0.0);
    CGContextAddLineToPoint(context, width / 2.0, 6.0);
    
    CGContextMoveToPoint(context, width / 2.0, height);
    CGContextAddLineToPoint(context, width / 2.0, height - 6.0);
    
    CGContextMoveToPoint(context, 0.0, height / 2.0);
    CGContextAddLineToPoint(context, 6.0, height / 2.0);
    
    CGContextMoveToPoint(context, width, height / 2.0);
    CGContextAddLineToPoint(context, width - 6.0, height / 2.0);
    
    CGContextStrokePath(context);
    
}


@end
