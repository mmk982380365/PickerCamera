//
//  INCameraTakePhotosView.h
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INCameraTakePhotosView;
@protocol INCameraTakePhotosViewDelegate <NSObject>

-(void)beganRecordingVideo:(INCameraTakePhotosView *)takeView;
-(void)endRecordingVideo:(INCameraTakePhotosView *)takeView;
-(void)didTriggerTakePhotos:(INCameraTakePhotosView *)takeView;

@end

@interface INCameraTakePhotosView : UIView

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, weak) id<INCameraTakePhotosViewDelegate> delegate;

@end
