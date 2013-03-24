//
//  FoodTableViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/8/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "BookmarksTableViewController.h"

@interface BookmarksTableViewController ()

@end

@implementation BookmarksTableViewController
@synthesize category = _category;
@synthesize favs = _favs;

#pragma mark - Setters/Getters
-(void)setFavs:(BOOL)fav
{
    _favs = fav;
}

-(void)setCategory:(NSString *)category
{
    if (_category != category)
        _category = category;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.favs = YES;
}

@end
