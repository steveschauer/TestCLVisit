//
//  AppDelegate.m
//  TestApp
//
//  Created by Steve Schauer on 6/18/14.
//  Copyright (c) 2014 Steve Schauer. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Storage.h"

@interface AppDelegate ()

@property (nonatomic) ViewController *controller;
@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    self.window.rootViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    _controller = (ViewController *)self.window.rootViewController;

    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings > UIUserNotificationTypeNone) {
        NSLog(@"Starting location manager");
        _locationManager = [[CLLocationManager alloc]  init];
        _locationManager.delegate = self;
        [_locationManager requestAlwaysAuthorization];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [_controller showLastVisit];
}

#pragma mark - Location

-(void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit
{
    [[Storage store] saveVisit:visit];

    UILocalNotification *n = [[UILocalNotification alloc] init];
    if ([visit.departureDate isEqual: [NSDate distantFuture]]) {
        n.alertBody = [NSString stringWithFormat:@"didVisit: We arrived somewhere!"];
    } else {
        n.alertBody = @"didVisit: We left somewhere!";
    }
    n.soundName = UILocalNotificationDefaultSoundName;
    n.fireDate = [NSDate date];
    [[UIApplication sharedApplication] scheduleLocalNotification:n];
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"We're good! starting visit monitoring with status: %d",status);
            [_locationManager startMonitoringVisits];
            break;
        default:
            NSLog(@"we're not good: %d",status);
            break;
    }
}

@end
