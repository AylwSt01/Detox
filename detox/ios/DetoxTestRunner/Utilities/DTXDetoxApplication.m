//
//  DTXDetoxApplication.m
//  DetoxTestRunner
//
//  Created by Leo Natan (Wix) on 9/22/19.
//

#import "DTXDetoxApplication.h"
#import "xpc_extensions.h"
@import ObjectiveC;

@interface NSObject ()

- (id)initWithServiceName:(NSString *)serviceName;
- (id)initWithMachServiceName:(NSString *)name;

@end

@interface DTXDetoxApplication () <NSXPCListenerDelegate>
{
	NSXPCListener* _listener;
	NSXPCConnection* _detoxHelperConnection;
	
	dispatch_queue_t _serviceQueue;
}

@end

@implementation DTXDetoxApplication

+ (void)load
{
//	Method m1 = class_getInstanceMethod(NSClassFromString(@"XCUIApplicationImpl"), NSSelectorFromString(@"_launchUsingPlatformWithArguments:environment:"));
//	Method m2 = class_getInstanceMethod(NSClassFromString(@"XCUIApplicationImpl"), NSSelectorFromString(@"_launchUsingXcodeWithArguments:environment:"));
//
//	IMP imp2 = method_getImplementation(m2);
//	method_setImplementation(m1, imp2);
	
	Method m = class_getInstanceMethod(NSClassFromString(@"XCUIApplicationRegistryRecord"), NSSelectorFromString(@"isTestDependency"));
	method_setImplementation(m, imp_implementationWithBlock(^ (id _self) {
		return YES;
	}));
}

- (void)_commonInit
{
	_listener = [NSXPCListener anonymousListener];
	_listener.delegate = self;
	[_listener resume];
	
	NSXPCConnection* c = [(id)[NSXPCConnection alloc] initWithMachServiceName:@"com.apple.testmanagerd" options:0];
	c.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DetoxHelperAPI)];
	[c resume];
	
	[[c synchronousRemoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
		NSLog(@"%@", error);
	}] waitForIdleWithCompletionHandler:^{
		NSLog(@"Yay");
	}];
	
//	_serviceQueue = dispatch_queue_create(@"com.wix.DetoxTester.service", 0);
//	_service = [EDOHostService serviceWithPort:0 rootObject:self queue:dispatch_get_main_queue()];
	
//	NSData* obj_data = _DTXSerializationDataForListenerEndpoint(_listener.endpoint);
//	NSXPCListenerEndpoint* endpoint = _DTXListenerEndpointFromSerializationData(obj_data);
//
//	NSXPCConnection* c = [[NSXPCConnection alloc] initWithListenerEndpoint:endpoint];
//	c.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DetoxHelperAPI)];
//	[c resume];
//
//	[[c synchronousRemoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
//		NSLog(@"Error: %@", error);
//	}] waitForIdleWithCompletionHandler:^{
//		NSLog(@"Done");
//	}];
}

- (instancetype)initWithBundleIdentifier:(NSString *)bundleIdentifier
{
	self = [super initWithBundleIdentifier:bundleIdentifier];
	
	if(self)
	{
		[self _commonInit];
	}
	
	return self;
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		[self _commonInit];
	}
	
	return self;
}

- (NSXPCConnection*)detoxHelperConnection
{
	return _detoxHelperConnection;
}

- (id<DetoxHelperAPI>)detoxHelper
{
	return _detoxHelperConnection.remoteObjectProxy;
}

- (void)launch
{
	NSMutableDictionary* userEnvironment = self.launchEnvironment.mutableCopy;
	userEnvironment[@"DYLD_INSERT_LIBRARIES"] = [[[NSBundle bundleForClass:self.class] URLForResource:@"DetoxHelper" withExtension:@"framework"] URLByAppendingPathComponent:@"DetoxHelper"].path;
//	userEnvironment[@"DetoxRunnerPort"] = @(_service.port.port);
	userEnvironment[@"DetoxRunnerEndpoint"] = [_DTXSerializationDataForListenerEndpoint(_listener.endpoint) base64EncodedStringWithOptions:0];
	self.launchEnvironment = userEnvironment;
	
	[super launch];
	
	NSLog(@"%@", self.value);
	NSLog(@"");
}

#pragma mark NSXPCListenerDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
	newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DetoxHelperAPI)];
	newConnection.exportedObject = self;
	
	_detoxHelperConnection = newConnection;
	
	[newConnection resume];
	
	return YES;
}

- (void)waitForIdleWithCompletionHandler:(dispatch_block_t)completionHandler
{
	completionHandler();
}

- (void)testHello:(NSString*)hello
{
	NSLog(@"hello");
}

@end
