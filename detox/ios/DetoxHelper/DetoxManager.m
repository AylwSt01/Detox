//
//  DetoxManager.m
//  DetoxHelper
//
//  Created by Leo Natan (Wix) on 9/18/19.
//

#import "DetoxManager.h"
#import "DetoxHelperAPI.h"
@import ObjectiveC;
@import Darwin;
#import "xpc_extensions.h"

@interface NSObject ()

- (id)initWithMachServiceName:(NSString *)name options:(NSXPCConnectionOptions)options;

@end

@interface DetoxManager () <DetoxHelperAPI>
{
	NSXPCConnection* _runnerConnection;
	id _proxy;
}

@end

@implementation DetoxManager

+ (void)load
{
	@autoreleasepool
	{
		[self.sharedListener connect];
	}
}

+ (instancetype)sharedListener
{
	static DetoxManager* manager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [DetoxManager new];
	});
	
	return manager;
}

- (void)connect
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
//		NSInteger port = [NSProcessInfo.processInfo.environment[@"DetoxRunnerPort"] integerValue];
//		id test = [EDOClientService rootObjectWithHostPort:[EDOHostPort hostPortWithLocalPort:port]];
////		[test testHello:@"Hello World!"];
//		[test waitForIdleWithCompletionHandler:^{
//			NSLog(@"");
//		}];
		
		
		NSXPCListenerEndpoint* endpoint = _DTXListenerEndpointFromSerializationData([[NSData alloc] initWithBase64EncodedString:NSProcessInfo.processInfo.environment[@"DetoxRunnerEndpoint"] options:0]);
		_runnerConnection = [[NSXPCConnection alloc] initWithListenerEndpoint:endpoint];
		_runnerConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DetoxHelperAPI)];
		_runnerConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DetoxHelperAPI)];
		_runnerConnection.exportedObject = self;
		[_runnerConnection resume];
		
		[[_runnerConnection synchronousRemoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
			NSLog(@"Error: %@", error);
		}] waitForIdleWithCompletionHandler:^{
			NSLog(@"Done");
		}];
	});
}

- (void)waitForIdleWithCompletionHandler:(dispatch_block_t)completionHandler
{
	completionHandler();
}

@end
