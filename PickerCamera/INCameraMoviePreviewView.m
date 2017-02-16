//
//  INCameraMoviePreviewView.m
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/10.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import "INCameraMoviePreviewView.h"

@implementation INCameraMoviePreviewView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setFileUrl:(NSURL *)fileUrl{
    _fileUrl = fileUrl;
    [self resetPlayer];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:fileUrl];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer insertSublayer:self.playerLayer atIndex:0];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlayMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

-(void)didFinishPlayMovie:(NSNotification *)note {
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self play];
}

-(void)resetPlayer{
    if (self.player) {
        [self.player pause];
    }
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
    }
}

-(void)play{
    [self.player play];
}

-(void)pause{
    [self.player pause];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
