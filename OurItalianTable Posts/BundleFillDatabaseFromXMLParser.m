//
//  BundleFillDatabaseFromXMLParser.m
//
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import "BundleFillDatabaseFromXMLParser.h"

@interface BundleFillDatabaseFromXMLParser ()
@property (nonatomic, strong) NSOperationQueue *queue;                          // queue for XML parsing
@property (nonatomic, strong) UIManagedDocument *databaseDocument;              // core DB file
@property (nonatomic, strong) ParseWordPressXML *parser;                        // object for XML parser
@property (nonatomic, strong) id<BundleFillDatabaseFromXMLParserDelegate> delegate;   // callback delegate for this class
@end

@implementation BundleFillDatabaseFromXMLParser

#pragma mark - init method

-(id)initWithURL:(NSURL *)url intoDatabase:(UIManagedDocument *)database withDelegate:(id <BundleFillDatabaseFromXMLParserDelegate>)delegate; {
    
    // store ivars needed at init
    self.databaseDocument = database;
    self.delegate = delegate;
    
    // get XML posts file from bundle
    NSData *XMLFile = [[NSData alloc] initWithContentsOfURL:url];
    
    // Crash if bundle file not found
    NSAssert(XMLFile, @"Can't locate bundle file");
    
    // create the queue to run our ParseOperation
    self.queue = [[NSOperationQueue alloc] init];
    
    // create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
    // "ownership of appListData has been transferred to the parse operation and should no longer be
    // referenced in this thread.
    //
    self.parser = [[ParseWordPressXML alloc] initWithData:XMLFile intoDatabase:self.databaseDocument withDelegate:self];
    [self.queue addOperation:self.parser];
    
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
//    NSAssert(NO, @"Parse operation failed");
}

@end