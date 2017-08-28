//
//  OSCThread.m
//  iosapp
//
//  Created by ChanAetern on 3/1/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCThread.h"
#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"
#import "OSCModelHandler.h"

#import "AFHTTPRequestOperationManager+Util.h"

#import <AFNetworking.h>

 
@implementation OSCThread

static NSTimer* _shareTimer;
+ (void)udateTimerMonitorNetworking:(NSTimeInterval)timeInterval
{
    if (_shareTimer) { [_shareTimer invalidate]; }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _shareTimer = [NSTimer timerWithTimeInterval:timeInterval block:^(NSTimer * _Nonnull timer) {
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
            
            NSString *strUrl = [NSString stringWithFormat:@"%@notice", OSCAPI_V2_PREFIX];
            
            [manager GET:strUrl parameters:@{ @"clear" : @(NO)} success:nil failure:nil];
            
        } repeats:NO];
        
        [[NSRunLoop currentRunLoop] addTimer:_shareTimer forMode:NSRunLoopCommonModes];
        
    });
}

@end
