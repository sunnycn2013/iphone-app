//
//  AFHTTPRequestOperationManager+Util.m
//  iosapp
//
//  Created by AeternChan on 6/18/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "AFHTTPRequestOperationManager+Util.h"
#import "UIDevice+SystemInfo.h"
#import "NSObject+Comment.h"
#import "Utils.h"
#import "OSCAPI.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <UIKit/UIKit.h>

@implementation AFHTTPRequestOperationManager (Util)

static AFHTTPRequestOperationManager* _OSCManager;
+ (instancetype)OSCManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _OSCManager = [AFHTTPRequestOperationManager manager];
        _OSCManager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
        _OSCManager.responseSerializer.acceptableContentTypes = [_OSCManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [_OSCManager.requestSerializer setValue:[self generateUserAgent] forHTTPHeaderField:@"User-Agent"];
        [_OSCManager.requestSerializer setValue:[Utils getAppToken] forHTTPHeaderField:@"AppToken"];
    });
    return _OSCManager;
}

static AFHTTPRequestOperationManager* _OSCJsonManager;
+ (instancetype)OSCJsonManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _OSCJsonManager = [AFHTTPRequestOperationManager manager];
        _OSCJsonManager.responseSerializer.acceptableContentTypes = [_OSCJsonManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [_OSCJsonManager.requestSerializer setValue:[self generateUserAgent] forHTTPHeaderField:@"User-Agent"];
        [_OSCJsonManager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [_OSCJsonManager.requestSerializer setValue:AppToken forHTTPHeaderField:@"AppToken"];
    });
    return _OSCJsonManager;
}


/** UA : "OSChina.NET/1.0 (oscapp; %s; iPhone %s; %s; %s)" */
+ (NSString *)generateUserAgent
{
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString* systemVersion = [UIDevice currentDevice].systemVersion;
    NSString* deviceCateory = kDeviceArray[[UIDevice currentDeviceResolution]];
    NSString *UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    //OSChina.NET/1.0 (oscapp; 3.7.6; iPhone 10.0; Simulator; 9C8AAFCD-FE47-4E56-AD1A-0DBD6A8315D8)
    NSString* UA = [NSString stringWithFormat:@"OSChina.NET/1.0 (oscapp; %@; iPhone %@; %@; %@)",appVersion,systemVersion,deviceCateory,UUID];
//    NSLog(@"UA :: %@",UA);

    return UA;
}

@end





@implementation AFNetworkReachabilityManager (Comment)

static AFNetworkReachabilityManager* _shareReachability;
+ (AFNetworkReachabilityManager* )shareReachability{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareReachability = [AFNetworkReachabilityManager managerForAddress:@"www.oschina.net"];
    });
    return _shareReachability;
}

@end








