//
//  OITBrain.m
//  oitPosts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OITBrain.h"

#define FAVORITES_KEY       @"FAVORITES_KEY"
#define POST_ICON_HEIGHT    48
#define TMP                 NSTemporaryDirectory()

@interface OITBrain()
@property (nonatomic,strong) ParseXML *parseXML;
@property (nonatomic,strong) NSArray *brainEntries;
@end

@implementation OITBrain
@synthesize parseXML = _parseXML;
@synthesize brainEntries = _brainEntries;
@synthesize delegate = _delegate;


#pragma mark - Initialization methods

-(id)init {
    
    // on init, kick off parsing
    self.parseXML = [[ParseXML alloc] init];
    [self.parseXML setDelegate:self];
    [self.parseXML startParse];
    
    return self;
}

#pragma mark - Private methods - Search support methods

// change display category to the one that WordPress knows
-(NSString *)fixCategory:(NSString *)category {
    NSString *lc = [category lowercaseString];
    NSString *noComma = [lc stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *noQuote = [noComma stringByReplacingOccurrencesOfString:@"'" withString:@""];
    NSString *addHyphen = [noQuote stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    return addHyphen;
}

#pragma mark - Private Methods - Icon loading support methods 

-(NSString *)uniquePathToCachedIcon:(NSString *)postID {
    NSString *filename = [NSString stringWithFormat:@"Cached-thumbnail-%@.jpg",postID];
    NSString *path = [TMP stringByAppendingPathComponent:filename];
    return path;
}

-(BOOL)isInIconCache:(NSString *)postID {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self uniquePathToCachedIcon:postID]]) {
        return TRUE;
    } else
        return FALSE;
}

-(UIImage *)getIconFromCache:(NSString *)postID {
    return [UIImage imageWithContentsOfFile:[self uniquePathToCachedIcon:postID]];
}

-(void)writeIconToCache:(NSString *)postID
       withImage:(UIImage*)postIcon {
    [UIImageJPEGRepresentation(postIcon, 1.0) writeToFile:[self uniquePathToCachedIcon:postID] atomically:YES];
}


- (UIImage *)adjustImage:(UIImage *)image
{
    if (image.size.width != POST_ICON_HEIGHT && image.size.height != POST_ICON_HEIGHT)
	{
        
        // Get base sizes
        CGSize imageSize = image.size;
        CGFloat sourceImageWidth = imageSize.width;
        CGFloat sourceImageHeight = imageSize.height;
        
        CGSize targetSize = CGSizeMake(POST_ICON_HEIGHT, POST_ICON_HEIGHT);
        CGFloat targetWidth = targetSize.width;
        CGFloat targetHeight = targetSize.height;
        
        // Initialize
        UIImage *newImage = [[UIImage alloc] init];
        CGFloat scaleFactor = 0.0;
        CGFloat scaledWidth = targetWidth;
        CGFloat scaledHeight = targetHeight;
        CGPoint thumbnailPoint = CGPointMake(0, 0);
        
        // Execute
        if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
            CGFloat widthFactor = targetWidth / sourceImageWidth;
            CGFloat heightFactor = targetHeight / sourceImageHeight;
            
            if (widthFactor > heightFactor)
                scaleFactor = widthFactor;  // scale to fit height
            else 
                scaleFactor = heightFactor; // scale to fit width
            
            scaledWidth = sourceImageWidth * scaleFactor;
            scaledHeight = sourceImageHeight * scaleFactor;
            
            // center the image
            if (widthFactor > heightFactor)
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            else if (widthFactor < heightFactor)
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
        
        // do the crop
        UIGraphicsBeginImageContext(targetSize);
        CGRect thumbnailRect = CGRectZero;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        
        [image drawInRect:thumbnailRect];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        if (newImage == nil) NSLog(@"could not scale image");
        
        UIGraphicsEndImageContext();
        
        return newImage;                
    }
    else
        return image;
}

#pragma mark - Public methods

// get array of posts based on parms
-(NSMutableArray *)isFav:(BOOL)fav
                 withTag:(NSString *)tag
            withCategory:(NSString *)category
      withDetailCategory:(NSString *)detailCategory {
    
    // declare target
    NSMutableArray *filtered;
    
    // start off with the entire array, a) if entire array, in reserve order or b) favorites
    if (!fav) {
        filtered = [NSMutableArray arrayWithCapacity:[self.brainEntries count]];
        for (PostRecord *postRecord in [self.brainEntries reverseObjectEnumerator]) {
            [filtered addObject:postRecord];
        }
    } else {
        filtered = [[self getFavorites] mutableCopy];
    }
    
    // filter categories if not nil
    if (category) {
        [filtered filterUsingPredicate:[NSPredicate predicateWithFormat:@"postCategories contains[c] %@",category]];
    }
    
    // filter tags if not nil
    if (tag) {
        [filtered filterUsingPredicate:[NSPredicate predicateWithFormat:@"postTags contains[c] %@",tag]];
    }
    
    // filter detail category (from picker) if not nil
    if (detailCategory) {
        [filtered filterUsingPredicate:[NSPredicate predicateWithFormat:@"ANY postCategories contains[c] %@", [self fixCategory: detailCategory]]];
    }
        
    return filtered;    
}

// search within array for searchText based on searchScopt
-(NSArray *)searchScope:(NSString *)scope                   // must be "All" | "Title" | "Article" | "Tags"
             withString:(NSString *)searchText
                 isFavs:(BOOL)fav
           withCategory:(NSString *)category {
    
    NSMutableArray *filtered = [[self isFav:fav withTag:nil withCategory:category withDetailCategory:nil] mutableCopy];
    
    if ([scope isEqualToString:@"Title"]) {
        [filtered filterUsingPredicate:[NSPredicate predicateWithFormat:@"postName contains[c] %@",searchText]];
    } else if ([scope isEqualToString:@"Article"]) {
        [filtered filterUsingPredicate:[NSPredicate predicateWithFormat:@"postHTML contains[c] %@",searchText]];
    } else if ([scope isEqualToString:@"Tags"]) {
        [filtered filterUsingPredicate:[NSPredicate predicateWithFormat:@"postTags contains[c] %@",searchText]];
    } else  if ([scope isEqualToString:@"All"]) {
        [filtered filterUsingPredicate:[NSPredicate predicateWithFormat:@"(postName contains[c] %@) OR (postHTML contains[c] %@) OR (postTags contains[c] %@)",searchText, searchText, searchText]];
    }
    return filtered;
}

// get all the favs, based on NSUserDefaults
-(NSArray *)getFavorites
{
    NSArray *favoriteEntries = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
    
    // create target
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    
    for (PostRecord *entry in self.brainEntries)
    {
        if ([favoriteEntries containsObject:entry.postID])
            [filtered addObject:entry];
    }
    
    return filtered;
}

// load up the table thumbnnail, if not cached, cache it
-(void)populateIcon:(PostRecord *)postRecord
            forCell:(UITableViewCell *)cell
       forTableView:(UITableView *)tableView
       forIndexPath:(NSIndexPath *)indexPath {
    
    // get index of tableview entry in memory array, assume its there somewhere since we just loaded it from XML file
    NSUInteger index = [self.brainEntries indexOfObjectIdenticalTo:postRecord];
    
    // check if icon in in memory array, if so, set it
    if ([[self.brainEntries objectAtIndex:index] postIcon]) {
        cell.imageView.image = [[self.brainEntries objectAtIndex:index] postIcon];
        
    // check if icon is in cache, if found populate memory too
    } else if ([self isInIconCache:postRecord.postID]) {
        cell.imageView.image = [self getIconFromCache:postRecord.postID];
        PostRecord *post = [self.brainEntries objectAtIndex:index];
        post.postIcon = cell.imageView.image;
        
    // if all else fails, load from internet. if found, load memory and cache too. If not found, just use placeholder.png    
    } else {
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        dispatch_queue_t queue = dispatch_queue_create("get Icon",NULL);
        dispatch_async(queue, ^{
            
            // load data from URL
            NSError *error = Nil;
            NSData *data =[NSData dataWithContentsOfURL:[NSURL URLWithString:postRecord.imageURLString] options:NSDataReadingUncached error:&error];
            
            // if we got data AND no error, proceed. Else let the placeholder.png remain
            if (data && !error)
                dispatch_async(dispatch_get_main_queue(), ^{
                    UITableViewCell *correctCell = [tableView cellForRowAtIndexPath:indexPath];
                    
                    correctCell.imageView.image = [self adjustImage:[UIImage imageWithData:data]];
                    [correctCell setNeedsLayout];
                    
                    // load into cache
                    [self writeIconToCache:postRecord.postID withImage:correctCell.imageView.image];
                    
                    // load into memory array
                    PostRecord *post = [self.brainEntries objectAtIndex:index];
                    post.postIcon = correctCell.imageView.image;
                    
                });
        });
        dispatch_release(queue);
    }
}

#pragma mark - External delegates

// when posts are loaded, call back to OITLaunch to enable buttons
-(void)finishedLoadingPosts:(NSArray *)posts {
    self.brainEntries = posts;
    [self.delegate OITBrainDidFinish];
}


@end
