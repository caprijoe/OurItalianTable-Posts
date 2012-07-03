//
//  PostDetailViewController.m
//  oitPosts
//
//  Created by Joseph Becci on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostDetailViewController.h"
#import "OITLaunchViewController.h"
#import "UIKit/UIKit.h"
#import "postsTableViewController.h"

@interface PostDetailViewController()
@property (nonatomic) NSInteger clicked;
@end

@implementation PostDetailViewController
@synthesize postDetail = _postDetail;
@synthesize authorPicture = _authorPicture;
@synthesize postTitle = _postTitle;
@synthesize datePublished = _datePublished;
@synthesize tagsView = _tagsView;
@synthesize clicked = _clicked;
@synthesize delegate = _delegate;


#pragma mark - View lifecycle

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGSize size = CGSizeMake(300,600);
    self.contentSizeForViewInPopover = size;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated {
    
    // post title
    self.postTitle.text = self.postDetail.postName;
    
    // Present date published
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"^(\\S+),\\s\\d+\\s\\S+\\s\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSTextCheckingResult *match = [regex firstMatchInString:self.postDetail.postPubDate options:0 range:NSMakeRange(0, [self.postDetail.postPubDate length])];
    if  (match)
    {
        self.datePublished.text = [self.postDetail.postPubDate substringWithRange:match.range];
    }
    
    // Present author picture
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.postDetail.postAuthor ofType:@"jpg"]];
    [self.authorPicture setImage:image];
    self.authorPicture.contentMode = UIViewContentModeScaleAspectFit;
    
    // Present "2D tag cloud"
    UIFont *font = self.datePublished.font;
    CGFloat maxX = self.tagsView.bounds.size.width;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat buttonHeight = 30;
    CGFloat buttonPad = 20;
    CGFloat nextButtonLength;
    
    
    for (int i = 0; i < [self.postDetail.postTags count]; i++) {
        UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        nextButtonLength = [[self.postDetail.postTags objectAtIndex:i] sizeWithFont:font].width + buttonPad;
        if (nextButtonLength > (maxX - x)) {
            x = 0;
            y = y + buttonHeight;
        }
        tagButton.frame =  CGRectMake(x,y,nextButtonLength , buttonHeight);
        x = x + tagButton.frame.size.width;
        
        [tagButton  setTitle:[self.postDetail.postTags objectAtIndex:i] forState:UIControlStateNormal ];
        [tagButton setTag:i];
        [tagButton addTarget:self action:@selector(takeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.tagsView addSubview:tagButton];
    }
}

 -(void)takeAction:(UIButton *)button {
     self.clicked = button.tag;
     id tag = [self.postDetail.postTags objectAtIndex:button.tag];
     [self.delegate postsDetailViewController:self choseTag:tag];
}

- (void)viewDidUnload
{
    [self setDatePublished:nil];
    [self setAuthorPicture:nil];
    [self setTagsView:nil];
    [self setPostTitle:nil];
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)doneButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
