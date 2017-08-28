//
//  NSObject+Comment.m
//  iosapp
//
//  Created by Graphic-one on 16/11/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NSObject+Comment.h"

#import "Utils.h"
#import "Config.h"
#import "OSCListItem.h"
#import "OSCMsgCount.h"

#import "OSCModelHandler.h"


@implementation NSObject (Comment)

@end


/** cache comment*/
NSString * const SandboxCacheType_bannerFolderName      = @"bannercache";
NSString * const SandboxCacheType_listFolderName        = @"listcache";
NSString * const SandboxCacheType_detailFolderName      = @"detailcache";
NSString * const SandboxCacheType_noticeFolderName      = @"noticecache";
NSString * const SandboxCacheType_chatFolderName        = @"chatcache";
NSString * const SandboxCacheType_otherFolderName       = @"othercache";
NSString * const SandboxCacheType_temporaryFolderName   = @"oneTheDay";

NSString * const SandboxCacheType_webViewImagesFolderName = @"webViewImages";
NSString * const SandboxCacheType_userContacterFolderName = @"userContacter";
NSString * const SandboxCacheType_topicFolderName         = @"topicFolderName";


@implementation NSObject (Cache)

+ (NSString* )cacheResourceNameWithURL:(NSString* )requestUrl
               parameterDictionaryDesc:(nullable NSString* )paraDicDesc
{
    NSString* resourceName = [NSString stringWithFormat:@"%@%@%ld",requestUrl,paraDicDesc,(long)[Config getOwnID]];
    return [Utils sha1:resourceName];
}

+ (NSString* )cacheBannerResourceNameWithURL:(NSString* )requestUrl
                               bannerCatalog:(OSCInformationListBannerType)catalog
{
    NSString* bannerResourceName = [NSString stringWithFormat:@"%@%ld%ld",requestUrl,(long)catalog,(long)[Config getOwnID]];
    return [Utils sha1:bannerResourceName];
}

/** 网络请求handle */
+ (BOOL)handleResponseObject:(id)responseObject
                    resource:(NSString* )resourceName
                   cacheType:(SandboxCacheType)sandboxCacheType
{
    if (!responseObject || !resourceName) { return NO; }
    if ([Config getOwnID] == 0) { return NO ;}
    
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary* responseObjectData = (NSDictionary* )responseObject;
        if ([self createCacheFileWithResourceName:resourceName cacheType:sandboxCacheType]) {
            NSString* path = [self cacheFilePathWithResourceName:resourceName cacheType:sandboxCacheType];
            return [responseObjectData writeToFile:path atomically:YES];
        }else{
            return NO;
        }
    }
    
    if ([responseObject isKindOfClass:[NSArray class]]) {
        NSArray* responseObjectData = (NSArray* )responseObject;
        if ([self createCacheFileWithResourceName:resourceName cacheType:sandboxCacheType]) {
            NSString* path = [self cacheFilePathWithResourceName:resourceName cacheType:sandboxCacheType];
            return [responseObjectData writeToFile:path atomically:YES];
        }else{
            return NO;
        }
    }
    
    return NO;
}

+ (id)responseObjectWithResource:(NSString* )resourceName
                       cacheType:(SandboxCacheType)sandboxCacheType
{
    NSString* path = [self cacheFilePathWithResourceName:resourceName cacheType:sandboxCacheType];
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

+ (nullable NSDate* )getFileCreatDateWithResourceName:(NSString* )resourceName
                                            cacheType:(SandboxCacheType)sandboxCacheType;
{
    NSString* path = [self cacheFilePathWithResourceName:resourceName cacheType:sandboxCacheType];
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (isExists) {
        NSDictionary* dic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
        return [dic valueForKey:NSFileCreationDate];
    }else{
        return nil;
    }
}


#pragma mark - file M

+ (NSString* )cacheFolderPath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString* )cacheFilePathWithResourceName:(NSString* )resourceName
                                  cacheType:(SandboxCacheType)sandboxCacheType
{
    resourceName = [NSString stringWithFormat:@"%@.json",resourceName];
    NSString* customFolder = [self sandboxCacheTypes][sandboxCacheType];
    NSString* cacheFilePath = [self customCache_cacheFolderPath:customFolder];
    return [cacheFilePath stringByAppendingPathComponent:resourceName];
}

+ (BOOL)createCacheFileWithResourceName:(NSString* )resourceName
                              cacheType:(SandboxCacheType)sandboxCacheType
{
    NSString* path = [self cacheFilePathWithResourceName:resourceName cacheType:sandboxCacheType];
    NSFileManager* fileManger = [NSFileManager defaultManager];
    BOOL isExists = [fileManger fileExistsAtPath:path];
    BOOL isCreated = NO;
    if (!isExists) {
        isCreated = [fileManger createFileAtPath:path contents:[NSData data] attributes:nil];
    }else{
        isCreated = YES;
    }
    return isCreated;
}

#pragma mark --- 缓存文件夹

+ (NSString* )webViewImagesCacheFolderPath
{
    return [self customCache_cacheFolderPath:SandboxCacheType_webViewImagesFolderName];
}

+ (NSString* )banner_cacheFolderPath
{
    return [self customCache_cacheFolderPath:SandboxCacheType_bannerFolderName];
}

+ (NSString* )list_cacheFolderPath
{
    return [self customCache_cacheFolderPath:SandboxCacheType_listFolderName];
}

+ (NSString* )detail_cacheFolderPath
{
    return [self customCache_cacheFolderPath:SandboxCacheType_detailFolderName];
}

+ (NSString* )notice_cacheFolderPath
{
    return [self customCache_cacheFolderPath:SandboxCacheType_noticeFolderName];
}

+ (NSString* )chat_cacheFolderPath{
    return [self customCache_cacheFolderPath:SandboxCacheType_chatFolderName];
}

+ (NSString* )other_cacheFolderPath
{
    return [self customCache_cacheFolderPath:SandboxCacheType_otherFolderName];
}

+ (NSString* )oneTheDay_cacheFolderPath
{
    return [self customCache_cacheFolderPath:SandboxCacheType_temporaryFolderName];
}

+ (NSString* )customCache_cacheFolderPath:(NSString* )folderName
{
    NSString* custom_cacheFolderPath = [self cacheFolderPath];
    custom_cacheFolderPath = [custom_cacheFolderPath stringByAppendingPathComponent:folderName];
    
    BOOL isDir = NO; BOOL isCreated = NO;
    BOOL isExisted = [[NSFileManager defaultManager] fileExistsAtPath:custom_cacheFolderPath isDirectory:&isDir];
    if (!(isDir && isExisted)) {
        isCreated = [[NSFileManager defaultManager] createDirectoryAtPath:custom_cacheFolderPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    if (isExisted) { isCreated = YES; }
    
    return  isCreated ? custom_cacheFolderPath : nil;
}

+ (void)clearOldCache
{
    NSString* extension1 = @"json";
    NSString* extension2 = @"plist";
    
    NSString* cachePath = [self cacheFolderPath];
    NSArray* docs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:NULL];
    NSEnumerator* enumerator = [docs objectEnumerator];
    
    NSString *fileName;
    while ((fileName = [enumerator nextObject])) {
        
        if ([[fileName pathExtension] isEqualToString:extension1] ||
            [[fileName pathExtension] isEqualToString:extension2] )
        {
            [[NSFileManager defaultManager] removeItemAtPath:[cachePath stringByAppendingPathComponent:fileName] error:NULL];
        }
    }
    
}

+ (void)DetectionOfCache2Delete
{
    NSFileManager* fileManger = [NSFileManager defaultManager];

    NSString* detailFolderPath = [self detail_cacheFolderPath];
    NSDictionary* detailPathInfo = [fileManger attributesOfItemAtPath:detailFolderPath error:NULL];
    
    if ([[detailPathInfo valueForKey:NSFileSize] integerValue] > detailCacheMaxSize) {
        
        [self deleteCacheWithPath:detailFolderPath percentage:0.5];
        
        return;
    }
    
    
    NSString* chatFolderPath   = [self chat_cacheFolderPath];
    NSDictionary* chatPathInfo = [fileManger attributesOfItemAtPath:chatFolderPath  error:NULL];

    if ([[chatPathInfo valueForKey:NSFileSize] integerValue] > chatCacheMaxSize) {
     
        [self deleteCacheWithPath:chatFolderPath percentage:0.5];
        
        return;
    }
}

+ (void)deleteCacheWithPath:(NSString* )curFullPath
                 percentage:(NSInteger)percentage
{
    NSArray* docs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:curFullPath error:NULL];
    NSMutableArray* fullPaths = [NSMutableArray arrayWithCapacity:docs.count];
    for (NSString* fileName in docs) {
        NSString* fullPath = [curFullPath stringByAppendingPathComponent:fileName];
        NSDictionary* curFullPathInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:NULL];
        NSDate* curFullPathCreatDate = [curFullPathInfo valueForKey:NSFileCreationDate];
        NSDictionary* pathDic = @{
                                  @"fullPath"           : fullPath,
                                  @"fullPathCreatDate"  : curFullPathCreatDate
                                  };
        [fullPaths addObject:pathDic];
    }
    
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullPathCreatDate" ascending:YES];
    [fullPaths sortUsingDescriptors:@[descriptor]];
    
    int index = 0;
    for (NSDictionary* fullPath in fullPaths) {
        NSString* curFullPath = fullPath[@"fullPath"];
        [[NSFileManager defaultManager] removeItemAtPath:curFullPath error:NULL];
        index++;
        if (index == fullPaths.count * percentage) { break;}
    }
}

+ (void)deleteTemporaryCache
{
    NSFileManager* fileManger = [NSFileManager defaultManager];
    NSString* temporaryCachePath = [self oneTheDay_cacheFolderPath];
    NSArray* docs = [fileManger contentsOfDirectoryAtPath:temporaryCachePath error:NULL];
    NSEnumerator* enumerator = [docs objectEnumerator];
    
    NSDate* curDate = [NSDate date];
    NSUInteger unitFlags = NSCalendarUnitDay ;
    
    NSString* fileName;
    while (fileName = [enumerator nextObject]) {
        NSString* curFilePath = [temporaryCachePath stringByAppendingPathComponent:fileName];
        NSDictionary* docDicInfo = [fileManger attributesOfItemAtPath:curFilePath error:NULL];
        NSDate *fileCreateDate = [docDicInfo objectForKey:NSFileCreationDate];
    
       NSDateComponents* components = [[NSCalendar currentCalendar] components:unitFlags fromDate:fileCreateDate toDate:curDate options:0];
        if (components.day > 1) {
            [fileManger removeItemAtPath:curFilePath error:NULL];
        }
    }
}

+ (void)deleteCacheWithSandboxCacheType:(SandboxCacheType)sandboxCacheType
{
    NSFileManager* fileManger = [NSFileManager defaultManager];
    NSString* cachePath = [self customCache_cacheFolderPath:[self sandboxCacheTypes][sandboxCacheType]];
    NSArray* docs = [fileManger contentsOfDirectoryAtPath:cachePath error:NULL];
    NSEnumerator* enumerator = [docs objectEnumerator];
    
    NSString* fileName;
    while (fileName = [enumerator nextObject]) {
        NSString* curFilePath = [cachePath stringByAppendingPathComponent:fileName];
        [fileManger removeItemAtPath:curFilePath error:NULL];
    }
}

+ (void)deleteAllCache
{
    [self deleteCacheWithSandboxCacheType:SandboxCacheType_banner];
    [self deleteCacheWithSandboxCacheType:SandboxCacheType_list];
    [self deleteCacheWithSandboxCacheType:SandboxCacheType_detail];
    [self deleteCacheWithSandboxCacheType:SandboxCacheType_notice];
    [self deleteCacheWithSandboxCacheType:SandboxCacheType_chat];
    [self deleteCacheWithSandboxCacheType:SandboxCacheType_other];
    [self deleteCacheWithSandboxCacheType:SandboxCacheType_temporary];
    
    [self deleteCacheWithSandboxCacheType:SandboxCacheType_webViewImages];
    [self deleteCacheWithSandboxCacheType:SandboxCacheType_topic];
}

+ (NSArray* )sandboxCacheTypes{
    return @[SandboxCacheType_bannerFolderName,SandboxCacheType_listFolderName,SandboxCacheType_detailFolderName,SandboxCacheType_noticeFolderName,SandboxCacheType_chatFolderName,SandboxCacheType_otherFolderName,SandboxCacheType_temporaryFolderName,SandboxCacheType_webViewImagesFolderName,SandboxCacheType_userContacterFolderName,SandboxCacheType_topicFolderName];
}

@end





/** userContacter cache comment*/
/** OSCAuthor 私有拓展 私有API导向 */
@interface OSCAuthor ()
- (NSDictionary* )getAuthorJSON;
+ (instancetype)authorWithJSON:(NSDictionary* )dic;
@end

#define recentlyContacter_Key       @"recentlyContacter.json"
#define attentionContacter_Key      @"attentionContacter.json"
@implementation NSObject (UserContacter)

+ (NSString* )contacterFolderPath
{
    return [self customCache_cacheFolderPath:SandboxCacheType_userContacterFolderName];
}

+ (NSString* )contacterFilePath:(NSString* )contacterName{
    NSString* contacterFolderPath = [self contacterFolderPath];
    return [contacterFolderPath stringByAppendingPathComponent:contacterName];
}

+ (nullable NSArray<OSCAuthor* >* )recentlyContacter{
    NSString* recentlyContacterFile = [self contacterFilePath:recentlyContacter_Key];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:recentlyContacterFile]) {
        NSArray* dicArr = [NSArray arrayWithContentsOfFile:recentlyContacterFile];
        NSMutableArray* mutableAuthors = [NSMutableArray arrayWithCapacity:dicArr.count];
        for (NSDictionary* dic in dicArr) {
            [mutableAuthors addObject:[OSCAuthor authorWithJSON:dic]];
        }
        return mutableAuthors.copy;
    }else{
        return nil;
    }
}

+ (nullable NSArray<OSCAuthor* >* )attentionContacter{
    NSString* attentionContacterFile = [self contacterFilePath:attentionContacter_Key];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:attentionContacterFile]) {
        NSArray* dicArr = [NSArray arrayWithContentsOfFile:attentionContacterFile];
        NSMutableArray* mutableAuthors = [NSMutableArray arrayWithCapacity:dicArr.count];
        for (NSDictionary* dic in dicArr) {
            [mutableAuthors addObject:[OSCAuthor authorWithJSON:dic]];
        }
        return mutableAuthors.copy;
    }else{
        return nil;
    }
}

+ (nullable NSArray<NSDictionary* >* )attentionContacter_dic{
    NSString* attentionContacterFile = [self contacterFilePath:attentionContacter_Key];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:attentionContacterFile]) {
        NSArray<NSDictionary* >* dicArr = [NSArray arrayWithContentsOfFile:attentionContacterFile];
        return dicArr.copy;
    }else{
        return nil;
    }
}

+ (BOOL)updateToRecentlyContacterList:(OSCAuthor* )user{
    if (user.id == NSNotFound || user.id == 0) { return NO; }
    if (user.relation == NSNotFound || user.relation == 0) { return NO; } /** 文字硬打出来的@用户 可能不存在 不进行保存*/
    
    NSArray<OSCAuthor* >* recentlyContacter = [self recentlyContacter];
    if (recentlyContacter && recentlyContacter.count > 0) {
        
        BOOL isExisted = NO;
        for (OSCAuthor* author in recentlyContacter) {
            if (author.id == user.id) {
                isExisted = YES;
                break;
            }
        }
        
        NSMutableArray<OSCAuthor* >* mutableRecentlyContacter = recentlyContacter.mutableCopy;
        if (isExisted) {
            [mutableRecentlyContacter removeObject:user];
            [mutableRecentlyContacter insertObject:user atIndex:0];
        }else{
            [mutableRecentlyContacter insertObject:user atIndex:0];
        }
        
        NSInteger D_value = mutableRecentlyContacter.count - 10;
        if (D_value > 0) {
            for (NSInteger i = 0 ; i < D_value; i++) {
                [mutableRecentlyContacter removeLastObject];
            }
        }
        
        NSMutableArray<NSDictionary* >* mutableRecentlyContacter_dic = [NSMutableArray arrayWithCapacity:mutableRecentlyContacter.count];
        for (OSCAuthor* author in mutableRecentlyContacter) {
            [mutableRecentlyContacter_dic addObject:[author getAuthorJSON]];
        }
        
        return [mutableRecentlyContacter_dic.copy writeToFile:[self contacterFilePath:recentlyContacter_Key] atomically:YES];
    }else{
        NSArray* newRecentlyContacter = @[[user getAuthorJSON]];
        return [newRecentlyContacter writeToFile:[self contacterFilePath:recentlyContacter_Key] atomically:YES];
    }
}

+ (BOOL)coverToAttentionContacterList:(NSArray<OSCAuthor* >* )users{
    if (!users || users.count == 0) { return NO; }
    
    NSString* attentionContacterFile = [self contacterFilePath:attentionContacter_Key];
    NSMutableArray* mutableDics = [NSMutableArray arrayWithCapacity:users.count];
    for (OSCAuthor* author in users) {
        [mutableDics addObject:[author getAuthorJSON]];
    }
    return [mutableDics.copy writeToFile:attentionContacterFile atomically:YES];
}

+ (BOOL)updateToAttentionContacterList:(NSArray<OSCAuthor* >* )user{
    if (!user || user.count == 0) { return NO; }

    NSArray<OSCAuthor* >* attentionContacter = [self attentionContacter];
    if (attentionContacter && attentionContacter.count > 0) {
        NSArray<NSDictionary* >* attentionContacter_dic = [self attentionContacter_dic];
        NSMutableArray<NSDictionary* >* mutableAttentionContacter_dic = attentionContacter_dic.mutableCopy;
        for (OSCAuthor* author in user) {
            if (![attentionContacter containsObject:author]) {
                [mutableAttentionContacter_dic addObject:[author getAuthorJSON]];
            }
        }
        return [mutableAttentionContacter_dic.copy writeToFile:[self contacterFilePath:attentionContacter_Key] atomically:YES];
    }else{
        NSMutableArray<NSDictionary* >* mutableDic = [NSMutableArray arrayWithCapacity:20];
        for (OSCAuthor* author in user) {
            [mutableDic addObject:[author getAuthorJSON]];
        }
        return [mutableDic.copy writeToFile:[self contacterFilePath:attentionContacter_Key] atomically:YES];
    }
}

+ (void)removeAllContacter
{
    [self removeRecentlyContacter];
    [self removeAttentionContacter];
}

+ (void)removeRecentlyContacter
{
    [[NSFileManager defaultManager] removeItemAtPath:[self contacterFilePath:recentlyContacter_Key] error:NULL];
}

+ (void)removeAttentionContacter
{
    [[NSFileManager defaultManager] removeItemAtPath:[self contacterFilePath:attentionContacter_Key] error:NULL];

}

@end







/** topic cache comment */
@implementation NSObject (Topic)
+ (NSString* )topicFilePath
{
    return [[self customCache_cacheFolderPath:SandboxCacheType_topicFolderName] stringByAppendingPathComponent:@"topics_list.json"];
}

+ (nullable NSArray<NSString* >* )allLocalTopics
{
    NSString* filePath = [self topicFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [NSArray arrayWithContentsOfFile:filePath];
    }else{
        return nil;
    }
}

+ (BOOL)updateTopic2LocalTopic:(NSString* )topic
{
    if (!topic || [topic isEqual:[NSNull null]]) { return NO; }
    
    NSArray* allTopics = [self allLocalTopics];
    if (allTopics && allTopics.count > 0) {
        NSMutableArray* mAllTopics = allTopics.mutableCopy;
        if ([mAllTopics containsObject:topic]) {
            [mAllTopics removeObject:topic];
        }
        [mAllTopics addObject:topic];
        return [mAllTopics.copy writeToFile:[self topicFilePath] atomically:YES];
    }else{
        NSArray* newTopics = @[topic];
        return [newTopics writeToFile:[self topicFilePath] atomically:YES];
    }
}

+ (BOOL)removeTopic:(NSString* )topicName
{
    NSArray* allTopics = [self allLocalTopics];
    if (allTopics && allTopics.count > 0 ) {
        if ([allTopics containsObject:topicName]) {
            NSMutableArray* mAllTopics = allTopics.mutableCopy;
            [mAllTopics removeObject:topicName];
            if (mAllTopics.count == 0) {
                [self removeAllTopics];
                return YES;
            }
            return [mAllTopics.copy writeToFile:[self topicFilePath] atomically:YES];
        }else{
            return YES;
        }
    }else{
        return YES;
    }
}

+ (BOOL)removeAllTopics
{
    NSFileManager* fileManger = [NSFileManager defaultManager];
    if ([fileManger fileExistsAtPath:[self topicFilePath]]) {
        return [fileManger removeItemAtPath:[self topicFilePath] error:NULL];
    }else{
        return YES;
    }
}

@end







/** msgCount comment */
@implementation NSObject (MsgCount)
static NSLock* _shareLock;
+ (NSLock* )shareLock{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareLock = [[NSLock alloc] init];
        _shareLock.name = @"standardUserDefaults_GA";
    });
    return _shareLock;
}

+ (void)settingTagHasBeenRead:(MsgCountType)msgCountType{
    [Utils sendRequest2MsgCountInterface:msgCountType];
}

+ (void)handleMsgCount:(NSDictionary *)msgCount_Dic{
    if (!_shareLock || [_shareLock isEqual:[NSNull null]]) { [self shareLock]; }
    
    [_shareLock lock];
    
    OSCMsgCount* curMsgCount = [OSCMsgCount osc_modelWithDictionary:msgCount_Dic];
    OSCMsgCount* prevMsgCount = [OSCMsgCount currentMsgCount];
    
    if ((curMsgCount.mention != prevMsgCount.mention) ||
        (curMsgCount.letter  != prevMsgCount.letter)  ||
        (curMsgCount.review  != prevMsgCount.review)  ||
        (curMsgCount.fans > 0))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:MsgCount_Notification_Key object:curMsgCount];
        });
    }
    
    if ((curMsgCount.mention != prevMsgCount.mention) && curMsgCount.mention > 0)
    {
        [Utils beforehandSend_AtMe_List_Request];
    }
    
    if ((curMsgCount.review  != prevMsgCount.review) && curMsgCount.review > 0)
    {
        [Utils beforehandSend_Comment_List_Request];
    }
    
    if ((curMsgCount.letter  != prevMsgCount.letter) && curMsgCount.letter > 0)
    {
        [Utils beforehandSend_Chat_List_Request];
    }
    
    if (![curMsgCount isEqualTo:prevMsgCount]) {
        [OSCMsgCount updateCurMsgCount:curMsgCount];
    }
    
    [_shareLock unlock];
}

@end






