//
//  LocationViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/19/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//
// NOTE: MKMapView delegate should be set in storyboard!!!!

#import "LocationMapViewController.h"

@implementation LocationMapViewController

#pragma mark - View Lifecycle Methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
        
    // setup the map type and set the UIMapView delegate
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.delegate = self;
    
    // if we have the coordinate pair, add the annotation
    if ((self.locationRecord.latitude != 0) && (self.locationRecord.longitude != 0)) {
        MapAnnotation *mapObject = [[MapAnnotation alloc] init];
        mapObject.entry = self.locationRecord;
        [self.mapView addAnnotation:mapObject];
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    }
    
    // set title
    self.navigationItem.title = self.locationRecord.postName;
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
        static NSString *pinIdentifier = @"pinIdentifier";
        
        MKPinAnnotationView * pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
        
        if (!pinView) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier];
            
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
        }
        pinView.annotation = annotation;
        
        // setup and load leftaccessory to hold flag/coat of arms
        CGRect targetRect = CGRectMake(0,0,31,31);                                      // unavoidable magic numbers
        UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:targetRect];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        iconImageView.image = [UIImage imageWithData:self.locationRecord.postIcon];
        pinView.leftCalloutAccessoryView = iconImageView;
        
        return pinView;
    }
    return nil;
}

@end
