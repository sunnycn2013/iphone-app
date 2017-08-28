//
//  OSCBaseCommetView.h
//  iosapp
//
//  Created by Graphic-one on 17/1/17.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

///< 配置右上角的辅助视图
typedef NS_OPTIONS(NSInteger,CommentUxiliaryNode){
    CommentUxiliaryNode_like        = 1 << 1,
    CommentUxiliaryNode_comment     = 1 << 2,
    
    CommentUxiliaryNode_none        = 0,
    CommentUxiliaryNode_customView  = NSIntegerMax,///< 额外的自定义辅助视图
};


@class OSCCommentItem , OSCBaseCommetView;

@protocol OSCCommetViewDelegate <NSObject>

@optional
- (void)commentViewDidClickUserPortrait:(__kindof OSCBaseCommetView* )commentView;

- (void)commentViewDidClickLikeButton:(__kindof OSCBaseCommetView* )commentView;

- (void)commentViewDidClickCommentButton:(__kindof OSCBaseCommetView* )commentView;


- (void)commentViewDidClickCustomView:(__kindof OSCBaseCommetView* )commentView;

@end


@interface OSCBaseCommetView : UIView

- (instancetype)initWithViewModel:(OSCCommentItem* )commentItem
                uxiliaryNodeStyle:(CommentUxiliaryNode)uxiliaryNode;

@property (nonatomic,readonly,strong) OSCCommentItem* commnetItem;


+ (UIImage* )likeImage;

+ (UIImage* )unlikeImage;

+ (UIImage* )commentImage;

//处理字符串
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString withFont:(CGFloat)fontSize;

- (void)setVoteStatus:(OSCCommentItem* )commentItem animation:(BOOL)isNeedAnimation;

@end
