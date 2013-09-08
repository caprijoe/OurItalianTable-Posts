//
//  Tag+CreateMany.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 4/6/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "Tag+CreateMany.h"

@implementation Tag (CreateMany)

+(Tag *)findOrCreateTag:(NSString *)tagString inManagedObjectContext:(NSManagedObjectContext *)context {
    
    // static to hold the tag listing
    static NSMutableDictionary *tagListing;
    
    // if it hasn't been alloc-ed, do it
    if (!tagListing) {
        
        tagListing = [[NSMutableDictionary alloc] init];
        
        // find out which of those tags are already in the database
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.predicate = nil;
        request.sortDescriptors = nil;
        
        NSError *error = nil;
        NSArray *tagsInDatabase = [[context executeFetchRequest:request error:&error] mutableCopy];
        
        // build a dictionary of the tags with the tagString as the key
        for (Tag *thisTag in tagsInDatabase)
            [tagListing setObject:thisTag forKey:thisTag.tagString];

    }
    
    // see if the tag is in the dictionary
    Tag *foundTag = [tagListing objectForKey:tagString];

    if (foundTag) {
        // if found in dictionary, return obj
        return foundTag;
        
    } else {
        // if not, create it, add to dictionary and return it
        Tag *thisTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        thisTag.tagString = tagString;
        [tagListing setObject:thisTag forKey:tagString];
        return thisTag;
    }
    
}

+ (NSSet *)createTagsWithString:(NSArray *)tagStrings
       inManagedObjectContext:(NSManagedObjectContext *)context {
        
    // set up a destination set for all objects to be returned back to caller
    NSMutableSet *allTags = [[NSMutableSet alloc] initWithCapacity:[tagStrings count]];
    
    // find or create the tags
    for (NSString *thisTag in tagStrings) {
        
        [allTags addObject:[self findOrCreateTag:thisTag inManagedObjectContext:context]];
        
    }
    
    return allTags;
}


@end
