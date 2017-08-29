//
//  AppDelegate.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-13.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
#import "Utils.h"
#import "UIView+Util.h"
#import "UIColor+Util.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCAPI.h"
#import "ScanViewController.h"
#import "ShakingViewController.h"
#import "TweetEditingVC.h"
#import "SwipableViewController.h"
#import "OSCInformationDetailController.h"
#import "NewBlogDetailController.h"
#import "OSCShareManager.h"
#import "OSCShareInvitation.h"
#import "OSCURLProtocol.h"
#import "OSCTabBarController.h"
#import "SoftWareViewController.h"
#import "QuesAnsDetailViewController.h"
#import "TranslationViewController.h"
#import "ActivityDetailViewController.h"
#import "OSCRandomCenterController.h"
#import "OSCSearchViewController.h"
#import "NewLoginViewController.h"
#import "UMMobClick/MobClick.h"
#import "NSObject+Comment.h"
#import "UIViewController+Comment.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCPushTypeControllerHelper.h"
#import "OSCReadingInfoManager.h"

#import <AFOnoResponseSerializer.h>
#import <Ono.h>

#import <UMSocial.h>
#import <UMengSocial/UMSocialQQHandler.h>
#import <UMengSocial/UMSocialWechatHandler.h>
#import <UMengSocial/UMSocialSinaSSOHandler.h>

#import "MTAManager.h"
#import "BuglyManager.h"

#define UM_APP_KEY @"54c9a412fd98c5779c000752"

#define WX_PAY_ID @"wxa8213dc827399101"
#define WX_APP_ID @"wxa8213dc827399101"
#define WX_APP_SECRET @"5c716417ce72ff69d8cf0c43572c9284"

#define SINA_APP_KEY @"3616966952"
#define SINA_APP_SECRET @"fd81f6d31427b467f49226e48a741e28"

#define QQ_APP_ID @"100942993"
#define QQ_APP_KEY @"8edd3cc7ca8dcc15082d6fe75969601b"

#define SHARE_EXTENSION_GROUP_ID @"group.net.oschina.share.tweet.app"

@interface AppDelegate () <UIApplicationDelegate>

@end

@implementation AppDelegate

NSLock *lock;

#pragma mark - 声明周期
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    ///缓存清理
    [NSObject deleteTemporaryCache];
    [NSObject DetectionOfCache2Delete];
	
	//缓存设置
	[self setupCache];
    [MTAManager initMTA];
    [BuglyManager initBugly];
	//加载Cookie
    [self loadCookies];
	
	//第三方配置
	[self setupThirdPartyStuff];
	
	//控件外观设置
	[self setupLookAndFeel];
    
    //检测通知
	UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
	UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
	[[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
	
	//3D Touch相关设置
	UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKeyedSubscript:UIApplicationLaunchOptionsShortcutItemKey];
	if(shortcutItem) {
		[self quickActionWithShortcutItem:shortcutItem];
	}
	
	//用户信息搜集
	[self uploadReadingInfo];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	OSCShareManager *shareManeger = [OSCShareManager shareManager];
	[shareManeger hiddenShareBoard];
    
    //隐藏邀请函的分享
    OSCShareInvitation *shareInvitation = [OSCShareInvitation shareManager];
    [shareInvitation hiddenShareBoard];
}

- (void)applicationWillTerminate:(UIApplication *)application {}

#pragma mark - 友盟等第三方相关配置
-(void) setupThirdPartyStuff {
	//友盟统计SDK
	UMConfigInstance.appKey = UM_APP_KEY;
	UMConfigInstance.channelId = @"AppStore";
	[MobClick startWithConfigure:UMConfigInstance];
	
	//友盟分享组件
	[UMSocialData setAppKey:UM_APP_KEY];
	[UMSocialWechatHandler setWXAppId:WX_APP_ID
							appSecret:WX_APP_SECRET
								  url:@"http://www.umeng.com/social"];
	
	[UMSocialQQHandler setQQWithAppId:QQ_APP_ID
							   appKey:QQ_APP_KEY
								  url:@"http://www.umeng.com/social"];
	
	[UMSocialQQHandler setSupportWebView:YES];
	[UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:SINA_APP_KEY
											  secret:SINA_APP_SECRET
										 RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
	
	/************ 第三方登录设置 *************/
	[WeiboSDK enableDebugMode:YES];
	[WeiboSDK registerApp:SINA_APP_KEY];
	
}

#pragma mark - 外部链接点击处理

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [UMSocialSnsService handleOpenURL:url]             ||
           [WXApi handleOpenURL:url delegate:_loginDelegate]  ||
           [TencentOAuth HandleOpenURL:url]                   ||
           [WeiboSDK handleOpenURL:url delegate:_loginDelegate];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //外部链接打开相关详情界面
    if ([[url scheme] isEqualToString:@"oscapp"]) {
        NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
        NSLog(@"URL scheme:%@", [url scheme]);
        NSLog(@"URL query: %@", [url query]);

        UIViewController* curVC ;
        if (_window.rootViewController) {
            curVC = [UIViewController topViewControllerForViewController:_window.rootViewController];
        }
		
        __block NSInteger type = 0;
        __block NSInteger objId = 0;
        UIViewController *detailVc;
        NSArray *queryArray = [[url query] componentsSeparatedByString:@"&"];
        [queryArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj containsString:@"type"] && ![obj isEqualToString:@"main"]) {
                NSCharacterSet* nonDigits =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                type =[[obj stringByTrimmingCharactersInSet:nonDigits] integerValue];
            } else if ([obj containsString:@"id"]) {
                NSCharacterSet* nonDigits =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                objId =[[obj stringByTrimmingCharactersInSet:nonDigits] integerValue];
            }
        }];
    
        detailVc = [OSCPushTypeControllerHelper pushControllerGeneralWithType:type detailContentID:objId];
        
        if (detailVc) {
            detailVc.hidesBottomBarWhenPushed = YES;
            if ([curVC isKindOfClass:[OSCTabBarController class]]) {
                OSCTabBarController* tabVC = (OSCTabBarController* )curVC;
                [tabVC.selectedViewController pushViewController:detailVc animated:YES];
            }else{
                [curVC.navigationController pushViewController:detailVc animated:YES];
            }
        }
        return YES;
    }else {
        return [UMSocialSnsService handleOpenURL:url]             ||
        [WXApi handleOpenURL:url delegate:_loginDelegate]  ||
        [TencentOAuth HandleOpenURL:url]                   ||
        [WeiboSDK handleOpenURL:url delegate:_loginDelegate];
    }    
}

#pragma mark - 设置外观

- (void)setupLookAndFeel {
	
	[UIApplication sharedApplication].statusBarHidden = NO;
	
	NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
	[[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
	[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
	
	[[UITabBar appearance] setTintColor:[UIColor colorWithHex:0x24CF5F]];
	[[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x24cf5f]} forState:UIControlStateSelected];
	
	[[UINavigationBar appearance] setBarTintColor:[UIColor navigationbarColor]];
	[[UITabBar appearance] setBarTintColor:[UIColor titleBarColor]];
	
	[UISearchBar appearance].tintColor = [UIColor colorWithHex:0x15A230];
	[[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setCornerRadius:14.0];
	[[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setAlpha:0.6];
	
	
	UIPageControl *pageControl = [UIPageControl appearance];
	pageControl.pageIndicatorTintColor = [UIColor colorWithHex:0xDCDCDC];
	pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
	
	[[UITextField appearance] setTintColor:[UIColor nameColor]];
	[[UITextView appearance]  setTintColor:[UIColor nameColor]];
	
	
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	[menuController setMenuVisible:YES animated:YES];
	[menuController setMenuItems:@[
								   [[UIMenuItem alloc] initWithTitle:@"复制" action:NSSelectorFromString(@"copyText:")],
								   [[UIMenuItem alloc] initWithTitle:@"删除" action:NSSelectorFromString(@"deleteObject:")]
								   ]];
}

#pragma mark - 3D Touch 处理
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    [self quickActionWithShortcutItem:shortcutItem];
    completionHandler(YES);
}

- (void)quickActionWithShortcutItem:(UIApplicationShortcutItem *)shortcutItem
{
    NSLog(@"%@",shortcutItem.type);
    
    if ([shortcutItem.type isEqualToString:@"弹一弹"]) {
        if ([Config getOwnID] == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
            NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
            [self.window.rootViewController presentViewController:loginVC animated:YES completion:nil];
        }else{
            TweetEditingVC *tweetEditingVC = [TweetEditingVC new];
            UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
            [self.window.rootViewController presentViewController:tweetEditingNav animated:YES completion:nil];
        }
    } else if ([shortcutItem.type isEqualToString:@"扫一扫"]) {
        ScanViewController *scanVC = [ScanViewController new];
        UINavigationController *scanNav = [[UINavigationController alloc] initWithRootViewController:scanVC];
        [self.window.rootViewController presentViewController:scanNav animated:NO completion:nil];
        
    } else if ([shortcutItem.type isEqualToString:@"找一找"]) {
        OSCSearchViewController *personSearchVC = [OSCSearchViewController new];
        UINavigationController *personSearchNavVC = [[UINavigationController alloc] initWithRootViewController:personSearchVC];
        [self.window.rootViewController presentViewController:personSearchNavVC animated:YES completion:nil];
    
    } else if ([shortcutItem.type isEqualToString:@"摇一摇"]) {
        if ([Config getOwnID] == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
            NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
            [self.window.rootViewController presentViewController:loginVC animated:YES completion:nil];
        }else{
            OSCRandomCenterController *shakingVC = [OSCRandomCenterController new];
            UINavigationController *shakingNavVC = [[UINavigationController alloc] initWithRootViewController:shakingVC];
            [self.window.rootViewController presentViewController:shakingNavVC animated:YES completion:nil];
        }
    }
}

#pragma mark - Cookie 缓存加载
- (void)loadCookies {
    NSUserDefaults* shareExstension = [[NSUserDefaults alloc] initWithSuiteName:SHARE_EXTENSION_GROUP_ID];
    
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	
    NSMutableArray* mArr = @[].mutableCopy;
	for (NSHTTPCookie *cookie in cookies){
		[cookieStorage setCookie: cookie];
        if ([cookie.domain isEqualToString:@".oschina.net"]) {
            [mArr addObject:cookie];
        }
	}
    
    if (mArr.count > 0) {
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:mArr.copy];
        [shareExstension setObject:data forKey:@"groupShareExtensionCookies"];
    }
    [shareExstension setObject:[AFHTTPRequestOperationManager generateUserAgent] forKey:@"groupShareExtensionUA"];
    [shareExstension setObject:[Utils getAppToken] forKey:@"groupShareExtensionAppToken"];
    [shareExstension synchronize];
}

#pragma mark - Webview缓存设置
- (void)setupCache {
	int cacheSizeMemory = 1*1024*1024;
	int cacheSizeDisk   = 5*1024*1024;
	NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity: cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
	[NSURLCache setSharedURLCache:sharedCache];
}

#pragma mark - 用户阅读习惯搜集 
- (void)uploadReadingInfo {
    //启动时间和上一次上传时间比较。是否超过48小时。
    NSString *lastTimeStr = [Config getLastUploadTime];
    // 比较时间
    
    NSDate* curDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay;
    NSDateComponents* components = [calendar components:unitFlags fromDate:[NSDate dateFromString:lastTimeStr] toDate:curDate options:0];

    OSCReadingInfoManager *readInfoManager = [OSCReadingInfoManager shareManager];
    if (components.day >= 2) {//如果超过48小时，立马上传
        NSMutableArray *arrDic  =  [readInfoManager queryData];
        [readInfoManager uploadReadingInfoWith:arrDic];
    }else {//48小时之内判断是否超过15条
        NSMutableArray *arrDic  =  [readInfoManager queryData];
        if ([arrDic count] >= 15) {
            [readInfoManager uploadReadingInfoWith:arrDic];
        }
    }
}

@end
