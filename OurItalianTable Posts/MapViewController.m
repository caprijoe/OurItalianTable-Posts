//
//  MapViewController.m
//  oitPosts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "postRecord.h"
#import "MapAnnotation.h"
#import "webViewController.h"

#define ANNOTATION_ICON_HEIGHT 30

@interface MapViewController ()
@property (strong,nonatomic) NSMutableArray *annotations;
@property (strong,nonatomic) NSArray *entries;
@property (strong,nonatomic) PostRecord *webRecord;
@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize toolbar = _toolbar;
@synthesize myBrain = _myBrain;
@synthesize annotations = _annotations;
@synthesize entries = _entries;
@synthesize webRecord = _webRecord;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize rootPopoverButtonItem = _rootPopoverButtonItem;


- (void)gotoLocation
{
    // start off by default in Italy
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 42; //42.521319;
    newRegion.center.longitude = 12.264425;
    newRegion.span.latitudeDelta = 9;
    newRegion.span.longitudeDelta = 4;
    
    [self.mapView setRegion:newRegion animated:YES];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self setSplitViewBarButtonItem:self.rootPopoverButtonItem];
    
    self.mapView.mapType = MKMapTypeStandard;   // also MKMapTypeSatellite or MKMapTypeHybrid    
    self.mapView.delegate = self;
    self.webRecord = [[PostRecord alloc] init];
    self.entries = [self.myBrain isFav:NO withTag:nil withCategory:@"wanderings" withDetailCategory:nil];
    self.annotations = [[NSMutableArray alloc] init];
    for (PostRecord *entry in self.entries)
    {
        if ((entry.coordinate.latitude != 0) && (entry.coordinate.longitude != 0)) {
            MapAnnotation *obj = [[MapAnnotation alloc] init];
            obj.entry = entry;
            [self.annotations addObject:obj];
        }
    }
     
    [self gotoLocation];    // finally goto Italy
    
    [self.mapView addAnnotations:self.annotations];
}

#pragma mark -
#pragma mark MKMapViewDelegate

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MapAnnotation *thisAnnotation =[view annotation]; 
    self.webRecord = thisAnnotation.entry;
    [self performSegueWithIdentifier:@"Push Travel Post" sender:self];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MapAnnotation class]])
    {
        MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
        if (!pinView) {
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            customPinView.rightCalloutAccessoryView = rightButton;
            
            customPinView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ANNOTATION_ICON_HEIGHT, ANNOTATION_ICON_HEIGHT)];
            [(UIImageView *)customPinView.leftCalloutAccessoryView setImage:nil];
                                                      
            return customPinView;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    } 
    return nil;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view 
{
    MapAnnotation *thisAnnotation = [view annotation];
    NSString *url = thisAnnotation.entry.imageURLString;
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("annotation image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *data =[NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:data];
            [(UIImageView *)view.leftCalloutAccessoryView setImage:image];
        });
    });
    dispatch_release(downloadQueue);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Push Travel Post"]) {
        [segue.destinationViewController setPostRecord:self.webRecord];
        [segue.destinationViewController setRootPopoverButtonItem:self.rootPopoverButtonItem];
    }
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

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
