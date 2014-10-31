//
//  OITSplitMasterViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/17/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "OITViewController.h"
#import "SplitViewBarButtonItemPresenter.h"
#import "WebViewController.h"

@interface OITSplitMasterViewController : OITViewController

-(id)splitViewDetailWithBarButtonItem;
-(void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController;
-(void)resetDetailView;

@end
