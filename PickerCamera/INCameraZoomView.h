//
//  INCameraZoomView.h
//  PickerCamera
//
//  Created by MaMingkun on 2017/2/13.
//  Copyright © 2017年 MaMingkun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INCameraZoomView : UIView

-(void)addTarget:(id)target action:(SEL)action;

@property (nonatomic, assign) float value;

@property (nonatomic, assign, readonly) float maxValue;

@property (nonatomic, assign, readonly) float minValue;

@end
