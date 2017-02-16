//
//  INCameraFilter.m
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/13.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import "INCameraFilter.h"
#import <CoreImage/CoreImage.h>

@interface INCameraFilter ()

@property (nonatomic, strong) CIFilter *filter;

@end

@implementation INCameraFilter

- (instancetype)initWithFilterName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.filter = [CIFilter filterWithName:name];
    }
    return self;
}

- (instancetype)initWithImageBuffer:(CVPixelBufferRef)imageBuffer
{
    self = [super init];
    if (self) {
        self.filter = [CIFilter filterWithCVPixelBuffer:imageBuffer properties:@{} options:@{}];
        self.filter.name = @"CIVignetteEffect";
    }
    return self;
}

-(void)setCenter:(CGPoint)center {
    [self.filter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:kCIInputCenterKey];
}

-(void)setRadius:(CGFloat)radius {
    [self.filter setValue:@(radius) forKey:kCIInputRadiusKey];
}

-(void)setSourceImage:(CIImage *)sourceImage {
    [self.filter setValue:sourceImage forKey:kCIInputImageKey];
}

-(CIImage *)outputImage {
    return self.filter.outputImage;
}

@end
