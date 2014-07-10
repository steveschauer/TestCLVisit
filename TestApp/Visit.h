//
//  Visits.h
//  TestApp
//
//  Created by Steve Schauer on 6/19/14.
//  Copyright (c) 2014 Steve Schauer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Visit : NSManagedObject

@property (nonatomic, retain) NSDate * arrivalDate;
@property (nonatomic, retain) NSDate * departureDate;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
