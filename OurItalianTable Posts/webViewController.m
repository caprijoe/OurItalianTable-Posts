//
//  webViewController.m
//  oitWebViewController
//
//  Created by Joseph Becci on 12/29/11.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "WebViewController.h"
#import "OITLaunchViewController.h"
#import "PostDetailViewController.h"
#import "LocationMapViewController.h"
#import "SharedUserDefaults.h"

#define FAVORITES_KEY       @"FAVORITES_KEY"
#define CSS_IMPORT_FILENAME @"HTMLStyles"
#define DOUBLE_QUOTE_CHAR   @"\""
#define IMAGE_SCALE         .95

@interface WebViewController() <PostsDetailViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>;
@property (nonatomic,strong) NSString *cssHTMLHeader;               // CSS Header to be stuck in front of HTML
@property (nonatomic,strong) UIStoryboardSegue* detailsViewSeque;   // saved segue for return from "Details" button
@property (nonatomic,strong) NSString *loadedHTML;                  // HTML code that was loaded -- for e-mailing
@property (nonatomic,strong) NSString *currentActionSheet;          // current sheet to figure clicked button
@property (nonatomic,weak)   UIPopoverController *infoPopover;      // the info popover, if on screen
@end

@implementation WebViewController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

#pragma mark - Setter

-(void)setThisPost:(Post *)thisPost
{
    _thisPost = thisPost;
    if(!self.cssHTMLHeader) {
        NSString *path = [[NSBundle mainBundle] pathForResource:CSS_IMPORT_FILENAME ofType:@"html"];
        NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
        self.cssHTMLHeader = [[NSString alloc] initWithData: 
                              [readHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding]; 
    }
}

#pragma mark - View lifecycle support
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set the split view bar button item
    [self setSplitViewBarButtonItem:self.splitViewBarButtonItem];
    
    // if not coordinates in post, delete compass icon (last object)
    if (self.thisPost.latitude == 0 && self.thisPost.longitude == 0) {
        
        NSMutableArray *toolbar = [self.topToolbar.items mutableCopy];
        [toolbar removeLastObject];
        self.topToolbar.items = [toolbar copy];

    }
    
    // fix CRLFs & WP caption blocks so they show on in webview
    NSString *modifiedHTML = [self modifyAllCaptionBlocks:[self convertCRLFstoPtag:self.thisPost.postHTML]];
            
    // Load up the style list, and the title and append
    NSString *titleTags = [NSString stringWithFormat:@"<h3>%@</h3>",self.thisPost.postName];
    NSString *finalHTMLstring = [[self.cssHTMLHeader stringByAppendingString:titleTags] stringByAppendingString:modifiedHTML];
    
    // remove "compass" icon if coordinates are absent
    if (self.thisPost.latitude == 0 && self.thisPost.latitude == 0)
        self.topNavBar.rightBarButtonItem = Nil;
    
    //show webview
    [self.webView loadHTMLString:finalHTMLstring baseURL:nil];
    
    // save final html in instance var for sharing button
    self.loadedHTML = finalHTMLstring;                                  
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    // get rid of any left over popovers
    [self.infoPopover dismissPopoverAnimated:YES];
    
}

#pragma mark - Segue support

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Push Post Detail"]) {
        [segue.destinationViewController setPostDetail:self.thisPost];
        [segue.destinationViewController setDelegate:self];
        
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            self.infoPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
            [segue.destinationViewController setPopover:self.infoPopover];
        }
        self.detailsViewSeque = segue;
    } else if ([segue.identifier isEqualToString:@"Push Location Map"]) {
        [segue.destinationViewController setLocationRecord:self.thisPost];
    }
}

-(void)performSegueWhenInfoButtonPressed:(UIButton *)button {
    [self performSegueWithIdentifier:@"Push Post Detail" sender:self];
}

#pragma mark - Rotation Support

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *toolbarsItems = [self.topToolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarsItems removeObject:_splitViewBarButtonItem];
    if(barButtonItem) [toolbarsItems insertObject:barButtonItem atIndex:0];
    self.topToolbar.items = toolbarsItems;
    _splitViewBarButtonItem = barButtonItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else  
        return YES;
}

#pragma mark - Private methods

-(NSString *)grabTextFrom:(NSString *)incomingText
     viaRegularExpression:(NSString *)regexString {
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:incomingText options:NSMatchingReportProgress range:NSMakeRange(0, [incomingText length])];
    return [incomingText substringWithRange:result.range];
}

-(NSString *)modifyCaptionBlock:(NSString *)originalCaptionBlock {
    
    NSString *alignmentAttributeText;                                                   // location for storing "align=" value
    NSString *widthAttributeText;                                                       // location for storing "width=" value
    NSString *captionAttributeText;                                                     // location for storing "caption=" value
    NSString *captionText;                                                              // location for storing -></a>text[/caption]
    NSString *imageTag;                                                                 // location for storing "<img ... />" tag
    NSString *imageWidthOnTag;                                                          // width value on IMG tage
    
    imageTag = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"<img[^>]*>"];
    imageWidthOnTag = [self grabTextFrom:imageTag viaRegularExpression:@"(?<= width=\").*?(?=\")"];
    alignmentAttributeText = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"(?<= align=\").*?(?=\")"];
    // following not used, width on IMG tag used instead in case image has been resized
    widthAttributeText = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"(?<= width=\").*?(?=\")"];
    captionAttributeText = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"(?<= caption=\").*?(?=\")"];
    captionText = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"(?<=/>).*?(?=\\[/caption)"];
    
    return [[NSString alloc] initWithFormat:@"<div class=\"%@\" style=\"width:%@ px;font-size:80%%;text-align:center;\">%@%@</div>", alignmentAttributeText, imageWidthOnTag, imageTag, ([captionAttributeText length] != 0) ? captionAttributeText : captionText];
}

-(NSString *)convertCRLFstoPtag:(NSString *)incomingText {
    
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

-(NSString *)modifyAllCaptionBlocks:(NSString *)incomingText {
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

#pragma mark - Action sheets

#define BOOKMARKS_TITLE @"Bookmarks"
#define ADD_BUTTON      @"Add Bookmark"
#define REMOVE_BUTTON   @"Remove Bookmark"
#define SHARE_TITLE     @"Share"
#define EMAIL_BUTTON    @"Email"
#define TWEET_BUTTON    @"Tweet"
#define FACEBOOK_BUTTON @"Facebook"
#define SMS_BUTTON      @"Message"
#define CANCEL_BUTTON   @"Cancel"

-(void)presentActionSheetforBookmarkFromBarButton:(UIBarButtonItem *)button {
    
    // determine if post is currently in favorites
    NSMutableArray *favorites = [[[SharedUserDefaults sharedSingleton] getObjectWithKey:FAVORITES_KEY] mutableCopy];
    if (!favorites) favorites = [NSMutableArray array];
    
    UIActionSheet *actionSheet;
    
    if ([self.thisPost.bookmarked boolValue])              // is currently a favorite
        actionSheet = [[UIActionSheet alloc] initWithTitle:BOOKMARKS_TITLE delegate:self cancelButtonTitle:CANCEL_BUTTON destructiveButtonTitle:nil otherButtonTitles:REMOVE_BUTTON, nil];
    else 
        actionSheet = [[UIActionSheet alloc] initWithTitle:BOOKMARKS_TITLE delegate:self cancelButtonTitle:CANCEL_BUTTON destructiveButtonTitle:nil otherButtonTitles:ADD_BUTTON, nil];
    
    self.currentActionSheet = BOOKMARKS_TITLE;
    
    [actionSheet showFromBarButtonItem:button animated:YES]; 
}

-(void)presentActionSheetforSharingFromBarButton:(UIBarButtonItem *)button {
    
    NSString *reqSysVerForFB = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    UIActionSheet *actionSheet;
    
    if ([currSysVer compare:reqSysVerForFB options:NSNumericSearch] != NSOrderedAscending) {
        // if running on ios6 and above, include Facebook as an option
        actionSheet = [[UIActionSheet alloc] initWithTitle:SHARE_TITLE delegate:self cancelButtonTitle:CANCEL_BUTTON destructiveButtonTitle:nil otherButtonTitles: EMAIL_BUTTON, SMS_BUTTON, TWEET_BUTTON, FACEBOOK_BUTTON, nil];
    } else {
        // if running a version less than ios6, don't include Facebook
        actionSheet = [[UIActionSheet alloc] initWithTitle:SHARE_TITLE delegate:self cancelButtonTitle:CANCEL_BUTTON destructiveButtonTitle:nil otherButtonTitles: EMAIL_BUTTON, SMS_BUTTON, TWEET_BUTTON, nil];
    }
    
    self.currentActionSheet = SHARE_TITLE;
    [actionSheet showFromBarButtonItem:button animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
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

#pragma mark - Share post via e-mail

-(void)shareViaEmail {
    
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot send email" message:@"Unable to send email from this device. Make sure you have setup at least one email account" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Share post via Twitter

-(void)shareViaTweet {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetController setInitialText:self.thisPost.postName];
        [tweetController addImage:[UIImage imageWithData: self.thisPost.postIcon]];
        [tweetController addURL:[NSURL URLWithString:self.thisPost.postURLstring]];
        [self presentViewController:tweetController animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Tweet" message:@"Unable to send Tweet from this device. Make sure Tweeter is available and you have set up Tweeter with at least one account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Share post via Facebook

-(void)shareViaFacebook {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *facebookController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookController setInitialText:self.thisPost.postName];
        [facebookController addImage:[UIImage imageWithData:self.thisPost.postIcon]];
        [facebookController addURL:[NSURL URLWithString:self.thisPost.postURLstring]];
        
        [self presentViewController:facebookController animated:YES completion:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot post to Facebook" message:@"Unable to post to Facebook from this device. Make sure Facebook is available and you have set up Facebook with at least one account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Share post via Message (SMS)

-(void)shareViaMessage {
    
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.body = [NSString stringWithFormat:@"%@ - %@",self.thisPost.postName, self.thisPost.postURLstring];
        [self presentViewController:messageController animated:YES completion:nil];
        messageController.messageComposeDelegate = self;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot send Message (SMS)" message:@"Unable to send a Message (SMS) from this device. Make sure iOS Messages is set up and you have logged in."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - IBActions

- (IBAction)addToFavorites:(UIBarButtonItem *)sender {
    
    [self presentActionSheetforBookmarkFromBarButton:sender];
}

- (IBAction)sharePost:(UIBarButtonItem *)sender {
    [self presentActionSheetforSharingFromBarButton:sender];

}

- (IBAction)fireBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

 
#pragma mark - External Delegates
-(void)didClickTag:(NSString *)tag {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [[(UIStoryboardPopoverSegue*)self.detailsViewSeque popoverController] dismissPopoverAnimated:YES];
    else {
        [self.detailsViewSeque.destinationViewController dismissModalViewControllerAnimated:YES];
    }
    
    if (self.delegate)
        [self.delegate didClickTag:tag];
}

@end
