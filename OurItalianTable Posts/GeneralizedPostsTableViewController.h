//
//  GeneralizedPostsTableViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/28/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "OITCoreDataTableViewController.h"
#import "WebViewController.h"
#import "TOCViewController.h"
#import "PostDetailViewController.h"
#import "MapViewController.h"
#import "RemoteFillDatabaseFromXMLParser.h"
#import "NewIconDownloader.h"
#import "SharedUserDefaults.h"
#import "AppDelegate.h"
#import "OITTabBarController.h"
#import "Post+Create.h"

@interface GeneralizedPostsTableViewController : OITCoreDataTableViewController <UISearchBarDelegate, WebViewControllerDelegate, TOCViewControllerDelegate, NSFetchedResultsControllerDelegate, MapViewControllerDelegate, UIActionSheetDelegate, RemoteFillDatabaseFromXMLParserDelegate, IconDownloaderDelegate>

// public properties
@property (nonatomic, strong) NSArray *sortDescriptors;             // Array of NSSortDescriptors for how UITableView will display "Post" entities list
@property (nonatomic, strong) NSString *sectionKey;                 // if not nil, key for how UITableView will breakup sections
@property (nonatomic, strong) NSString *rightSideSegueName;         // seque ID for right side when a reset happens
@property (nonatomic, strong) NSPredicate *majorPredicate;          // predicate for "Post" entity to select items for this tab of a UITabViewController

// outlets
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *contextLabel;

@end