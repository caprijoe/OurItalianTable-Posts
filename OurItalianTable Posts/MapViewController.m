//
//  MapViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"
#import "PostRecord.h"
#import "RegionAnnotation.h"
#import "WebViewController.h"
#import "RegionAnnotationView.h"
#import "OITLaunchViewController.h"

#define ANNOTATION_ICON_HEIGHT 30

@implementation MapViewController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;


-(void)setupGeoReferenceInfo {
    // updates self.geoCoordinates, self.geoList
    
    // setup appDelegate for accessing shared properties and methods
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    
    // get the list of DISTINCT geos in DB
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:appDelegate.parentMOC];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) ", @"wanderings"];
    request.resultType = NSDictionaryResultType;
    request.returnsDistinctResults = YES;
    request.propertiesToFetch = @[@"geo"];
    
    // Execute the fetch.
    NSError *error;
    NSArray *objects = [appDelegate.parentMOC executeFetchRequest:request error:&error];
    if (error) NSLog(@"error at geoReferenceInfo = %@",error);
    
    // Assuming we got at least one, build the list of Annotations
    if (objects == nil) {
        
        // Handle the error.
        NSLog(@"nil array returned at geoReferenceInfo build");
        
    } else {
        
        // build the region list and annotations object
        self.geoCoordinates = [[NSMutableArray alloc] init];
        
        int i = 0;
        for (NSDictionary *region in objects) {
            
            // if there is annotation information, load into annotation object list
            NSArray *geoInfo = appDelegate.candidateGeos[region[@"geo"]];
            
            if ([geoInfo count] > 2) {
                
                // create an annotation object with the coordinates
                RegionAnnotation *annotationObject = [[RegionAnnotation alloc] init];
                
                annotationObject.regionName = region[@"geo"];
                annotationObject.latitude = [(NSNumber *)[geoInfo objectAtIndex:0] floatValue];
                annotationObject.longitude = [(NSNumber *)[geoInfo objectAtIndex:1] floatValue];
                annotationObject.flagURL = [geoInfo objectAtIndex:2];
                annotationObject.correspondingSection = i++;
                [self.geoCoordinates addObject:annotationObject];
                
            }
        }
    }
}

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
    
    // setup split bar button item
    [self setSplitViewBarButtonItem:self.splitViewBarButtonItem];
    
    // make sure bottom toolbar in nav controller is hidden
    [self.navigationController setToolbarHidden:YES];
    
    [self setupGeoReferenceInfo];
    
    // setup the mapp type and set the UIMapView delegate
    self.mapView.mapType = MKMapTypeHybrid; // MKMapTypeStandard;   // also MKMapTypeSatellite or MKMapTypeHybrid
    self.mapView.delegate = self;
    
    // finally goto Italy
    [self gotoLocation];    
    
    // add the incoming annotations
    [self.mapView addAnnotations:self.geoCoordinates];
}

#pragma mark -
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

 -(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    // get the annotation clicked
    RegionAnnotation *thisAnnotation = [view annotation];
    
    // perform the call back to the post view controller
    [self.delegate didMapClick:self sectionNumber:thisAnnotation.correspondingSection];
} 

#pragma mark - Rotation support

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarsItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarsItems removeObject:_splitViewBarButtonItem];
    if(splitViewBarButtonItem) [toolbarsItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = toolbarsItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else  
        return YES;
}
@end
