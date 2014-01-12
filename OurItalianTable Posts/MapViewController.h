//
//  MapViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "OITSplitDetailViewController.h"
#import "AppDelegate.h"
#import "Post+Query.h"
#import "RegionAnnotation.h"
#import "WebViewController.h"
#import "RegionAnnotationView.h"

@class MapViewController;

@protocol MapViewControllerDelegate

-(void)didMapClick:(MapViewController *)sender
     sectionNumber:(NSInteger)section;
@end

@interface MapViewController : OITSplitDetailViewController <MKMapViewDelegate>

// outlets
@property (nonatomic,weak) IBOutlet MKMapView *mapView;
@property (nonatomic,weak) IBOutlet UIToolbar *toolbar;

// public properties
@property (nonatomic, strong) id<MapViewControllerDelegate> delegate;

@end
