//
//  INCameraMoviePreviewView.h
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import "INCameraPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@interface INCameraMoviePreviewView : INCameraPreviewView

@property (nonatomic, strong) NSURL *fileUrl;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

-(void)play;

-(void)pause;

@end
