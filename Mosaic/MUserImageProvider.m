//
//  MUserImageProvider.m
//  Mosaic
//
//  Created by Scott on 4/21/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//

#import "MUserImageProvider.h"

BOOL MKCoordinateRegionContainsCoordinate(MKCoordinateRegion region, CLLocationCoordinate2D coord) {
  return (coord.latitude <= region.center.latitude + region.span.latitudeDelta &&
          coord.latitude >= region.center.latitude - region.span.latitudeDelta) &&
         (coord.longitude <= region.center.longitude + region.span.longitudeDelta &&
          coord.longitude >= region.center.longitude - region.span.longitudeDelta);
}

@implementation MUserImageProvider

- (void)imagesForRegion:(MKCoordinateRegion)region callback:(void (^)(NSArray *images))callback; {
  __block NSUInteger totalAssets = 0;
  __block NSUInteger seenAssets = 0;
  NSMutableArray *xy =[[NSMutableArray alloc]init];
  NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
  
  ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
  
  NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
  // Group Enumerator
  void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
    if(group != nil) {
      NSUInteger numAssets = [group numberOfAssets];
      totalAssets += numAssets;
      // Asset Enumerator
      [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != nil) {
          if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
            [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
            
            NSURL *url= (NSURL*) [[result defaultRepresentation]url];
            // Only download the image if it is inside the region
            CLLocation *imageLocation = [result valueForProperty:ALAssetPropertyLocation];
            if (MKCoordinateRegionContainsCoordinate(region,[imageLocation coordinate])) {
              [library assetForURL:url
                       resultBlock:^(ALAsset *asset) {
                         seenAssets++;
                         [xy addObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]];
                         if (seenAssets == totalAssets) {
                           callback(xy);
                         }
                       }
                      failureBlock:^(NSError *error){ NSLog(@"test:Fail"); } ];
            }
            else {
              seenAssets++;
              if (seenAssets == totalAssets) {
                callback(xy);
              }
            }
          }
        }
      }];
      [assetGroups addObject:group];
    }
  };
  
  assetGroups = [[NSMutableArray alloc] init];
  
  [library enumerateGroupsWithTypes:ALAssetsGroupAll
                         usingBlock:assetGroupEnumerator
                       failureBlock:^(NSError *error) {NSLog(@"A problem occurred");}];
}

@end
