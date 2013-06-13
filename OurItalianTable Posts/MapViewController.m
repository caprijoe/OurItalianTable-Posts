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

@interface MapViewController ();
@property (nonatomic) BOOL needRegionUpdate;
@end

@implementation MapViewController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    [self updateRegion];
}

-(void)updateRegion
{
    
    self.needRegionUpdate = NO;
    CGRect boundingRect;
    BOOL started = NO;
    
    for (id<MKAnnotation>annotation in self.mapView.annotations) {
        CGRect annotationRect = CGRectMake(annotation.coordinate.latitude, annotation.coordinate.longitude, 0, 0);
        if (!started) {
            started = YES;
            boundingRect = annotationRect;
        } else {
            boundingRect = CGRectUnion(boundingRect, annotationRect);
        }
    }
    
    if (started) {
        boundingRect = CGRectInset(boundingRect, -0.2, -0.2);
        if ((boundingRect.size.width < 20) && (boundingRect.size.height <20)) {
            MKCoordinateRegion region;
            region.center.latitude = boundingRect.origin.x + boundingRect.size.width / 2;
            region.center.longitude = boundingRect.origin.y + boundingRect.size.height / 2;
            region.span.latitudeDelta = boundingRect.size.height;
            region.span.longitudeDelta = boundingRect.size.height;
            [self.mapView setRegion:region animated:YES];
            
        }
    }
}

-(void)setupGeoReferenceInfo {
    
    // setup appDelegate for accessing shared properties and methods
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // setup the MOC for background processing
    NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] init];
    [backgroundMOC setPersistentStoreCoordinator:[appDelegate.parentMOC persistentStoreCoordinator]];
            
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
        
        // load up annotations for geos found in DB, set section # for click back
        
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
                [self.mapView addAnnotation:annotationObject];
                
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
    newRegion.span.longitudeDelta = 8;
    
    [self.mapView setRegion:newRegion animated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // setup split bar button item
    [self setSplitViewBarButtonItem:self.splitViewBarButtonItem];
    
    // make sure bottom toolbar in nav controller is hidden
    [self.navigationController setToolbarHidden:YES];

}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // setup the mapp type and set the UIMapView delegate
    self.mapView.mapType = MKMapTypeHybrid; // MKMapTypeStandard;   // also MKMapTypeSatellite or MKMapTypeHybrid
    self.mapView.delegate = self;
    
    // finally goto Italy
    [self gotoLocation];
    
//    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(42, 12.264425);
    
    // clear and reload annotations
    [self setupGeoReferenceInfo];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self updateRegion];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.mapView.delegate = nil;
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
