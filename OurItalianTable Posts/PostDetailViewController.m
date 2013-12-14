//
//  PostDetailViewController.m
//  oitPosts
//
//  Created by Joseph Becci on 1/15/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "PostDetailViewController.h"

@implementation PostDetailViewController

#pragma mark - View lifecycle

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGSize size = CGSizeMake(300,600);
    self.contentSizeForViewInPopover = size;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // set background color
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    // set date published
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    self.datePublished.text = [formatter stringFromDate:self.postDetail.postPubDate];
    
    // set post title
    self.postTitle.text = self.postDetail.postName;
    
    // set author picture
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.postDetail.postAuthor ofType:@"jpg"]];
    [self.authorPicture setImage:image];
    self.authorPicture.contentMode = UIViewContentModeScaleAspectFit;
    
    // create "2D tag cloud"
    
    // set up parameters of cloud
    UIFont *font = self.datePublished.font;
    CGFloat maxX = self.tagsView.bounds.size.width;
    CGFloat maxY = self.tagsView.bounds.size.height;
    
    CGFloat buttonHeight = 30;
    CGFloat buttonTitlePad = 20;
    CGFloat buttonSpacing = 2;
    
    __block CGFloat x = 0;
    __block CGFloat y = 0;

    [self.postDetail.whichTags enumerateObjectsUsingBlock:^(id tag, BOOL *stop) {
        
        // get the tag text for this button
        NSString *thisTag = ((Tag *)tag).tagString;
        
        // set initial button state
        UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeSystem];
        
        // determine the size of this button and it it will fit on the current line, if not move to next line
        CGFloat nextButtonLength = [thisTag sizeWithFont:font].width + buttonTitlePad;
        if ((nextButtonLength + buttonSpacing) > (maxX - x)) {
            x = 0;
            y = y + buttonHeight + buttonSpacing;
        }
        tagButton.frame =  CGRectMake(x,y,nextButtonLength , buttonHeight);
        x = x + tagButton.frame.size.width + buttonSpacing;
        
        // configure button with title and state
        [tagButton setTitle:thisTag forState:UIControlStateNormal];
        
        // check if any more vertical room
        if (y + buttonHeight + buttonSpacing <= maxY) {
            
            // add the target action and add button to subview
            [tagButton addTarget:self action:@selector(takeAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.tagsView addSubview:tagButton];
        }
    
    }];
}

-(void)takeAction:(UIButton *)button {
    
    // call back with button pressed
    [self.delegate didClickTag:button.titleLabel.text];
     
}

#pragma mark - Outlets/Actions
- (IBAction)doneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
