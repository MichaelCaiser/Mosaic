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
  __block NSUInteger totalAssets = 0;
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
            
            [library assetForURL:url
                     resultBlock:^(ALAsset *asset) {
                       [xy addObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]];
                       if ([xy count] == totalAssets) {
                         callback(xy);
                       }
                     }
                    failureBlock:^(NSError *error){ NSLog(@"test:Fail"); } ];
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
