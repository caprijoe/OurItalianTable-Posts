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
#import "OITTabBarController.h"
#import "WebViewController.h"
#import "TOCViewController.h"
#import "PostDetailViewController.h"
#import "Post.h"
#import "MapViewController.h"
#import "RegionAnnotation.h"
#import "RemoteFillDatabaseFromXMLParser.h"

@interface GeneralizedPostsTableViewController : UIViewController  <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, WebViewControllerDelegate, TOCViewController, NSFetchedResultsControllerDelegate, MapViewControllerDelegate, UIActionSheetDelegate, RemoteFillDatabaseFromXMLParserDelegate>

// public properties
@property (nonatomic, strong) NSString *category;                   // food || wine || wanderings, favs == NO
@property (nonatomic) BOOL favs;                                    // YES == bookmarks

// outlets
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *contextLabel;

@end
