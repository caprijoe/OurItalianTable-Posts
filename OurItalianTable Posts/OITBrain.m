//
//  OITBrain.m
//  oitPosts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OITBrain.h"
#import "ParseXML.h"
#import "postRecord.h"

#define FAVORITES_KEY       @"FAVORITES_KEY"
#define POST_ICON_HEIGHT    48
#define TMP                 NSTemporaryDirectory()

@interface OITBrain()
@property (nonatomic,strong) ParseXML *parseXML;
@property (nonatomic, strong) NSArray *brainEntries;
@end

@implementation OITBrain
@synthesize parseXML = _parseXML;
@synthesize brainEntries = _brainEntries;
@synthesize delegate = _delegate;


#pragma mark -
#pragma mark Initialization methods

-(id)init {
    self.parseXML = [[ParseXML alloc] init];
    [self.parseXML setDelegate:self];
    [self.parseXML startParse];
    
    return self;
}

-(void)finishedLoadingPosts:(NSArray *)posts {
    self.brainEntries = posts;
    [self.delegate OITBrainDidFinish];
}

#pragma mark - Search methods

-(NSMutableArray *)isFav:(BOOL)fav
                 withTag:(NSString *)tag
            withCategory:(NSString *)category
      withDetailCategory:(NSString *)detailCategory {
    
    // declare target
    NSMutableArray *filtered;
    
    // start off with the entire array, if entire array, in reserve order else favorites
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
    // FIX THIS .. UGLY
    if (detailCategory) {
        NSUInteger index = 0;
        NSMutableIndexSet *indexesToDelete = [[NSMutableIndexSet alloc] init];
        for (PostRecord *postRecord in filtered) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",detailCategory];
            NSArray *matchs = [postRecord.postCategories filteredArrayUsingPredicate:predicate];
            if (![matchs count]) {
                [indexesToDelete addIndex:index];
            };
            index++;
        }
        if (indexesToDelete) {
            [filtered removeObjectsAtIndexes:indexesToDelete];
        }
    }
        
    return filtered;    
}

-(NSArray *)searchScope:(NSString *)scope 
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

#pragma mark - 
#pragma mark Icon loading support methods

-(NSString *)uniquePath:(NSString *)postID {
    NSString *filename = [NSString stringWithFormat:@"Cached-thumbnail-%@.jpg",postID];
    NSString *path = [TMP stringByAppendingPathComponent:filename];
    return path;
}

-(BOOL)inIconCache:(NSString *)postID {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self uniquePath:postID]]) {
        return TRUE;
    } else
        return FALSE;
}

-(UIImage *)getIconFromCache:(NSString *)postID {
    return [UIImage imageWithContentsOfFile:[self uniquePath:postID]];
}

-(void)cacheIcon:(NSString *)postID
       withImage:(UIImage*)postIcon {
    [UIImageJPEGRepresentation(postIcon, 1.0) writeToFile:[self uniquePath:postID] atomically:YES];
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

-(void)populateIcon:(PostRecord *)postRecord
            forCell:(UITableViewCell *)cell
       forTableView:(UITableView *)tableView
       forIndexPath:(NSIndexPath *)indexPath {
    
    // get index of tableview entry in memory array, assume its there somewhere since we just loaded it from XML file
    NSUInteger index = [self.brainEntries indexOfObjectIdenticalTo:postRecord];
    
    // check if icon in in memory array
    if ([[self.brainEntries objectAtIndex:index] postIcon]) {
        cell.imageView.image = [[self.brainEntries objectAtIndex:index] postIcon];
        
        // check if icon is in cache, if found populate memory too
    } else if ([self inIconCache:postRecord.postID]) {
        cell.imageView.image = [self getIconFromCache:postRecord.postID];
        PostRecord *post = [self.brainEntries objectAtIndex:index];
        post.postIcon = cell.imageView.image;
        
        // if all else fails, load from internet. if found, load memory and cache too    
    } else {
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        dispatch_queue_t queue = dispatch_queue_create("get Icon",NULL);
        dispatch_async(queue, ^{
            NSData *data =[NSData dataWithContentsOfURL:[NSURL URLWithString:postRecord.imageURLString]];
            if (data)
                dispatch_async(dispatch_get_main_queue(), ^{
                    UITableViewCell *correctCell = [tableView cellForRowAtIndexPath:indexPath];
                    
                    correctCell.imageView.image = [self adjustImage:[UIImage imageWithData:data]];
                    [correctCell setNeedsLayout];
                    
                    // load into cache
                    [self cacheIcon:postRecord.postID withImage:correctCell.imageView.image];
                    
                    // load into memory array
                    PostRecord *post = [self.brainEntries objectAtIndex:index];
                    post.postIcon = correctCell.imageView.image;
                    
                });
        });
        dispatch_release(queue);
    }
}

@end
