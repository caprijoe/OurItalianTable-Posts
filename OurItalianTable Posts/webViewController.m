//
//  WebViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/29/11.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "WebViewController.h"
#import "LocationMapViewController.h"

#define CSS_IMPORT_FILENAME @"HTMLStyles"
#define DOUBLE_QUOTE_CHAR   @"\""
#define IMAGE_SCALE         .95

@interface WebViewController() <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>;
@property (nonatomic,strong) NSString *cssHTMLHeader;               // CSS Header to be stuck in front of HTML
@property (nonatomic,strong) NSString *loadedHTML;                  // HTML code that was loaded -- for e-mailing
@property (nonatomic,strong) NSString *currentActionSheet;          // current sheet to figure clicked button
@property (nonatomic,strong) UIActionSheet *bookmarksActionSheet;
@property (nonatomic,strong) UIActionSheet *sharingActionSheet;
@property (nonatomic,weak)   UIPopoverController *detailPopover;      // the info popover, if on screen
@property (nonatomic,weak)   UIPopoverController *locationPopover;  // the location popover, if on screen
@end

@implementation WebViewController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

#pragma mark - Setters/Getters
-(void)setThisPost:(Post *)thisPost
{
    _thisPost = thisPost;
    (_thisPost) ? [self loadPost] : [self loadLogo];
}

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = barButtonItem;
    _splitViewBarButtonItem = barButtonItem;
}

#pragma mark - View lifecycle support
-(void)viewDidLoad
{
    [super viewDidLoad];
        
    // set button for initial startup (before rotation)
    [self setSplitViewBarButtonItem:self.splitViewBarButtonItem];

    // support for change of perferred text font and size
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // get rid of any left over popovers
    [self.detailPopover dismissPopoverAnimated:YES];
    [self.locationPopover dismissPopoverAnimated:YES];
}

#pragma mark - Private methods
-(void)loadPost
{
    // configure buttons in storyboard
    self.infoButton.target = self;
    self.infoButton.action = @selector(showDetail:);
    self.mapButton.target = self;
    self.mapButton.action = @selector(showLocationMap:);
    
    // configure buttons without segues
    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePost:)];
    UIBarButtonItem *bookmarksButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(addToFavorites:)];
    
    // if no coordinates in post, delete compass icon (last object)
    if (self.thisPost.latitude == 0 && self.thisPost.longitude == 0)
        self.navigationItem.rightBarButtonItems = @[self.infoButton, forwardButton, bookmarksButton ];
    else
        self.navigationItem.rightBarButtonItems = @[self.infoButton, forwardButton, self.mapButton, bookmarksButton  ];
    
    // if we haven't loaded the css header, do it now...
    if(!self.cssHTMLHeader) {
        NSString *path = [[NSBundle mainBundle] pathForResource:CSS_IMPORT_FILENAME ofType:@"html"];
        NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
        self.cssHTMLHeader = [[NSString alloc] initWithData:
                              [readHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
    }
    
    // load title
    self.navigationItem.title = self.thisPost.postName;
    
    // fix CRLFs & WP caption blocks so they show on in webview
    NSString *modifiedHTML = [self modifyAllCaptionBlocks:[self convertCRLFstoPtag:self.thisPost.postHTML]];
    
    // Load up the style list, and the title and append
    NSString *titleTags = [NSString stringWithFormat:@"<h1>%@</h1>",self.thisPost.postName];
    NSString *finalHTMLstring = [[self.cssHTMLHeader stringByAppendingString:titleTags] stringByAppendingString:modifiedHTML];
    
    //show webview
    [self.webView loadHTMLString:finalHTMLstring baseURL:nil];
    
    // save final html in instance var for sharing button
    self.loadedHTML = finalHTMLstring;
}

-(void)loadLogo
{
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString *htmlString = @"<html><head><style type='text/css'>html,body {margin: 0;padding: 0;width: 100%;height: 100%;}html {display: table;}body {display: table-cell;vertical-align: middle;padding: 20px;text-align: center;-webkit-text-size-adjust: none;}</style></head><body><img src=\"ouritaliantable-original-transparent.gif\"></body></html>​";
    
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
    
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.title = nil;
}

-(NSString *)grabTextFrom:(NSString *)incomingText
     viaRegularExpression:(NSString *)regexString
{
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:incomingText options:NSMatchingReportProgress range:NSMakeRange(0, [incomingText length])];
    return [incomingText substringWithRange:result.range];
}

-(NSString *)modifyCaptionBlock:(NSString *)originalCaptionBlock
{
    NSString *alignmentAttributeText;                                                   // location for storing "align=" value
    NSString *captionAttributeText;                                                     // location for storing "caption=" value
    NSString *captionText;                                                              // location for storing -></a>text[/caption]
    NSString *imageTag;                                                                 // location for storing "<img ... />" tag
    NSString *imageWidthOnTag;                                                          // width value on IMG tage
    
    imageTag = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"<img[^>]*>"];
    imageWidthOnTag = [self grabTextFrom:imageTag viaRegularExpression:@"(?<= width=\").*?(?=\")"];
    alignmentAttributeText = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"(?<= align=\").*?(?=\")"];
    captionAttributeText = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"(?<= caption=\").*?(?=\")"];
    captionText = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"(?<=/>).*?(?=\\[/caption)"];
    
    return [[NSString alloc] initWithFormat:@"<div class=\"%@ captionfont\" style=\"width:%@ px;text-align:center;\">%@<br>%@</div>", alignmentAttributeText, imageWidthOnTag, imageTag, ([captionAttributeText length] != 0) ? captionAttributeText : captionText];    
}

-(NSString *)convertCRLFstoPtag:(NSString *)incomingText
{
    /* print string in hex
     
     NSMutableString *result = [[NSMutableString alloc] init];
     const char *cstring = [incomingText UTF8String];
     int i;
     for (i=0; i<strlen(cstring); i++) {
     [result appendString:[NSString stringWithFormat:@"%c[%02x]",cstring[i],cstring[i]]];
     }
     NSLog(@"hex--> %@",result); */
    
    
    /*    return [incomingText stringByReplacingOccurrencesOfString:@"\n\n" withString:@"<p>\n"]; */
    
    return [incomingText stringByReplacingOccurrencesOfString:@"\x0D\x0A\x0D\x0A" withString:@"<p>\x0D\x0A"];
}

-(NSString *)modifyAllCaptionBlocks:(NSString *)incomingText
{
    // captionScanner - edit the caption to true <div> structures; change WP to div. see example below
    
    /* [caption id="attachment_156" align="alignleft" width="300" caption="Zuppa Gallurese"]<a href="http://ouritaliantable.files.wordpress.com/2008/08/zuppagallurese-031.jpg"><img class="size-medium wp-image-156" src="http://ouritaliantable.files.wordpress.com/2008/08/zuppagallurese-031.jpg?w=300" alt="Zuppa Gallurese" width="300" height="199" /></a>[/caption] */
    
    /* <div class="alignleft" style="width:300 px;font-size:80%;text-align:center;"><img class="size-medium wp-image-156" src="http://ouritaliantable.files.wordpress.com/2008/08/zuppagallurese-031.jpg?w=300" alt="Zuppa Gallurese" width="300" height="199" />Zuppa Gallurese</div> */
    
    NSScanner *captionScanner = [NSScanner scannerWithString:incomingText];
    NSString *accumulatedHTML = [[NSString alloc] init];                            // location for building new html with replaced [catpion] structure
    NSString *foundString;                                // location for text between "[caption]" blocks
    NSString *captionBlock;;
    
    [captionScanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    
    [captionScanner scanUpToString:@"[caption" intoString:&accumulatedHTML];
    while(![captionScanner isAtEnd]) {
        
        [captionScanner scanUpToString:@"[/caption]" intoString:&captionBlock];
        [captionScanner scanString:@"[/caption]" intoString:NULL];
        captionBlock = [captionBlock stringByAppendingString:@"[/caption]"];
        
        accumulatedHTML = [accumulatedHTML stringByAppendingString:[self modifyCaptionBlock:captionBlock]];
        
        [captionScanner scanUpToString:@"[caption" intoString:&foundString];
        if (foundString)
            accumulatedHTML = [accumulatedHTML stringByAppendingString:foundString];
    }
    return accumulatedHTML;
}

#pragma mark - Dynamic type support
- (void)preferredContentSizeChanged:(NSNotification *)aNotification
{
    //
}

#pragma mark - Action sheets
#define BOOKMARKS_TITLE @"Favorites"
#define ADD_BUTTON      @"Add Favorite"
#define REMOVE_BUTTON   @"Remove Favorite"
#define SHARE_TITLE     @"Share"
#define EMAIL_BUTTON    @"Email"
#define TWEET_BUTTON    @"Tweet"
#define FACEBOOK_BUTTON @"Facebook"
#define SMS_BUTTON      @"Message"
#define CANCEL_BUTTON   @"Cancel"

-(void)presentActionSheetforBookmarkFromBarButton:(UIBarButtonItem *)button
{
    // if bookmark sheet is up, dismiss it
    if (self.bookmarksActionSheet) {
        [self.bookmarksActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        self.bookmarksActionSheet = nil;
        return;
    }
    
    if ([self.thisPost.bookmarked boolValue])              // is currently a favorite
        self.bookmarksActionSheet = [[UIActionSheet alloc] initWithTitle:BOOKMARKS_TITLE
                                                  delegate:self
                                         cancelButtonTitle:CANCEL_BUTTON
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:REMOVE_BUTTON, nil];
    else 
        self.bookmarksActionSheet = [[UIActionSheet alloc] initWithTitle:BOOKMARKS_TITLE
                                                  delegate:self
                                         cancelButtonTitle:CANCEL_BUTTON
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:ADD_BUTTON, nil];
    
    self.currentActionSheet = BOOKMARKS_TITLE;
    
    [self.bookmarksActionSheet showFromBarButtonItem:button animated:YES];
}

-(void)presentActionSheetforSharingFromBarButton:(UIBarButtonItem *)button
{
    // if sharing sheet is up, dismiss it
    if (self.sharingActionSheet) {
        [self.sharingActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        self.sharingActionSheet = nil;
        return;
    }
    
    
    self.sharingActionSheet = [[UIActionSheet alloc] initWithTitle:SHARE_TITLE
                                              delegate:self
                                     cancelButtonTitle:CANCEL_BUTTON
                                destructiveButtonTitle:nil
                                     otherButtonTitles: EMAIL_BUTTON, SMS_BUTTON, TWEET_BUTTON, FACEBOOK_BUTTON, nil];
    
    self.currentActionSheet = SHARE_TITLE;
    [self.sharingActionSheet showFromBarButtonItem:button animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // record sheet being dismissed
    if (actionSheet == self.sharingActionSheet) {
        self.sharingActionSheet = nil;
    } else if (actionSheet == self.bookmarksActionSheet)
        self.bookmarksActionSheet = nil;
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self.currentActionSheet isEqualToString:BOOKMARKS_TITLE]) {
        
        // get button pressed
        NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if ([choice isEqualToString:ADD_BUTTON]) {
            self.thisPost.bookmarked = @YES;
        } else if ([choice isEqualToString:REMOVE_BUTTON]) {
            self.thisPost.bookmarked = @NO;
        }
        
        // save any loaded changes at this point
        [self.thisPost.managedObjectContext save:NULL];    // save any loaded changes at this point

        
    } else if ([self.currentActionSheet isEqualToString: SHARE_TITLE]) {
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString: EMAIL_BUTTON]) {
            [self shareViaEmail];
        } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:TWEET_BUTTON]) {
            [self shareViaTweet];
        } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:SMS_BUTTON]) {
            [self shareViaMessage];
        } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:FACEBOOK_BUTTON]) {
            [self shareViaFacebook];
        }
    }
}

#pragma mark - Support for each sharing method
-(void)showSimpleAlertWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

#pragma mark - Share post via e-mail
-(void)shareViaEmail
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:[NSString stringWithFormat:@"From Our Italian Table - %@",self.thisPost.postName]];
        
        UIImage *oitLogo = [UIImage imageNamed:@"oitIcon-72x72.png"];
        NSData *imageData = UIImagePNGRepresentation(oitLogo);
        [mailer addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"Our Italian Table Logo"];
        
        [mailer setMessageBody:self.loadedHTML isHTML:YES];
        
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:mailer animated:YES completion:NULL];
    } else {
        [self showSimpleAlertWithTitle:@"Cannot send email"
                           withMessage:@"Unable to send email from this device. Make sure you have setup at least one email account"];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Share post via Twitter
-(void)shareViaTweet
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetController setInitialText:self.thisPost.postName];
        [tweetController addImage:[UIImage imageWithData: self.thisPost.postIcon]];
        [tweetController addURL:[NSURL URLWithString:self.thisPost.postURLstring]];
        [self presentViewController:tweetController animated:YES completion:nil];
    } else {
        [self showSimpleAlertWithTitle:@"Cannot Tweet"
                           withMessage:@"Unable to send Tweet from this device. Make sure Tweeter is available and you have set up Tweeter with at least one account."];
    }
}

#pragma mark - Share post via Facebook
-(void)shareViaFacebook
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *facebookController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookController setInitialText:self.thisPost.postName];
        [facebookController addImage:[UIImage imageWithData:self.thisPost.postIcon]];
        [facebookController addURL:[NSURL URLWithString:self.thisPost.postURLstring]];
        
        [self presentViewController:facebookController animated:YES completion:nil];
        
    } else {
        [self showSimpleAlertWithTitle:@"Cannot post to Facebook"
                           withMessage:@"Unable to post to Facebook from this device. Make sure Facebook is available and you have set up Facebook with at least one account in Settings."];
    }
}

#pragma mark - Share post via Message (SMS)
-(void)shareViaMessage
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.body = [NSString stringWithFormat:@"%@ - %@",self.thisPost.postName, self.thisPost.postURLstring];
        [self presentViewController:messageController animated:YES completion:nil];
        messageController.messageComposeDelegate = self;
    } else {
        [self showSimpleAlertWithTitle:@"Cannot send Message (SMS)"
                           withMessage:@"Unable to send a Message (SMS) from this device. Make sure iOS Messages is set up and you have logged in."];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Segue support
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Push Post Detail"]) {
        [segue.destinationViewController setPostDetail:self.thisPost];
        [segue.destinationViewController setDelegate:self];
        
        // if we're segueing to a popover, save it in self and in the destination controller
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            self.detailPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        }
    } else if ([segue.identifier isEqualToString:@"Push Location Map"]) {
        [segue.destinationViewController setLocationRecord:self.thisPost];
        
        // if we're segueing to a popover, save it in self and in the destination controller
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            self.locationPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        }
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Push Post Detail"]) {
        return self.detailPopover ? NO: YES;
    } else if ([identifier isEqualToString:@"Push Location Map"]) {
        return self.locationPopover ? NO : YES;
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

#pragma mark - IBActions
-(IBAction)showLocationMap:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"Push Location Map" sender:self];
}

- (IBAction)addToFavorites:(UIBarButtonItem *)sender
{
    [self presentActionSheetforBookmarkFromBarButton:sender];
}

- (IBAction)sharePost:(UIBarButtonItem *)sender
{
    [self presentActionSheetforSharingFromBarButton:sender];
}

-(IBAction)showDetail:(id)sender
{
    [self performSegueWithIdentifier:@"Push Post Detail" sender:self];
}

#pragma mark - PostDetaiViewControllerDelegate call back
-(void)didClickTag:(NSString *)tag
{
    [self.delegate didClickTag:tag];                            // call back with tag
    
    // all nil if on an iphone if strictly a UINavVC
    [self.detailPopover dismissPopoverAnimated:YES];            // dismiss the popover
    self.detailPopover = nil;                                   // nil out the holder
}

@end
