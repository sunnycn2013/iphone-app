//
//  UIButton+EnlargeTouchArea.h
//  iosapp
//
//  Created by wupei on 2017/4/27.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 用于不增加frame的情况下，增加点击响应范围
 */
@interface UIButton (EnlargeTouchArea)

- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;

- (void)setEnlargeEdge:(CGFloat) size;

@end
