//
//  ParseWordPressXML.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 11/16/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#define BATCH_SAVE_COUNT 50

#import "ParseWordPressXML.h"
#import "PostRecord.h"
#import "Post+Create.h"
#import "AppDelegate.h"

@interface ParseWordPressXML ()

// private properties
@property (nonatomic, strong) NSMutableSet *candidateGeos;
@property (nonatomic, strong) NSData *dataToParse;                      // XML data load in from disk
@property (nonatomic, strong) PostRecord *workingEntry;                 // current post being parsed
@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) NSString *workingPropertyString;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *elementsToParse;                 // XML tags to parse
@property                     BOOL storingElementOfInterest;
@property (nonatomic, strong) NSManagedObjectContext *parentMOC;
@property (nonatomic, strong) NSManagedObjectContext *backgroundMOC;
@property (nonatomic, weak) id <ParseWordPressXMLDelegate> delegate;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property                     BOOL inGPSTag;
@property                     BOOL postTypeOfPost;
@property                     BOOL postStatusOfPublish;
@property                     int postCount;

@end

@implementation ParseWordPressXML
@synthesize delegate;

#pragma mark - Init method

- (id)initWithData:(NSData *)data
    usingParentMOC:(NSManagedObjectContext *)parentMOC
      withDelegate:(id <ParseWordPressXMLDelegate>)theDelegate;
{
    self = [super init];
    if (self != nil)
    {
        // save key init parms for when "main" starts
        self.dataToParse = data;
        self.delegate = theDelegate;
        self.parentMOC = parentMOC;
        
        // set the app delegate for accessing shared methods
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // setup date formatter
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [self.dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];

        
        // set "global" variables
        self.storingElementOfInterest = NO;
                
        // set up the XML elements that will be parsed
        self.elementsToParse = @[POST_LINK_TAG, POST_TITLE_TAG, POST_ID_NUM_TAG, POST_HTML_CONTENT_TAG, POST_AUTHOR_TAG, POST_PUBLISH_DATE, POST_CATEGORY_TAG ,POST_META_KEY, POST_META_VALUE, POST_TYPE, POST_STATUS];
    }
    return self;
}

// override point for NSOperation

- (void)main
{
    
    // setup the MOC for background processing - this must be done in the "main" method which is in the background thread
    self.backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.backgroundMOC.parentContext = self.parentMOC;
    
    [self.backgroundMOC performBlock:^{
        
        // setup the XML parser
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.dataToParse];
        
        // set it's delegate to this method and start it
        [parser setDelegate:self];
        [parser parse];
        
        if (![self isCancelled])
        {
            // save everything
            [self saveWhenReady:0];
            
            // notify our AppDelegate that the parsing is complete
            [self.delegate didFinishParsing];
        } 
        
        self.workingPropertyString = nil;
        self.dataToParse = nil;
        
    }];
}

#pragma mark - Private methods
-(void)saveWhenReady:(int)postCount {
    
    // save when postCount == 0 || divisable by constant
    if (!postCount || !(postCount % BATCH_SAVE_COUNT)) {
        // push to parent
        NSError *error;
        if (![self.backgroundMOC save:&error])
        {
            // handle error
            NSLog(@"error saving background MOC = %@",error);
        }
        
        // save parent to disk asynchronously
        [self.backgroundMOC.parentContext performBlock:^{
            NSError *error;
            if (![self.parentMOC save:&error])
            {
                // handle error
                NSLog(@"error saving parent MOC = %@",error);
                
            }
        }];
    }
}

-(void)storeAwayCategoriesAndTagsFromDict:attributeDict {
    
    // category tag example --
    // <category domain="category" nicename="food">
    // <category domain="post_tag" nicename="pasta">
    
    // if domain == category, process
    if ([attributeDict[@"domain"] isEqualToString:@"category"])
    {
        // store the category away for if this is a real post
        [self.workingEntry.postCategories addObject:attributeDict[@"nicename"]];
        
        // if this is a valid geo, store away
        if(self.appDelegate.candidateGeoSlugs[attributeDict[@"nicename"]])
            self.workingEntry.geo = self.appDelegate.candidateGeoSlugs[attributeDict[@"nicename"]];
                
    }
    // if domain == post_tag, process
    else if ([attributeDict[@"domain"] isEqualToString:@"post_tag"])
    {
        // store the tag away for if this is a real post
        [self.workingEntry.postTags addObject:attributeDict[@"nicename"]];
    }
}

-(void)storeAwayElement:elementName usingString:trimmedString {
    
    // look for specific end element and store the data away
    if ([elementName isEqualToString:POST_TYPE]) {
        if ([trimmedString isEqualToString:@"post"])
            self.postTypeOfPost = YES;
        else
            self.postTypeOfPost = NO;
    }
    else if ([elementName isEqualToString:POST_LINK_TAG])
    {
        self.workingEntry.postURLString = trimmedString;
    }
    else if ([elementName isEqualToString:POST_TITLE_TAG])
    {
        self.workingEntry.postName = trimmedString;
    }
    else if ([elementName isEqualToString:POST_ID_NUM_TAG])
    {
        int i = [trimmedString intValue];
        self.workingEntry.postID = [NSNumber numberWithInt: i];
    }
    else if ([elementName isEqualToString:POST_AUTHOR_TAG])
    {
        self.workingEntry.postAuthor = trimmedString;
    }
    else if ([elementName isEqualToString:POST_HTML_CONTENT_TAG])
    {
        // Look for the src= attribute (should only be on IMG tag
        NSRange attributeMatch = [trimmedString rangeOfString:@" src=\""];
        
        if (attributeMatch.location != NSNotFound) {
            
            // set up new search range (right after src=" to EOL) - start of URL is urlSearch.location
            NSRange urlSearch = {attributeMatch.location + attributeMatch.length,[trimmedString length] - (attributeMatch.location + attributeMatch.length)};
            
            // look for the end quote
            NSRange urlMatch = [trimmedString rangeOfString:@"\"" options:0 range:urlSearch];
            
            // pull out the URL
            NSString *tempURLString = [trimmedString substringWithRange:NSMakeRange(urlSearch.location, urlMatch.location - urlSearch.location)];
            
            // strip off "?w=" from URL
            NSRange range = [tempURLString rangeOfString:@"?w="];
            if (range.location != NSNotFound) {
                tempURLString = [tempURLString substringToIndex:range.location];
            }
            
            self.workingEntry.imageURLString = tempURLString;
            self.workingEntry.postHTML = trimmedString;
        }
    }
    else if ([elementName isEqualToString:POST_PUBLISH_DATE])
    {
        self.workingEntry.postPubDate = [self.dateFormatter dateFromString:trimmedString];
        
    }
    else if([elementName isEqualToString:POST_STATUS]) {
        if ([trimmedString isEqualToString:@"publish"])
            self.postStatusOfPublish = YES;
        else
            self.postStatusOfPublish = NO;
    }
    else if ([elementName isEqualToString:POST_META_KEY]) {
        if ([trimmedString isEqualToString:@"gps_coordinates"]) {
            self.inGPSTag = YES;
        }
    }
    else if ([elementName isEqualToString:POST_META_VALUE]) {
        if (self.inGPSTag) {
            self.inGPSTag = NO;
            NSArray *floats = [trimmedString componentsSeparatedByString:@","];
            if ([floats count] == 2) {
                self.workingEntry.latitude = [NSNumber numberWithFloat:[floats[0] floatValue]];
                self.workingEntry.longitude = [NSNumber numberWithFloat:[floats[1] floatValue]];
            }
        }
    }    
}


#pragma mark - NSXMLParser processing delegates

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                       qualifiedName:(NSString *)qName
                                          attributes:(NSDictionary *)attributeDict
{
    // if we at start of new segment, reset tracking properties
    if ([elementName isEqualToString:TOP_LEVEL_TAG])
	{
        self.workingEntry = [[PostRecord alloc] init];
        self.workingEntry.postCategories = [[NSMutableArray alloc] init];
        self.workingEntry.postTags = [[NSMutableArray alloc] init];
        self.workingEntry.geo = @"elsewhere";

        // assume this is a post and published until we find otherwise
        self.postTypeOfPost = YES;
        self.postStatusOfPublish = YES;

    }
    
    // set BOOL to YES if one of the element tags is found
    self.storingElementOfInterest = [self.elementsToParse containsObject:elementName];
    if (self.storingElementOfInterest)
    {
        // clear out string for capture of this element
        self.workingPropertyString = [NSString string];
                        
        // if domain == category, process
        if ([elementName isEqualToString:POST_CATEGORY_TAG])
            [self storeAwayCategoriesAndTagsFromDict:attributeDict];

    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (self.workingEntry && self.postTypeOfPost && self.postStatusOfPublish)
	{
        if (self.storingElementOfInterest)
        {
            // created "trimmedString" from data accumulated between start and end tags
            NSString *trimmedString = [self.workingPropertyString stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            // reset storingElementOfInterest for inspection of next go around
            self.storingElementOfInterest = NO;
            
            // store away trimmed string to the element that matches it.... multiple ivars accessed in this method
            [self storeAwayElement:elementName usingString:trimmedString];
            
        }
        else if ([elementName isEqualToString:TOP_LEVEL_TAG])
        // if top level tag end found, reset everything for next time around
        {
            
            // should only have gotten here if this is a real post and published .. save it...
            [Post createPostwithPostRecord:self.workingEntry inManagedObjectContext:self.backgroundMOC];
            [self saveWhenReady:++self.postCount];
            
            // hit end tag so clear for next trip with top level tag
            self.workingEntry = nil;
            
        } else {
            // found a tag we don't care about .. do nothing
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.workingEntry && self.storingElementOfInterest)
    {
        self.workingPropertyString = [self.workingPropertyString stringByAppendingString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [delegate parseErrorOccurred:parseError];
}

@end
