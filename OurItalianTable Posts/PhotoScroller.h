//
//  PhotoScroller.h
//  oitPosts
//
//  Created by Joseph Becci on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface PhotoScroller : UIViewController <UIScrollViewDelegate, SplitViewBarButtonItemPresenter>

// outlets
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UILabel *photoName;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

// actions
@property (nonatomic, weak) UIBarButtonItem *rootPopoverButtonItem;

@end
