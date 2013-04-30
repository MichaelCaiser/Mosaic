//
//  MMosaicView.m
//  Mosaic
//
//  Created by Scott on 4/21/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//
//  A view which shows the user's location on top of a set of images.
//

#import "MMosaicView.h"
#import "MMarkerView.h"

@implementation MMosaicView

- (id)initWithImages:(NSArray *)images {
  self = [self initWithFrame:CGRectZero];
  if (self) {
    [self setImages:images];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImages:(NSArray *)images {
  if (_images == images) return;
  _images = images;
  [self _createImageViews];
  [self setNeedsLayout];
}

- (void)layoutSubviews {
  // TODO: Lay out the images in a mosaic pattern
  for (NSUInteger i = 0; i < [_markerViews count]; i++) {
    NSUInteger group = ((5 * (i/5)) + 5) / 5;
    NSUInteger val = i % 5;
    //NSUInteger iter = [_markerViews count] / i;
    MMarkerView *current = [_markerViews objectAtIndex:i];
    NSUInteger x = 0;
    NSUInteger y = 0;
    
    if (val <= 1) {
      x = (self.width/2) - (val * current.width);
      y = (group-1)* (current.height + (current.height/2));
      [current setUpsideDown:YES];
    }
    else if (val >= 2) {
      NSLog(@"%f", current.height);
      x = self.width - ((val - 1) * current.width) - 10;
      y = (group * current.height) - 47 + (group-1)*(current.height/2);
    }
    
    [current setFrameOrigin:CGPointMake(x,y)];
  }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)_createImageViews {
  _markerViews = [NSMutableArray arrayWithCapacity:[_images count]];
  for (NSUInteger i = 0; i < [_images count]; i++) {
    UIImage *image = [_images objectAtIndex:i];
    MMarkerView *current = [[MMarkerView alloc] init];
    [current setImage:image];
    [_markerViews addObject:current];
    [self addSubview:current];
  }
}

- (CGFloat)contentHeight {
  CGFloat max = 0;
  NSLog(@"%@",_markerViews);
  for (MMarkerView *current in _markerViews) {
    CGFloat heightRequired = current.y + current.height;
    if (heightRequired > max) {
      max = heightRequired;
    }
  }
  return max;
}

@end
