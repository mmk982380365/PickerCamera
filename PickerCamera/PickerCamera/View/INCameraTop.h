//
//  INCameraTop.h
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CameraTopBtnType) {
    CameraTopBtnTypeCancel,
    CameraTopBtnTypeFlashMode,
    CameraTopBtnTypePosition,
};

typedef NS_ENUM(NSInteger, CameraFlashMode) {
    CameraFlashModeAuto,
    CameraFlashModeOn,
    CameraFlashModeOff,
};

#define StatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

@class INCameraTop;
@protocol INCameraTopDelegate <NSObject>

-(void)cancelBtnOnClick:(INCameraTop *)topView;
-(void)flashModeOnClick:(INCameraTop *)topView mode:(CameraFlashMode)flashMode;
-(void)positionOnClick:(INCameraTop *)topView;

@end

@interface INCameraTop : UIView

@property (nonatomic, weak) id<INCameraTopDelegate> delegate;

@property (nonatomic, assign) CameraFlashMode flashMode;

-(void)setFlashBtnHidden:(BOOL)hidden;

-(void)setBtnTitle:(NSString *)title type:(CameraTopBtnType)type;

@end
