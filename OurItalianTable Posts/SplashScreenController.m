//
//  SplashScreenController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/1/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "SplashScreenController.h"
#import "OITLaunchViewController.h"

@implementation SplashScreenController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
                
    [self setSplitViewBarButtonItem:self.splitViewBarButtonItem];
    
}

#pragma mark - Rotation support

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarsItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarsItems removeObject:_splitViewBarButtonItem];
    if(splitViewBarButtonItem) [toolbarsItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = toolbarsItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
