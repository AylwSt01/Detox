//
//  AppDelegate.m
//  ExampleApp
//
//  Created by Leo Natan (Wix) on 9/18/19.
//

#import "AppDelegate.h"
#import "DetoxHelperAPI.h"
#import "xpc_extensions.h"

@interface AppDelegate () <NSXPCListenerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
	NSXPCConnection* c = [(id)[NSXPCConnection alloc] initWithMachServiceName:@"com.apple.testmanagerd" options:0];
	c.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DetoxHelperAPI)];
	[c resume];
	
	[[c synchronousRemoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
		NSLog(@"%@", error);
	}] waitForIdleWithCompletionHandler:^{
		NSLog(@"Yay");
	}];
	
	return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
	// Called when a new scene session is being created.
	// Use this method to select a configuration to create the new scene with.
	return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
	// Called when the user discards a scene session.
	// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
	// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
