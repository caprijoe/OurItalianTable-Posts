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

@end
