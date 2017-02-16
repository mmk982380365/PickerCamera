//
//  INCameraTakePhotosView.m
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import "INCameraTakePhotosView.h"

@interface INCameraTakePhotosView ()

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation INCameraTakePhotosView

- (void)dealloc
{
    [self.longPressGesture removeObserver:self forKeyPath:@"state"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
        [self addGestureRecognizer:self.longPressGesture];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tap];
        
        [self.longPressGesture addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"state"]) {
        UIGestureRecognizerState state = ((UILongPressGestureRecognizer *)object).state;
        if (state == UIGestureRecognizerStateEnded) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(endRecordingVideo:)]) {
                [self.delegate endRecordingVideo:self];
            }
            self.progress = 0;
            [self setNeedsDisplay];
            [UIView animateWithDuration:0.25 animations:^{
                CGPoint center = self.center;
                CGRect frame = self.frame;
                frame.size.width = frame.size.width / 1.3;
                frame.size.height /= 1.3;
                self.frame = frame;
                self.center = center;
            } completion:^(BOOL finished) {
                [self setNeedsDisplay];
            }];
        }
    }
}

-(void)onTap:(UITapGestureRecognizer *)recognizer{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTriggerTakePhotos:)]) {
        [self.delegate didTriggerTakePhotos:self];
    }
}

-(void)onPress:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(beganRecordingVideo:)]) {
        [self.delegate beganRecordingVideo:self];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        CGPoint center = self.center;
        CGRect frame = self.frame;
        frame.size.width *= 1.3;
        frame.size.height *= 1.3;
        self.frame = frame;
        self.center = center;
    } completion:^(BOOL finished) {
        [self setNeedsDisplay];
    }];
    
}

-(void)setProgress:(CGFloat)progress{
    if (progress > 1) {
        return;
    }
    _progress = progress;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, YES);
    CGContextSetLineWidth(ctx, 4.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    CGFloat radius = (self.frame.size.width - 2 * 4.0) / 2.0;
    
    CGContextAddArc(ctx, self.frame.size.width * 0.5, self.frame.size.height * 0.5, radius, 0, M_PI * 2.0, 1);
    CGContextStrokePath(ctx);
    
    if (self.progress > 0) {
        CGFloat angle = 2.0 * M_PI * self.progress - M_PI_2;
        
        CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
        CGContextAddArc(ctx, self.frame.size.width / 2.0, self.frame.size.height / 2.0, radius, -M_PI_2, angle, 0);
        CGContextStrokePath(ctx);
    }
    
}


@end
