//
//  FoodTableViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/8/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "BookmarksTableViewController.h"

@implementation BookmarksTableViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"postPubDate" ascending:NO]];
    self.sectionKey = nil;
    self.rightSideSegueName = @"Reset Splash View";
    self.majorPredicate = [NSPredicate predicateWithFormat:@"bookmarked == %@", @YES];
}

@end
