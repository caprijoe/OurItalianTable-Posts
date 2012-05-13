/*
     File: ParseOperation.m 
 Abstract: NSOperation code for parsing the RSS feed.
  
  Version: 1.2 
   
 */

#import "ParseOperation.h"
#import "postRecord.h"

// string contants found in the RSS feed
#define TOP_LEVEL_TAG                @"item"
    #define POST_TITLE_TAG                  @"title"
    #define POST_LINK_TAG                   @"link"
    #define POST_PUBLISH_DATE               @"pubDate"
    #define POST_AUTHOR_TAG                 @"dc:creator"
    #define POST_HTML_CONTENT_TAG           @"content:encoded"
    #define POST_GPS_COORDINATES_TAG        @"excerpt:encoded"
        #define POST_GPS_COORDINATES_FLAG       @"GPS: "
    #define POST_ID_NUM_TAG                 @"wp:post_id"
    #define POST_META_DATA_TAG              @"category"
        #define POST_META_DATA_TYPE_ATTR        @"domain"
            #define POST_META_DATA_CATEGORY         @"category"
            #define POST_META_DATA_POSTTAG          @"post_tag"
        #define POST_META_DATA_DESCRIPTION_ATTR @"nicename"
// close top level tag

@interface ParseOperation ()

// private properties
@property (nonatomic, strong) NSData *dataToParse;                      // XML data load in from disk
@property (nonatomic, strong) NSMutableArray *workingArray;             // array to accumulate parsed data
@property (nonatomic, strong) PostRecord *workingEntry;                 // current post being parsed
@property (nonatomic, strong) NSMutableString *workingPropertyString;
@property (nonatomic, strong) NSArray *elementsToParse;                 // XML tags to parse
@property BOOL storingCharacterData;
@end

@implementation ParseOperation

@synthesize dataToParse = _dataToParse;
@synthesize workingArray = _workingArray;
@synthesize workingEntry = _workingEntry;
@synthesize workingPropertyString = _workingPropertyString;
@synthesize elementsToParse = _elementsToParse;
@synthesize storingCharacterData = _storingCharacterData;
@synthesize delegate;


- (id)initWithData:(NSData *)data delegate:(id <ParseOperationDelegate>)theDelegate
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = data;
        self.delegate = theDelegate;
        self.elementsToParse = [NSArray arrayWithObjects:POST_LINK_TAG, POST_TITLE_TAG, POST_ID_NUM_TAG, POST_HTML_CONTENT_TAG, POST_AUTHOR_TAG, POST_PUBLISH_DATE, POST_META_DATA_TAG ,POST_GPS_COORDINATES_TAG, nil];
    }
    return self;
}

// -------------------------------------------------------------------------------
//	main:
//  Given data to parse, use NSXMLParser and process all the top paid apps.
// -------------------------------------------------------------------------------
- (void)main
{	
	self.workingArray = [NSMutableArray array];
    self.workingPropertyString = [NSMutableString string];
    
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not
	// desirable because it gives less control over the network, particularly in responding to
	// connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.dataToParse];
    
	[parser setDelegate:self];
    [parser parse];
	
	if (![self isCancelled])
    {
        // notify our AppDelegate that the parsing is complete
        [self.delegate didFinishParsing:self.workingArray];
    }
    
    self.workingArray = nil;
    self.workingPropertyString = nil;
    self.dataToParse = nil;
}


#pragma mark -
#pragma mark RSS processing

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
    }
    
    // set BOOL to YES if one of the element tags is found
    self.storingCharacterData = [self.elementsToParse containsObject:elementName];
    if (self.storingCharacterData)
    {
        NSString *attrContent = [attributeDict objectForKey:POST_META_DATA_DESCRIPTION_ATTR];
        
        // strip off attributes and contents if the self-contained meta data tag found
        if ([elementName isEqualToString:POST_META_DATA_TAG])
        {
            if ([[attributeDict objectForKey:POST_META_DATA_TYPE_ATTR] isEqualToString:POST_META_DATA_CATEGORY])
            {
                [self.workingEntry.postCategories addObject:attrContent];
            }
            else if ([[attributeDict objectForKey:POST_META_DATA_TYPE_ATTR] isEqualToString:POST_META_DATA_POSTTAG])
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
        if (self.storingCharacterData)
        {
            // created "trimmedString" from data accumulated between start and end tags
            NSString *trimmedString = [self.workingPropertyString stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            // clear the string for next time around
            [self.workingPropertyString setString:@""];  
            
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
                self.workingEntry.postID = trimmedString;
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
                self.workingEntry.postPubDate = trimmedString;
            }
            else if ([elementName isEqualToString:POST_GPS_COORDINATES_TAG])
            {
                // look for format "GPS: <float>,<float>", if found, load into coodinate
                NSRange where = [trimmedString rangeOfString:POST_GPS_COORDINATES_FLAG];
                if (where.location!= NSNotFound)
                {
                    NSArray *floats = [[trimmedString substringFromIndex:where.length] componentsSeparatedByString:@","];
                    self.workingEntry.coordinate = CLLocationCoordinate2DMake([[floats objectAtIndex:0] doubleValue], [[floats objectAtIndex:1] doubleValue]);
                }
            }
        }
        else if ([elementName isEqualToString:TOP_LEVEL_TAG])
        // if top level tag end found, reset everything for next time around
        {
            [self.workingArray addObject:self.workingEntry];  
            self.workingEntry = nil;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.storingCharacterData)
    {
        [self.workingPropertyString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [delegate parseErrorOccurred:parseError];
}

@end
