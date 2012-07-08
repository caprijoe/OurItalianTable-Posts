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
@property (nonatomic, strong) NSMutableArray *pageViews;        // holds created views (only those visible)
@end

@implementation PhotoScroller

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize photoName = _photoName;
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
    
    // Update photo name
    self.photoName.text = [[self.imagePaths objectAtIndex:page] stringByDeletingPathExtension];

}

- (void)loadPage:(NSInteger)page
        withPath:(NSString *)path {
/*    
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    } */
    
    // Load an individual page, first seeing if we've already loaded it
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0.0f;
    
    UIImageView *newPageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:path]];
    newPageView.contentMode = UIViewContentModeScaleAspectFit;
    newPageView.frame = frame;
    [self.scrollView addSubview:newPageView];
    [self.pageViews addObject:newPageView];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // make sure bottom toolbar in nav controller is hidden
    [self.navigationController setToolbarHidden:YES];
    
    self.title = @"The Family";
    [self setSplitViewBarButtonItem:self.rootPopoverButtonItem];
    
    // get image names from PLIST
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"NextImage" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    self.imagePaths = [NSArray arrayWithArray:[dict objectForKey:@"Root"]];
    
    // load number of pages
    NSInteger pageCount = self.imagePaths.count;
    
    // Set up the page control
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = self.imagePaths.count;
    
    // Set up the array with views for each page
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self loadPage:i withPath:[self.imagePaths objectAtIndex:i]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set up the content size of the scroll view
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.imagePaths.count, pagesScrollViewSize.height);
    
    // Load the initial set of pages that are on screen
    [self loadVisiblePages];
}

- (void)viewDidUnload {
    [self setPhotoName:nil];
    [super viewDidUnload];
    
    self.scrollView = nil;
    self.pageControl = nil;
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
