//
//  PageContentViewController.m
//  PageViewDemo
//
//  Created by Simon on 24/11/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "PageContentViewController.h"

@implementation PageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup fonts
    [self setupFonts];
    
    // support for change of perferred text font and size
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    // setup the image and label on this page controller
    self.titleLabel.text = [self.imageFilename stringByDeletingPathExtension];
    self.backgroundImageView.image = [UIImage imageNamed:self.imageFilename];
}

#pragma mark - Dynamic type support
-(void)setupFonts
{
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

- (void)preferredContentSizeChanged:(NSNotification *)aNotification
{
    // override from abstract class
    [self setupFonts];
    [self.view setNeedsLayout];
}

@end
