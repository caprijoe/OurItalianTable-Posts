//
//  ModelController.m
//  PVCTest
//
//  Created by Joseph Becci on 6/11/13.
//  Copyright (c) 2013 Joseph Becci. All rights reserved.
//

#import "PhotoModelController.h"
#import "ImageViewController.h"

@interface PhotoModelController()
@property (nonatomic, strong) NSArray *imagePaths;
@end

@implementation PhotoModelController

- (id)init
{
    self = [super init];
    if (self) {
        // Create the data model.
        
        // get image names from PLIST
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"NextImage" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        self.imagePaths = [NSArray arrayWithArray:[dict objectForKey:@"Root"]];
        
        // if unable to retrieve list or got an empty one, don't create model
        if ([self.imagePaths count] == 0 || !self.imagePaths)
            
            return nil;

    }
    return self;
}

- (ImageViewController *)viewControllerAtIndex:(NSInteger)index storyboard:(UIStoryboard *)storyboard
{
    // Return the data view controller for the given index.
    if (index < 0 || (index >= [self.imagePaths count])) {
        return nil;
    } else {
        
        // Create a new view controller and pass suitable data.
        ImageViewController *imageViewController = [storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
        imageViewController.imageIndex = index;
        imageViewController.imagePath = self.imagePaths[index];
        imageViewController.numOfPages = [self.imagePaths count];
        return imageViewController;
    }
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = ((ImageViewController *)viewController).imageIndex;
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = ((ImageViewController *)viewController).imageIndex;
    
    index++;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
