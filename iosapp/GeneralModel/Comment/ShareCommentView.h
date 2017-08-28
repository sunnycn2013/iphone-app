//
//  ShareCommentView.h
//  iosapp
//
//  Created by wupei on 2017/4/25.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCCommentItem.h"

@interface ShareCommentView : UIView

@property (nonatomic, strong) OSCCommentItem *commentItem;

- (instancetype)initWithFrame:(CGRect)frame CommentItem:(OSCCommentItem *)commentItem title:(NSString *)titleStr;

@end
