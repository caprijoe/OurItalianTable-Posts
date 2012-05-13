//
//  SetupParse.h
//  oitPosts
//
//  Created by Joseph Becci on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseOperation.h"


@protocol ProcessedPostsDelegate <NSObject>
@required
- (void) finishedLoadingPosts:(NSArray *) posts;
@end

@interface ParseXML : NSObject <ParseOperationDelegate>;
@property (nonatomic,weak) id <ProcessedPostsDelegate> delegate;
-(void)startParse;
@end


