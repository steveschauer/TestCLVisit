//
//  Storage.h
//  TestApp
//
//  Created by Steve Schauer on 6/30/14.
//  Copyright (c) 2014 Steve Schauer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface Storage : NSObject

+ (Storage *) store;

@property (readonly, assign, nonatomic) int visitCount;

-(NSDictionary *)firstVisit;
-(NSDictionary *)lastVisit;
-(NSDictionary *)visitAtIndex:(int)index;

- (void)saveVisit:(CLVisit *) visit;

@end
