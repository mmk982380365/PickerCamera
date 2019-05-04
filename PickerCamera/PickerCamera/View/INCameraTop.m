//
//  INCameraTop.m
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import "INCameraTop.h"

@interface INCameraTop ()

@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *flashModeBtn;
@property (nonatomic, strong) UIButton *positionBtn;

@property (nonatomic, strong) UIButton *flashOn;
@property (nonatomic, strong) UIButton *flashAuto;
@property (nonatomic, strong) UIButton *flashOff;

@property (nonatomic, assign) BOOL showOption;

@end

@implementation INCameraTop

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44 + [UIApplication sharedApplication].statusBarFrame.size.height)];
    if (self) {
        _flashMode = CameraFlashModeOff;
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
        self.cancelBtn.frame = CGRectMake(5, StatusBarHeight, 65, self.frame.size.height - StatusBarHeight);
        
        self.flashModeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.flashModeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.flashModeBtn setTitle:@"闪光" forState:UIControlStateNormal];
        self.flashModeBtn.frame = CGRectMake(self.frame.size.width - 65 * 2 - 5 * 2, StatusBarHeight, 65, self.frame.size.height - StatusBarHeight);
        
        self.positionBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.positionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.positionBtn setTitle:@"后置" forState:UIControlStateNormal];
        self.positionBtn.frame = CGRectMake(self.frame.size.width - 65 * 1.0 - 2 * 1.0, StatusBarHeight, 65, self.frame.size.height - StatusBarHeight);
        
        self.flashOff = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.flashOff.frame = CGRectMake(CGRectGetMinX(self.flashModeBtn.frame) - 5 - 45, StatusBarHeight, 45, self.frame.size.height - StatusBarHeight);
        [self.flashOff setTitle:@"关闭" forState:UIControlStateNormal];
        self.flashOff.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.flashOff setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.flashOff.alpha = 0;
        
        self.flashOn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.flashOn.frame = CGRectMake(CGRectGetMinX(self.flashModeBtn.frame) - 5 * 2 - 45 * 2, StatusBarHeight, 45, self.frame.size.height - StatusBarHeight);
        [self.flashOn setTitle:@"打开" forState:UIControlStateNormal];
        self.flashOn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.flashOn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.flashOn.alpha = 0;
        
        self.flashAuto = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.flashAuto.frame = CGRectMake(CGRectGetMinX(self.flashModeBtn.frame) - 5 * 3 - 45 * 3, StatusBarHeight, 45, self.frame.size.height - StatusBarHeight);
        [self.flashAuto setTitle:@"自动" forState:UIControlStateNormal];
        self.flashAuto.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.flashAuto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.flashAuto.alpha = 0;
        
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        
        [self addSubview:self.cancelBtn];
        [self addSubview:self.flashModeBtn];
        [self addSubview:self.positionBtn];
        [self addSubview:self.flashAuto];
        [self addSubview:self.flashOn];
        [self addSubview:self.flashOff];
        
        [self.flashOff setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        
        SEL selector1 = @selector(btnOnClick:);
        SEL selector2 = @selector(flashOnClick:);
        
        [self.cancelBtn addTarget:self action:selector1 forControlEvents:UIControlEventTouchUpInside];
        [self.flashModeBtn addTarget:self action:selector1 forControlEvents:UIControlEventTouchUpInside];
        [self.positionBtn addTarget:self action:selector1 forControlEvents:UIControlEventTouchUpInside];
        
        [self.flashOn addTarget:self action:selector2 forControlEvents:UIControlEventTouchUpInside];
        [self.flashOff addTarget:self action:selector2 forControlEvents:UIControlEventTouchUpInside];
        [self.flashAuto addTarget:self action:selector2 forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

-(void)btnOnClick:(UIButton *)btn{
    if (btn == self.cancelBtn) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cancelBtnOnClick:)]) {
            [self.delegate cancelBtnOnClick:self];
        }
    } else if (btn == self.positionBtn) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(positionOnClick:)]) {
            [self.delegate positionOnClick:self];
        }
    } else if (btn == self.flashModeBtn) {
        if (self.showOption) {
            self.showOption = NO;
            [UIView animateWithDuration:0.25 animations:^{
                self.flashAuto.alpha = 0;
                self.flashOn.alpha = 0;
                self.flashOff.alpha = 0;
            }];
        } else {
            self.showOption = YES;
            [UIView animateWithDuration:0.25 animations:^{
                self.flashAuto.alpha = 1;
                self.flashOn.alpha = 1;
                self.flashOff.alpha = 1;
            }];
        }
    }
}

-(void)flashOnClick:(UIButton *)btn{
    CameraFlashMode mode = CameraFlashModeOff;
    if (btn == self.flashOn) {
        mode = CameraFlashModeOn;
    } else if (btn == self.flashOff) {
        mode = CameraFlashModeOff;
    } else if (btn == self.flashAuto) {
        mode = CameraFlashModeAuto;
    }
    self.flashMode = mode;
}

-(void)setFlashBtnHidden:(BOOL)hidden{
    if (hidden) {
        self.showOption = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.flashOff.alpha = 0;
            self.flashAuto.alpha = 0;
            self.flashOn.alpha = 0;
            self.flashModeBtn.alpha = 0;
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.flashModeBtn.alpha = 1;
        }];
    }
}

-(void)setBtnTitle:(NSString *)title type:(CameraTopBtnType)type{
    switch (type) {
        case CameraTopBtnTypeCancel:
        {
            [self.cancelBtn setTitle:title forState:UIControlStateNormal];
        }
            break;
        case CameraTopBtnTypePosition:
        {
            [self.positionBtn setTitle:title forState:UIControlStateNormal];
        }
            break;
        case CameraTopBtnTypeFlashMode:
        {
            [self.flashModeBtn setTitle:title forState:UIControlStateNormal];
        }
            
        default:
            break;
    }
}

-(void)setFlashMode:(CameraFlashMode)flashMode{
    if (_flashMode != flashMode) {
        switch (_flashMode) {
            case CameraFlashModeAuto:
            {
                [self.flashAuto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
                break;
            case CameraFlashModeOn:
            {
                [self.flashOn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
                break;
            case CameraFlashModeOff:
            {
                [self.flashOff setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
        
        switch (flashMode) {
            case CameraFlashModeAuto:
            {
                [self.flashAuto setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            }
                break;
            case CameraFlashModeOn:
            {
                [self.flashOn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            }
                break;
            case CameraFlashModeOff:
            {
                [self.flashOff setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
        _flashMode = flashMode;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(flashModeOnClick:mode:)]) {
            [self.delegate flashModeOnClick:self mode:flashMode];
        }
        
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
