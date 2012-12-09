//
//  Post+Create.h
//  oitPosts V2
//
//  Created by Joseph Becci on 11/17/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import "Post.h"
#import "PostRecord.h"

@interface Post (Create)

+ (Post *)createPostwithPostRecord:(PostRecord *)postRecord
            inManagedObjectContext:(NSManagedObjectContext *)context;

@end
