//
//  FoodTableViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/8/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "BookmarksTableViewController.h"
#import "SplashScreenController.h"

@implementation BookmarksTableViewController

-(void)viewDidLoad
{
    self.majorPredicate = [NSPredicate predicateWithFormat:@"bookmarked == %@", @YES];
    self.defaultContextTitle = @"Bookmarks";
        
    // now call super, out of normal order
    [super viewDidLoad];
}


@end