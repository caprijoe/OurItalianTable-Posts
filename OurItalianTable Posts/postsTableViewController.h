//
//  postsTableViewController.h
//  oitPosts
//
//  Created by Joseph Becci on 1/7/12.
//  Copyright (c) 2012 OurItalianTable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OITBrain.h"
#import "webViewController.h"
#import "TOCViewController.h"

@interface PostsTableViewController : UITableViewController <UISearchDisplayDelegate,UISearchBarDelegate,WebViewControllerDelegate, TOCViewController>

// public properties
@property (nonatomic, strong) OITBrain *myBrain;                        // data brain
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) UIBarButtonItem *rootPopoverButtonItem;
@property (nonatomic) BOOL favs;
@end
