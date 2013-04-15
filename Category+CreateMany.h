//
//  Category+CreateMany.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 4/7/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "Category.h"

@interface Category (CreateMany)

+ (NSSet *)createCategoriesWithString:(NSArray *)categoryStrings
         inManagedObjectContext:(NSManagedObjectContext *)context;

@end
