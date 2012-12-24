//
//  postsTableViewController.h
//  oitPosts
//
//  Created by Joseph Becci on 1/7/12.
//  Copyright (c) 2012 OurItalianTable. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "webViewController.h"
#import "TOCViewController.h"

@interface PostsTableViewController : UITableViewController <UISearchBarDelegate, WebViewControllerDelegate, TOCViewController, NSFetchedResultsControllerDelegate>

// public properties
@property (nonatomic, strong) NSString *category;
@property (nonatomic) BOOL favs;
@end
