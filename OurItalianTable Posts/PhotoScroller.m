//
//  PhotoScroller.m
//  oitPosts
//
//  Created by Joseph Becci on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoScroller.h"

@interface PhotoScroller () 
@property (nonatomic, strong) NSArray *imagePaths;              // holds photos loaded from PLIST
@property (nonatomic, strong) NSMutableArray *pageImages;       // holds images load from disk
@property (nonatomic, strong) NSMutableArray *pageViews;        // holds created views (only those visible)

- (void)loadVisiblePages;
- (void)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;
@end

@implementation PhotoScroller

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize photoName = _photoName;
@synthesize pageImages = _pageImages;
@synthesize pageViews = _pageViews;
@synthesize imagePaths = _imagePaths;
@synthesize toolbar = _toolbar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize rootPopoverButtonItem = _rootPopoverButtonItem;

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem !=splitViewBarButtonItem) {
        NSMutableArray *toolbarsItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarsItems removeObject:_splitViewBarButtonItem];
        if(splitViewBarButtonItem) [toolbarsItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarsItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

#pragma mark - Private methods
- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    self.pageControl.currentPage = page;
        
    // Work out which pages we want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    for (NSInteger i=lastPage+1; i<self.pageImages.count; i++) {
        [self purgePage:i];
    }
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Load an individual page, first seeing if we've already loaded it
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:page]];
        newPageView.contentMode = UIViewContentModeScaleAspectFit;
        newPageView.frame = frame;
        [self.scrollView addSubview:newPageView];
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
    }
    
    // update photo name
    self.photoName.text = [[self.imagePaths objectAtIndex:page] stringByDeletingPathExtension];
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"The Family";
    [self setSplitViewBarButtonItem:self.rootPopoverButtonItem];
    
    // get image names from PLIST
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"NextImage" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    self.imagePaths = [NSArray arrayWithArray:[dict objectForKey:@"Root"]];
    
    // Set up the image we want to scroll & zoom and add it to the scroll view
    self.pageImages = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.imagePaths.count;i++) {
        [self.pageImages addObject:[UIImage imageNamed:[self.imagePaths objectAtIndex:i]]];
    }
    
    NSInteger pageCount = self.pageImages.count;
    
    // Set up the page control
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = self.pageImages.count;
    
    // Set up the array to hold the views for each page
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set up the content size of the scroll view
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.pageImages.count, pagesScrollViewSize.height);
    
    // Load the initial set of pages that are on screen
    [self loadVisiblePages];
}

- (void)viewDidUnload {
    [self setPhotoName:nil];
    [super viewDidUnload];
    
    self.scrollView = nil;
    self.pageControl = nil;
    self.pageImages = nil;
    self.pageViews = nil;
}

#pragma mark - Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else  
        return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages which are now on screen
    [self loadVisiblePages];
}

@end
