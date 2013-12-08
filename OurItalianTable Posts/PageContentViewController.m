//
//  PageContentViewController.m
//  PageViewDemo
//
//  Created by Simon on 24/11/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "PageContentViewController.h"

@interface PageContentViewController ()

@end

@implementation PageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.backgroundImageView.image = [UIImage imageNamed:self.imageFilename];
    self.titleLabel.text = [self.imageFilename stringByDeletingPathExtension];

}

@end
