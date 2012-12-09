//
//  Tag+Create.h
//  oitPosts V2
//
//  Created by Joseph Becci on 11/18/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+ (Tag *)createTagWithString:(NSString *)tagString
      inManagedObjectContext:(NSManagedObjectContext *)context;


@end
