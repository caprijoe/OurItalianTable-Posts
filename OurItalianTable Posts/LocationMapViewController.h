//
//  LocationViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/19/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "postRecord.h"
#import "MapAnnotation.h"

@interface LocationMapViewController : UIViewController <MKMapViewDelegate>

// outlets and actions
@property (nonatomic,weak) IBOutlet MKMapView *mapView;

// public properties
@property (nonatomic,strong) PostRecord *locationRecord;

@end
