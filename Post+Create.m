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
#import "Tag+CreateMany.h"
#import "Category+CreateMany.h"

@implementation Post (Create)

+ (Post *)createPostwithPostRecord:(PostRecord *)postRecord
            inManagedObjectContext:(NSManagedObjectContext *)context {
    
    Post *thisPost = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    request.predicate = [NSPredicate predicateWithFormat:@"postID = %@", postRecord.postID];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"postID" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        
        // handle error - nil matchs or more than 1
        NSLog(@"error -- more than one match of Post returned from database");
        
    } else if ([matches count] == 0) {
        
        // no match found, insert
        thisPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:context];
        [self updatePost:thisPost withRecord:postRecord inManagedObjectContext:context];
        
    } else {
        
        // match found, update
        thisPost = [matches lastObject];
        [self updatePost:thisPost withRecord:postRecord inManagedObjectContext:context];

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
    thisPost.postPubDate = postRecord.postPubDate;
    thisPost.latitude = postRecord.latitude;
    thisPost.longitude = postRecord.longitude;
    thisPost.geo = postRecord.geo;
    
    thisPost.whichCategories = nil;
    thisPost.whichTags = nil;
        
    // load tags into table    
    [thisPost addWhichTags:[Tag createTagsWithString:postRecord.postTags inManagedObjectContext:context]];
    
    // load categories into table    
    [thisPost addWhichCategories:[Category createCategoriesWithString:postRecord.postCategories inManagedObjectContext:context]];
}

@end
