//
//  MViewController.m
//  Mosaic
//
//  Created by Scott on 4/21/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//

#import "MViewController.h"

@interface MViewController ()

@end

@implementation MViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [[self view] setFrame:[[UIScreen mainScreen] bounds]];
  NSArray *images = [self loadImages];
  _mosaic = [[MMosaicView alloc] initWithImages:images];
  [_mosaic setFrame:[[self view] bounds]];
  [[self view] addSubview:_mosaic];
}

- (NSArray *)loadImages {
  MKCoordinateRegion region = [self regionForCoordinate:CLLocationCoordinate2DMake(10, 10)];
  NSArray *providers = @[
                         [[MUserImageProvider alloc] init]
//                         [[MFlickrImageProvider alloc] init]
                         ];
  NSMutableArray *providerFinished = [NSMutableArray arrayWithCapacity:[providers count]];
  for (NSUInteger i = 0 ; i < [providers count] ; i++) {
    [providerFinished addObject:[NSNumber numberWithBool:NO]];
  }
  NSMutableArray *totalImages = [NSMutableArray arrayWithCapacity:30];
  for (NSUInteger i = 0 ; i < [providers count] ; i++) {
    NSObject<MImageProvider> *provider = [providers objectAtIndex:i];
    [provider imagesForRegion:region callback:^(NSArray *images) {
      [totalImages addObjectsFromArray:images];
      [providerFinished replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
    }];
  }
  BOOL waiting = YES;
  while (waiting) {
    // Check if we are actually waiting
    BOOL allDone = YES;
    for (NSNumber *flag in providerFinished) {
      allDone = allDone && [flag boolValue];
    }
    if (allDone) {
      waiting = NO;
    }
  }
  return totalImages;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (MKCoordinateRegion)regionForCoordinate:(CLLocationCoordinate2D)coordinate {
  MKCoordinateSpan span = MKCoordinateSpanMake(10, 10);
  return MKCoordinateRegionMake(coordinate, span);
}

@end
