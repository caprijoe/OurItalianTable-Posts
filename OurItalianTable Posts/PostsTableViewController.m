//
//  PostsTableViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/8/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "PostsTableViewController.h"
#import "SplashScreenController.h"

@implementation PostsTableViewController

-(void)viewDidLoad
{
    self.majorPredicate = nil;
    self.defaultContextTitle = @"Our Italian Table";
    
    // set nav VC buttons

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    // set the index button
    self.indexButton.target = self;
    self.indexButton.action = @selector(showTOC:);
    self.navigationItem.rightBarButtonItem = self.indexButton;
    
    // set the refresh buttom
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshView:)];
    self.navigationItem.leftBarButtonItem = leftButton;

#pragma clang diagnostic pop
    
    // now call super, out of normal order
    [super viewDidLoad];
}

@end
