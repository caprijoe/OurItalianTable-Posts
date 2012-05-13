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

@interface MapViewController : UIViewController <MKMapViewDelegate,SplitViewBarButtonItemPresenter>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *rootPopoverButtonItem;
@property (strong, nonatomic) OITBrain *myBrain;
@end
