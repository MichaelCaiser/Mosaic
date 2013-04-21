//
//  MUserImageProvider.m
//  Mosaic
//
//  Created by Scott on 4/21/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//

#import "MUserImageProvider.h"

@implementation MUserImageProvider

- (void)imagesForRegion:(MKCoordinateRegion)region callback:(void (^)(NSArray *images))callback; {
  ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
  [library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop){
      NSLog(@"Sup!");
    }];
  } failureBlock:nil];
  callback(@[]);
}

@end
