//
//  NewPhotoScroller.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/1/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface NewPhotoScroller : OITViewController <UIPageViewControllerDataSource, SplitViewBarButtonItemPresenter>
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end
