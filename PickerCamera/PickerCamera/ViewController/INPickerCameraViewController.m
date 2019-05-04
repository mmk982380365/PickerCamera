//
//  INPickerCameraViewController.m
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import "INPickerCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "INPickerCamera.h"
#import <GLKit/GLKit.h>
#import "INCameraCursor.h"
#import "INCameraTop.h"
#import "INCameraTakePhotosView.h"
#import "INCameraPreviewView.h"
#import "INCameraMoviePreviewView.h"
#import "INCameraFilter.h"
#import "INCameraZoomView.h"

#define VideoMaxRecordTime 10

@interface INPickerCameraViewController () <INPickerCameraDelegate, INCameraTopDelegate, INCameraTakePhotosViewDelegate, INCameraPreviewViewDelegate,UIGestureRecognizerDelegate>

{
    CGFloat videoDuration;
    CIContext *ciContext;
    EAGLContext *context;
    CGRect previewBounds;
    CGFloat beginGestureScele;
    CGFloat effectiveScale;
}

@property (nonatomic, strong) INPickerCamera *camera;
@property (nonatomic, strong) GLKView *previewView;
@property (nonatomic, strong) INCameraCursor *focusCursor;
@property (nonatomic, strong) INCameraTop *topView;
@property (nonatomic, strong) INCameraTakePhotosView *takePhotosView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) INCameraPreviewView *photoPreviewer;
@property (nonatomic, strong) INCameraMoviePreviewView *moviePreviewer;
@property (nonatomic, strong) NSTimer *timer;
//@property (nonatomic, strong) NSMutableArray *filterArray;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic, strong) INCameraZoomView *zoomSlider;

@end

@implementation INPickerCameraViewController
- (void)dealloc
{
    [self.camera stopSession];
    [EAGLContext setCurrentContext:nil];
    NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.camera = [[INPickerCamera alloc] init];
        self.camera.delegate = self;
        //        self.filterArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self setupView];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.camera setupSession];
        [self.camera startSession];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setFocusPoint:CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0)];
        });
        
    });
    
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.camera stopSession];
}

-(void)setupView{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        ciContext = [CIContext contextWithEAGLContext:context options:@{
                                                                        kCIContextWorkingColorSpace: [NSNull null]
                                                                        }];
        self.camera.ciContext = ciContext;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.view.opaque = NO;
            
            self.previewView = [[GLKView alloc] initWithFrame:self.view.bounds context:context];
            self.previewView.enableSetNeedsDisplay = NO;
            
            self.previewView.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.previewView.frame = self.view.bounds;
            
            [self.view addSubview:self.previewView];
            
            [self.previewView bindDrawable];
            previewBounds = CGRectZero;
            previewBounds.size.width = self.previewView.drawableWidth;
            previewBounds.size.height = self.previewView.drawableHeight;
            
            self.topView = [[INCameraTop alloc] init];
            self.topView.delegate = self;
            [self.view addSubview:self.topView];
            
            
            
            self.takePhotosView = [[INCameraTakePhotosView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 80.0) / 2.0, [UIScreen mainScreen].bounds.size.height - 20.0 - 80.0, 80.0 , 80.0)];
            if (@available(iOS 11.0, *)) {
                self.takePhotosView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 80.0) / 2.0, [UIScreen mainScreen].bounds.size.height - 20.0 - 80.0 - self.view.safeAreaInsets.bottom, 80.0 , 80.0);
            }
            self.takePhotosView.delegate = self;
            [self.view addSubview:self.takePhotosView];
            
            self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.takePhotosView.frame) - 29.0, [UIScreen mainScreen].bounds.size.width, 14.0)];
            self.descLabel.font = [UIFont systemFontOfSize:13.0];
            self.descLabel.textColor = [UIColor whiteColor];
            self.descLabel.textAlignment = NSTextAlignmentCenter;
            self.descLabel.text = @"点击拍照，长按录像";
            [self.view addSubview:self.descLabel];
            
            self.zoomSlider = [[INCameraZoomView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.descLabel.frame) - 88.0, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height - (CGRectGetMinY(self.descLabel.frame) - 88.0) + 50)];
            
            [self.zoomSlider addTarget:self action:@selector(sliderOnSlide:)];
            [self.view addSubview:self.zoomSlider];
            
            [self.view addSubview:self.photoPreviewer];
            [self.view addSubview:self.moviePreviewer];
            
            
            
            
            
            
            self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
            self.pinchRecognizer.delegate = self;
            [self.previewView addGestureRecognizer:self.pinchRecognizer];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [self.previewView addGestureRecognizer:tap];
            
            [tap requireGestureRecognizerToFail:self.pinchRecognizer];
            
        });
        
    });
    
    
}

-(void)sliderOnSlide:(INCameraZoomView *)slider{
    CGFloat value = slider.value;
    self.camera.videoZoomFactor = value;
    effectiveScale = value;
    NSLog(@"11111");
}

-(void)pinchAction:(UIPinchGestureRecognizer *)recognizer {
    BOOL allTouchesAreOnPreview = YES;
    NSUInteger numOfTouch = [recognizer numberOfTouches];
    for (int i = 0; i < numOfTouch; i++) {
        
        CGPoint location = [recognizer locationOfTouch:i inView:self.view];
        if (!CGRectContainsPoint(self.view.frame, location)) {
            allTouchesAreOnPreview = NO;
            break;
        }
        
    }
    
    if (allTouchesAreOnPreview) {
        effectiveScale = beginGestureScele * recognizer.scale;
        if (effectiveScale < 1.0) {
            effectiveScale = 1.0;
        }
        
        CGFloat maxScaleAndCropFactor = 10;
        
        if (effectiveScale > maxScaleAndCropFactor) {
            effectiveScale = maxScaleAndCropFactor;
        }
        
        
        self.zoomSlider.value = effectiveScale;
    }
    
}

-(void)tapAction:(UIGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    [self setFocusPoint:location];
}

-(void)setupTimer{
    videoDuration = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recording) userInfo:nil repeats:YES];
}

-(void)removeTimer{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)recording{
    videoDuration += 1;
    self.takePhotosView.progress = videoDuration / VideoMaxRecordTime;
    self.descLabel.text = [NSString stringWithFormat:@"%.0f秒",videoDuration];
    if (videoDuration >= VideoMaxRecordTime) {
        [self endRecordingVideo:self.takePhotosView];
    }
}

-(void)setFocusPoint:(CGPoint)point {
    self.focusCursor.center = point;
    self.focusCursor.transform = CGAffineTransformMakeScale(1.3, 1.3);
    [UIView animateWithDuration:0.2 animations:^{
        self.focusCursor.transform = CGAffineTransformIdentity;
    }];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 2.0;
    animation.values = @[@1, @1, @0];
    animation.keyTimes = @[@0.0, @0.8, @1.0];
    [self.focusCursor.layer addAnimation:animation forKey:@"alpha"];
    
    CGPoint cameraPoint = CGPointMake(point.y / self.view.bounds.size.height, 1 - point.x / self.view.bounds.size.width);
    [self.camera setFocusMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose interestPoint:cameraPoint];
    
}

#pragma mark - gesture delegate

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.pinchRecognizer) {
        beginGestureScele = effectiveScale;
    }
    
    return YES;
}

#pragma mark - topView delegate

-(void)cancelBtnOnClick:(INCameraTop *)topView{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(INPickerCameraViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(cameraControllerDidCancel:)]) {
        [self.delegate cameraControllerDidCancel:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)flashModeOnClick:(INCameraTop *)topView mode:(CameraFlashMode)flashMode{
    AVCaptureFlashMode mode = AVCaptureFlashModeOff;
    switch (flashMode) {
        case CameraFlashModeOn:
            mode = AVCaptureFlashModeOn;
            break;
        case CameraFlashModeOff:
            mode = AVCaptureFlashModeOff;
        default:
            mode = AVCaptureFlashModeAuto;
            break;
    }
    self.camera.flashMode = mode;
}

-(void)positionOnClick:(INCameraTop *)topView{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        AVCaptureDevicePosition toPosition = AVCaptureDevicePositionFront;
        
        if (self.camera.cameraPosition == AVCaptureDevicePositionFront) {
            toPosition = AVCaptureDevicePositionBack;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.topView setBtnTitle:@"后置" type:CameraTopBtnTypePosition];
                
                
                
            });
            
            
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.topView setBtnTitle:@"前置" type:CameraTopBtnTypePosition];
            });
            
            
            
        }
        
        self.camera.cameraPosition = toPosition;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CATransition *animation = [CATransition animation];
            animation.duration = 0.5;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.type = @"oglFlip";
            animation.subtype = toPosition == AVCaptureDevicePositionFront ? kCATransitionFromLeft : kCATransitionFromRight;
            [self.previewView.layer addAnimation:animation forKey:@"anims"];
        });
        
        
        
    });
    
    
    
}

#pragma mark - preview delegate

-(void)didClickSendBtn:(INCameraPreviewView *)previewView {
    if (previewView == self.photoPreviewer) {
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(INPickerCameraViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(cameraController:didFinishSelectPhotos:)]) {
            [self.delegate cameraController:self didFinishSelectPhotos:previewView.image];
        }
    } else if (previewView == self.moviePreviewer) {
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(INPickerCameraViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(cameraController:didFinishRecordVideoWithVideoPath:)]) {
            [self.delegate cameraController:self didFinishRecordVideoWithVideoPath:[INPickerCamera movieFileUrl]];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didClickRetakeBtn:(INCameraPreviewView *)previewView{
    if (previewView == self.photoPreviewer) {
        self.photoPreviewer.hidden = YES;
        
    } else {
        self.moviePreviewer.hidden = YES;
        [self.moviePreviewer pause];
    }
}

#pragma mark - take photos delegate

-(void)beganRecordingVideo:(INCameraTakePhotosView *)takeView{
    self.descLabel.text = @"请稍后";
    [self.camera startRecording];
    
}

-(void)endRecordingVideo:(INCameraTakePhotosView *)takeView{
    if (self.camera.isRecording) {
        [self removeTimer];
        
        [self.camera stopRecrding];
        self.descLabel.text = @"请稍后";
    }
}

-(void)didTriggerTakePhotos:(INCameraTakePhotosView *)takeView{
    __weak typeof(self) ws = self;
    self.takePhotosView.userInteractionEnabled = NO;
    [self.camera takePhotos:^(UIImage *result) {
        ws.takePhotosView.userInteractionEnabled = YES;
        ws.photoPreviewer.hidden = NO;
        ws.photoPreviewer.image = result;
    }];
}

#pragma mark - camera delegate

-(void)cameraReadyToRecord:(INPickerCamera *)camera{
    self.descLabel.text = @"0秒";
    [self setupTimer];
}

-(void)cameraFinishToRecord:(INPickerCamera *)camera{
    self.moviePreviewer.hidden = NO;
    self.moviePreviewer.fileUrl = [INPickerCamera movieFileUrl];
    [self.moviePreviewer play];
    self.descLabel.text = @"点击拍照，长按录像";
}

-(void)cameraOutputAudio:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}

static CGRect sourceExtent;
static CGFloat sourceAspect;
static CGFloat previewAspect;
//static CIImage *sourceImage;

-(void)cameraOutputVideo:(AVCaptureOutput *)captureOutput didOutputImageBuffer:(CIImage *)sourceImage fromConnection:(AVCaptureConnection *)connection{
    
    
    if (sourceImage) {
        sourceExtent = sourceImage.extent;
        
        sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
        previewAspect = previewBounds.size.width / previewBounds.size.height;
        
        CGRect drawRect = sourceExtent;
        
        if (sourceAspect > previewAspect) {
            drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
            drawRect.size.width = drawRect.size.height * previewAspect;
        } else {
            drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0;
            drawRect.size.height = drawRect.size.width / previewAspect;
        }
        
        [self.previewView bindDrawable];
        
        if ([EAGLContext currentContext] != context) {
            [EAGLContext setCurrentContext:context];
        }
        
        glClearColor(0.5, 0.5, 0.5, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        
        [ciContext drawImage:sourceImage inRect:previewBounds fromRect:drawRect];
        
        
        [self.previewView display];
        
    }
    
    
}

-(INCameraCursor *)focusCursor {
    if (_focusCursor == nil) {
        _focusCursor = [[INCameraCursor alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 80.0)];
        _focusCursor.alpha = 0;
        [self.view addSubview:_focusCursor];
    }
    return _focusCursor;
}

-(INCameraPreviewView *)photoPreviewer{
    if (_photoPreviewer == nil) {
        _photoPreviewer = [[INCameraPreviewView alloc] initWithFrame:self.view.bounds];
        _photoPreviewer.delegate = self;
        _photoPreviewer.hidden = YES;
    }
    return _photoPreviewer;
}

-(INCameraMoviePreviewView *)moviePreviewer{
    if (_moviePreviewer == nil) {
        _moviePreviewer = [[INCameraMoviePreviewView alloc] initWithFrame:self.view.bounds];
        _moviePreviewer.delegate = self;
        _moviePreviewer.hidden = YES;
    }
    return _moviePreviewer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
