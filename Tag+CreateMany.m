//
//  Tag+CreateMany.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 4/6/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "Tag+CreateMany.h"

@implementation Tag (CreateMany)

+ (NSSet *)createTagsWithString:(NSArray *)tagStrings
       inManagedObjectContext:(NSManagedObjectContext *)context {
    
    // create an initial set of tags that need relationships created
    NSMutableSet *tagSet = [NSMutableSet setWithArray:tagStrings];
    
    // find out which of those tags are already in the database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"tagString IN %@", tagStrings];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tagString" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // set up a destination set for all objects to be returned back to caller
    NSMutableSet *allTags = [NSMutableSet setWithArray:matches];
    
    // remove those tags that are already in the database
    [tagSet minusSet:[NSSet setWithArray:[matches valueForKey:@"tagString"]]];
    
    // insert the new tags into the database and add to destination set
    for (NSString *newTag in tagSet) {
        
        Tag *thisTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        thisTag.tagString = newTag;
        [allTags addObject:thisTag];
    }

    return allTags;
}


@end
