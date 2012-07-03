//
//  webViewController.m
//  oitWebViewController
//
//  Created by Joseph Becci on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "webViewController.h"
#import "PostDetailViewController.h"

#define FAVORITES_KEY       @"FAVORITES_KEY"
#define CSS_IMPORT_FILENAME @"oitHTMLStyles"
#define DOUBLE_QUOTE_CHAR   @"\""
#define IMAGE_SCALE         .95

@interface WebViewController() <PostsDetailViewControllerDelegate>;
@property (nonatomic,strong) NSString *cssHTMLHeader;                   // CSS Header to be stuck in front of HTML
@property (nonatomic,strong) UIStoryboardSegue* detailsViewSeque;       // saved segue for return from "Details" button
@property (nonatomic,strong) NSString *loadedHTML;                      // HTML code that was loaded -- for e-mailing
@end

@implementation WebViewController
@synthesize favoritesButton = _favoritesButton;
@synthesize webView = _webView;
@synthesize postRecord = _postRecord;
@synthesize cssHTMLHeader =_cssHTMLHeader;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize rootPopoverButtonItem = _rootPopoverButtonItem;
@synthesize toolbar = _toolbar;
@synthesize delegate = _delegate;
@synthesize detailsViewSeque = _detailsViewSeque;
@synthesize loadedHTML = _loadedHTML;

#pragma mark - Setter
-(void)setPostRecord:(PostRecord *)postRecord
{
    _postRecord = postRecord;
    if(!self.cssHTMLHeader) {
        NSString *path = [[NSBundle mainBundle] pathForResource:CSS_IMPORT_FILENAME ofType:@"html"];
        NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
        self.cssHTMLHeader = [[NSString alloc] initWithData: 
                              [readHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding]; 
    }
}

#pragma mark - Private methods

-(NSString *)grabTextFrom:(NSString *)incomingText
 viaRegularExpression:(NSString *)regexString {
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:incomingText options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, [incomingText length])];
    return [incomingText substringWithRange:result.range];
}

-(NSString *)modifyCaptionBlock:(NSString *)originalCaptionBlock {
    
    NSString *alignmentAttributeText;                                                   // location for storing "align=" value
    NSString *widthAttributeText;                                                       // location for storing "width=" value
    NSString *captionAttributeText;                                                     // location for storing "caption=" value
    NSString *captionText;                                                              // location for storing -></a>text[/caption]
    NSString *imageTag;                                                                 // location for storing "<img ... />" tag
    
    imageTag = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"<img[^>]*>"];
    alignmentAttributeText = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"(?<= align=\").*?(?=\")"];
    widthAttributeText = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"(?<= width=\").*?(?=\")"];
    captionAttributeText = [self grabTextFrom:originalCaptionBlock viaRegularExpression:@"(?<= caption=\").*?(?=\")"];
    captionText =[self grabTextFrom:originalCaptionBlock viaRegularExpression:@"(?<=/>).*?(?=\\[/caption)"];
        
    return [[NSString alloc] initWithFormat:@"<div class=\"%@\" style=\"width:%@ px;font-size:80%%;text-align:center;\">%@%@</div>", alignmentAttributeText, captionAttributeText,imageTag, ([captionAttributeText length] != 0) ? captionAttributeText : captionText];
}

-(NSString *)convertCRLFstoPtag:(NSString *)incomingText {
    return [incomingText stringByReplacingOccurrencesOfString:@"\x0D\x0A\x0D\x0A" withString:@"<p>\x0D\x0A"];
}

-(NSString *)modifyAllCaptionBlocks:(NSString *)incomingText {
    // captionScanner - edit the caption to true <div> structures; change WP to div. see example below
    
    /* [caption id="attachment_156" align="alignleft" width="300" caption="Zuppa Gallurese"]<a href="http://ouritaliantable.files.wordpress.com/2008/08/zuppagallurese-031.jpg"><img class="size-medium wp-image-156" src="http://ouritaliantable.files.wordpress.com/2008/08/zuppagallurese-031.jpg?w=300" alt="Zuppa Gallurese" width="300" height="199" /></a>[/caption] */
    
    /* <div class="alignleft" style="width:300 px;font-size:80%;text-align:center;"><img class="size-medium wp-image-156" src="http://ouritaliantable.files.wordpress.com/2008/08/zuppagallurese-031.jpg?w=300" alt="Zuppa Gallurese" width="300" height="199" />Zuppa Gallurese</div> */
    
    NSScanner *captionScanner = [NSScanner scannerWithString:incomingText];
    NSString *accumulatedHTML = [[NSString alloc] init];                            // location for building new html with replaced [catpion] structure
    NSString *foundString;                                                          // location for text between "[caption]" blocks
    NSString *captionBlock;
    
    [captionScanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    
    [captionScanner scanUpToString:@"[caption" intoString:&accumulatedHTML];
    while(![captionScanner isAtEnd]) {
        
        [captionScanner scanUpToString:@"[/caption]" intoString:&captionBlock];        
        [captionScanner scanString:@"[/caption]" intoString:NULL];
        captionBlock = [captionBlock stringByAppendingString:@"[/caption]"];
        
        accumulatedHTML = [accumulatedHTML stringByAppendingString:[self modifyCaptionBlock:captionBlock]];
        
        [captionScanner scanUpToString:@"[caption" intoString:&foundString];
        accumulatedHTML = [accumulatedHTML stringByAppendingString:foundString];        
    }
    return accumulatedHTML;
}

#pragma mark - View lifecycle support
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // load if this is a "favorities" post from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if ([favorites containsObject:self.postRecord.postID]) 
        self.favoritesButton.title = @"Remove from Favorites";
    else 
        self.favoritesButton.title = @"Add to Favorities";
    
    // self button for detail splitViewController when in portrait
    [self setSplitViewBarButtonItem:self.rootPopoverButtonItem];

    NSString *accumulatedHTML = [self modifyAllCaptionBlocks:[self convertCRLFstoPtag:self.postRecord.postHTML]];
    
    // img tag width and height if picture too big (usually for iPhone)
    // <img .... width="300" height="199" .. />
    int maxWidth = self.webView.scrollView.frame.size.width;
    
    NSString *regexPattern = @"<img[^>]*width=['\"\\s]*([0-9]+)[^>]*height=['\"\\s]*([0-9]+)[^>]*>";
    
    NSRegularExpression *regex = 
    [NSRegularExpression regularExpressionWithPattern:regexPattern 
                                              options:NSRegularExpressionDotMatchesLineSeparators 
                                                error:nil];
    
    NSMutableString *modifiedHTML = [NSMutableString stringWithString:accumulatedHTML];
    
    NSArray *matchesArray = [regex matchesInString:modifiedHTML 
                                           options:NSRegularExpressionCaseInsensitive 
                                             range:NSMakeRange(0, [modifiedHTML length]) ]; 
    
    NSTextCheckingResult *match;
    
    // need to calculate offset because range position of matches
    // within the HTML string will change after we modify the string
    int offset = 0, newoffset = 0;
    
    for (match in matchesArray) {
        
        NSRange widthRange = [match rangeAtIndex:1];
        NSRange heightRange = [match rangeAtIndex:2];
        
        widthRange.location += offset;
        heightRange.location += offset;
        
        NSString *widthStr = [modifiedHTML substringWithRange:widthRange];
        NSString *heightStr = [modifiedHTML substringWithRange:heightRange];
        
        int width = [widthStr intValue];
        int height = [heightStr intValue];
        
        if (width > maxWidth) {
            height = (height * maxWidth) / width * IMAGE_SCALE;
            width = maxWidth * IMAGE_SCALE;
            
            NSString *newWidthStr = [NSString stringWithFormat:@"%d", width];
            NSString *newHeightStr = [NSString stringWithFormat:@"%d", height];
            
            [modifiedHTML replaceCharactersInRange:widthRange withString:newWidthStr];
            
            newoffset = ([newWidthStr length] - [widthStr length]);
            heightRange.location += newoffset;
            
            [modifiedHTML replaceCharactersInRange:heightRange withString:newHeightStr];                
            
            newoffset += ([newHeightStr length] - [heightStr length]);            
            offset += newoffset;
        }
    }
    
    // Load up the style list, and the title and append
    NSString *titleTags = [NSString stringWithFormat:@"<h3>%@</h3>",self.postRecord.postName];
    
    NSString *finalHTMLstring = [[self.cssHTMLHeader stringByAppendingString:titleTags] stringByAppendingString:modifiedHTML];   
    
    //show webview
    
    [self.webView loadHTMLString:finalHTMLstring baseURL:nil];
    self.loadedHTML = finalHTMLstring;
}

- (void)viewDidUnload {
    [self setFavoritesButton:nil];
    [super viewDidUnload];
}

#pragma mark - Segue support

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Push Post Detail"]) {
        [segue.destinationViewController setPostDetail:self.postRecord];
        [segue.destinationViewController setDelegate:self];
        self.detailsViewSeque = segue;
    }
}

#pragma mark - Rotation Support

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem !=splitViewBarButtonItem) {
        NSMutableArray *toolbarsItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarsItems removeObject:_splitViewBarButtonItem];
        if(splitViewBarButtonItem) [toolbarsItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarsItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else  
        return YES;
}

#pragma mark - IBActions

- (IBAction)addToFavorites:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if (!favorites) favorites = [NSMutableArray array];
    if ([favorites containsObject:self.postRecord.postID]) {
        self.favoritesButton.title = @"Add to Favorities";
        [favorites removeObject:self.postRecord.postID];
    } else {
        self.favoritesButton.title = @"Remove from Favorites";
        [favorites addObject:self.postRecord.postID];
    }
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    [defaults synchronize];
}

- (IBAction)forwardPost:(id)sender {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:[NSString stringWithFormat:@"From Our Italian Table - %@",self.postRecord.postName]];
        
        UIImage *oitLogo = [UIImage imageNamed:@"oitIcon-57x57.png"];
        NSData *imageData = UIImagePNGRepresentation(oitLogo);
        [mailer addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"Our Italian Table Logo"];
        
        [mailer setMessageBody:self.loadedHTML isHTML:YES];
        
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:mailer animated:YES];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" 
                                                        message:@"Your device does not support e-mail" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
}


-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}
 
#pragma mark - Delegates
-(void)postsDetailViewController:(PostDetailViewController *)sender choseTag:(id)tag {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [[(UIStoryboardPopoverSegue*)self.detailsViewSeque popoverController] dismissPopoverAnimated:YES];
    else {
        [self.detailsViewSeque.destinationViewController dismissModalViewControllerAnimated:YES];
    }
    
    [self.delegate webViewController:self chosetag:tag]; 
}

@end
