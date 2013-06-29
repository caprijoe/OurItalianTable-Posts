//
//  DataViewController.m
//  PVCTest
//
//  Created by Joseph Becci on 6/11/13.
//  Copyright (c) 2013 Joseph Becci. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageView.image = [UIImage imageNamed:self.imagePath];
    self.photoName.text = [self.imagePath stringByDeletingPathExtension];
    self.pageControl.numberOfPages = self.numOfPages;
    self.pageControl.currentPage = self.imageIndex;
}

@end
