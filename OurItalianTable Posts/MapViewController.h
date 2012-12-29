//
//  MapViewController.h
//  oitPosts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SplitViewBarButtonItemPresenter.h"
#import "OLDPostRecord.h"

@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>

-(void)didMapClick:(MapViewController *)sender
          geoNamed:(NSString *)region;
@end

@interface MapViewController : UIViewController <MKMapViewDelegate,SplitViewBarButtonItemPresenter>

@property (nonatomic,weak) IBOutlet MKMapView *mapView;
@property (nonatomic,weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic,weak) UIBarButtonItem *rootPopoverButtonItem;

@property (nonatomic,weak) id<MapViewControllerDelegate> delegate;

@property (nonatomic,strong) NSArray *geoCoordinates;                        // annotations to be displayed
@end
