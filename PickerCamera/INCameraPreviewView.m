//
//  INCameraPreviewView.m
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import "INCameraPreviewView.h"
#import "INCameraTop.h"
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
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    bgView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    [self addSubview:bgView];
    
    _retakeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _retakeBtn.frame = CGRectMake(5, StatusBarHeight, 65, 64 - StatusBarHeight);
    [_retakeBtn setTitle:@"重拍" forState:UIControlStateNormal];
    [_retakeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_retakeBtn addTarget:self action:@selector(retakeOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:_retakeBtn];
    
    _sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _sendBtn.frame = CGRectMake(self.frame.size.width - 80.0, self.frame.size.height - 50.0, 60.0, 30.0);
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
