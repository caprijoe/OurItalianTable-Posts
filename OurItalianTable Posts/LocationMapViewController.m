//
//  LocationViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/19/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//
// NOTE: MKMapView delegate should be set in storyboard!!!!

#import "LocationMapViewController.h"

#define ANNOTATION_ICON_HEIGHT 30

@implementation LocationMapViewController

#pragma mark Private methods

// not used, save this in case
- (void)gotoLocation
{
    // center map on coordinates of post
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = [self.locationRecord.latitude floatValue];
    newRegion.center.longitude = [self.locationRecord.longitude floatValue];

    newRegion.span.latitudeDelta = 9;
    newRegion.span.longitudeDelta = 4;
    
    [self.mapView setRegion:newRegion animated:YES];
}

#pragma mark - View Lifecycle Methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
        
    // setup the map type and set the UIMapView delegate
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    
    // finally goto location
//    [self gotoLocation];
    
    // if we have the coordinate pair, add the annotation
    if ((self.locationRecord.latitude != 0) && (self.locationRecord.longitude != 0)) {
        MapAnnotation *mapObject = [[MapAnnotation alloc] init];
        mapObject.entry = self.locationRecord;
        [self.mapView addAnnotation:mapObject];
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    }
}

#pragma mark - MKMapViewDelegate support
-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    // select the annotation so it pops up once the map is rendered
    [self.mapView selectAnnotation:[self.mapView.annotations objectAtIndex:0] animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MapAnnotation class]])
    {
        MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
        if (!pinView) {
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
            
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            customPinView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ANNOTATION_ICON_HEIGHT, ANNOTATION_ICON_HEIGHT)];
            [(UIImageView *)customPinView.leftCalloutAccessoryView setImage:[UIImage imageWithData:self.locationRecord.postIcon]];
            
            return customPinView;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

#pragma mark - IBActions
- (IBAction)doneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
