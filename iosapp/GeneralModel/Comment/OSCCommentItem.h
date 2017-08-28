//
//  OSCCommentItem.h
//  iosapp
//
//  Created by Holden on 16/7/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import "OSCUserItem.h"
#import "OSCReference.h"
#import "OSCReply.h"
#import "TeamMember.h"
#import "enumList.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct{
    CGRect userPortraitFrame;
    CGRect userNameLbFrame;
    CGRect timeLbFrame;
    CGRect likeBtnFrame;
    CGRect commentBtnFrame;
    CGRect customViewFrame;
    
    CGRect contentTextViewFrame;
} CommentLayoutInfo;///< 基本的commentLayoutInfo

typedef struct __attribute__((objc_boxable)) {
    CGRect bottomLineFrame;
    CGRect leftLineFrame;
    CGRect contentTextViewFrame;
} CommentReplyLayoutInfo;///< 引用部分的LayoutInfo

@class OSCCommentItemRefer, OSCCommentItemReply;

@interface OSCCommentItem : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, strong) OSCUserItem *author;

@property (nonatomic, strong) NSString *content;

@property (nonatomic, strong) NSString *pubDate;

@property (nonatomic, assign) AppClientType appClient;

/** new comment_list **/
@property (nonatomic, assign) NSInteger vote;

@property (nonatomic, assign) CommentStatusType voteState;

@property (nonatomic, assign) BOOL best;

@property (nonatomic, strong) NSArray <OSCCommentItemRefer* >* refer;

@property (nonatomic, strong) NSArray <OSCCommentItemReply* >* reply;
/** new comment_list **/

///<新接口未用到的属性，如需用更改属性名与后台返回名字相同
@property (nonatomic, strong) NSArray<OSCCommentItemRefer* >* references;

@property (nonatomic, strong) NSArray<OSCCommentItemReply*>* replies;



/** about layout*/
+ (NSAttributedString *)attributedTextFromReplies:(NSArray *)replies;

- (void)calculateLayout:(BOOL)isNeedRefer;///< 计算布局信息

@property (nonatomic,assign) CommentLayoutInfo layoutInfo;///< 基本的commentLayoutInfo

@property (nullable,nonatomic,strong) NSArray<NSValue* >* replysInfo;///< 引用部分的LayoutInfo 数组成员需要调用openBoxCase:方法拆箱成CommentReplyLayoutInfo

@property (nonatomic,assign) CGFloat layoutHeight;

///< 比较方法
- (BOOL)isEqualTo:(OSCCommentItem* )commentItem;

@end


//引用
@interface OSCCommentItemRefer : NSObject
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *pubDate;
@end


//回复
@interface OSCCommentItemReply : NSObject
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) OSCUserItem *author;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *pubDate;
@end


///< 用作CommentReplyLayoutInfo 装箱 拆箱
@interface NSValue (boxable_CommentReplyLayoutInfo)

+ (nullable instancetype)boxing:(CommentReplyLayoutInfo)replyLayoutInfo;///< 手动装箱

- (CommentReplyLayoutInfo)openBoxCase;

@end


NS_ASSUME_NONNULL_END


