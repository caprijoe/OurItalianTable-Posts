//
//  MapViewController.h
//  oitPosts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OITBrain.h"
#import "SplitViewBarButtonItemPresenter.h"
#import "PostRecord.h"

@class MapViewController;

@protocol MapViewController <NSObject>

-(void)MapViewContoller:(MapViewController *)sender
          regionClicked:(NSString *)region;
@end

@interface MapViewController : UIViewController <MKMapViewDelegate,SplitViewBarButtonItemPresenter>

@property (nonatomic,weak) IBOutlet MKMapView *mapView;
@property (nonatomic,weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic,weak) UIBarButtonItem *rootPopoverButtonItem;

@property (nonatomic,weak) id<MapViewController> delegate;

@property (nonatomic,strong) NSArray *regionCoordinates;                        // annotations to be displayed
@end
