//
//  RemoteFillDatabaseFromXMLParser.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 9/1/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#define REMOTE_LAST_MODIFIED_KEY        @"Last-Modified"

#import "RemoteFillDatabaseFromXMLParser.h"

@interface RemoteFillDatabaseFromXMLParser ()
@property (nonatomic, strong) NSOperationQueue *queue;                          // queue for XML parsing
@property (nonatomic, strong) NSManagedObjectContext *parentMOC;              // core DB file
@property (nonatomic, strong) GetFileFromRemoteURL *fileGetter;                 // object for remote file getter
@property (nonatomic, strong) ParseWordPressXML *parser;                        // object for XML parser
@property (nonatomic, strong) id<RemoteFillDatabaseFromXMLParserDelegate> delegate;   // callback delegate for this class 
@property (nonatomic, strong) NSString *lastUpdateStringtoSave;                 // date of last update, if not-nil -> save in NSUserDefaults
@end

@implementation RemoteFillDatabaseFromXMLParser

#pragma mark - Init method

-(id)initWithURL:(NSURL *)url
  usingParentMOC:(NSManagedObjectContext *)parentMOC
    withDelegate:(id<RemoteFillDatabaseFromXMLParserDelegate>)delegate {
    
    // store ivars needed at init
    self.parentMOC = parentMOC;
    self.delegate = delegate;
    
    // launch the filegetter - must be on main thread because it's using NSURLConnection
    dispatch_async(dispatch_get_main_queue(), ^{
        self.fileGetter = [[GetFileFromRemoteURL alloc] initWithURL:url withDelegate:self];
    });
    
    return self;
}

#pragma mark - External delegates - GetFileFromRemoteURL

-(void)didReturnRemoteFillDate:(NSString*)remoteDateString {
    
    self.lastUpdateStringtoSave = remoteDateString;
    
}

-(void)didFinishLoadingURL:(NSData *)XMLfile withSuccess:(BOOL)success {
    
    // release URL connection object
    self.fileGetter = nil;
    
    if (success) {
        
        // create the queue to run our ParseOperation
        self.queue = [[NSOperationQueue alloc] init];
        
        // create a parser from the ParseWordPressXML class and add to an NSOperationQueue, will call back when done
        self.parser = [[ParseWordPressXML alloc] initWithData:XMLfile usingParentMOC:self.parentMOC withDelegate:self];
        [self.queue addOperation:self.parser];
        
    } else
        
        [self didFinishParsing];
}

#pragma mark - External Delegates - ParseWordPressXML

- (void)didFinishParsing
{
    // release parser object
    self.parser = nil;
    
    // if a new file was successfully download and parsed, save new date into NSUserDefaults
    if (self.lastUpdateStringtoSave) {
        
        // finished parsing sucessfully, update NSUserDefaults with last update date
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.lastUpdateStringtoSave forKey:REMOTE_LAST_MODIFIED_KEY];
        [defaults synchronize];
        
    }
    
    // callback to called signaling DONE
    [self.delegate doneFillingFromRemote];
}

- (void)parseErrorOccurred:(NSError *)error {
// do nothing
}

@end