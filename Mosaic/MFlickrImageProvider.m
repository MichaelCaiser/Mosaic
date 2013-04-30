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
    NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_m.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
    [photoURLs addObject:[NSURL URLWithString:photoURLString]];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoURLString]];
    UIImage *image = [UIImage imageWithData:imageData];
    [images addObject:[self convertImageToGrayScale:image]];
  }
  callback(images);
}

// Build the URL to hit
// TODO: add in bbox support
-(NSURL *)getFlickrURLForRegion:(MKCoordinateRegion)region {
  NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&extras=geo&lat=%f&lon=%f&radius=5&min_taken_date=1335312000&per_page=50&format=json&nojsoncallback=1", flickrKey, region.center.latitude, region.center.longitude];
  NSURL *url = [NSURL URLWithString:urlString];
  return url;
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
  // Create image rectangle with current image width/height
  CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
  
  // Grayscale color space
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
  
  // Create bitmap content with current image size and grayscale colorspace
  CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
  
  // Draw image into current context, with specified rectangle
  // using previously defined context (with grayscale colorspace)
  CGContextDrawImage(context, imageRect, [image CGImage]);
  
  // Create bitmap image info from pixel data in current context
  CGImageRef imageRef = CGBitmapContextCreateImage(context);
  
  // Create a new UIImage object
  UIImage *newImage = [UIImage imageWithCGImage:imageRef];
  
  // Release colorspace, context and bitmap information
  CGColorSpaceRelease(colorSpace);
  CGContextRelease(context);
  CFRelease(imageRef);
  
  // Return the new grayscale image
  return newImage;
}

@end