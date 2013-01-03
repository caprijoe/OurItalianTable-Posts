//
//  BundleFillDatabaseFromXMLParser.m
//  OurItalianTable Posts
//
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import "BundleFillDatabaseFromXMLParser.h"

@interface BundleFillDatabaseFromXMLParser ()
@property (nonatomic, strong) NSOperationQueue *queue;                                  // queue for XML parsing
@property (nonatomic, strong) NSManagedObjectContext *parentMOC;                        // core DB file
@property (nonatomic, strong) ParseWordPressXML *parser;                                // object for XML parser
@property (nonatomic, strong) id<BundleFillDatabaseFromXMLParserDelegate> delegate;     // callback delegate for this class
@end

@implementation BundleFillDatabaseFromXMLParser

#pragma mark - init method

-(id)initWithURL:(NSURL *)url
  usingParentMOC:(NSManagedObjectContext *)parentMOC
    withDelegate:(id <BundleFillDatabaseFromXMLParserDelegate>)delegate {
    
    self = [super init];
    if (self) {
        
        // store ivars needed at init
        self.parentMOC = parentMOC;
        self.delegate = delegate;
        
        // get XML posts file from bundle
        NSData *XMLFile = [[NSData alloc] initWithContentsOfURL:url];
        
        // Crash if bundle file not found
        NSAssert(XMLFile, @"Can't locate bundle file");
        
        // create the queue to run our ParseOperation
        self.queue = [[NSOperationQueue alloc] init];
        
        // create a parser from the ParseWordPressXML class and add to an NSOperationQueue, will call back when done
        self.parser = [[ParseWordPressXML alloc] initWithData:XMLFile usingParentMOC:self.parentMOC withDelegate:self];
        [self.queue addOperation:self.parser];
    }
    
    return self;
}

#pragma mark - External Delegates - ParseWordPressXML

- (void)didFinishParsing
{
    // release parser object
    self.parser = nil;
        
    // callback to called signaling DONE
    [self.delegate doneFillingFromBundle];
}

- (void)parseErrorOccurred:(NSError *)error {
// do nothing
}

@end