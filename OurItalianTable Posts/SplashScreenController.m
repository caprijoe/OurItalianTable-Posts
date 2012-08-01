//
//  splashScreen.m
//  oitPosts
//
//  Created by Joseph Becci on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplashScreenController.h"
#import "OITLaunchViewController.h"

@implementation SplashScreenController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *rootPopoverButtonItem = ((OITLaunchViewController *)[((UINavigationController *)[((UISplitViewController *)self.parentViewController).viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0]).rootPopoverButtonItem;
    
    [self setSplitViewBarButtonItem:rootPopoverButtonItem];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Rotation support

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem !=splitViewBarButtonItem) {
        NSMutableArray *toolbarsItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarsItems removeObject:_splitViewBarButtonItem];
        if(splitViewBarButtonItem) [toolbarsItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarsItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
