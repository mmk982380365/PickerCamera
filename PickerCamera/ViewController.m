//
//  ViewController.m
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/8.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import "ViewController.h"
#import "INPickerCameraViewController.h"

@interface ViewController () <INPickerCameraViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)btnOnClick:(id)sender {
    INPickerCameraViewController *cameraVc = [[INPickerCameraViewController alloc] init];
    cameraVc.delegate = self;
    [self presentViewController:cameraVc animated:YES completion:^{
        
    }];
}

-(void)cameraController:(INPickerCameraViewController *)controller didFinishSelectPhotos:(UIImage *)photo{
    self.view.layer.contentsGravity = kCAGravityResizeAspect;
    self.view.layer.contents = (__bridge id _Nullable)(photo.CGImage);
}

-(void)cameraController:(INPickerCameraViewController *)controller didFinishRecordVideoWithVideoPath:(NSURL *)videoPath{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
