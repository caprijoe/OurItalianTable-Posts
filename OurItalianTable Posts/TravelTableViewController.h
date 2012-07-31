//
//  TravelTableViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/19/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OITBrain.h"
#import "webViewController.h"
#import "MapViewController.h"

@interface TravelTableViewController : UITableViewController <UISearchDisplayDelegate,UISearchBarDelegate,MapViewController>

// public properties
@property (nonatomic, strong) OITBrain *myBrain;                        // data brain
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) UIBarButtonItem *rootPopoverButtonItem;

@end
