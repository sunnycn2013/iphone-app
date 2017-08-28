//
//  SelectBoardView.h
//  iosapp
//
//  Created by wupei on 2017/4/27.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCCommentItem.h"
@protocol SelectBoardViewDelegate <NSObject>

@required

- (void)copyClickBtn:(OSCCommentItem *)item;//复制

- (void)commentClickBtn:(OSCCommentItem *)item ;//

- (void)shareClickBtn:(OSCCommentItem *)item;//

@end

@interface SelectBoardView : UIView


@property (nonatomic, weak) id <SelectBoardViewDelegate> delegate;//点击事件代理

//数据模型
@property (nonatomic, strong) OSCCommentItem *item;

@end
