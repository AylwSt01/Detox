//
//  xpc_extensions.m
//  Detox
//
//  Created by Leo Natan (Wix) on 9/22/19.
//

#import "xpc_extensions.h"
@import ObjectiveC;

@interface NSXPCConnection (ZZZ) @end
@implementation NSXPCConnection (ZZZ)

+ (void)load
{
	Method m1 = class_getInstanceMethod(NSXPCConnection.class, @selector(resume));
	Method m2 = class_getInstanceMethod(NSXPCConnection.class, @selector(_dtx_resume));
	method_exchangeImplementations(m1, m2);
	
	m1 = class_getInstanceMethod(NSXPCConnection.class, @selector(synchronousRemoteObjectProxyWithErrorHandler:));
	m2 = class_getInstanceMethod(NSXPCConnection.class, @selector(_dtx_synchronousRemoteObjectProxyWithErrorHandler:));
	method_exchangeImplementations(m1, m2);
	
	m1 = class_getInstanceMethod(NSXPCConnection.class, @selector(setRemoteObjectInterface:));
	m2 = class_getInstanceMethod(NSXPCConnection.class, @selector(_dtx_setRemoteObjectInterface:));
	method_exchangeImplementations(m1, m2);
}

- (void)_dtx_resume
{
	[self _dtx_resume];
}

- (id)_dtx_synchronousRemoteObjectProxyWithErrorHandler:(void (^)(NSError * _Nonnull))handler
{
	return [self _dtx_synchronousRemoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
		handler(error);
	}];
}

extern const char *
_protocol_getMethodTypeEncoding(Protocol *proto_gen, SEL sel,
								BOOL isRequiredMethod, BOOL isInstanceMethod);

- (void)_dtx_setRemoteObjectInterface:(NSXPCInterface *)exportedInterface
{
	unsigned int count;
	struct objc_method_description* methods = protocol_copyMethodDescriptionList(exportedInterface.protocol, YES, YES, &count);
	for (unsigned int idx = 0; idx < count; idx++)
	{
		struct objc_method_description desc = methods[idx];
		const char* extendedTypes = _protocol_getMethodTypeEncoding(exportedInterface.protocol, desc.name, YES, YES);
		
		NSLog(@"%@: %@", NSStringFromSelector(desc.name), @(extendedTypes));
	}
	free(methods);
	
	[self _dtx_setRemoteObjectInterface:exportedInterface];
}

@end

extern NSData* _DTXSerializationDataForListenerEndpoint(NSXPCListenerEndpoint* endpoint)
{
	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
	
	id z = [endpoint valueForKey:@"endpoint"];
	size_t obj_size = malloc_size((__bridge void*)z);
	size_t instance_size = class_getInstanceSize([z class]);
	size_t extraBytes = obj_size - instance_size;
	NSData* obj_data = [NSData dataWithBytes:(__bridge void*)z length:obj_size];
	
	[archiver encodeObject:obj_data forKey:@"data"];
	[archiver encodeObject:@(obj_size) forKey:@"obj_size"];
	[archiver encodeObject:@(instance_size) forKey:@"instance_size"];
	[archiver encodeObject:@(extraBytes) forKey:@"extraBytes"];
	[archiver encodeObject:NSStringFromClass([z class]) forKey:@"class"];
	
	return [archiver encodedData];
}

extern NSXPCListenerEndpoint* _DTXListenerEndpointFromSerializationData(NSData* data)
{
	NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	
	Class cls = NSClassFromString([unarchiver decodeObjectForKey:@"class"]);
	size_t extraBytes = [[unarchiver decodeObjectForKey:@"extraBytes"] unsignedLongLongValue];
	size_t obj_size = [[unarchiver decodeObjectForKey:@"obj_size"] unsignedLongLongValue];
	NSData* obj_data = [unarchiver decodeObjectForKey:@"data"];
	
	id a = class_createInstance(cls, extraBytes);
	[obj_data getBytes:(__bridge void*)a length:obj_size];
	
	NSXPCListenerEndpoint* endpoint = [NSXPCListenerEndpoint new];
	[endpoint setValue:a forKey:@"endpoint"];
	
	return endpoint;
}
