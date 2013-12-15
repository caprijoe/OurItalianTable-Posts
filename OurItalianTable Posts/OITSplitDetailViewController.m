//
//  OITSplitDetailViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/11/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "OITSplitDetailViewController.h"

@interface OITSplitDetailViewController ()

@end

@implementation OITSplitDetailViewController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

#pragma mark - Rotation support

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    self.navigationItem.leftBarButtonItem = splitViewBarButtonItem;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

@end
