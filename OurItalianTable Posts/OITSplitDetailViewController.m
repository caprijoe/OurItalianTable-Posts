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
    self.navigationItem.leftBarButtonItem = barButtonItem;
    _splitViewBarButtonItem = barButtonItem;
}

@end
