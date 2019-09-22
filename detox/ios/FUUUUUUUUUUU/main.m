//
//  main.m
//  FUUUUUUUUUUU
//
//  Created by Leo Natan (Wix) on 9/23/19.
//

#import <Foundation/Foundation.h>
#import "DetoxHelperAPI.h"

int main(int argc, const char * argv[]) {
	@autoreleasepool {
	    // insert code here...
		NSXPCConnection* c = [[NSXPCConnection alloc] initWithMachServiceName:@"com.wix.DetoxMachService" options:0];
		c.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DetoxHelperAPI)];
		[c resume];
		
		[[c synchronousRemoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
			NSLog(@"%@", error);
		}] waitForIdleWithCompletionHandler:^{
			NSLog(@"Yay");
		}];
	}
	return 0;
}
