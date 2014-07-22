//
//  PhotoScroller.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/1/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "PhotoScroller.h"

@interface PhotoScroller ()
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageImageFilenames;
@end

@implementation PhotoScroller
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

#pragma mark - Setters/Getters
-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = barButtonItem;
    _splitViewBarButtonItem = barButtonItem;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set button for initial startup (before rotation)
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
    
    [_pageViewController.view setFrame:self.mainView.bounds];
    [self addChildViewController:_pageViewController];
    [self.mainView addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    // support for change of perferred text font and size
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
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

#pragma mark - Dynamic type support
- (void)preferredContentSizeChanged:(NSNotification *)aNotification
{
    //
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

@end