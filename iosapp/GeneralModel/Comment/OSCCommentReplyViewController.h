//
//  OSCCommentReplyViewController.h
//  iosapp
//
//  Created by 李萍 on 2016/11/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "enumList.h"

@interface OSCCommentReplyViewController : UIViewController

- (instancetype)initWithCommentType:(InformationType)commentType
                           sourceID:(NSInteger)sourceId;

/** 用于回传给详情界面，更改评论状态 */
@property (nonatomic,copy) void (^changeCommentStatus_block)(BOOL);

@end
