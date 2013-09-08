//
//  Category+CreateMany.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 4/7/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "Category+CreateMany.h"

@implementation Category (CreateMany)

+(Category *)findOrCreateCategory:(NSString *)categoryString inManagedObjectContext:(NSManagedObjectContext *)context {
    
    // static to hold the tag listing
    static NSMutableDictionary *categoryListing;
    
    // if it hasn't been alloc-ed, do it
    if (!categoryListing) {
        
        categoryListing = [[NSMutableDictionary alloc] init];
        
        // find out which of those tags are already in the database
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
        request.predicate = nil;
        request.sortDescriptors = nil;
        
        NSError *error = nil;
        NSArray *tagsInDatabase = [[context executeFetchRequest:request error:&error] mutableCopy];
        
        // build a dictionary of the tags with the tagString as the key
        for (Category *thisCategory in tagsInDatabase)
            [categoryListing setObject:thisCategory forKey:thisCategory.categoryString];
    }
    
    // see if the tag is in the dictionary
    Category *foundCategory = [categoryListing objectForKey:categoryString];
    
    if (foundCategory) {
        // if found in dictionary, return obj
        return foundCategory;
        
    } else {
        // if not, create it, add to dictionary and return it
        Category *thisCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        thisCategory.categoryString = categoryString;
        [categoryListing setObject:thisCategory forKey:categoryString];
        return thisCategory;
    }
}


+ (NSSet *)createCategoriesWithString:(NSArray *)categoryStrings
         inManagedObjectContext:(NSManagedObjectContext *)context {

    // set up a destination set for all objects to be returned back to caller
    NSMutableSet *allCategories = [[NSMutableSet alloc] initWithCapacity:[categoryStrings count]];
    
    // find or create the tags
    for (NSString *thisCategory in categoryStrings) {
        
        [allCategories addObject:[self findOrCreateCategory:thisCategory inManagedObjectContext:context]];
        
    }
    
    return allCategories;
}

@end
