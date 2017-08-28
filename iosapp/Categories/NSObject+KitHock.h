//
//  NSObject+KitHock.h
//  iosapp
//
//  Created by Graphic-one on 17/1/5.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <MJRefresh.h>
#import <MJRefreshHeader.h>
#import <TZImageManager.h>
#import <AFNetworking.h>
#import <YYKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KitHock)
/** 第三方库hock分类 */
@end

///< AFN GET POST请求hock以处理msgCount接收
@interface AFHTTPRequestOperationManager (Comment)
/** AFN 私有方法导向 */
- (AFHTTPRequestOperation *)HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**Git网络请求使用*/
- (AFHTTPRequestOperation *)gitGet:(NSString *)URLString
                        parameters:(id)parameters
                           success:(void (^)(AFHTTPRequestOperation * _Nonnull, id _Nonnull))success
                           failure:(void (^)(AFHTTPRequestOperation * _Nullable, NSError * _Nonnull))failur;

@end


///< TZImageManager图片排序hock (库默认使用图片修改时间进行排序 改成图片创建时间进行排序)
@interface TZImageManager (Comment)

- (TZAlbumModel *)modelWithResult:(id)result name:(NSString *)name;///< 私有API导向

@end


///< MJRefreshComponent基类刷新status_hock (防止头部尾部控件同时刷新)
@interface MJRefreshComponent (Comment)


@end



///< hock YYKit 实现YYTextView支持接收YYTextAttachment
@interface NSAttributedString (YYKit)

+ (NSMutableAttributedString *)attachmentStringWithTextAttachment:(YYTextAttachment* )textAttachment
                                                        imageSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END


