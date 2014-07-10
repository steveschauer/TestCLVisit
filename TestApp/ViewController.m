//
//  ViewController.m
//  TestApp
//
//  Created by Steve Schauer on 6/18/14.
//  Copyright (c) 2014 Steve Schauer. All rights reserved.
//

#import "ViewController.h"
#import "Storage.h"
#import <MapKit/MapKit.h>

@interface ViewController ()
            
@property (weak, nonatomic) IBOutlet UILabel *arrivalLabel;
@property (weak, nonatomic) IBOutlet UILabel *departureLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *visitNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousDepartureLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextArrivalLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextDepartureLabel;

@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (assign) int visitIndex;

@end

@implementation ViewController

#define METERS_PER_MILE 1609.344

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _visitIndex = [[Storage store] visitCount]-1;

    UISwipeGestureRecognizer *gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showNextVisit)];
    [gr setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:gr];
    
    gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showPreviousVisit)];
    [gr setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:gr];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showLastVisit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideAll
{
    [_arrivalLabel setHidden:YES];
    [_departureLabel setHidden:YES];
    [_timeStampLabel setHidden:YES];
    [_visitNumberLabel setHidden:YES];
    [_previousDepartureLabel setHidden:YES];
    [_nextArrivalLabel setHidden:YES];
    [_nextDepartureLabel setHidden:YES];
    [_mapView setHidden:YES];
}

- (void)showAll
{
    [_arrivalLabel setHidden:NO];
    [_departureLabel setHidden:NO];
    [_timeStampLabel setHidden:NO];
    [_visitNumberLabel setHidden:NO];
    [_previousDepartureLabel setHidden:NO];
    [_nextArrivalLabel setHidden:NO];
    [_nextDepartureLabel setHidden:NO];
    [_mapView setHidden:NO];
}

- (void)showVisitContext
{
    NSDictionary *info = [[Storage store] visitAtIndex:_visitIndex-1];
    if (info) {
        [_previousDepartureLabel setText:info[@"departureDate"]];
        [_previousButton setEnabled:YES];
    } else {
        [_previousDepartureLabel setHidden:YES];
        [_previousButton setEnabled:NO];
    }
    
    info = [[Storage store] visitAtIndex:_visitIndex+1];
    if (info) {
        [_nextArrivalLabel setText:info[@"arrivalDate"]];
        [_nextDepartureLabel setText:info[@"departureDate"]];
        [_nextButton setEnabled:YES];
    } else {
        [_nextArrivalLabel setHidden:YES];
        [_nextDepartureLabel setHidden:YES];
        [_nextButton setEnabled:NO];
    }
}

- (IBAction) showPreviousVisit
{
    NSDictionary *info = [[Storage store] visitAtIndex:_visitIndex-1];
    if (info) {
        _visitIndex--;
        [self showVisit:info];
    }
}

- (IBAction) showNextVisit
{
    NSDictionary *info = [[Storage store] visitAtIndex:_visitIndex+1];
    if (info) {
        _visitIndex++;
        [self showVisit:info];
    }
}

- (void) showLastVisit
{
    _visitIndex = [[Storage store] visitCount]-1;
    [self showVisit:[[Storage store] visitAtIndex:_visitIndex]];
}

- (void) showVisit: (NSDictionary *)visitInfo
{
    if (visitInfo) {

        [self showAll];

        NSString *title = [NSString stringWithFormat:@"Visit #%d",_visitIndex+1];
        [_visitNumberLabel setText:title];
        [_arrivalLabel setText:visitInfo[@"arrivalDate"]];
        [_departureLabel setText:visitInfo[@"departureDate"]];
        [_timeStampLabel setText:visitInfo[@"timeStamp"]];
        
        [self showVisitContext];

        [_mapView removeAnnotations:[_mapView annotations]];
        CLLocationCoordinate2D zoomLocation;
        zoomLocation.latitude = [visitInfo[@"latitude"] doubleValue];
        zoomLocation.longitude= [visitInfo[@"longitude"] doubleValue];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1.0*METERS_PER_MILE, 0.25*METERS_PER_MILE);
        [_mapView setRegion:viewRegion animated:YES];
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:zoomLocation];
        [annotation setTitle:title];
        [_mapView addAnnotation:annotation];
        
    } else {
        [self hideAll];
        [_nextButton setEnabled:NO];
        [_previousButton setEnabled:NO];
    }
}

@end
