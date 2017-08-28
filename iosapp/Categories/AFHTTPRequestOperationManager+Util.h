//
//  AFHTTPRequestOperationManager+Util.h
//  iosapp
//
//  Created by AeternChan on 6/18/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface AFHTTPRequestOperationManager (Util)

+ (instancetype)OSCManager;         ///<  XML manger

+ (instancetype)OSCJsonManager;     ///< JSON manger

+ (NSString *)generateUserAgent;

@end


@interface AFNetworkReachabilityManager (Comment)

+ (AFNetworkReachabilityManager* )shareReachability;

@end
