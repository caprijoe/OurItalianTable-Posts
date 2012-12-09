//
//  Category+Create.m
//  oitPosts V2
//
//  Created by Joseph Becci on 11/18/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import "Category+Create.h"

@implementation Category (Create)

+ (Category *)createCategoryWithString:(NSString *)categoryString
                inManagedObjectContext:(NSManagedObjectContext *)context {

    Category *thisCategory = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    request.predicate = [NSPredicate predicateWithFormat:@"categoryString = %@", categoryString];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"categoryString" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || [matches count] > 1)
        // handle error
        NSLog(@"error -- more than one match of Tag returned from database");
    else if ([matches count] == 0) {
        
        thisCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        thisCategory.categoryString = categoryString;
        
    } else {
        thisCategory = [matches lastObject];
    }
    
    return thisCategory;
    
};

@end
