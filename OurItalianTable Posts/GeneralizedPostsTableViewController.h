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

@interface GeneralizedPostsTableViewController : OITCoreDataTableViewController <UISearchBarDelegate, WebViewControllerDelegate, TOCViewController, NSFetchedResultsControllerDelegate, MapViewControllerDelegate, UIActionSheetDelegate, RemoteFillDatabaseFromXMLParserDelegate, IconDownloaderDelegate>

// public properties
@property (nonatomic, strong) NSString *category;                   // food || wine || wanderings, favs == NO
@property (nonatomic, strong) NSString *sortKey;
@property (nonatomic, strong) NSString *sectionKey;
@property (nonatomic, strong) NSString *rightSideSegueName;
@property (nonatomic) BOOL favs;                                    // YES == bookmarks

// outlets
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *contextLabel;

@end
