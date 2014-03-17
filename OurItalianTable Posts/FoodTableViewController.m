//
//  FoodTableViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/8/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "FoodTableViewController.h"
#import "SplashScreenController.h"

@implementation FoodTableViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"postPubDate" ascending:NO]];
    self.sectionKey = nil;
    self.majorPredicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) ", @"food"];
}

@end
