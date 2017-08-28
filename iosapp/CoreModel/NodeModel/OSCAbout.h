//
//  OSCAbout.h
//  iosapp
//
//  Created by Graphic-one on 16/12/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import "OSCTweetItem.h"

#import "enumList.h"
#import "OSCExtra.h"
#import "OSCNetImage.h"
#import "OSCStatistics.h"

/** 详情页面的相关推荐 和 动弹的转发引用*/
@interface OSCAbout : NSObject <NSMutableCopying>

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, strong) NSString* title;

@property (nonatomic, strong) NSString* content;

@property (nonatomic, assign) InformationType type;

@property (nonatomic, strong) OSCStatistics* statistics;

@property (nonatomic, strong) NSString* href;

@property (nonatomic, strong) NSArray<OSCNetImage* > *images;

/** 以下是布局信息*/
@property (nonatomic,assign) CGRect titleLabelFrame;///< 非动弹转发 用到

@property (nonatomic,assign) CGRect contectTextViewFrame;///< 非动弹转发 动弹转发 用到

@property (nonatomic,assign) CGRect imageFrame;///< 动弹转发(单图) 用到

@property (nonatomic,assign) MultipleImageViewFrame forwardingMultipleFrame;///< 动弹转发(多图) 用到

@property (nonatomic,assign) CGFloat viewHeight;

/** 当model解析完成之后调用该方法以获取异步布局信息 传入你期待的forwardView宽度度实现自适应 */
- (void)calculateLayoutWithForwardViewWidth:(CGFloat)curForwardViewWidth;

/** 快速构造方法 return一个包含布局信息的model*/
+ (instancetype)forwardInfoModelWithTitle:(NSString* )title
                                  content:(NSString* )content
                                     type:(InformationType)type
                                fullWidth:(CGFloat)fullWidth;///< 用于生成 转发文章(咨询 博客)跳转编辑界面 显示的ForwardView


@end
