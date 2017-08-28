//
//  OSCThread.h
//  iosapp
//
//  Created by ChanAetern on 3/1/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

#define moitorCycle 60 ///< (1 * 60s)  1min moitor cycle...

@class AFNetworkReachabilityManager;
@interface OSCThread : NSObject

+ (void)udateTimerMonitorNetworking:(NSTimeInterval)timeInterval;

@end
