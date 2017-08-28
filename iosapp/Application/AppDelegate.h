//
//  AppDelegate.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-13.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "WXApi.h"

#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) id <WeiboSDKDelegate, WXApiDelegate> loginDelegate;
@property (nonatomic, strong) BMKMapManager *mapManager;
@property (nonatomic, strong) BMKLocationService *locationService;
@property (nonatomic,assign) CLLocationCoordinate2D curLocation;
@property (nonatomic, strong) BMKRadarManager *radarManager;

@end

