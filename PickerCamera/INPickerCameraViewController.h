//
//  INPickerCameraViewController.h
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import <UIKit/UIKit.h>


@class INPickerCameraViewController;

@protocol INPickerCameraViewControllerDelegate <NSObject>

-(void)cameraController:(INPickerCameraViewController *)controller didFinishSelectPhotos:(UIImage *)photo;

-(void)cameraController:(INPickerCameraViewController *)controller didFinishRecordVideoWithVideoPath:(NSURL *)videoPath;
@optional
-(void)cameraControllerDidCancel:(INPickerCameraViewController *)controller;

@end

@interface INPickerCameraViewController : UIViewController

@property (nonatomic, weak) id<INPickerCameraViewControllerDelegate> delegate;

@end
