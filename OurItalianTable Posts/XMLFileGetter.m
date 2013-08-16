//
//  RemoteFileGetter.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/1/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "XMLFileGetter.h"
#import "SharedUserDefaults.h"
#import "OHAlertView.h"

@interface XMLFileGetter ()
@property (nonatomic, strong) Reachability *reach;
@end

@implementation XMLFileGetter

#pragma mark - Init method

-(id)init
{
    
    self = [super init];
    if (self) {
        
        // set ivars for getting XML file inside the ZIP file
        self.expectedMIMETypes = @[@"application/zip"];
                
    }
    
    return self;    
}

-(void)startFileDownload {
    
    // set up Reachability class to help with internet errors
    self.reach = [Reachability reachabilityWithHostname:[self.url host]];
    __weak XMLFileGetter *weakSelf = self;
    
    self.reach.reachableBlock = ^(Reachability *reach) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"reachable");
            
            // if we have a wi-fi connection, just start
            if ([weakSelf.reach isReachableViaWiFi]) {
                
                [super startFileDownload];
                
            } else {
                // assume it's a WAN connection
                
                // if the download preference has not been set, ask for it...
                if (![[SharedUserDefaults sharedSingleton] getObjectWithKey:UPDATE_OVER_CELLULAR]) {
                    
                    // ask the user preference
                    [OHAlertView showAlertWithTitle:@"Question?" message:@"You currently only have a cellular connection. OK to download Our Italian Table updates over cellular?" cancelButton:@"NO" okButton:@"YES" onButtonTapped:^(OHAlertView* alert, NSInteger buttonIndex)
                     {
                         if (buttonIndex == alert.cancelButtonIndex) {
                             
                             // save it, if NO for cellular, skip download
                             [[SharedUserDefaults sharedSingleton] setObjectWithKey:UPDATE_OVER_CELLULAR withObject:@NO];
                             
                             [OHAlertView showAlertWithTitle:@"Perference set!" message:@"Go to Settings App > ouritaliantable to change" dismissButton:@"OK"];
                             
                         } else {
                             
                             // save it and if OK for cellular, start the download
                             [[SharedUserDefaults sharedSingleton] setObjectWithKey:UPDATE_OVER_CELLULAR withObject:@YES];
                             
                             [super startFileDownload];
                             
                             [OHAlertView showAlertWithTitle:@"Perference set!" message:@"Go to Settings App > ouritaliantable to change" dismissButton:@"OK"];
                         }
                     }];
                    
                } else if ([[[SharedUserDefaults sharedSingleton] getObjectWithKey:UPDATE_OVER_CELLULAR] isEqual: @YES]) {
                    // if WAN and preference is YES, start download
                    
                    [super startFileDownload];
                } else {
                    // if WAN and preference is NO, exit signally failure
                    
                    [weakSelf exitGetFileWithData:nil withSuccess:NO withLastUpdateDate:nil];

                }
            }
        });
    };
    
    self.reach.unreachableBlock = ^(Reachability *reach) {
      
        NSLog(@"not reachable, do nothing");
        
        // exit signally failure
        [weakSelf exitGetFileWithData:nil withSuccess:NO withLastUpdateDate:nil];
        
    };
    
    [self.reach startNotifier];
    
}

#pragma mark - Private methods
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
        
        // signal failure to delegate
        [self.delegate didFinishLoadingURL:nil withSuccess:NO findingMetadata:nil];
    }
}

@end
