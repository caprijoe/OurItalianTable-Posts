//
//  FillDatabaseFromXMLParser.m
//  ASBH
//
//  Created by Joseph Becci on 9/1/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#define REMOTE_LAST_MODIFIED_KEY        @"Last-Modified"

#import "RemoteFillDatabaseFromXMLParser.h"

@interface RemoteFillDatabaseFromXMLParser ()
@property (nonatomic, strong) NSOperationQueue *queue;                          // queue for XML parsing
@property (nonatomic, strong) UIManagedDocument *databaseDocument;              // core DB file
@property (nonatomic, strong) GetFileFromRemoteURL *fileGetter;                 // object for remote file getter
@property (nonatomic, strong) ParseWordPressXML *parser;                        // object for XML parser
@property (nonatomic, strong) id<RemoteFillDatabaseFromXMLParserDelegate> delegate;   // callback delegate for this class 
@property (nonatomic, strong) NSString *lastUpdateStringtoSave;                 // date of last update, if not-nil -> save in NSUserDefaults
@end

@implementation RemoteFillDatabaseFromXMLParser

#pragma mark - Init method

-(id)initWithURL:(NSURL *)url intoDatabase:(UIManagedDocument *)database withDelegate:(id<RemoteFillDatabaseFromXMLParserDelegate>)delegate {
    
    // store ivars needed at init
    self.databaseDocument = database;
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
        
        // create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
        // "ownership of appListData has been transferred to the parse operation and should no longer be
        // referenced in this thread.
        //
        self.parser = [[ParseWordPressXML alloc] initWithData:XMLfile intoDatabase:self.databaseDocument withDelegate:self];
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
//    NSAssert(NO, @"Parse operation failed");
}

@end