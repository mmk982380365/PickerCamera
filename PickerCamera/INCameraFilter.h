//
//  INCameraFilter.h
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/13.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface INCameraFilter : NSObject

@property (nonatomic, assign) CGPoint center;

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, strong) CIImage *sourceImage;

@property (nonatomic, strong) CIImage *outputImage;

-(instancetype)initWithFilterName:(NSString *)name;

-(instancetype)initWithImageBuffer:(CVPixelBufferRef)imageBuffer;

@end
