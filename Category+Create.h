//
//  Category+Create.h
//  oitPosts V2
//
//  Created by Joseph Becci on 11/18/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import "Category.h"

@interface Category (Create)

+ (Category *)createCategoryWithString:(NSString *)categoryString
      inManagedObjectContext:(NSManagedObjectContext *)context;

@end
