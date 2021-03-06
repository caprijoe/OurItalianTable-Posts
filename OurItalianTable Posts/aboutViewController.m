//
//  aboutViewController.m
//  oitPosts
//
//  Created by Joseph Becci on 5/5/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "aboutViewController.h"

@interface aboutViewController ()

@end

@implementation aboutViewController
@synthesize versionBuildDisplay = _versionBuildDisplay;
@synthesize txtDisplay = _txtDisplay;

#pragma mark Private methods

- (NSString*) getAppVersion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"© Our Italian Table, 2012 (v%@)", version];
}

#pragma mark - View lifecycle support
-(void)viewDidLoad {
    [super viewDidLoad];
    
    // load text file from bundle
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"bios" ofType:@"txt"];
    NSString *txtContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    self.txtDisplay.text = txtContents;
    self.versionBuildDisplay.text = [self getAppVersion];
}

- (void)viewDidUnload {
    [self setTxtDisplay:nil];
    [self setVersionBuildDisplay:nil];
    [super viewDidUnload];
}

#pragma mark - Rotation support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else  
        return YES;
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskAll;
}

#pragma mark - Outlets
// when done button pressed (on iPhone only) dismiss self
- (IBAction)doneButton:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    [self dismissModalViewControllerAnimated:YES];
}   
@end
