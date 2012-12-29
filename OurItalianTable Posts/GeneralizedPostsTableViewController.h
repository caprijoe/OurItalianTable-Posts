//
//  GeneralizedPostsTableViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/28/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "OITLaunchViewController.h"
#import "WebViewController.h"
#import "TOCViewController.h"
#import "PostDetailViewController.h"
#import "Post.h"
#import "MapViewController.h"
#import "RegionAnnotation.h"

@interface GeneralizedPostsTableViewController : UITableViewController  <UISearchBarDelegate, WebViewControllerDelegate, TOCViewController, NSFetchedResultsControllerDelegate, MapViewControllerDelegate, UIActionSheetDelegate>

// public properties
@property (nonatomic, strong) NSString *category;
@property (nonatomic) BOOL favs;

@end
