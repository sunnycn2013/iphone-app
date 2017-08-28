//
//  OSCPageControl.h
//  test
//
//  Created by 李萍 on 2016/12/14.
//  Copyright © 2016年 李萍. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, UIPageControlDotAlignment){
    UIPageControlDotAlignmentLeft = 0,
    UIPageControlDotAlignmentCenter,
    UIPageControlDotAlignmentRight,
};

@interface OSCPageControl : UIPageControl

@property (nonatomic, assign) CGFloat dotNomalWidth;//正常小圆点宽度
@property (nonatomic, assign) CGFloat dotCurrentWidth;//选中时小圆点宽度
@property (nonatomic, assign) CGFloat dotPadding;//小圆点间距

@property (nonatomic) UIPageControlDotAlignment pageControlDotAlignment;//小圆点对齐方式

@property (nonatomic, assign) BOOL isDotImage; //图片替换小图标
@property (nonatomic, copy) NSString *currentImageName; //选中时图片名
@property (nonatomic, copy) NSString *nomalImageName; //正常时图片名

@end
