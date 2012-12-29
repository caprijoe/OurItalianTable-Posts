//
//  Post+Create.m
//  oitPosts V2
//
//  Created by Joseph Becci on 11/17/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import "Post+Create.h"
#import "Tag+Create.h"
#import "Category+Create.h"

@implementation Post (Create)

+ (Post *)createPostwithPostRecord:(PostRecord *)postRecord
            inManagedObjectContext:(NSManagedObjectContext *)context {
    
    Post *thisPost = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    request.predicate = [NSPredicate predicateWithFormat:@"postID = %i", postRecord.postID];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"postID" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        
        // handle error - nil matchs or more than 1
        NSLog(@"error -- more than one match of Post returned from database");
        
    } else if ([matches count] == 0) {
        
        // no match found, insert
        NSLog(@"inserting = %lli",postRecord.postID);
        thisPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:context];
        [self updatePost:thisPost withRecord:postRecord inManagedObjectContext:context];
        
    } else {
        
        // match found, update
        thisPost = [matches lastObject];
        NSLog(@"updating = %lli",postRecord.postID);
        [self updatePost:thisPost withRecord:postRecord inManagedObjectContext:context];

/*        if (postRecord.postLastUpdate > thisPost.postLastUpdate) {
            NSLog(@"updating = %lld",postRecord.postID);

            [self updatePost:thisPost withRecord:postRecord inManagedObjectContext:context];
        } */
    }
    
    return thisPost;
    
};

+(void)     updatePost:(Post *)thisPost
            withRecord:(PostRecord *)postRecord
inManagedObjectContext:(NSManagedObjectContext *)context {
    
    thisPost.postName  = postRecord.postName;
    thisPost.postID = postRecord.postID;
    thisPost.postAuthor = postRecord.postAuthor;
    thisPost.imageURLString = postRecord.imageURLString;
    thisPost.postURLstring = postRecord.postURLString;
    thisPost.postHTML = postRecord.postHTML;
    thisPost.postLastUpdate = postRecord.postLastUpdate;
    thisPost.postPubDate = postRecord.postPubDate;
    thisPost.latitude = postRecord.latitude;
    thisPost.longitude = postRecord.longitude;
    
    thisPost.whichCategories = nil;
    thisPost.whichTags = nil;
    
    // load tags into table
    for (NSString *tagItem in postRecord.postTags) {
        [thisPost addWhichTagsObject:[Tag createTagWithString:tagItem inManagedObjectContext:context]];
    }
    
    // load categories into table
    for (NSString *categoryItem in postRecord.postCategories) {
        [thisPost addWhichCategoriesObject:[Category createCategoryWithString:categoryItem inManagedObjectContext:context]];
    }
    
    
}

@end