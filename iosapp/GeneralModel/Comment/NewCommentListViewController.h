//
//  NewCommentListViewController.h
//  iosapp
//
//  Created by 李萍 on 16/6/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "enumList.h"

@interface NewCommentListViewController : UIViewController

- (instancetype)initWithCommentType:(InformationType)commentType
                           sourceID:(NSInteger)sourceId
                           titleStr:(NSString *)titleStr;

/** 用于回传给详情界面，更改评论状态 */
@property (nonatomic,copy) void (^changeCommentStatus_block)(BOOL);

@end
