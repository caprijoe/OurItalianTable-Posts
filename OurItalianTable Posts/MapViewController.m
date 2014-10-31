//
//  MapViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ();
@property (nonatomic, strong) NSString *selectedRegion;
@end

@implementation MapViewController

#pragma mark - View lifecycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // support for change of perferred text font and size
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    // setup the map type and set the UIMapView delegate
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    
    // reset context label
    self.navigationItem.title = @"Our Italian Table";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // add pins but only once- must be done in viewDidAppear because geometry not set in viewdidload
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [self addAnnotations];
    });
}

#pragma mark - Rotation support
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // re-layout pins on rotation event
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

#pragma mark - Private methods
-(void)addAnnotations
{
    // setup the appdelegate to access the MOC
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // get the DISTINCT geo proporties in the DB, array is dictionaries of geo = <region>
    NSArray *geoObjects = [Post queryPostForDistinctProperty:@"geo"
                                               withPredicate:[NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) ", @"wanderings"]
                                      inManagedObjectContext:appDelegate.parentMOC];
    
    // load up annotations for geos found in DB, set section # for click back
    [geoObjects enumerateObjectsUsingBlock:^(id region, NSUInteger idx, BOOL *stop) {
        
        // if there is annotation information, load into annotation object list
        NSArray *geoInfo = appDelegate.categoryDictionary[@"regions"][region[@"geo"]];

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
    }];
    
    // show the annotations all at once and all visible
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

#pragma mark - Dynamic type support
- (void)preferredContentSizeChanged:(NSNotification *)aNotification
{
    //
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(RegionAnnotation *)annotation
{
    static NSString *pinIdentifier = @"pinIdentifier";
    
    MKPinAnnotationView * pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
    
    // if no pins available, make one
    if (!pinView) {
        
        // setup basic pin
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier];
        pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        
        // setup and load rightaccessory to hold detail disclosure button
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
    }
    
    // load annotation into pin
    pinView.annotation = annotation;

    // setup and load leftaccessory to hold flag/coat of arms
    CGRect targetRect = CGRectMake(0,0,31,31);                                      // unavoidable magic numbers
    UIImageView *flagImageView = [[UIImageView alloc]initWithFrame:targetRect];
    flagImageView.contentMode = UIViewContentModeScaleAspectFit;
    flagImageView.image = [UIImage imageNamed:annotation.flagURL];
    pinView.leftCalloutAccessoryView = flagImageView;
    
    return pinView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // grab the selected annotation and the associated region
    RegionAnnotation *annotation = view.annotation;
    self.selectedRegion = annotation.regionName;
    
    // seque to posts VC
    [self performSegueWithIdentifier:@"Show Region Posts" sender:self];
}

#pragma mark - Segue support
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Region Posts"]) {
        [segue.destinationViewController setSelectedRegion:self.selectedRegion];
    }
}

@end
