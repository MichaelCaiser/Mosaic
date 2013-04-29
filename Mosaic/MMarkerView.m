//
//  MMarkerView.m
//  Mosaic
//
//  Created by Scott on 4/29/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//

#import "MMarkerView.h"

#define kPadding 5

@implementation MMarkerView

- (id)init {
  return [self initWithFrame:CGRectMake(0, 0, 100, 140)];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialize
    [self setBackgroundColor:[UIColor clearColor]];
  }
  return self;
}

- (void)setImage:(UIImage *)image {
  if (image == _image) return;
  _image = image;
  [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
  NSLog(@"¯\\(ツ)/¯");
  [[self markerPath] addClip];
  [self drawScaledImage];
}

- (UIBezierPath *)markerPath {
  UIBezierPath *path = [UIBezierPath bezierPath];
  [path moveToPoint:[self pointForTip]];
  [path addLineToPoint:[self curvePointForSide:NSLayoutAttributeLeft]];
  [path addArcWithCenter:self.arcCenter radius:self.arcRadius startAngle:M_PI endAngle:0 clockwise:NO];
  [path addLineToPoint:[self pointForTip]];
  return path;
}

#pragma mark Private Methods

/*/
 *
 *  HERE BE DRAGONS
 *
/*/

- (void)drawScaledImage {
  UIImage *scaled = [self scaledImage];
  CGPoint drawPoint = [self drawPointForImage:scaled centeredInside:[self bounds]];
  NSLog(@"%@",NSStringFromCGPoint(drawPoint));
  [scaled drawAtPoint:drawPoint];
}

- (CGPoint)drawPointForImage:(UIImage *)image centeredInside:(CGRect)rect {
  CGPoint center = CGPointMake(rect.origin.x + (rect.size.width / 2), rect.origin.y + (rect.size.height / 2));
  CGPoint imageCenter = CGPointMake(image.size.width / 2, image.size.height / 2);
  return CGPointMake(center.x - imageCenter.x, center.y - imageCenter.y);
}

- (UIImage *)scaledImage {
//  return [self scaleImage:_image toSize:self.scaleSize];
  return [UIImage imageWithCGImage:_image.CGImage scale:self.scaleFactor orientation:_image.imageOrientation];
}

- (CGFloat)scaleFactor {
  CGSize imageSize = [_image size];
  if (imageSize.width < imageSize.height) {
    // Scale it such that the width of the image is at least the width of the frame
    return imageSize.width / self.width;
  }
  else {
    return imageSize.height / self.height;
  }
}

- (CGPoint)pointForTip {
  // The tip should be at y value at kPadding, and x value in the middle of the view
  return CGPointMake(self.width / 2, kPadding);
}

- (CGPoint)arcCenter {
  // The center of the arc should be in the middle of the frame, and at a height
  // Where the edge of the arc would be at kPadding.
  return CGPointMake(self.width / 2, self.height - kPadding - self.arcRadius);
}

- (CGFloat)arcRadius {
  return self.markerWidth / 2;
}

- (CGFloat)markerWidth {
  return self.width - (2 * kPadding);
}

- (CGPoint)curvePointForSide:(NSLayoutAttribute)side {
  // The curve point should begin at the y value of the arcCenter
  if (side == NSLayoutAttributeLeft) {
    return CGPointMake(kPadding, self.arcCenter.y);
  }
  if (side == NSLayoutAttributeRight) {
    return CGPointMake(kPadding + self.markerWidth, self.arcCenter.y);
  }
  return CGPointZero;
}

#pragma mark Code taken from the internet

/*/
 *  Taken from:
 *  http://stackoverflow.com/questions/6703502/how-to-resize-an-uiimage-while-maintaining-its-aspect-ratio
/*/
- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
  CGSize scaledSize = newSize;
  float scaleFactor = 1.0;
  if( image.size.width > image.size.height ) {
    scaleFactor = image.size.width / image.size.height;
    scaledSize.width = newSize.width;
    scaledSize.height = newSize.height / scaleFactor;
  }
  else {
    scaleFactor = image.size.height / image.size.width;
    scaledSize.height = newSize.height;
    scaledSize.width = newSize.width / scaleFactor;
  }
  
  UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
  CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
  [image drawInRect:scaledImageRect];
  UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return scaledImage;
}

@end
