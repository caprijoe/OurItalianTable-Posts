//
//  OITViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/1/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "OITViewController.h"

@interface OITViewController ()

@end

@implementation OITViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // support for change of perferred text font and size
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

}

// Must be overridden, abstract method to handle text change
- (void)preferredContentSizeChanged:(NSNotification *)aNotification {

    // should be overridden
    NSAssert(NO,  @"This is an abstract method and must be overridden");

}

@end
