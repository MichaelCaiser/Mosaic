//
//  MImageProvider.h
//  Mosaic
//
//  Created by Scott on 4/21/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol MImageProvider <NSObject>

@required
- (void)imagesForRegion:(MKCoordinateRegion)region callback:(void (^)(NSArray *images))callback;

@end
