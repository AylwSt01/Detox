//
//  xpc_extensions.h
//  Detox
//
//  Created by Leo Natan (Wix) on 9/22/19.
//

#import <Foundation/Foundation.h>

@interface NSObject ()
- (instancetype)initWithMachServiceName:(NSString *)name;
- (instancetype)initWithMachServiceName:(NSString *)name options:(NSXPCConnectionOptions)options;
@end

extern NSData* _DTXSerializationDataForListenerEndpoint(NSXPCListenerEndpoint* endpoint);
extern NSXPCListenerEndpoint* _DTXListenerEndpointFromSerializationData(NSData* data);
