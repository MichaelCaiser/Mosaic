//
//  MViewController.m
//  Mosaic
//
//  Created by Scott on 4/21/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//

#import "MViewController.h"

#define kLabelHeight 30

@interface MViewController ()

@end

typedef enum {
  MLoadingPhaseDetermineLocation,
  MLoadingPhaseRetrieveImages,
  MLoadingPhaseDone
} MLoadingPhase;

@implementation MViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [[self view] setBackgroundColor:[UIColor blackColor]];
  [[self view] setFrame:[[UIScreen mainScreen] bounds]];
  [self loadImages];
}

- (void)loadImages {
  [self setLoadingPhase:MLoadingPhaseRetrieveImages];
  MKCoordinateRegion region = [self regionForCoordinate:CLLocationCoordinate2DMake(40.116304, -88.243519)];
  NSArray *providers = @[
                         [[MUserImageProvider alloc] init],
                         [[MFlickrImageProvider alloc] init]
                         ];
  NSMutableArray *providerFinished = [NSMutableArray arrayWithCapacity:[providers count]];
  for (NSUInteger i = 0 ; i < [providers count] ; i++) {
    [providerFinished addObject:@NO];
  }
  NSMutableArray *totalImages = [NSMutableArray arrayWithCapacity:30];
  for (NSUInteger i = 0 ; i < [providers count] ; i++) {
    NSObject<MImageProvider> *provider = [providers objectAtIndex:i];
    [provider imagesForRegion:region callback:^(NSArray *images) {
      [totalImages addObjectsFromArray:images];
      [providerFinished replaceObjectAtIndex:i withObject:@YES];
      if ([self allProvidersFinished:providerFinished]) {
        _images = totalImages;
        [self createMosaic];
      }
    }];
  }
}

- (void)createMosaic {
  [self setLoadingPhase:MLoadingPhaseDone];
  NSLog(@"Images: %@",_images);
  
  _mosaic = [[MMosaicView alloc] initWithImages:_images];
  [_mosaic setFrame:CGRectMake(0, kLabelHeight, self.view.width, self.view.height - kLabelHeight)];
  
  _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kLabelHeight)];
  [_locationLabel setCenterX:[[self view] centerX]];
  [_locationLabel setText:@"Urbana, IL"];
  [_locationLabel setBackgroundColor:[UIColor clearColor]];
  [_locationLabel setTextColor:[UIColor whiteColor]];
  [_locationLabel setTextAlignment:NSTextAlignmentCenter];
  [_locationLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:20.0]];
  
  [[self view] addSubview:_mosaic];
  [[self view] addSubview:_locationLabel];
}

- (BOOL)allProvidersFinished:(NSArray *)providerFinished {
  BOOL allDone = YES;
  for (NSNumber *finished in providerFinished) {
    allDone = allDone & [finished boolValue];
  }
  return allDone;
}

- (void)setLoadingPhase:(MLoadingPhase)phase {
  if (!_loadingView || !_loadingLabel) {
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingView.center = self.view.center;
    _loadingView.y = _loadingView.y - (_loadingView.height / 2);
    _loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [[self view] addSubview:_loadingView];
    [[self view] addSubview:_loadingLabel];
  }
  if (phase == MLoadingPhaseDetermineLocation) {
    [_loadingLabel setText:@"Determining Location..."];
  }
  if (phase == MLoadingPhaseRetrieveImages) {
    [_loadingLabel setText:@"Retrieving Images..."];
  }
  if (phase == MLoadingPhaseDone) {
    [_loadingView removeFromSuperview];
    [_loadingLabel removeFromSuperview];
    return;
  }
  // Realign the loading label with the next text
  [_loadingLabel sizeToFit];
  _loadingLabel.center = self.view.center;
  _loadingLabel.y = _loadingLabel.y + (_loadingLabel.height / 2);
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (MKCoordinateRegion)regionForCoordinate:(CLLocationCoordinate2D)coordinate {
  MKCoordinateSpan span = MKCoordinateSpanMake(1, 1);
  return MKCoordinateRegionMake(coordinate, span);
}

@end
