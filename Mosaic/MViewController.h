//
//  MViewController.h
//  Mosaic
//
//  Created by Scott on 4/21/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "MMosaicView.h"
#import "MUserImageProvider.h"
#import "MFlickrImageProvider.h"

@interface MViewController : UIViewController <CLLocationManagerDelegate> {
  // Loading Views
  UIActivityIndicatorView *_loadingView;
  UILabel *_loadingLabel;
  
  // Main Views
  UILabel *_locationLabel;
  MMosaicView *_mosaic;
  NSArray *_images;
  
  // Data
  CLLocationManager *_locationManager;
  CLLocationCoordinate2D _location;
}

@end
