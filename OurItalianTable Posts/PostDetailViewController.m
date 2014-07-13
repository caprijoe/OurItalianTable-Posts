//
//  PostDetailViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/15/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "PostDetailViewController.h"

@interface PostDetailViewController ()
@property (nonatomic, strong) NSString *clickedTag;     // selected tag
@end

@implementation PostDetailViewController

#pragma mark - View lifecycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup fonts
    [self setupFonts];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // set date published
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    self.datePublished.text = [NSString stringWithFormat:@"Published on\n\n%@",[formatter stringFromDate:self.postDetail.postPubDate]];
    
    // set post title
    self.navigationItem.title = self.postDetail.postName;
    
    // set author picture
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.postDetail.postAuthor ofType:@"jpg"]];
    [self.authorPicture setImage:image];
    self.authorPicture.contentMode = UIViewContentModeScaleAspectFit;

    [self draw2DTagCloud];
}

#pragma mark - Rotation support
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self draw2DTagCloud];
}

#pragma mark - Private methods
-(void)draw2DTagCloud
{
    // create "2D tag cloud"
    
    // clear out old tags
    [[self.tagsScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // set up parameters of cloud
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    CGFloat scrollMaxX = self.tagsScrollView.bounds.size.width;
    __block CGFloat scrollMaxY = 0; // y max for scrollview
    __block NSMutableArray *buttonArray = [[NSMutableArray alloc] initWithCapacity:[self.postDetail.whichCategories count]];
    
    // set up parameters for each button
    CGFloat buttonHeight = 30;
    CGFloat buttonTitlePad = 20; // sum of pad on both sides of text
    CGFloat buttonSpacing = 2;
    
    // tracking variables for button's locaton in cloud
    __block CGFloat x = 0;
    __block CGFloat y = 0;
    
    [self.postDetail.whichTags enumerateObjectsUsingBlock:^(id tag, BOOL *stop) {
        
        // if first time thru (at least on button), increment
        if (scrollMaxY == 0)
            scrollMaxY = buttonHeight + buttonSpacing;
        
        // get the tag text for this button
        NSString *thisTag = ((Tag *)tag).tagString;
        
        // set initial button state
        UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeSystem];
        
        // determine the size of this button and it it will fit on the current line, if not move to next line
        [[tagButton titleLabel] setFont:font];
        CGFloat nextButtonLength = [thisTag sizeWithAttributes:@{NSFontAttributeName:font}].width + buttonTitlePad;
        if ((nextButtonLength + buttonSpacing) > (scrollMaxX - x)) {
            x = 0;                                                          // reset to new line
            y += buttonHeight + buttonSpacing;                              // increment row y position
            scrollMaxY += buttonHeight + buttonSpacing;                     // increment the scrollview content size
        }
        tagButton.frame =  CGRectMake(x,y,nextButtonLength , buttonHeight);
        x += tagButton.frame.size.width + buttonSpacing;                    // increment the row x position
        
        // configure button with title and state
        [tagButton setTitle:thisTag forState:UIControlStateNormal];
        
        // add the target action and add button to subview
        [tagButton addTarget:self action:@selector(takeAction:) forControlEvents:UIControlEventTouchUpInside];
        [buttonArray addObject:tagButton];
    }];
    
    // setup the UIScrollView content size
    self.tagsScrollView.contentSize = CGSizeMake(scrollMaxX, scrollMaxY);
    
    // add all button's to scroll view
    [buttonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.tagsScrollView addSubview:obj];
    }];
}

#pragma mark - Dynamic type support
-(void)setupFonts
{
    self.datePublished.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.tagsText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

- (void)preferredContentSizeChanged:(NSNotification *)aNotification
{
    // override from abstract class
    [self setupFonts];
    [self draw2DTagCloud];
    [self.view setNeedsLayout];
}

#pragma mark - Selector for custom button
-(void)takeAction:(UIButton *)button
{
    // call back with button pressed
    [self.delegate didClickTag:button.titleLabel.text];
}

@end
