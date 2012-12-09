//
//  Tag+Create.m
//  oitPosts V2
//
//  Created by Joseph Becci on 11/18/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+ (Tag *)createTagWithString:(NSString *)tagString
      inManagedObjectContext:(NSManagedObjectContext *)context {

    Tag *thisTag = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"tagString = %@", tagString];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tagString" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if (!matches || [matches count] > 1)
        // handle error
        NSLog(@"error -- more than one match of Tag returned from database");
    else if ([matches count] == 0) {
        
        thisTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        thisTag.tagString = tagString;

    } else {
        thisTag = [matches lastObject];
    }

    return thisTag;
    
};

@end
