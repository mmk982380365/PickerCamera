//
//  INCameraPreviewView.m
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import "INCameraPreviewView.h"
#import "INCameraTop.h"
#import <sys/utsname.h>

@implementation INCameraPreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleAspectFill;
        [self initView];
    }
    return self;
}

-(void)initView{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44 + StatusBarHeight)];
    bgView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    [self addSubview:bgView];
    
    _retakeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _retakeBtn.frame = CGRectMake(5, StatusBarHeight, 65, bgView.frame.size.height - StatusBarHeight);
    [_retakeBtn setTitle:@"重拍" forState:UIControlStateNormal];
    [_retakeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_retakeBtn addTarget:self action:@selector(retakeOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:_retakeBtn];
    
    _sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _sendBtn.frame = CGRectMake(self.frame.size.width - 80.0, self.frame.size.height - 50.0, 60.0, 30.0);
    if (@available(iOS 11.0, *)) {
        _sendBtn.frame = CGRectMake(self.frame.size.width - 80.0, self.frame.size.height - 50.0 - ([INCameraPreviewView isIpx] ? 34 : 0), 60.0, 30.0);
    }
    [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _sendBtn.layer.cornerRadius = 3.0;
    _sendBtn.layer.masksToBounds = YES;
    _sendBtn.layer.borderWidth = 1.0;
    _sendBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _sendBtn.layer.backgroundColor = [UIColor colorWithRed:90/255.0 green:190/255.0 blue:247/255.0 alpha:1.0].CGColor;
    [_sendBtn addTarget:self action:@selector(sendOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendBtn];
    
}

-(void)retakeOnClick:(UIButton *)btn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickRetakeBtn:)]) {
        [self.delegate didClickRetakeBtn:self];
    }
}

-(void)sendOnClick:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSendBtn:)]) {
        [self.delegate didClickSendBtn:self];
    }
}

#pragma mark - private

+ (NSString *)machineName {
#if TARGET_IPHONE_SIMULATOR
    NSString *model = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
#else
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *model = [NSString stringWithUTF8String:systemInfo.machine];
#endif
    return model;
}

+ (BOOL)isIpx {
    static NSString *mcName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mcName = [self machineName];
    });
    
    
    if ([mcName isEqualToString:@"iPhone10,3"]) return YES;// X
    if ([mcName isEqualToString:@"iPhone10,6"]) return YES;// X
    
    if ([mcName isEqualToString:@"iPhone11,2"]) return YES;// XS
    if ([mcName isEqualToString:@"iPhone11,4"]) return YES;// XS MAX
    if ([mcName isEqualToString:@"iPhone11,6"]) return YES;// XS MAX
    if ([mcName isEqualToString:@"iPhone11,8"]) return YES;// XR
    
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
