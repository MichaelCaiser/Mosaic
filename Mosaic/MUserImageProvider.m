//
//  MUserImageProvider.m
//  Mosaic
//
//  Created by Scott on 4/21/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//

#import "MUserImageProvider.h"

BOOL MKCoordinateRegionContainsCoordinate(MKCoordinateRegion region, CLLocationCoordinate2D coord) {
  coord = CLLocationCoordinate2DMake(40.1164, -88.2433);
  return (coord.latitude <= region.center.latitude + region.span.latitudeDelta &&
          coord.latitude >= region.center.latitude - region.span.latitudeDelta) &&
         (coord.longitude <= region.center.longitude + region.span.longitudeDelta &&
          coord.longitude >= region.center.longitude - region.span.longitudeDelta);
}

@implementation MUserImageProvider

- (void)imagesForRegion:(MKCoordinateRegion)region callback:(void (^)(NSArray *images))callback; {
  // I'm sorry for having written this method. Ugh.
  __block NSUInteger totalAssets = 0;
  __block NSUInteger seenAssets = 0;
  __block BOOL callbackFired = NO;
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
            // Only download the image if it is inside the region
            CLLocation *imageLocation = [result valueForProperty:ALAssetPropertyLocation];
            if (MKCoordinateRegionContainsCoordinate(region,[imageLocation coordinate])) {
              seenAssets++;
              [xy addObject:[UIImage imageWithCGImage:[[result defaultRepresentation] fullScreenImage]]];
              if (seenAssets == totalAssets) {
                if (!callbackFired) {
                  callbackFired = YES;
                  callback(xy);
                }
              }
            }
            else {
              seenAssets++;
              if (seenAssets == totalAssets) {
                if (!callbackFired) {
                  callbackFired = YES;
                  callback(xy);
                }
              }
            }
          }
        }
        else {
          if (seenAssets == totalAssets) {
            if (!callbackFired) {
              callbackFired = YES;
              callback(xy);
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
