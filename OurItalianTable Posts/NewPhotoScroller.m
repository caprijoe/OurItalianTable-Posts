//
//  NewPhotoScroller.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/1/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "NewPhotoScroller.h"

@interface NewPhotoScroller ()
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageImageFilenames;
@end

@implementation NewPhotoScroller
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // set the button for portrait mode
    [self setSplitViewBarButtonItem:self.splitViewBarButtonItem];
    
    // set window title
    self.title = @"The Family";
    
    // get image names from PLIST
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"NextImage" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    self.pageImageFilenames = [NSArray arrayWithArray:[dict objectForKey:@"Root"]];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

}

#pragma mark - Private methods
- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageImageFilenames count] == 0) || (index >= [self.pageImageFilenames count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFilename = self.pageImageFilenames[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - UIPageViewControllerDataSourceDelegate methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageImageFilenames count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageImageFilenames count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - Rotation support
-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    self.navigationItem.leftBarButtonItem = splitViewBarButtonItem;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

@end
