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

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setSplitViewBarButtonItem:self.splitViewBarButtonItem];

}

#pragma mark - Rotation support

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *toolbarsItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarsItems removeObject:_splitViewBarButtonItem];
    if(barButtonItem) [toolbarsItems insertObject:barButtonItem atIndex:0];
    self.toolbar.items = toolbarsItems;
    _splitViewBarButtonItem = barButtonItem;
}

@end
