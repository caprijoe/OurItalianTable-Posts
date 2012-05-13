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
@synthesize txtDisplay = _txtDisplay;

#pragma mark - View lifecycle support

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // load text file from bundle
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"bios" ofType:@"txt"];
    NSString *txtContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    self.txtDisplay.text = txtContents;
}

- (void)viewDidUnload {
    [self setTxtDisplay:nil];
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

#pragma mark - Outlets

- (IBAction)doneButton:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    [self dismissModalViewControllerAnimated:YES];
}   
@end
