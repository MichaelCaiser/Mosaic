//
//  UIView+FrameSettingAdditions.m
//  MobileTA
//
//  Created by Scott on 4/1/13.
//  Copyright (c) 2013 Steven Sheldon. All rights reserved.
//

#import "UIView+FrameAdditions.h"

@implementation UIView (FrameAdditions)

#pragma mark Getting Origin

- (CGFloat)x {
  return self.frame.origin.x;
}

- (CGFloat)y {
  return self.frame.origin.y;
}

- (CGPoint)frameOrigin {
  return self.frame.origin;
}

#pragma mark Setting Origin

- (void)setX:(CGFloat)x {
  CGFloat y = self.frame.origin.y;
  [self setFrameOrigin:CGPointMake(x, y)];
}

- (void)setY:(CGFloat)y {
  CGFloat x = self.frame.origin.x;
  [self setFrameOrigin:CGPointMake(x, y)];
}

- (void)setFrameOrigin:(CGPoint)point {
  CGSize size = self.frame.size;
  [self setFrame:CGRectMake(point.x, point.y, size.width, size.height)];
}

#pragma mark Getting Size

- (CGFloat)width {
  return self.frame.size.width;
}

- (CGFloat)height {
  return self.frame.size.height;
}

- (CGSize)frameSize {
  return self.frame.size;
}

#pragma mark Setting Size

- (void)setWidth:(CGFloat)width {
  CGFloat height = self.frame.size.height;
  [self setFrameSize:CGSizeMake(width, height)];
}

- (void)setHeight:(CGFloat)height {
  CGFloat width = self.frame.size.width;
  [self setFrameSize:CGSizeMake(width, height)];
}

- (void)setFrameSize:(CGSize)size {
  CGPoint origin = self.frame.origin;
  [self setFrame:CGRectMake(origin.x, origin.y, size.width, size.height)];
}

@end
