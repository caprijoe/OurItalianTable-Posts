//
//  LocationViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/19/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "LocationMapViewController.h"

#define ANNOTATION_ICON_HEIGHT 30

@interface LocationMapViewController ()
@end

@implementation LocationMapViewController
@synthesize locationRecord = _locationRecord;
@synthesize mapView = _mapView;

#pragma mark Private methods


- (void)gotoLocation
{
    // start off by default in Italy
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 42;
    newRegion.center.longitude = 12.264425;
    newRegion.span.latitudeDelta = 9;
    newRegion.span.longitudeDelta = 4;
    
    [self.mapView setRegion:newRegion animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    // make sure bottom toolbar in nav controller is hidden
    [self.navigationController setToolbarHidden:YES];
    
    self.mapView.delegate = self;
    
    // set map type to regular map
    self.mapView.mapType = MKMapTypeStandard;   // also MKMapTypeSatellite or MKMapTypeHybrid    
    
    [self gotoLocation];    // finally goto Italy
    
    if ((self.locationRecord.coordinate.latitude != 0) && (self.locationRecord.coordinate.longitude != 0)) {
        MapAnnotation *mapObject = [[MapAnnotation alloc] init];
        mapObject.entry = self.locationRecord;
        [self.mapView addAnnotation:mapObject];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MapAnnotation class]])
    {
        MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
        if (!pinView) {
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
            
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = NO;
            customPinView.canShowCallout = YES;
            
            customPinView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ANNOTATION_ICON_HEIGHT, ANNOTATION_ICON_HEIGHT)];
            [(UIImageView *)customPinView.leftCalloutAccessoryView setImage:self.locationRecord.postIcon];
            
            return customPinView;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    } 
    return nil;
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    [self.mapView selectAnnotation:[self.mapView.annotations objectAtIndex:0] animated:YES];
}

@end
