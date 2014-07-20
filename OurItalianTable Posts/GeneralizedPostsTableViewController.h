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
#import "MapViewController.h"
#import "RemoteFillDatabaseFromXMLParser.h"
#import "IconDownloader.h"
#import "SharedUserDefaults.h"
#import "OITTabBarController.h"
#import "Post+Create.h"

@interface GeneralizedPostsTableViewController : OITCoreDataTableViewController <UISearchBarDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, IconDownloaderDelegate, WebViewControllerDelegate>

// public properties
@property (nonatomic, strong) NSPredicate *majorPredicate;          // predicate for "Post" entity to select items for this tab of a UITabViewController
@property (nonatomic, strong) NSString *selectedRegion;             // region to show for this Table VC
@property (nonatomic, strong) NSString *defaultContextTitle;        // when no better choice, display this title on nav VC

// outlets
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *contextLabel;

@end