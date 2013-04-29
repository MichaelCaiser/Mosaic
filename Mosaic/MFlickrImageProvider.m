//
//  MFlickrImageProvider.m
//  Mosaic
//
//  Created by Scott on 4/21/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//

#import "MFlickrImageProvider.h"

@implementation MFlickrImageProvider
NSString *const flickrKey = @"39cf517f8800ff1389230201bb6e514f";
NSString *const flickrSecret = @"941343a35691dc97";

- (void)imagesForRegion:(MKCoordinateRegion)region callback:(void (^)(NSArray *))callback {
  NSURL *url = [self getFlickrURLForRegion:region];
  NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
  
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
  NSDictionary *jsonObjects = [jsonParser objectWithString:jsonString];
  NSArray *photos = [[jsonObjects objectForKey:@"photos"] objectForKey:@"photo"];
  NSMutableArray *photoNames = [[NSMutableArray alloc] init];
  NSMutableArray *photoURLs = [[NSMutableArray alloc]init];
  NSMutableArray *images = [[NSMutableArray alloc]init];
  // 3. Pick thru results and build our arrays
  for (NSDictionary *photo in photos) {
    // 3.a Get title for e/ photo
    NSString *title = [photo objectForKey:@"title"];
    
    [photoNames addObject:(title.length > 0 ? title : @"Untitled")];
    // 3.b Construct URL for e/ photo.
    NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
    [photoURLs addObject:[NSURL URLWithString:photoURLString]];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoURLString]];
    UIImage *image = [UIImage imageWithData:imageData];
    [images addObject:image];
  }
  NSLog(@"%@", images);
  callback(images);
}

// Build the URL to hit
// TODO: add in bbox support
-(NSURL *)getFlickrURLForRegion:(MKCoordinateRegion)region {
  NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&extras=geo&lat=%f&lon=%f&radius=5&min_taken_date=1335312000&per_page=20&format=json&nojsoncallback=1", flickrKey, region.center.latitude, region.center.longitude];
  NSURL *url = [NSURL URLWithString:urlString];
  return url;
}

@end