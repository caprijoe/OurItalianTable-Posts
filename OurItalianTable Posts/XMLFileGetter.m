//
//  RemoteFileGetter.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/1/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "XMLFileGetter.h"

@interface XMLFileGetter ()
@property (nonatomic, strong) Reachability *reach;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation XMLFileGetter

#pragma mark - Init method

-(id)init
{
    
    self = [super init];
    if (self) {
        
        // set ivars for getting XML file inside the ZIP file
        self.expectedMIMETypes = @[@"application/zip"];
                
        // set up Reachability class to help with internet errors        
        self.reach = [Reachability reachabilityWithHostname:[self.url host]];
        
        [self.reach startNotifier];
        
    }
    
    return self;    
}

#pragma mark - Private methods

-(void)invokeTimeout {
    
    NSLog(@"killed by timer");
    
    // process timeout
    self.reach.reachableBlock = nil;
    
    [self.delegate didFinishLoadingURL:nil withSuccess:NO findingMetadata:nil];

    
}

-(NSData *)unZipFile:(NSData *)zipFile
{
    // write received NSData to a file in the tmp directory
    NSString *zipFileURL = [NSTemporaryDirectory() stringByAppendingPathComponent:[self.url lastPathComponent]];
    NSString *XMLFileURL = [NSTemporaryDirectory() stringByAppendingPathComponent:@"zipDir/our-italian-table.xml"];
        
    [zipFile writeToFile:zipFileURL atomically:NO];
    
    NSError *error;
    
    [SSZipArchive unzipFileAtPath:zipFileURL toDestination:[NSTemporaryDirectory() stringByAppendingPathComponent:@"zipDir"] overwrite:YES password:nil error:&error];
    
    return [NSData dataWithContentsOfFile:XMLFileURL];
    
}

#pragma mark - External delegates

-(void)exitGetFileWithData:(NSData *)XMLfile withSuccess:(BOOL)success withLastUpdateDate:(NSString *)date
{
    NSLog(@"exiting ...");
    
    [self prepareToExit];
    
    if (success && XMLfile) {
        
        // turn off Reachability
        self.reach = nil;
        
        NSData *unZippedXMLfile = [self unZipFile:XMLfile];
        
        // successfully loaded file or discovered remote file was of same date
        [self.delegate didFinishLoadingURL:unZippedXMLfile withSuccess:success findingMetadata:date];

    
    } else if (success && !XMLfile) {
        
        // turn off Reachability
        self.reach = nil;
                
        // successfully loaded file or discovered remote file was of same date
        [self.delegate didFinishLoadingURL:nil withSuccess:success findingMetadata:date];

    } else {
        
        // requeue file load when and if internet comes back

        // if seconds passed in, set up a time out
        if (self.seconds)
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.seconds target:self selector:@selector(invokeTimeout) userInfo:nil repeats:NO];
        
        __weak XMLFileGetter *selfInBlock = self;
        
        NSLog(@"waiting for internet connection");
        
        self.reach.reachableBlock = ^(Reachability * reachability)
        {
            [selfInBlock startFileDownload];
        };        
    }
}

@end
