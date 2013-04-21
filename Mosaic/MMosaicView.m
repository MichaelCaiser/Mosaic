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
  _imageViews = [NSMutableArray arrayWithCapacity:[_images count]];
  for (UIImage *image in _images) {
    // TODO(srice): Create the view;
  }
}

@end
