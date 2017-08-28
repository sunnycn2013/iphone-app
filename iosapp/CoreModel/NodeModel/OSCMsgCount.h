//
//  OSCMsgCount.h
//  iosapp
//
//  Created by Graphic-one on 16/12/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

#define userDefault_mention_key     @"noticeMention"
#define userDefault_review_key      @"noticeReview"
#define userDefault_letter_key      @"noticeLetter"
#define userDefault_fans_key        @"noticeFans"
#define userDefault_like_key        @"noticeLike"

#define userDefault_mention_key_updateTime      @"noticeMention_time"
#define userDefault_review_key_updateTime       @"noticeReview_time"
#define userDefault_letter_key_updateTime       @"noticeLetter_time"


/** 用作显示【我的】界面的消息中心入口小红点 */
@interface OSCMsgCount : NSObject <NSCopying>

@property (nonatomic,assign) NSInteger mention;

@property (nonatomic,assign) NSInteger review;

@property (nonatomic,assign) NSInteger letter;

@property (nonatomic,assign) NSInteger fans;

@property (nonatomic,assign) NSInteger like;

@property (nonatomic,assign) NSInteger totalCount;  ///< 返回的是@数量 私信数量 回复数量的总和

//methods
+ (instancetype)currentMsgCount; ///< 获取最近的当前的OSCMsgCount模型
+ (void)updateCurMsgCount:(OSCMsgCount* )curMsgCount; ///< 更新curMsgCount单例

- (BOOL)isEqualTo:(OSCMsgCount* )msgCount; ///< 根据count进行比较

@end
/**
 mention    :   @数量
 review     :   回复数量
 letter     :   私信数量
 fans       :   粉丝数量
 like       :   赞数量
 */
