//
//  DetoxHelperAPI.h
//  Detox
//
//  Created by Leo Natan (Wix) on 9/18/19.
//

#ifndef DetoxHelperAPI_h
#define DetoxHelperAPI_h

@protocol DetoxHelperAPI <NSObject>

@optional

- (void)testHello:(NSString*)hello;
- (void)waitForIdleWithCompletionHandler:(dispatch_block_t)completionHandler;

@end

#endif /* DetoxHelperAPI_h */
