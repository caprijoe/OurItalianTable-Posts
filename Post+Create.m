//
//  Post+Create.m
//  oitPosts V2
//
//  Created by Joseph Becci on 11/17/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import "Post+Create.h"
#import "Tag+CreateMany.h"
#import "Category+CreateMany.h"

@implementation Post (Create)

+ (Post *)createPostwithPostRecord:(PostRecord *)postRecord
            inManagedObjectContext:(NSManagedObjectContext *)context {
    
    static NSNumber *initialLoad;
    
    if (!initialLoad) {
        
        initialLoad = [self determineIfInitialLoad:context];
        
    }
    
    Post *thisPost = nil;
    
    if ([initialLoad isEqualToNumber:@YES]) {
        
        thisPost = [self createNewPostWithRecord:postRecord inManagedObjectContext:context];
        
    } else {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
        request.predicate = [NSPredicate predicateWithFormat:@"postID = %@", postRecord.postID];
        request.sortDescriptors = nil;
        
        NSError *error = nil;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            
            // handle error - nil matchs or more than 1
            NSLog(@"error -- more than one match of Post returned from database");
            
        } else if ([matches count] == 0) {
            
            // no match found, insert
            thisPost = [self createNewPostWithRecord:postRecord inManagedObjectContext:context];
            
        } else {
            
            // match found, update
            thisPost = [matches lastObject];
            [self updatePost:thisPost withRecord:postRecord inManagedObjectContext:context];
            
        }
    }
    
    return thisPost;
};

+(NSNumber *)determineIfInitialLoad:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    request.predicate = nil;
    request.sortDescriptors = nil;
    
    NSError *error;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    
    if (count == NSNotFound) {
        
        NSLog(@"An error occured determining post count");
        return nil;
        
    } else if (count == 0) {
        return @YES;
    } else {
        return @NO;
    }    
}

+(Post *)createNewPostWithRecord:(PostRecord *)postRecord
          inManagedObjectContext:(NSManagedObjectContext *)context {
    
    Post* thisPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:context];
    [self updatePost:thisPost withRecord:postRecord inManagedObjectContext:context];
    
    return thisPost;
    
}

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
