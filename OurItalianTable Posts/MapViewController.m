//
//  MapViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "MapViewController.h"

#define ANNOTATION_ICON_HEIGHT 30

@interface MapViewController ();
@end

@implementation MapViewController

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // setup the map type and set the UIMapView delegate
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self addAnnotations];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self addAnnotations];
}

#pragma mark - Private methods
-(void)addAnnotations {
    
    // setup the appdelegate to access the MOC
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // get the DISTINCT geo proporties in the DB, array is dictionaries of geo = <region>
    NSArray *geoObjects = [Post queryPostForDistinctProperty:@"geo"
                                            withPredicate:[NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) ", @"wanderings"]
                                   inManagedObjectContext:appDelegate.parentMOC];
    
    // load up annotations for geos found in DB, set section # for click back
    [geoObjects enumerateObjectsUsingBlock:^(id region, NSUInteger idx, BOOL *stop) {
        
        // if there is annotation information, load into annotation object list
        NSArray *geoInfo = appDelegate.candidateGeos[region[@"geo"]];
        
        if ([geoInfo count] > 2)
        {
            // create an annotation object with the coordinates
            RegionAnnotation *annotationObject = [[RegionAnnotation alloc] init];
            annotationObject.regionName = region[@"geo"];
            annotationObject.latitude = [(NSNumber *)[geoInfo objectAtIndex:0] floatValue];
            annotationObject.longitude = [(NSNumber *)[geoInfo objectAtIndex:1] floatValue];
            annotationObject.flagURL = [geoInfo objectAtIndex:2];
            annotationObject.correspondingSection = idx;
            [self.mapView addAnnotation:annotationObject];

        }
        
        // show the annotations all at once and all visible
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    }];
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{    
    static NSString *AnnotationViewID = @"annotationViewID";
    
    RegionAnnotationView *annotationView = (RegionAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
        annotationView = [[RegionAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    
    annotationView.annotation = annotation;
    
    return annotationView;
}


#pragma mark MapViewControllerDelegate method callback
 -(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    // get the annotation clicked
    RegionAnnotation *thisAnnotation = [view annotation];
    
    // perform the call back to the post view controller
    [self.delegate didMapClick:self sectionNumber:thisAnnotation.correspondingSection];
} 

@end
