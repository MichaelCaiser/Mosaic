//
//  MMosaicView.h
//  Mosaic
//
//  Created by Scott on 4/21/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMosaicView : UIView {
  NSMutableArray *_markerViews;
}

- (id)initWithImages:(NSArray *)images;

@property(nonatomic,strong)NSArray *images;

@end
