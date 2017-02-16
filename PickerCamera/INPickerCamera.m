//
//  INPickerCamera.m
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import "INPickerCamera.h"
#import "INCameraFilter.h"

#define DEFAULT_FILE_TYPE AVFileTypeQuickTimeMovie

@interface INPickerCamera ()

{
    EAGLContext *_context;
    CIContext *_ciContext;
    CGRect _previewBounds;
}

@property (nonatomic, copy) void (^photoResultBlock)(UIImage *);

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, assign, readwrite) BOOL isRecording;

@end

@implementation INPickerCamera
@synthesize session;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

-(void)setupSession {
    
    session = [[AVCaptureSession alloc] init];
    [session beginConfiguration];
    
    if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    
    AVCaptureDevice *videoDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    
    
    
    if (videoDevice == nil) {
        NSLog(@"获取摄像头失败");
        return;
    }
    
    __autoreleasing NSError *error;
    
    self.captureVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (error) {
        NSLog(@"初始化摄像头错误：%@",error);
        return;
    }
    
    self.flashMode = AVCaptureFlashModeOff;
    
    AVCaptureDevice *audioDevice = [self getAudioDevice];
    
    if (audioDevice == nil) {
        NSLog(@"获取麦克风失败");
        return;
    }
    
    self.captureAudioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    if (error) {
        NSLog(@"初始化麦克风错误：%@",error);
        return;
    }
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        self.capturePhotoOutput = [[AVCapturePhotoOutput alloc] init];
    } else {
        self.capturePhotoOutput = [[AVCaptureStillImageOutput alloc] init];
    }
    
    self.captureMovieOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    
//    self.captureVideoOutput = [[AVCaptureVideoDataOutput alloc] init];
//    self.captureVideoOutput.alwaysDiscardsLateVideoFrames = true;
//    
//    dispatch_queue_t videoQueue = dispatch_queue_create("com.video.dataoutput", NULL);
//    [self.captureVideoOutput setSampleBufferDelegate:self queue:videoQueue];
//    self.captureVideoOutput.videoSettings = @{
//                                              (NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
//                                              };
//    
//    self.captureAudioOutput = [[AVCaptureAudioDataOutput alloc] init];
//    dispatch_queue_t audioQueue = dispatch_queue_create("com.audio.dataoutput", NULL);
//    [self.captureAudioOutput setSampleBufferDelegate:self queue:audioQueue];
    
    if ([session canAddInput:self.captureAudioInput]) {
        [session addInput:self.captureAudioInput];
    }
    if ([session canAddInput:self.captureVideoInput]) {
        [session addInput:self.captureVideoInput];
    }
    
    if ([session canAddOutput:self.captureMovieOutput]) {
        [session addOutput:self.captureMovieOutput];
    }
    
//    if ([session canAddOutput:self.captureVideoOutput]) {
//        [session addOutput:self.captureVideoOutput];
//    }
//    if ([session canAddOutput:self.captureAudioOutput]) {
//        [session addOutput:self.captureAudioOutput];
//    }
    if ([session canAddOutput:self.capturePhotoOutput]) {
        [session addOutput:self.capturePhotoOutput];
    }
    
//    self.audioConnection = [self.captureAudioOutput connectionWithMediaType:AVMediaTypeAudio];
//    self.videoConnection = [self.captureVideoOutput connectionWithMediaType:AVMediaTypeVideo];
//    
    
    [session commitConfiguration];
    
}

-(void)startSession{
    [session startRunning];
}

-(void)stopSession{
    [session stopRunning];
}

-(CGFloat)videoMaxScaleAndCropFactor{
    return [self.captureMovieOutput connectionWithMediaType:AVMediaTypeVideo].videoMaxScaleAndCropFactor;
}

-(void)setVideoZoomFactor:(CGFloat)videoZoomFactor{
    if (![self.captureVideoInput.device lockForConfiguration:nil]) {
        return;
    }
    self.captureVideoInput.device.videoZoomFactor = videoZoomFactor;
    [self.captureVideoInput.device unlockForConfiguration];
}

-(AVCaptureDevice *)getAudioDevice{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInMicrophone] mediaType:AVMediaTypeAudio position:AVCaptureDevicePositionUnspecified];
        if (discoverySession.devices.count > 0) {
            
            return discoverySession.devices.firstObject;
            
        }else{
            return nil;
        }
    } else {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
        if (devices.count > 0) {
            return devices.firstObject;
        } else {
            return nil;
        }
    }
}

-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
        if (discoverySession) {
            for (AVCaptureDevice *device in discoverySession.devices) {
                if (device.position == position) {
                    return device;
                }
            }
            return nil;
        } else {
            return  nil;
        }
    } else {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        if (devices) {
            for (AVCaptureDevice *device in devices) {
                if (device.position == position) {
                    return device;
                }
            }
            return nil;
        } else {
            return nil;
        }
    }
}

-(void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition{
    if (_cameraPosition != cameraPosition) {
        AVCaptureDevice *toDevice = [self getCameraDeviceWithPosition:cameraPosition];
        
        if (toDevice) {
            __autoreleasing NSError *error;
            AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:toDevice error:&error];
            
            if (error) {
                NSLog(@"切换摄像头失败：%@",error);
                return;
            }
//            [session stopRunning];
            
            [session beginConfiguration];
            [session removeInput:self.captureVideoInput];
            if ([session canAddInput:self.captureVideoInput]) {
                [session addInput:newInput];
                self.captureVideoInput = newInput;
            }
           
//            self.videoConnection = [self.captureVideoOutput connectionWithMediaType:AVMediaTypeVideo];
            
            [session commitConfiguration];
            
            [session startRunning];
            _cameraPosition = cameraPosition;
        }
        
        
    }
}

-(void)setFlashMode:(AVCaptureFlashMode)flashMode{
    
    AVCaptureDevice *device = self.captureVideoInput.device;
    if (device) {
        if ([UIDevice currentDevice].systemVersion.floatValue < 10.0) {
            __autoreleasing NSError *error;
            if ([device lockForConfiguration:&error]) {
                
                if ([device isFlashModeSupported:flashMode]) {
                    device.flashMode = flashMode;
                    _flashMode = flashMode;
                }
                
                [device unlockForConfiguration];
            }
        } else {
            _flashMode = flashMode;
        }
        
    }
}

-(void)setStabilizationMode:(AVCaptureVideoStabilizationMode)stabilizationMode{
    AVCaptureDevice *device = self.captureVideoInput.device;
    if (device) {
        __autoreleasing NSError *error;
        if ([device lockForConfiguration:&error]) {
            [self.captureVideoInput.device.activeFormat isVideoStabilizationModeSupported:stabilizationMode];
            [self.captureMovieOutput connectionWithMediaType:AVMediaTypeVideo].preferredVideoStabilizationMode = stabilizationMode;
            _stabilizationMode = stabilizationMode;
            [device unlockForConfiguration];
        }
        
        
    }
}

-(void)setFocusMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode interestPoint:(CGPoint)point{
    AVCaptureDevice *device = self.captureVideoInput.device;
    
    if (device) {
        
        __autoreleasing NSError *error;
        
        if ([device lockForConfiguration:&error]) {
            if ([device isFocusPointOfInterestSupported]) {
                device.focusPointOfInterest = point;
            }
            if ([device isFocusModeSupported:focusMode]) {
                device.focusMode = focusMode;
            }
            if ([device isExposurePointOfInterestSupported]) {
                device.exposurePointOfInterest = point;
            }
            if ([device isExposureModeSupported:exposureMode]) {
                device.exposureMode = exposureMode;
            }
            [device unlockForConfiguration];
        } else {
            NSLog(@"锁定设备失败：%@",error);
        }
        
    }
    
}

-(void)takePhotos:(void (^)(UIImage *))results{
    if ([self.capturePhotoOutput isKindOfClass:[AVCapturePhotoOutput class]]) {
        //10.0
        [self.lock lock];
        self.photoResultBlock = results;
        AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey: AVVideoCodecJPEG}];
        
        AVCaptureDevice *device = self.captureVideoInput.device;
        
        if (device) {
            
            if ([device isFlashModeSupported:self.flashMode]) {
                photoSettings.flashMode = self.flashMode;
            }
            
            AVCapturePhotoOutput *output = (AVCapturePhotoOutput *)self.capturePhotoOutput;
            
            [output capturePhotoWithSettings:photoSettings delegate:self];
            
        }
        
        
    } else {
        // 9.0以下
        AVCaptureStillImageOutput *output = (AVCaptureStillImageOutput *)self.capturePhotoOutput;
        
        AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
        if (connection) {
            
            __weak typeof(self) ws = self;
            [output captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                __strong typeof(ws) self = ws;
                if (error) {
                    NSLog(@"拍照失败：%@",error);
                } else {
                    
                    
                    UIImage *img = [UIImage imageWithData:[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer]];
                    
                    if (self.filterArray.count > 0) {
                        CIImage *ciimage = [CIImage imageWithCGImage:img.CGImage];
                        for (INCameraFilter *filter in self.filterArray) {
                            filter.sourceImage = ciimage;
                            ciimage = filter.outputImage;
                        }
                        ciimage = [ciimage imageByApplyingOrientation:6];
                        UIImage *result = [UIImage imageWithCIImage:ciimage];
                        results(result);
                    } else {
                        results(img.fixOrientation);
                    }
                    
                    
                }
                
            }];
        }
        
        
        
    }
}

-(void)startRecording {
        
        
        AVCaptureConnection *connection = [self.captureMovieOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if (connection == nil) {
            NSLog(@"录像失败");
            return;
        }
        
        if (!self.captureMovieOutput.isRecording) {
            [self.captureMovieOutput startRecordingToOutputFileURL:[INPickerCamera movieFileUrl] recordingDelegate:self];
        }
        
        /*
        if (!self.isRecording) {
            __autoreleasing NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:[INPickerCamera movieFilePath] error:&error];
            
            error = nil;
            
            self.assetWriter = [AVAssetWriter assetWriterWithURL:[INPickerCamera movieFileUrl] fileType:AVFileTypeQuickTimeMovie error:&error];
            
            if (error) {
                NSLog(@"录制失败：%@",error);
            }
            
            self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:[self.captureVideoOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie]];
            self.videoWriterInput.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.videoWriterInput.expectsMediaDataInRealTime = YES;
            
            if ([self.assetWriter canAddInput:self.videoWriterInput]) {
                [self.assetWriter addInput:self.videoWriterInput];
            }
            
            self.audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:[self.captureAudioOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie]];
            self.audioWriterInput.expectsMediaDataInRealTime = YES;
            if ([self.assetWriter canAddInput:self.audioWriterInput]) {
                [self.assetWriter addInput:self.audioWriterInput];
            }
            
            self.bufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoWriterInput sourcePixelBufferAttributes:nil];
            
            self.isRecording = YES;
        }*/
    
}

-(void)stopRecrding {
        
        if (self.captureMovieOutput.isRecording) {
            [self.captureMovieOutput stopRecording];
        }
        
        /*
        
        if (self.isRecording) {
            self.isRecording = NO;
            
            
            
            [self.videoWriterInput markAsFinished];
            [self.audioWriterInput markAsFinished];
            __weak typeof(self) ws = self;
            [self.assetWriter finishWritingWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"finish record");
                    
                    if (ws.delegate && [ws.delegate respondsToSelector:@selector(cameraFinishToRecord:)]) {
                        [ws.delegate cameraFinishToRecord:ws];
                    }
                });
            }];
        }
        
        */
        
    
}

#pragma mark - photo output delegate

-(void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error {
    if (error) {
        NSLog(@"拍照失败：%@",error);
    } else {
        if (self.photoResultBlock) {
            NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
            UIImage *img = [UIImage imageWithData:imageData];
            
            if (self.filterArray.count > 0) {
                NSLog(@"%f",img.size.width);
                
                CIImage *ciimage = [CIImage imageWithCGImage:img.CGImage];
                for (INCameraFilter *filter in self.filterArray) {
                    filter.sourceImage = ciimage;
                    ciimage = filter.outputImage;
                }
                ciimage = [ciimage imageByApplyingOrientation:6];
                
                UIImage *result = [UIImage imageWithCIImage:ciimage];
                
                self.photoResultBlock(result);
            } else {
                self.photoResultBlock(img.fixOrientation);
            }
            
            
        }
    }
    [self.lock unlock];
}

#pragma mark - video audio data ountput delegate

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraReadyToRecord:)]) {
            [self.delegate cameraReadyToRecord:self];
        }
    });
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"finish record");
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraFinishToRecord:)]) {
            [self.delegate cameraFinishToRecord:self];
        }
    });
}

/*
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @synchronized (self) {
        
        if (self.isRecording && self.assetWriter.status != AVAssetWriterStatusWriting && self.assetWriter.status != AVAssetWriterStatusFailed) {
            [self.assetWriter startWriting];
            [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(cameraReadyToRecord:)]) {
                    [self.delegate cameraReadyToRecord:self];
                }
            });
        }
        
        if (connection == self.audioConnection) {
            if ([self.audioWriterInput isReadyForMoreMediaData]) {
                [self.audioWriterInput appendSampleBuffer:sampleBuffer];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(cameraOutputAudio:didOutputSampleBuffer:fromConnection:)]) {
                [self.delegate cameraOutputAudio:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
            }
        } else if (connection == self.videoConnection) {
            
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            CVPixelBufferLockBaseAddress(imageBuffer, 0);
            
            CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
            
            CIImage *output = sourceImage;
            
            for (INCameraFilter *filter in self.filterArray) {
                filter.sourceImage = output;
                
                output = filter.outputImage;
            }
            
            if (self.filterArray.count > 0) {
                [self.ciContext render:output toCVPixelBuffer:imageBuffer];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(cameraOutputVideo:didOutputImageBuffer:fromConnection:)]) {
                if (imageBuffer) {
                    [self.delegate cameraOutputVideo:captureOutput didOutputImageBuffer:sourceImage fromConnection:connection];
                }
                
            }
            
            
            if (imageBuffer) {
                
                if ([self.videoWriterInput isReadyForMoreMediaData]) {
                    [self.bufferAdaptor appendPixelBuffer:imageBuffer withPresentationTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                }
                CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                imageBuffer = nil;
            }
            
            
        }
        
    }
    
}
*/


+(NSString *)movieFilePath{
    return [NSTemporaryDirectory() stringByAppendingString:@"tempMovie.mov"];
}

+(NSURL *)movieFileUrl{
    return [NSURL fileURLWithPath:[self movieFilePath]];
}
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}
@end

@implementation UIImage (ori)

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    
    
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
