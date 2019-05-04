//
//  INCameraZoomView.m
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/13.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import "INCameraZoomView.h"

@interface INCameraZoomView ()

@property (nonatomic, strong) UILabel *valueLabel;

@property (nonatomic, weak) id target;

@property (nonatomic, assign) SEL action;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, assign) BOOL showLine;

@property (nonatomic, strong) NSTimer *time;

@end

@implementation INCameraZoomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _maxValue = 10.0;
        _minValue = 1.0;
        
//        self.layer.borderWidth = 1.0;
//        self.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:self.valueLabel];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewOnPan:)];
        [self addGestureRecognizer:self.panGesture];
        
        [self addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
        self.value = 1;
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"value"];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (self.isAnimating) {
        return CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, 150), point) ? view : nil;
    }
    if (CGRectContainsPoint(self.valueLabel.frame, point)) {
        return view;
    } else {
        return nil;
    }
    
}

-(void)timeEnd:(NSTimer *)timer {
    self.showLine = NO;
    [self setNeedsDisplay];
    [UIView animateWithDuration:0.2 animations:^{
        self.center = CGPointMake(self.center.x, self.center.y + 40);
        
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
        
    }];
}

static float old = 1;

-(void)viewOnPan:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"222");
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.time) {
            [self.time invalidate];
            self.time = nil;
        }
        if (!self.isAnimating) {
            [UIView animateWithDuration:0.2 animations:^{
                self.center = CGPointMake(self.center.x, self.center.y - 40);
                
            }];
        }
        old = self.value;
        self.isAnimating = YES;
        
        self.showLine = YES;
        [self setNeedsDisplay];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        self.time = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timeEnd:) userInfo:nil repeats:NO];
        
        
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        float delta = [recognizer translationInView:self].x;
        
        float newValue = -delta / (249.0 * sqrt(2)) * (self.maxValue - self.minValue) + old;
        
        if (newValue >= self.maxValue) {
            newValue = self.maxValue;
        }
        
        if (newValue <= 1) {
            newValue = 1;
        }
        
        self.value = newValue;
        
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"value"]) {
        NSLog(@"%@",change);
        float value = [change[NSKeyValueChangeNewKey] floatValue];
        [self setNeedsDisplay];
        self.valueLabel.text = [NSString stringWithFormat:@"%.0fx",value];
        
        if (self.target && [self.target respondsToSelector:self.action]) {
            [self.target performSelector:self.action withObject:self afterDelay:0];
        }
        
    }
}

-(UILabel *)valueLabel{
    if (_valueLabel == nil) {
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.5 - 18.0, 0, 36.0, 36.0)];
        _valueLabel.textColor = [UIColor whiteColor];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.font = [UIFont systemFontOfSize:15];
        _valueLabel.text = @"1x";
        _valueLabel.layer.cornerRadius = 18.0;
        _valueLabel.layer.borderWidth = 1.0;
        _valueLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return _valueLabel;
}

-(void)addTarget:(id)target action:(SEL)action {
    self.target = target;
    self.action = action;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    if (self.showLine) {
        CGPoint circleCenter = CGPointMake(self.valueLabel.center.x, self.valueLabel.center.y + 250);
        
        CGFloat radius = 250 - 1;
        
        CGFloat deltaAngle = ((self.value - self.minValue) / (self.maxValue - self.minValue)) * M_PI_2;
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGFloat leng[] = {10,10};
        
        CGContextSetLineDash(ctx, 0, leng, 2);
        
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        
        CGContextSetLineWidth(ctx, 2);
        
        CGContextAddArc(ctx, circleCenter.x, circleCenter.y, radius, -M_PI_2 - deltaAngle, 0 - deltaAngle, 0);
        
        CGContextStrokePath(ctx);
        
        CGContextSetFillColorWithColor(ctx, [[UIColor grayColor] colorWithAlphaComponent:0.4].CGColor);
        
        CGContextAddArc(ctx, circleCenter.x, circleCenter.y, radius + 3, -M_PI_2 * 2, 0, 0);
        CGContextClosePath(ctx);
        CGContextDrawPath(ctx, kCGPathFill);
    }
    
    
}


@end
