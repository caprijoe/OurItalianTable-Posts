//
//  FoodTableViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/8/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "FoodTableViewController.h"

@interface FoodTableViewController ()

@end

@implementation FoodTableViewController
// @synthesize category = _category;

#pragma mark - Setters/Getters
/* -(void)setCategory:(NSString *)category
{
    if (_category != category)
        _category = category;
} */

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.category = @"food";
    self.sortKey = @"postPubDate";
    self.sectionKey = nil;
    self.rightSideSegueName = @"Reset Splash View";
}

@end
