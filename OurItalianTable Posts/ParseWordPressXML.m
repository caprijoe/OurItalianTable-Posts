//
//  ParseWordPressXML.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 11/16/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import "ParseWordPressXML.h"
#import "GetFileFromRemoteURL.h"
#import "PostRecord.h"
#import "Post+Create.h"
#import "AppDelegate.h"

@interface ParseWordPressXML ()

// private properties
@property (nonatomic, strong) NSMutableSet *candidateGeos;
@property (nonatomic, strong) NSData *dataToParse;                      // XML data load in from disk
@property (nonatomic, strong) PostRecord *workingEntry;                 // current post being parsed
@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) NSMutableString *workingPropertyString;
@property (nonatomic, strong) NSArray *elementsToParse;                 // XML tags to parse
@property                     BOOL storingElementOfInterest;
@property (nonatomic, strong) UIManagedDocument *database;
@property (nonatomic, strong) NSManagedObjectContext *backgroundMOC;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, weak) id <ParseWordPressXMLDelegate> delegate;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation ParseWordPressXML
@synthesize delegate;

#pragma mark - Init method

- (id)initWithData:(NSData *)data
      intoDatabase:(UIManagedDocument *)database
      withDelegate:(id <ParseWordPressXMLDelegate>)theDelegate;
{
    self = [super init];
    if (self != nil)
    {
        // save key init parms for when "main" starts
        self.dataToParse = data;
        self.delegate = theDelegate;
        self.database = database;
        
        // set the app delegate for accessing shared methods
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // set "global" variables
        self.workingPropertyString = [NSMutableString string];
        self.storingElementOfInterest = NO;
        
        // setup date formatter
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ssss zzz"];
        
        // load and sort candidate regions and islands
        self.candidateGeos = [NSMutableSet set];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CategoryDictionary" ofType:@"plist"];
        [self.candidateGeos addObjectsFromArray:[[[NSDictionary alloc] initWithContentsOfFile:filePath][@"Regions of Italy"] allKeys]];
        [self.candidateGeos addObjectsFromArray:[[[NSDictionary alloc] initWithContentsOfFile:filePath][@"Islands"] allKeys]];
        
        // set up the XML elements that will be parsed
        self.elementsToParse = @[POST_LINK_TAG, POST_TITLE_TAG, POST_ID_NUM_TAG, POST_HTML_CONTENT_TAG, POST_AUTHOR_TAG, POST_PUBLISH_DATE, POST_META_DATA_TAG ,POST_GPS_COORDINATES_TAG];
    }
    return self;
}

-(void)mergeChanges:(NSNotification *)notification {
    NSManagedObjectContext *mainMoc = self.database.managedObjectContext;
    [mainMoc performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
}

// override point for NSOperation

- (void)main
{
    
    // setup the MOC for background processing - this must be done in the "main" method which is in the background thread
    self.backgroundMOC = [[NSManagedObjectContext alloc] init];
    [self.backgroundMOC setPersistentStoreCoordinator:[self.database.managedObjectContext persistentStoreCoordinator]];
        
    // setup the XML parser
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.dataToParse];
    
    // set it's delegate to this method and start it
	[parser setDelegate:self];
    [parser parse];
	
	if (![self isCancelled])
    {
        [self.backgroundMOC save:NULL];
        
        // notify our AppDelegate that the parsing is complete
        [self.delegate didFinishParsing];
    } 
    
    self.workingPropertyString = nil;
    self.dataToParse = nil;
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
    }
    
    // set BOOL to YES if one of the element tags is found
    self.storingElementOfInterest = [self.elementsToParse containsObject:elementName];
    if (self.storingElementOfInterest)
    {
        NSString *attrContent = attributeDict[POST_META_DATA_DESCRIPTION_ATTR];
        
        // strip off attributes and contents if the self-contained meta data tag found
        if ([elementName isEqualToString:POST_META_DATA_TAG])
        {
            if ([attributeDict[POST_META_DATA_TYPE_ATTR] isEqualToString:POST_META_DATA_CATEGORY])
            {
                [self.workingEntry.postCategories addObject:attrContent];
                
                [self.candidateGeos enumerateObjectsUsingBlock:^(id geo, BOOL *stop) {
                    
                    NSRange range = [attrContent rangeOfString:[self.appDelegate fixCategory:geo]];
                    if (range.location != NSNotFound) {
                        self.workingEntry.geo = geo;
                        *stop = YES;
                    }
                
                }];
            }
            else if ([attributeDict[POST_META_DATA_TYPE_ATTR] isEqualToString:POST_META_DATA_POSTTAG])
            {
                [self.workingEntry.postTags addObject:attrContent];
            } 
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (self.workingEntry)
	{
        if (self.storingElementOfInterest)
        {
            // created "trimmedString" from data accumulated between start and end tags
            NSString *trimmedString = [self.workingPropertyString stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            // clear the string for next time around
            [self.workingPropertyString setString:@""];
            self.storingElementOfInterest = NO;
            
            // look for specific end element and store the data away
            if ([elementName isEqualToString:POST_LINK_TAG])
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
                self.workingEntry.postID = i;
            }
            else if ([elementName isEqualToString:POST_AUTHOR_TAG])
            {
                self.workingEntry.postAuthor = trimmedString;
            }
            else if ([elementName isEqualToString:POST_HTML_CONTENT_TAG])
            {
                // look for first -->scr="image url"<-- in the HTML
                NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(?<= src=\").*?(?=\")" options:NSRegularExpressionCaseInsensitive error:nil];
                NSTextCheckingResult *match = [regex firstMatchInString:trimmedString options:0 range:NSMakeRange(0, [trimmedString length])];
                
                if  (match)
                {
                    self.workingEntry.imageURLString = [trimmedString substringWithRange:match.range];
                    self.workingEntry.postHTML = trimmedString;
                }
            }
            else if ([elementName isEqualToString:POST_PUBLISH_DATE])
            {
                NSDate *pubDate = [self.dateFormatter dateFromString:trimmedString];
                self.workingEntry.postPubDate = [pubDate timeIntervalSinceReferenceDate];
            }
            else if ([elementName isEqualToString:POST_GPS_COORDINATES_TAG])
            {
                // look for format "GPS: <float>,<float>", if found, load into coodinate
                NSRange where = [trimmedString rangeOfString:POST_GPS_COORDINATES_FLAG];
                if (where.location!= NSNotFound)
                {
                    NSArray *floats = [[trimmedString substringFromIndex:where.length] componentsSeparatedByString:@","];
                    self.workingEntry.latitude = [floats[0] doubleValue];
                    self.workingEntry.longitude = [floats[1] doubleValue];
                }
            }
        }
        else if ([elementName isEqualToString:TOP_LEVEL_TAG])
        // if top level tag end found, reset everything for next time around
        {
            [Post createPostwithPostRecord:self.workingEntry
                    inManagedObjectContext:self.backgroundMOC];
            self.workingEntry = nil;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.workingEntry && self.storingElementOfInterest)
    {
        [self.workingPropertyString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [delegate parseErrorOccurred:parseError];
}

@end
