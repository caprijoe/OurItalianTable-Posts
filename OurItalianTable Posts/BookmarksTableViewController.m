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

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"postPubDate" ascending:NO]];
    self.sectionKey = nil;
    self.majorPredicate = [NSPredicate predicateWithFormat:@"bookmarked == %@", @YES];
}

-(void)resetDetailView
{
    // if in a splitview and right side is not the specificed controller, segue too it
    id detail = [self.splitViewController.viewControllers lastObject];
    if (self.splitViewController && ![detail isKindOfClass:[SplashScreenController class]])
        [self performSegueWithIdentifier:@"Reset Splash View" sender:self];
}

@end