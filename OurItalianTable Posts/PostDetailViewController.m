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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated {
    
    // set post title
    self.postTitle.text = self.postDetail.postName;
    
    // set date published
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    self.datePublished.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:self.postDetail.postPubDate]];
    
    // set author picture
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.postDetail.postAuthor ofType:@"jpg"]];
    [self.authorPicture setImage:image];
    self.authorPicture.contentMode = UIViewContentModeScaleAspectFit;
    
    // create "2D tag cloud"
    UIFont *font = self.datePublished.font;
    CGFloat maxX = self.tagsView.bounds.size.width;
    CGFloat buttonHeight = 30;
    CGFloat buttonPad = 20;
    
    __block CGFloat x = 0;
    __block CGFloat y = 0;

    [self.postDetail.whichTags enumerateObjectsUsingBlock:^(id tag, BOOL *stop) {
        
        UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        NSString *thisTag = ((Tag *)tag).tagString;
        CGFloat nextButtonLength = [thisTag sizeWithFont:font].width + buttonPad;
        if (nextButtonLength > (maxX - x)) {
            x = 0;
            y = y + buttonHeight;
        }
        tagButton.frame =  CGRectMake(x,y,nextButtonLength , buttonHeight);
        x = x + tagButton.frame.size.width;
        
        [tagButton  setTitle:thisTag forState:UIControlStateNormal ];
        [tagButton addTarget:self action:@selector(takeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.tagsView addSubview:tagButton];        
    
    }];
}

-(void)takeAction:(UIButton *)button {
    
    // call back with button pressed
     [self.delegate didClickTag:button.titleLabel.text];
     
}

- (void)viewDidUnload
{
    [self setDatePublished:nil];
    [self setAuthorPicture:nil];
    [self setTagsView:nil];
    [self setPostTitle:nil];
    [super viewDidUnload];
}

#pragma mark - Rotation Support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

#pragma mark - Outlets/Actions
- (IBAction)doneButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
