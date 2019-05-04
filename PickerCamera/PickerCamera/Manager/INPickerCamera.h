//
//  INPickerCamera.h
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@class INPickerCamera;
@protocol INPickerCameraDelegate <NSObject>

-(void)cameraOutputVideo:(AVCaptureOutput *)captureOutput didOutputImageBuffer:(CIImage *)sourceImage fromConnection:(AVCaptureConnection *)connection;

-(void)cameraOutputAudio:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

-(void)cameraReadyToRecord:(INPickerCamera *)camera;
-(void)cameraFinishToRecord:(INPickerCamera *)camera;

@end

@interface INPickerCamera : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate>
{
    dispatch_queue_t audioWritingQueue;
    dispatch_queue_t videoWritingQueue;
}

#pragma mark - camera

@property (nonatomic, weak) id<INPickerCameraDelegate> delegate;

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureDeviceInput *captureVideoInput;

@property (nonatomic, strong) AVCaptureDeviceInput *captureAudioInput;

@property (nonatomic, strong) AVCaptureOutput *capturePhotoOutput;

@property (nonatomic, strong) AVCaptureVideoDataOutput *captureVideoOutput;

@property (nonatomic, strong) AVCaptureAudioDataOutput *captureAudioOutput;

#pragma mark - writer

@property (nonatomic, strong) AVAssetWriter *assetWriter;

@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;

@property (nonatomic, strong) AVAssetWriterInput *audioWriterInput;

@property (nonatomic, strong) AVCaptureConnection *audioConnection;

@property (nonatomic, strong) AVCaptureConnection *videoConnection;

@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *bufferAdaptor;

-(void)setupSession;

-(void)startSession;

-(void)stopSession;

@property (nonatomic, assign) AVCaptureFlashMode flashMode;

@property (nonatomic, assign) AVCaptureVideoStabilizationMode stabilizationMode;

-(void)setFocusMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode interestPoint:(CGPoint)point;

-(void)takePhotos:(void (^)(UIImage *))results;

@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;

+(NSString *)movieFilePath;

+(NSURL *)movieFileUrl;

@property (nonatomic, assign, readonly) BOOL isRecording;

-(void)startRecording;

-(void)stopRecrding;

#pragma mark - filter

@property (nonatomic, strong) NSArray *filterArray;

@property (nonatomic, strong) CIContext *ciContext;

@property (nonatomic, assign) CGFloat videoMaxScaleAndCropFactor;

@property (nonatomic, assign) CGFloat videoZoomFactor;

@end

@interface UIImage (ori)

- (UIImage *)fixOrientation;

@end

