//
//  Storage.m
//  TestApp
//
//  Created by Steve Schauer on 6/30/14.
//  Copyright (c) 2014 Steve Schauer. All rights reserved.
//

#import "Storage.h"
#import "Visit.h"

@interface Storage ()

@property (strong, nonatomic) NSArray *visits;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation Storage

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (Storage *) store
{
    static Storage *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[Storage alloc] init];
    });
    
    return store;
}

- (id) init
{
    self = [super init];
    if (self) {
        _managedObjectContext = [self managedObjectContext];
        _visits = [self retrieveVisits];
    }
    return self;
}

#pragma mark - Storage and Retrieval

-(NSDictionary *)dictionaryFromVisit:(Visit *)visit
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MM-dd-yy h:mm a";

    [df setTimeZone:[NSTimeZone localTimeZone]];
    NSString *arrivalDate = ([visit.arrivalDate isEqualToDate:[NSDate distantPast]] ? @"distantPast" : [df stringFromDate:visit.arrivalDate]);
    NSString *departureDate = ([visit.departureDate isEqualToDate:[NSDate distantFuture]] ? @"distantFuture" : [df stringFromDate:visit.departureDate]);
    NSString *timeStamp = [df stringFromDate:visit.timeStamp];
    NSDictionary *visitInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                     arrivalDate, @"arrivalDate", departureDate, @"departureDate", timeStamp, @"timeStamp", visit.latitude, @"latitude", visit.longitude, @"longitude", nil];
    return visitInfo;
}

- (NSArray *)retrieveVisits
{
    NSFetchRequest *r = [NSFetchRequest fetchRequestWithEntityName:@"Visit"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"timeStamp" ascending:YES];
    [r setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSError *error = nil;
    NSArray *visits = [_managedObjectContext executeFetchRequest:r error: &error];
    if (error) {
        NSLog(@"error: %@",error);
    }
    return visits;
}

- (int) visitCount
{
    return (int)[_visits count];
}

- (void)saveVisit:(CLVisit *) visit
{
    Visit *thisVisit = [NSEntityDescription insertNewObjectForEntityForName:@"Visit" inManagedObjectContext:[self managedObjectContext]];
    thisVisit.arrivalDate = visit.arrivalDate;
    thisVisit.departureDate = visit.departureDate;
    thisVisit.timeStamp = [NSDate date];
    thisVisit.latitude = [NSNumber numberWithDouble:visit.coordinate.latitude];
    thisVisit.longitude = [NSNumber numberWithDouble:visit.coordinate.longitude];
    [self saveContext];
}

-(NSDictionary *)firstVisit
{
    if ([_visits count]) {
        return [self dictionaryFromVisit:_visits[0]];
    }
    return nil;
}

-(NSDictionary *)lastVisit
{
    if ([_visits count]) {
        return [self dictionaryFromVisit:_visits[[_visits count]-1]];
    }
    return nil;
}

-(NSDictionary *)visitAtIndex:(int)index
{
    if ([_visits count] > index)
        return [self dictionaryFromVisit:_visits[index]];
    return nil;
}

#pragma mark - Core Data stack

- (NSError *)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else {
            _visits = [self retrieveVisits];
        }
    }
    return error;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TestApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                               inDomains:NSUserDomainMask] lastObject]
                       URLByAppendingPathComponent:@"TestApp.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

@end
