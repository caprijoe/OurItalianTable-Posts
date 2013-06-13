//
//  MapViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "SplitViewBarButtonItemPresenter.h"

@class MapViewController;

@protocol MapViewControllerDelegate

-(void)didMapClick:(MapViewController *)sender
     sectionNumber:(NSInteger)section;
@end

@interface MapViewController : UIViewController <MKMapViewDelegate,SplitViewBarButtonItemPresenter>

// outlets
@property (nonatomic,weak) IBOutlet MKMapView *mapView;
@property (nonatomic,weak) IBOutlet UIToolbar *toolbar;

// public properties
@property (nonatomic, strong) id<MapViewControllerDelegate> delegate;

@end
