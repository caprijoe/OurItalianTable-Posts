//
//  Tag+CreateMany.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 4/6/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "Tag.h"

@interface Tag (CreateMany)

+ (NSSet *)createTagsWithString:(NSArray *)tagStrings
      inManagedObjectContext:(NSManagedObjectContext *)context;

@end
