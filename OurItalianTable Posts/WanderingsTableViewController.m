//
//  FoodTableViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/8/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "WanderingsTableViewController.h"
#import "MapViewController.h"

@implementation WanderingsTableViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"geo" ascending:YES],
                             [NSSortDescriptor sortDescriptorWithKey:@"postPubDate" ascending:NO]];
    self.sectionKey = @"geo";
    self.majorPredicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) ", @"wanderings"];
}

-(void)resetDetailView
{
    // if in a splitview and right side is not the specificed controller, segue too it
    id detail = [self.splitViewController.viewControllers lastObject];
    if (self.splitViewController && ![detail isKindOfClass:[MapViewController class]])
        [self performSegueWithIdentifier:@"Show Region Map" sender:self];
}

@end
