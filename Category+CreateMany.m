//
//  Category+CreateMany.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 4/7/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "Category+CreateMany.h"

@implementation Category (CreateMany)

+ (NSSet *)createCategoriesWithString:(NSArray *)categoryStrings
         inManagedObjectContext:(NSManagedObjectContext *)context {
    
    // create an initial set of categories that need relationships created
    NSMutableSet *categorySet = [NSMutableSet setWithArray:categoryStrings];
    
    // find out which of those categories are already in the database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    request.predicate = [NSPredicate predicateWithFormat:@"categoryString IN %@", categoryStrings];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"categoryString" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // set up a destination set for all objects to be returned back to caller
    NSMutableSet *allCategories = [NSMutableSet setWithArray:matches];
    
    // remove those tags that are already in the database
    [categorySet minusSet:[NSSet setWithArray:[matches valueForKey:@"categoryString"]]];
    
    // insert the new tags into the database and add to destination set
    for (NSString *newCategory in categorySet) {
        
        Category *thisCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        thisCategory.categoryString = newCategory;
        [allCategories addObject:thisCategory];
    }
    
    return allCategories;
}

@end
