//
//  IconDownloader.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/17/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "IconDownloader.h"

@interface IconDownloader()
@property (nonatomic, strong) AtomicGetFileFromRemoteURL *iconGetter;
@property (nonatomic, strong) id<iconDownloaderDelegate>delegate;
@property (nonatomic) int64_t postID;
@property (nonatomic, strong) NSString *originalURL;
@property (nonatomic) int numberOfAttempts;
@end

@implementation IconDownloader

#pragma mark - Init method

-(id)initWithURL:(NSString *)incomingURLString forPostID:(int64_t)postID withDelegate:(id<iconDownloaderDelegate>)delegate
{
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        self.postID = postID;
        self.originalURL = incomingURLString;
        self.numberOfAttempts = 0;

        // edit image URL to get path thumbnail instead, if available
        // -- delete and existing dimension
        // -- -150x150 to the primary URL
        
        NSString *newURL = [self modifyURLToThumbnailFile:incomingURLString];
                        
        // try first with altereded ULR string to get thumbnail
        self.iconGetter = [[AtomicGetFileFromRemoteURL alloc] init];
        self.iconGetter.url = [NSURL URLWithString:newURL];
        self.iconGetter.lastUpdateToDBDate = nil;
        self.iconGetter.expectedMIMETypes = @[@"image/jpeg", @"image/png"];
        self.iconGetter.delegate = self;
        
        [self.iconGetter startFileDownload];
        
        if (!self.iconGetter) {
            
            [self.delegate iconDownloadComplete:nil forPostID:0 withSucess:NO];
            
        } else {
            
            self.numberOfAttempts++;
            
        }
    }
    return self;
}

#pragma mark - External Delegate

-(void)didFinishLoadingURL:(NSData *)iconFile withSuccess:(BOOL)success findingDate:(NSString *)date
{
    UIImage *newImage;
    
    if (iconFile && success)
    {
        newImage = [self createAndAdjustImage:iconFile];
        self.iconGetter = nil;
        
        NSData *iconData;
            iconData = UIImageJPEGRepresentation(newImage, 1.0);
        
        [self.delegate iconDownloadComplete:iconData forPostID:self.postID withSucess:YES];
        
    } else if (self.numberOfAttempts == 1) {
        
        // could not get thumbnail file, now try with original URL
        self.iconGetter = [[AtomicGetFileFromRemoteURL alloc] init];
        self.iconGetter.url = [NSURL URLWithString:self.originalURL];
        self.iconGetter.lastUpdateToDBDate = nil;
        self.iconGetter.expectedMIMETypes = @[@"image/jpeg", @"image/png"];
        self.iconGetter.delegate = self;
        
        [self.iconGetter startFileDownload];
        
        if (!self.iconGetter) {
            
            [self.delegate iconDownloadComplete:nil forPostID:0 withSucess:NO];
            
        } else {
            
            self.numberOfAttempts++;
            
        }
        
    } else if (self.numberOfAttempts == 2) {
        
        // failed on second attempt with original URL, fail out
        [self.delegate iconDownloadComplete:nil forPostID:0 withSucess:NO];
        
    }
        
}

#pragma mark - Private methods
-(UIImage *)createAndAdjustImage:(NSData *)data
{
    UIImage *image = [[UIImage alloc] initWithData:data];
    
    UIImage *newImage;
    
    if (image.size.width != POST_ICON_HEIGHT && image.size.height != POST_ICON_HEIGHT)
	{
        CGSize itemSize = CGSizeMake(POST_ICON_HEIGHT, POST_ICON_HEIGHT);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
    }
    
    return newImage;
}

-(NSString *)modifyURLToThumbnailFile:(NSString *)incomingURLString
{
    
    // edit image URL to get path thumbnail instead, if available
    // -- delete and existing dimension
    // -- -150x150 to the primary URL
    // -- if malformed ULR (no extension), just return incoming
    
    NSRange searchRange = [incomingURLString rangeOfString:@"." options:NSBackwardsSearch];
    if (searchRange.location != NSNotFound) {
        
        NSString *primaryURL = [incomingURLString stringByDeletingPathExtension];
        NSString *fileExtension = [incomingURLString pathExtension];
        
        // look for trailing size information
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(-)(\\d+)(x)(\\d+)$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:primaryURL options:0 range:NSMakeRange(0, [primaryURL length])];
        
        // if trailing file size info found, delete it
        if  (match)
        {
            primaryURL = [primaryURL substringToIndex:match.range.location];
        }
        
        // attach the thumbnail size for WP
        primaryURL = [primaryURL stringByAppendingString:@"-150x150"];
        
        return [primaryURL stringByAppendingPathExtension:fileExtension];
        
    } else {
        
        // no extension, just return incoming
        return incomingURLString;
        
    }
}

@end
