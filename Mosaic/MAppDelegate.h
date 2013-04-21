//
//  MAppDelegate.h
//  Mosaic
//
//  Created by Scott on 4/21/13.
//  Copyright (c) 2013 Stacks on Stacks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MViewController;

@interface MAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MViewController *viewController;

@end
