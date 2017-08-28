//
//  NSObject+KitHock.m
//  iosapp
//
//  Created by Graphic-one on 17/1/5.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "NSObject+KitHock.h"
#import "OSCAPI.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AFOnoResponseSerializer.h>

#import "UIDevice+SystemInfo.h"
#import "NSObject+Comment.h"

@implementation NSObject (KitHock)

@end


///< AFN GET POST请求hock以处理msgCount接收
@implementation AFHTTPRequestOperationManager (Comment)
/** AFN hock */
- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFHTTPRequestOperation * _Nonnull, id _Nonnull))success
                        failure:(void (^)(AFHTTPRequestOperation * _Nullable, NSError * _Nonnull))failure
{
    ///< 临时区分git接口和主站接口
    if ([URLString containsString:@"git.oschina.net/api"]) {//tmp Git interface
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"GET" URLString:URLString parameters:parameters success:success failure:failure];
        
        [self.operationQueue addOperation:operation];
        
        return operation;
    }
    ///< 临时区分git接口和主站接口

    
    void (^containsMsgCountSussessCallBack)(AFHTTPRequestOperation *operation, id responseObject) ;
    
    if (![self.responseSerializer isKindOfClass:[AFOnoResponseSerializer class]]) { //非XML
        containsMsgCountSussessCallBack = ^(AFHTTPRequestOperation *operation, id responseObject){
            BOOL isSuccess = [responseObject[@"code"]integerValue] == 1;
            if (isSuccess) {
                [NSObject handleMsgCount:responseObject[@"notice"]];
            }
            if (success) {
                success(operation,responseObject);
            }
        };
    }else{//XML
        containsMsgCountSussessCallBack = success;
    }
    
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"GET" URLString:URLString parameters:parameters success:containsMsgCountSussessCallBack failure:failure];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(AFHTTPRequestOperation * _Nonnull, id _Nonnull))success
                         failure:(void (^)(AFHTTPRequestOperation * _Nullable, NSError * _Nonnull))failure
{
    void (^containsMsgCountSussessCallBack)(AFHTTPRequestOperation *operation, id responseObject) ;
    
    if (![self.responseSerializer isKindOfClass:[AFOnoResponseSerializer class]]) { //非XML
        containsMsgCountSussessCallBack = ^(AFHTTPRequestOperation *operation, id responseObject){
            BOOL isSuccess = [responseObject[@"code"]integerValue] == 1;
            if (isSuccess) {
                [NSObject handleMsgCount:responseObject[@"notice"]];
            }
            if (success) {
                success(operation,responseObject);
            }          
        };
    }else{//XML
        containsMsgCountSussessCallBack = success;
    }
    
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"POST" URLString:URLString parameters:parameters success:containsMsgCountSussessCallBack failure:failure];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)gitGet:(NSString *)URLString
                        parameters:(id)parameters
                           success:(void (^)(AFHTTPRequestOperation * _Nonnull, id _Nonnull))success
                           failure:(void (^)(AFHTTPRequestOperation * _Nullable, NSError * _Nonnull))failure{
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"GET" URLString:URLString parameters:parameters success:success failure:failure];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

@end


///< TZImageManager图片排序hock (库默认使用图片修改时间进行排序 改成图片创建时间进行排序)
@implementation TZImageManager (Comment)

- (void)getCameraRollAlbum:(BOOL)allowPickingVideo
         allowPickingImage:(BOOL)allowPickingImage
                completion:(void (^)(TZAlbumModel *))completion
{
    __block TZAlbumModel *model;
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    if (!allowPickingVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    if (!allowPickingImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                                PHAssetMediaTypeVideo];
    
     option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        
        if (![collection isKindOfClass:[PHAssetCollection class]]) return;
        
        if ([self isCameraRollAlbum:collection.localizedTitle]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            model = [self modelWithResult:fetchResult name:collection.localizedTitle];
            if (completion) completion(model);
            break;
        }
    }
    
}

@end



///< MJRefreshComponent基类刷新status_hock (防止头部尾部控件同时刷新)
@implementation MJRefreshComponent (Comment)

- (void)beginRefreshing{
    if ([self isKindOfClass:[MJRefreshHeader class]]) {
        MJRefreshFooter* footer = [self.superview valueForKeyPath:@"mj_footer"];
        if (footer && footer.isRefreshing) {
            [self endRefreshing];
            return;
        }
    }
    
    if ([self isKindOfClass:[MJRefreshFooter class]]) {
        MJRefreshFooter* header = [self.superview valueForKeyPath:@"mj_header"];
        if (header && header.isRefreshing) {
            [self endRefreshing];
            return;
        }
    }
    
    [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
        self.alpha = 1.0;
    }];
    self.pullingPercent = 1.0;
    // 只要正在刷新，就完全显示
    if (self.window) {
        self.state = MJRefreshStateRefreshing;
    } else {
        // 预防正在刷新中时，调用本方法使得header inset回置失败
        if (self.state != MJRefreshStateRefreshing) {
            self.state = MJRefreshStateWillRefresh;
            // 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
            [self setNeedsDisplay];
        }
    }
}

@end




///< hock YYKit 实现YYTextView支持接收YYTextAttachment
@implementation NSAttributedString (YYKit)

+ (NSMutableAttributedString *)attachmentStringWithTextAttachment:(YYTextAttachment* )textAttachment
                                                        imageSize:(CGSize)size
{
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:YYTextAttachmentToken];
    
    [atr setTextAttachment:textAttachment range:NSMakeRange(0, atr.length)];
    
    YYTextRunDelegate *delegate = [YYTextRunDelegate new];
    delegate.width = size.width;
    delegate.ascent = 16;
    delegate.descent = 2;
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    [atr setRunDelegate:delegateRef range:NSMakeRange(0, atr.length)];
    if (delegate) CFRelease(delegateRef);
    
    return atr;

}

@end







