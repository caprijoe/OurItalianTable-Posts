//
//  RemoteFillDatabaseFromXMLParser.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 9/1/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#define LAST_UPDATE_TO_CORE_DB  @"LAST_UPDATE_TO_CORE_DB_DATE"

#import "RemoteFillDatabaseFromXMLParser.h"

@interface RemoteFillDatabaseFromXMLParser ()
@property (nonatomic, strong) NSOperationQueue *queue;                          // queue for XML parsing
@property (nonatomic, strong) NSManagedObjectContext *parentMOC;              // core DB file
@property (nonatomic, strong) RemoteFileGetter *fileGetter;                 // object for remote file getter
@property (nonatomic, strong) ParseWordPressXML *parser;                        // object for XML parser
@property (nonatomic, strong) id<RemoteFillDatabaseFromXMLParserDelegate> delegate;   // callback delegate for this class 
@property (nonatomic, strong) NSString *lastUpdateDateFromDefaults;                 // date of last update, if not-nil -> save in NSUserDefaults
@property (nonatomic, strong) NSString *lastUpdateDateFromRemote;
@property (nonatomic) NSTimeInterval seconds;
@end

@implementation RemoteFillDatabaseFromXMLParser

#pragma mark - Init method

-(id)initWithURL:(NSURL *)url
  usingParentMOC:(NSManagedObjectContext *)parentMOC
    withDelegate:(id<RemoteFillDatabaseFromXMLParserDelegate>)delegate
     giveUpAfter:(NSTimeInterval)seconds {
    
    // store ivars needed at init
    self.parentMOC = parentMOC;
    self.delegate = delegate;
    self.seconds = seconds;
    
    // get NSUserDefaults object with date of last download file (if present)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.lastUpdateDateFromDefaults = [defaults stringForKey:LAST_UPDATE_TO_CORE_DB];
    
    // kick off file get
    self.fileGetter = [[RemoteFileGetter alloc] initWithURL:url whenMoreRecentThan:self.lastUpdateDateFromDefaults withDelegate:self giveUpAfter:self.seconds];
    
    return self;
}

#pragma mark - External delegates - GetFileFromRemoteURL


-(void)didFinishLoadingRemoteFile:(NSData *)XMLfile withSuccess:(BOOL)success findingDate:(NSString *)date {
    
    // release URL connection object
    self.fileGetter = nil;
    
    // record date of remote file (will be the same the input date if no load needed)
    self.lastUpdateDateFromRemote = date;
    
    if (success && XMLfile) {
        
        // create the queue to run our ParseOperation
        self.queue = [[NSOperationQueue alloc] init];
        
        // create a parser from the ParseWordPressXML class and add to an NSOperationQueue, will call back when done
        self.parser = [[ParseWordPressXML alloc] initWithData:XMLfile usingParentMOC:self.parentMOC withDelegate:self];
        [self.queue addOperation:self.parser];
        
    } else {
        
        // release parser object
        self.parser = nil;
        
        // error or nothing to parse, signal done
        [self.delegate doneFillingFromRemote:NO];
    }
}

#pragma mark - External Delegates - ParseWordPressXML

- (void)didFinishParsing
{
    // release parser object
    self.parser = nil;
    
    // if a new file was successfully download and parsed, save new date into NSUserDefaults
    if (![self.lastUpdateDateFromDefaults isEqualToString:self.lastUpdateDateFromRemote]) {
        
        // finished parsing sucessfully, update NSUserDefaults with last update date
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.lastUpdateDateFromRemote forKey:LAST_UPDATE_TO_CORE_DB];
        [defaults synchronize];
        
    }
    
    // callback to called signaling DONE
    [self.delegate doneFillingFromRemote:YES];
}

- (void)parseErrorOccurred:(NSError *)error {
// do nothing
}

@end