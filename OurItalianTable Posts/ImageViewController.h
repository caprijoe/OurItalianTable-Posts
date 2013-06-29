//
//  DataViewController.h
//  PVCTest
//
//  Created by Joseph Becci on 6/11/13.
//  Copyright (c) 2013 Joseph Becci. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

// properties
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic) NSUInteger imageIndex;
@property (nonatomic) NSUInteger numOfPages;

// outlets
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *photoName;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end
