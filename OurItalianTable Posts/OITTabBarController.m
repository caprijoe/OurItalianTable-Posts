//
//  OITTabBarController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/2/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "OITTabBarController.h"

@implementation OITTabBarController

#pragma mark - View lifecycle support

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    // set delegate for rotation support
    self.splitViewController.delegate = self;
    self.delegate = self;
}

-(void)didReceiveMemoryWarning
{
    NSLog(@"ouritaliantable did receive memory warning");
}

#pragma mark - UISplitViewController delgates

// if detail controller responds to SplitViewBarButtonItemPresenter, return it's <id>, else return nil
- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if ([detailVC isKindOfClass:[UINavigationController class]])
        detailVC = [((UINavigationController *)detailVC).viewControllers firstObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)])
        detailVC = nil;
    return detailVC;
}

-(BOOL)splitViewController:(UISplitViewController *)svc
  shouldHideViewController:(UIViewController *)vc
             inOrientation:(UIInterfaceOrientation)orientation
{
    // if there's a qualifying dvc, showhide if in portrait
    NSLog(@"shouldHide, dvt = %@",[self splitViewBarButtonItemPresenter]);
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

-(void)splitViewController:(UISplitViewController *)svc
    willHideViewController:(UIViewController *)aViewController
         withBarButtonItem:(UIBarButtonItem *)barButtonItem
      forPopoverController:(UIPopoverController *)pc
{
    // if there's a qualifying dvc, on willHide, assign button to setter
    NSLog(@"willHide, dvt = %@",[self splitViewBarButtonItemPresenter]);
    barButtonItem.title = @"Menu";
    self.masterPopoverController = pc;
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

-(void)splitViewController:(UISplitViewController *)svc
    willShowViewController:(UIViewController *)aViewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // if there's a qualifying dvc, on willShow, assign nil to setter
    NSLog(@"willShow, dvt = %@",[self splitViewBarButtonItemPresenter]);
    self.masterPopoverController = nil;
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

@end
