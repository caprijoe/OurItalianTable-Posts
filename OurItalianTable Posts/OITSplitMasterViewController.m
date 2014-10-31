//
//  OITSplitMasterViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/17/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "OITSplitMasterViewController.h"

@implementation OITSplitMasterViewController

#pragma mark - Segue support
-(id)splitViewDetailWithBarButtonItem
{
    id detail = [self.splitViewController.viewControllers lastObject];
    if (![detail respondsToSelector:@selector(setSplitViewBarButtonItem:)] || ![detail respondsToSelector:@selector(splitViewBarButtonItem)]) detail = nil;
    return detail;
}

-(void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem ];
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
}

-(void)resetDetailView
{
    // reset logic for detail view controller
    
    // if we're in a split
    if (self.splitViewController) {
        
        // assume the detail is always a navVC
        UINavigationController *navVC = (UINavigationController *)self.splitViewController.viewControllers[1];
        
        // if the top VC is a webVC, reset the property to nil (will cause logo to reappear)
        if ([[navVC topViewController] isKindOfClass:[WebViewController class]]) {
            WebViewController *webVC = (WebViewController *)[navVC topViewController];
            webVC.thisPost = nil;
        } else {
            
            /// else reset the detail side with a new replace segue
            [self performSegueWithIdentifier:@"Push Web View" sender:self];
        }
    }
}

@end
