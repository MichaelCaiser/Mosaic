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
  NSLog(@"viewDidLoad");
  [super viewDidLoad];
  [[self view] setBackgroundColor:[UIColor blackColor]];
  [[self view] setFrame:[[UIScreen mainScreen] bounds]];
  _image_queue = dispatch_queue_create("image_queue", NULL);
  
  _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  [[self view] addSubview:_scrollView];
}

- (void)viewDidAppear:(BOOL)animated {
  [self getCurrentLocation];
//  [self loadImages];
}

- (void)getCurrentLocation {
  if (!_locationManager) {
    _locationManager = [[CLLocationManager alloc] init];
  }
  if ([CLLocationManager locationServicesEnabled]) {
    [_locationManager setDelegate:self];
    [_locationManager startUpdatingLocation];
    [self setLoadingPhase:MLoadingPhaseDetermineLocation];
  }
  else {
    // Error case, there are no location services. Tell the user the problem and
    // do nothing
    [_loadingLabel setText:@"Error: Location Services not enabled"];
    [_loadingView stopAnimating];
    [_loadingView setHidden:YES];
  }
}

- (void)loadImages {
  [self setLoadingPhase:MLoadingPhaseRetrieveImages];
  dispatch_async(_image_queue, ^{
    MKCoordinateRegion region = [self regionForCoordinate:_location];
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
          dispatch_async(dispatch_get_main_queue(), ^{
            [self createMosaicForRegion:region];
          });
        }
      }];
    }
  });
}

- (void)createMosaicForRegion:(MKCoordinateRegion)region {
  NSLog(@"Images: %@",_images);
  
  NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.places.findByLatLon&api_key=9ac99419d1e4d4c101e0f10339bdc84a&lat=%f&lon=%f&accuracy=11&format=rest&auth_token=72157633368979707-92f9b1829813902a&api_sig=ed298e89ffba270ca4e91f4fed45ac33", region.center.latitude, region.center.longitude];
  NSURL *url = [NSURL URLWithString:urlString];
  
  NSString *xmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
  
  NSRange range = [xmlString rangeOfString:@"name=\""];
  NSString *substring = [[xmlString substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  
  range = [substring rangeOfString:@"\""];
  substring = [[substring substringToIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  
  NSArray *cityAndState = [substring componentsSeparatedByString:@","];
  NSString *location = [NSString stringWithFormat:@"%@, %@", [cityAndState objectAtIndex:0], [cityAndState objectAtIndex:1]];

  [self setLoadingPhase:MLoadingPhaseDone];
  
  _mosaic = [[MMosaicView alloc] initWithImages:_images];
  [_mosaic setFrame:CGRectMake(0, kLabelHeight, self.view.width, self.view.height - kLabelHeight)];

  _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kLabelHeight)];
  [_locationLabel setCenterX:[[self view] centerX]];
  [_locationLabel setText:location];
  [_locationLabel setBackgroundColor:[UIColor clearColor]];
  [_locationLabel setTextColor:[UIColor whiteColor]];
  [_locationLabel setTextAlignment:NSTextAlignmentCenter];
  [_locationLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:20.0]];
  
  [_scrollView addSubview:_mosaic];
  [_scrollView addSubview:_locationLabel];
  
  // I know I'm not supposed to do this, but screw it...
  [_mosaic layoutSubviews];
  [_scrollView setContentSize:CGSizeMake(self.view.width, [_mosaic contentHeight] + _mosaic.y + 20)];
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
    [_loadingLabel setBackgroundColor:[UIColor clearColor]];
    [_loadingLabel setTextColor:[UIColor whiteColor]];
    [_loadingLabel setTextAlignment:NSTextAlignmentCenter];
    [_loadingLabel setWidth:self.view.width];
    [_loadingLabel setHeight:30.0];
    [_loadingLabel setY:self.view.center.y + 15.0];
    [[self view] addSubview:_loadingView];
    [[self view] addSubview:_loadingLabel];
    
    [_loadingView startAnimating];
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

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  // Error case
  [_loadingLabel setText:[NSString stringWithFormat:@"Error: %@",[error localizedDescription]]];
  [_loadingView stopAnimating];
  [_loadingView setHidden:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  // After we have their location, we don't care about updating any more
  [manager stopUpdatingLocation];
  CLLocation *currentLocation = [locations lastObject];
  _location = [currentLocation coordinate];
  [self loadImages];
}

@end
