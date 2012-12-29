//
//  LocationViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/19/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Post.h"
#import "MapAnnotation.h"

@interface LocationMapViewController : UIViewController <MKMapViewDelegate>

// public properties
@property (nonatomic,strong) Post *locationRecord;

// outlets
@property (nonatomic,weak) IBOutlet MKMapView *mapView;

// actions
- (IBAction)doneButton:(id)sender;

@end
