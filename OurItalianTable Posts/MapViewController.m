//
//  MapViewController.m
//  oitPosts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "MapViewController.h"
#import "postRecord.h"
#import "RegionAnnotation.h"
#import "webViewController.h"
#import "OITLaunchViewController.h"
#import "RegionAnnotationView.h"

#define ANNOTATION_ICON_HEIGHT 30

@implementation MapViewController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

- (void)gotoLocation
{
    // start off by default in Italy
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 42;
    newRegion.center.longitude = 12.264425;
    newRegion.span.latitudeDelta = 15;
    newRegion.span.longitudeDelta = 10;
    
    [self.mapView setRegion:newRegion animated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    UIBarButtonItem *rootPopoverButtonItem = ((OITLaunchViewController *)[((UINavigationController *)[((UISplitViewController *)self.parentViewController).viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0]).rootPopoverButtonItem;
    
    // make sure bottom toolbar in nav controller is hidden
    [self.navigationController setToolbarHidden:YES];
    
    // self button for detail splitViewController when in portrait
    [self setSplitViewBarButtonItem:rootPopoverButtonItem];
    
    self.mapView.mapType = MKMapTypeHybrid; // MKMapTypeStandard;   // also MKMapTypeSatellite or MKMapTypeHybrid
    self.mapView.delegate = self;
     
    [self gotoLocation];    // finally goto Italy
    
    [self.mapView addAnnotations:self.regionCoordinates];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{    
    static NSString *AnnotationViewID = @"annotationViewID";
    
    RegionAnnotationView *annotationView =
    (RegionAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil)
    {
        annotationView = [[RegionAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    
    annotationView.annotation = annotation;
    
    return annotationView;
}

 -(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    RegionAnnotation *thisAnnotation = [view annotation];    
    [self.delegate MapViewContoller:self regionClicked:thisAnnotation.regionName];
} 

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Rotation support

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem !=splitViewBarButtonItem) {
        NSMutableArray *toolbarsItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarsItems removeObject:_splitViewBarButtonItem];
        if(splitViewBarButtonItem) [toolbarsItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarsItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    } 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else  
        return YES;
}
@end
