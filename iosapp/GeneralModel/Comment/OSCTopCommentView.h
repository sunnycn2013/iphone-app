//
//  OSCTopCommentView.h
//  iosapp
//
//  Created by Graphic-one on 17/1/17.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCBaseCommetView.h"

@interface OSCTopCommentView : OSCBaseCommetView

@property (nonatomic , weak) id<OSCCommetViewDelegate> delegate;

- (instancetype)initWithViewModel:(OSCCommentItem *)commentItem
                uxiliaryNodeStyle:(CommentUxiliaryNode)uxiliaryNode
                          isShare:(BOOL)isShare;

//获取分享图片时候新的评论区高度
- (CGFloat)getShareLHeight;

@end
