//
//  AppDelegate.h
//  TestApp
//
//  Created by Steve Schauer on 6/18/14.
//  Copyright (c) 2014 Steve Schauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

