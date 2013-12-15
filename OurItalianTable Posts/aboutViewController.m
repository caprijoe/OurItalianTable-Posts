//
//  aboutViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 5/5/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "aboutViewController.h"

@implementation aboutViewController

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
    
    // setup app version info
    self.versionBuildDisplay.text = [self getAppVersion];
    
    CGSize size = CGSizeMake(300,600);
    //  self.contentSizeForViewInPopover = size;
    [self setPreferredContentSize:size];
    
    // setup fonts
    [self setupFonts];
}

#pragma mark - Dynamic type support
-(void)setupFonts {
    
    self.txtDisplay.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.versionBuildDisplay.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    
}

- (void)preferredContentSizeChanged:(NSNotification *)aNotification {
    
    // override from abstract class
    [self setupFonts];
    [self.view setNeedsLayout];
    
}


#pragma mark - IBActions
- (IBAction)fireBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
