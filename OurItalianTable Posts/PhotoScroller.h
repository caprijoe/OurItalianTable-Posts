//
//  PhotoScroller.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 3/3/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OITLaunchViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface PhotoScroller : UIViewController <UIScrollViewDelegate, SplitViewBarButtonItemPresenter>

// outlets
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UILabel *photoName;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

@end
