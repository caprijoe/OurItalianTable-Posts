//
//  ModelController.h
//  PVCTest
//
//  Created by Joseph Becci on 6/11/13.
//  Copyright (c) 2013 Joseph Becci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewController.h"

@interface PhotoModelController : NSObject <UIPageViewControllerDataSource>

- (ImageViewController *)viewControllerAtIndex:(NSInteger)index storyboard:(UIStoryboard *)storyboard;

@end
