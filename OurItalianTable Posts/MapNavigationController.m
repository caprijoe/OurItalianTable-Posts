//
//  MapNavigationController.m
//  oitPosts
//
//  Created by Joseph Becci on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapNavigationController.h"
#import "MapViewController.h"


@implementation MapNavigationController
@synthesize myBrain = _myBrain;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((MapViewController *)self.topViewController).myBrain = self.myBrain;
}

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
/*    if (_splitViewBarButtonItem !=splitViewBarButtonItem) {
        NSMutableArray *toolbarsItems = [self.navigationBar.items mutableCopy];
        NSLog(@"MapNavigationController toolbar = %i",[toolbarsItems count]);
        if (_splitViewBarButtonItem) [toolbarsItems removeObject:_splitViewBarButtonItem];
        if(splitViewBarButtonItem) [toolbarsItems insertObject:splitViewBarButtonItem atIndex:0];
        self.navigationItem.lef = toolbarsItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    } */
    
    self.navigationItem.leftBarButtonItem = splitViewBarButtonItem;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else  
        return YES;
}

@end
