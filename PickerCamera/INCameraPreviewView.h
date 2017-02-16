//
//  INCameraPreviewView.h
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INCameraPreviewView;
@protocol INCameraPreviewViewDelegate <NSObject>

-(void)didClickRetakeBtn:(INCameraPreviewView *)previewView;
-(void)didClickSendBtn:(INCameraPreviewView *)previewView;

@end

@interface INCameraPreviewView : UIImageView

@property (nonatomic, weak) id<INCameraPreviewViewDelegate> delegate;

@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UIButton *retakeBtn;

@end
