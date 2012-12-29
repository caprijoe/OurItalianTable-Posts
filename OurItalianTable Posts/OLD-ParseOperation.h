/*
     File: ParseOperation.h 
 Abstract: NSOperation code for parsing the RSS feed.
  
  Version: 1.2 
  
 */

@protocol ParseOperationDelegate;

@interface ParseOperation : NSOperation <NSXMLParserDelegate>
@property (nonatomic, weak) id <ParseOperationDelegate> delegate;
- (id)initWithData:(NSData *)data delegate:(id <ParseOperationDelegate>)theDelegate;
@end

@protocol ParseOperationDelegate
- (void)didFinishParsing:(NSArray *)postList;
- (void)parseErrorOccurred:(NSError *)error;
@end
