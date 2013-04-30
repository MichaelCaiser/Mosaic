//
//  MMarkerView.m
//  Mosaic
//
//  Created by Scott on 4/29/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//

#import "MMarkerView.h"

#define D2R(degrees) ((M_PI * degrees)/ 180)

#define kPadding 5
#define kAngle D2R(45)

@implementation MMarkerView

- (id)init {
  return [self initWithFrame:CGRectMake(0, 0, 100, 120)];
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

- (void)setUpsideDown:(BOOL)upsideDown {
  if (upsideDown == _upsideDown) return;
  _upsideDown = upsideDown;
  [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
  NSLog(@"¯\\(ツ)/¯");
  [[self markerPath] addClip];
  [self drawScaledImage];
}

#pragma mark Private Methods

#pragma mark -Image Related Methods

/*/
 *
 *  HERE BE DRAGONS
 *
/*/

- (void)drawScaledImage {
  UIImage *scaled = [self scaledImage];
  CGPoint drawPoint = [self drawPointForImage:scaled centeredInside:[self bounds]];
  [scaled drawAtPoint:drawPoint];
}

- (CGPoint)drawPointForImage:(UIImage *)image centeredInside:(CGRect)rect {
  CGPoint center = CGPointMake(rect.origin.x + (rect.size.width / 2), rect.origin.y + (rect.size.height / 2));
  CGPoint imageCenter = CGPointMake(image.size.width / 2, image.size.height / 2);
  return CGPointMake(center.x - imageCenter.x, center.y - imageCenter.y);
}

- (UIImage *)scaledImage {
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

#pragma mark -Clipping Related Methods

- (UIBezierPath *)markerPath {
  UIBezierPath *path = [UIBezierPath bezierPath];
  [path moveToPoint:[self pointForTip]];
  // When it is upside down, it should go clockwise. Otherwise, it should go counterclockwise
  if (_upsideDown) {
    [path addArcWithCenter:self.arcCenter radius:self.arcRadius startAngle:M_PI - kAngle endAngle:(2 * M_PI) + kAngle clockwise:YES];
  }
  else {
    [path addArcWithCenter:self.arcCenter radius:self.arcRadius startAngle:M_PI + kAngle endAngle:(2 * M_PI) - kAngle clockwise:NO];
  }
  [path addLineToPoint:[self pointForTip]];
  return path;
}

- (CGPoint)pointForTip {
  // The tip should be at y value at kPadding, and x value in the middle of the view
  if (!_upsideDown)
    return CGPointMake(self.width / 2, kPadding);
  else
    return CGPointMake(self.width / 2, self.height - kPadding);
}

- (CGPoint)arcCenter {
  // The center of the arc should be in the middle of the frame, and at a height
  // Where the edge of the arc would be at kPadding.
  if (!_upsideDown)
    return CGPointMake(self.width / 2, self.height - kPadding - self.arcRadius);
  else
    return CGPointMake(self.width / 2, kPadding + self.arcRadius);
}

- (CGFloat)arcRadius {
  return self.markerWidth / 2;
}

- (CGFloat)markerWidth {
  return self.width - (2 * kPadding);
}

- (CGPoint)curvePointForSide:(NSLayoutAttribute)side {
  // The curve point should begin at the y value of the arcCenter
  CGFloat deltax = self.markerWidth * cos(kAngle);
  CGFloat deltay = self.markerWidth * sin(kAngle);
  NSLog(@"%f,%f",deltax,deltay);
  if (side == NSLayoutAttributeLeft) {
      return CGPointMake(kPadding + (self.markerWidth - deltax), self.arcCenter.y - deltay);
  }
  NSLog(@"TODO: DONT SCREW THIS UP");
  return CGPointMake(kPadding, self.arcCenter.y - deltay);
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
