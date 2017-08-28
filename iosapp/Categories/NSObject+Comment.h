//
//  NSObject+Comment.h
//  iosapp
//
//  Created by Graphic-one on 16/11/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "enumList.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Comment)


@end





/** cache comment*/
typedef NS_ENUM (NSInteger,SandboxCacheType){
    SandboxCacheType_banner             = 0,
    SandboxCacheType_list               = 1,
    SandboxCacheType_detail             = 2,
    SandboxCacheType_notice             = 3,
    SandboxCacheType_chat               = 4,
    SandboxCacheType_other              = 5,
    
    SandboxCacheType_temporary          = 6,
    SandboxCacheType_webViewImages      = 7,
    SandboxCacheType_userContacter      = 8,
    SandboxCacheType_topic              = 9,
};///新增缓存类型需要更新 +(NSArray* )sandboxCacheTypes;
FOUNDATION_EXPORT NSString * const SandboxCacheType_bannerFolderName;
FOUNDATION_EXPORT NSString * const SandboxCacheType_listFolderName;
FOUNDATION_EXPORT NSString * const SandboxCacheType_detailFolderName;
FOUNDATION_EXPORT NSString * const SandboxCacheType_noticeFolderName;
FOUNDATION_EXPORT NSString * const SandboxCacheType_chatFolderName;
FOUNDATION_EXPORT NSString * const SandboxCacheType_otherFolderName;
FOUNDATION_EXPORT NSString * const SandboxCacheType_temporaryFolderName;
FOUNDATION_EXPORT NSString * const SandboxCacheType_webViewImagesFolderName;
FOUNDATION_EXPORT NSString * const SandboxCacheType_userContacterFolderName;
FOUNDATION_EXPORT NSString * const SandboxCacheType_topicFolderName;

#define detailCacheMaxSize 6291456 //1024 * 1024 * 5
#define chatCacheMaxSize   3145728 //1024 * 1024 * 3

@interface NSObject (Cache)

/**
 缓存文件名的命名规则 ::
 请求URL+参数字典的Desc+用户ID ---'hash'---> hash.plist
 
 持久化 
 result:{
         "items":[
                     { item 1... },
                     { item 2... },
                     { item 3... }
                 ],
         "nextPageToken" :"string",
         "prevPageToken" :"string",
         "totalResults"  :"integer",
         "resultsPerPage":"integer"
         }
 */

+ (NSString* )cacheResourceNameWithURL:(NSString* )requestUrl
               parameterDictionaryDesc:(nullable NSString* )paraDicDesc;

+ (NSString* )cacheBannerResourceNameWithURL:(NSString* )requestUrl
                               bannerCatalog:(OSCInformationListBannerType)catalog;

/** 网络请求handle */
+ (BOOL)handleResponseObject:(id)responseObject
                    resource:(NSString* )resourceName
                   cacheType:(SandboxCacheType)sandboxCacheType;


+ (id)responseObjectWithResource:(NSString* )resourceName
                       cacheType:(SandboxCacheType)sandboxCacheType;

+ (nullable NSDate* )getFileCreatDateWithResourceName:(NSString* )resourceName
                                            cacheType:(SandboxCacheType)sandboxCacheType;

#pragma mark - file M

/** webView images 专用缓存 */

+ (NSString* )webViewImagesCacheFolderPath; ///webView图片缓存文件夹

/** 常规缓存 */
+ (NSString* )list_cacheFolderPath;     ///列表缓存文件夹的全路径

+ (NSString* )detail_cacheFolderPath;   ///详情缓存文件夹的全路径

+ (NSString* )banner_cacheFolderPath;   ///banner缓存文件夹的全路径

+ (NSString* )notice_cacheFolderPath;   ///通知类缓存文件夹的全路径

+ (NSString* )chat_cacheFolderPath;     ///私信类缓存文件夹的全路径

+ (NSString* )other_cacheFolderPath;    ///额外类缓存文件夹的全路径

/** 当日临时缓存 */
+ (NSString* )oneTheDay_cacheFolderPath;///临时缓存文件夹的全路径（存储当日浏览的全部详情信息 隔天删除）

+ (NSString* )cacheFilePathWithResourceName:(NSString* )resourceName
                                  cacheType:(SandboxCacheType)sandboxCacheType;///根据'resourceName'获取文件的全路径

+ (BOOL)createCacheFileWithResourceName:(NSString* )resourceName
                              cacheType:(SandboxCacheType)sandboxCacheType;///根据'resourceName'创建缓存文件夹下面的文件

+ (void)clearOldCache;///仅提供与v3.7.7版本调用 ( 保留至v3.7.9版本 防止跨版本升级 )

+ (void)DetectionOfCache2Delete;///<检测常规缓存并删除

+ (void)deleteTemporaryCache;   ///<检测当日临时缓存缓存并删除

+ (void)deleteCacheWithSandboxCacheType:(SandboxCacheType)sandboxCacheType; ///<删除指定类型缓存

+ (void)deleteAllCache;         ///<删除全部缓存

@end


/** userContacter cache comment */
@class OSCAuthor;
@interface NSObject (UserContacter)

+ (nullable NSArray<OSCAuthor* >* )recentlyContacter;    ///< 最近联系人(最多显示10位)

+ (nullable NSArray<OSCAuthor* >* )attentionContacter;   ///< 用户关注用户

+ (BOOL)updateToRecentlyContacterList:(OSCAuthor* )user;               ///< 将用户更新到最近联系人列表中

+ (BOOL)coverToAttentionContacterList:(NSArray<OSCAuthor* >* )users;   ///< 将用户覆盖到用户关注列表中

+ (BOOL)updateToAttentionContacterList:(NSArray<OSCAuthor* >* )user;   ///< 将用户更新到用户关注列表中

+ (void)removeAllContacter;       ///< remove所有联系人

+ (void)removeRecentlyContacter;  ///< 清除最近联系人(最多显示10位)

+ (void)removeAttentionContacter; ///< 清除用户关注用户

@end




/** topic cache comment */
@interface NSObject (Topic)

+ (nullable NSArray<NSString* >* )allLocalTopics;   ///< 全部的本地存储的话题

+ (BOOL)updateTopic2LocalTopic:(NSString* )topic;   ///< 更新话题到本地话题

+ (BOOL)removeTopic:(NSString* )topicName;          ///< 从本地存储中删除话题

+ (BOOL)removeAllTopics;                            ///< 删除全部的本地存储话题

@end




/** msgCount comment */
#define MsgCount_Notification_Key       @"MsgCountDidChange"

@interface NSObject (MsgCount)

+ (void)settingTagHasBeenRead:(MsgCountType)msgCountType;

+ (void)handleMsgCount:(NSDictionary* )msgCount_Dic;

@end





NS_ASSUME_NONNULL_END
