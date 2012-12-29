//
//  TravelTableViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/19/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "AppDelegate.h"
#import "OITLaunchViewController.h"
#import "MapViewController.h"
#import "RegionAnnotation.h"
#import "WebViewController.h"
#import "PostDetailViewController.h"

@interface OLD_TravelTableViewController : UITableViewController <MapViewControllerDelegate>

// public properties
@property (nonatomic, strong) NSString *category;

@end
