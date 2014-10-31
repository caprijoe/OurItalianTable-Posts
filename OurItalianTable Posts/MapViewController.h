//
//  MapViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "UIViewController+SplitMasterVC.h"
#import "AppDelegate.h"
#import "Post+Query.h"
#import "RegionAnnotation.h"

@interface MapViewController : UIViewController <MKMapViewDelegate>

// outlets
@property (nonatomic,weak) IBOutlet MKMapView *mapView;

@end
