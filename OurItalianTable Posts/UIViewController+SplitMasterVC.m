//
//  UIViewController+SplitMasterVC.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/17/14.
//  Copyright (c) 2014 Our Italian Table. All rights reserved.
//

#import "UIViewController+SplitMasterVC.h"

@implementation UIViewController (SplitMasterVC)

#pragma mark - Segue support
-(id)splitViewDetailWithBarButtonItem
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if ([detailVC isKindOfClass:[UINavigationController class]])
        detailVC = ((UINavigationController *)detailVC).topViewController;
    if (![detailVC respondsToSelector:@selector(setSplitViewBarButtonItem:)] || ![detailVC respondsToSelector:@selector(splitViewBarButtonItem)]) detailVC = nil;
    return detailVC;
}

-(void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem ];
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
}

#pragma mark -  Private methods specific to master side
-(void)resetDetailView
{
    // reset logic for detail view controller
    
    // if we're in a split
    if (self.splitViewController) {
        [self performSegueWithIdentifier:@"Push Web View" sender:self];
    }
}

@end
