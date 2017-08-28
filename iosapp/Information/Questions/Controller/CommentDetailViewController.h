//
//  CommentDetailViewController.h
//  iosapp
//
//  Created by 李萍 on 16/6/17.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "enumList.h"

@interface CommentDetailViewController : UIViewController

- (instancetype)initWithDetailCommentID:(NSInteger)commentId
                        commentAuthorID:(NSInteger)commentAuthorID
                             detailType:(InformationType)detailType;

@property (nonatomic, assign) NSInteger questDetailId;

@end
