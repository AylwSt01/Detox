//
//  main.m
//  DetoxLaunchAgent
//
//  Created by Leo Natan (Wix) on 9/23/19.
//

#import <Foundation/Foundation.h>
#import "DetoxHelperAPI.h"

@interface DTXServiceListener : NSObject <NSXPCListenerDelegate, DetoxHelperAPI> @end
@implementation DTXServiceListener
{
	NSXPCListener* _listener;
}

- (void)run
{
	_listener = [[NSXPCListener alloc] initWithMachServiceName:@"com.wix.DetoxMachService"];
	_listener.delegate = self;
	[_listener resume];
	
	[NSRunLoop.currentRunLoop run];
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
	newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DetoxHelperAPI)];
	newConnection.exportedObject = self;
	
	[newConnection resume];
	
	return YES;
}

- (void)waitForIdleWithCompletionHandler:(dispatch_block_t)completionHandler
{
	completionHandler();
}

@end

int main(int argc, const char * argv[]) {
	[[DTXServiceListener new] run];
	
	return 0;
}
