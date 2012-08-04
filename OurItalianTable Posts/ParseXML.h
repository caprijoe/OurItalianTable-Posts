//
//  SetupParse.h
//  oitPosts
//
//  Created by Joseph Becci on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParseOperation.h"

@protocol ProcessedPostsDelegate <NSObject>
@required
- (void) finishedLoadingPosts:(NSArray *) posts;
@end

@interface ParseXML : NSObject <ParseOperationDelegate>;

// public properties
@property (nonatomic,weak) id <ProcessedPostsDelegate> delegate;

// public methods
-(void)startParse;
@end


