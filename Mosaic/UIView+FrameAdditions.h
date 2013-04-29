//
//  UIView+FrameSettingAdditions.h
//  MobileTA
//
//  Created by Scott on 4/1/13.
//  Copyright (c) 2013 Steven Sheldon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameAdditions)

// Getting Origin
- (CGFloat)x;
- (CGFloat)y;
- (CGPoint)frameOrigin;

// Setting Origin
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;
- (void)setFrameOrigin:(CGPoint)point;

// Getting Size
- (CGFloat)width;
- (CGFloat)height;
- (CGSize)frameSize;

// Setting Size
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (void)setFrameSize:(CGSize)size;

@end
