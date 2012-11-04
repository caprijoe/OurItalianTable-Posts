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

- (void)gotoLocation
{
    // start off by default in Italy
    MKCoordinateRegion newRegion;
/*  FIXME:   newRegion.center.latitude = 42;
    newRegion.center.longitude = 12.264425; */
    newRegion.center.latitude = self.locationRecord.coordinate.latitude;
    newRegion.center.longitude = self.locationRecord.coordinate.longitude;

    newRegion.span.latitudeDelta = 9;
    newRegion.span.longitudeDelta = 4;
    
    [self.mapView setRegion:newRegion animated:YES];
}

#pragma mark - View Lifecycle Methods

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    // make sure bottom toolbar in nav controller is hidden
    [self.navigationController setToolbarHidden:YES];
    
    // set map type to regular map
    self.mapView.mapType = MKMapTypeHybrid;   // also MKMapTypeSatellite or MKMapTypeHybrid
    
    [self gotoLocation];    // finally goto Italy
    
    if ((self.locationRecord.coordinate.latitude != 0) && (self.locationRecord.coordinate.longitude != 0)) {
        MapAnnotation *mapObject = [[MapAnnotation alloc] init];
        mapObject.entry = self.locationRecord;
        [self.mapView addAnnotation:mapObject];
    }
}

#pragma mark - Rotation support
-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskAll;
}

#pragma mark - MKMapViewDelegate support

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
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

#pragma mark - Actions/Outlets
- (IBAction)doneButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
