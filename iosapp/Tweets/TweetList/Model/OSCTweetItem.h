//
//  OSCTweetItem.h
//  iosapp
//
//  Created by Graphic-one on 16/7/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "OSCUserItem.h"

#import "enumList.h"

struct MultipleImageViewFrame {
    int line;
    int row;
    CGRect frame;
};
typedef struct MultipleImageViewFrame MultipleImageViewFrame;

static MultipleImageViewFrame _multipleImageViewFrameZero;///<静态Zero


@class OSCTweetAuthor,OSCTweetCode,OSCTweetAudio,OSCAbout,OSCStatistics,OSCExtra,OSCNetImage,OSCUserIdentity;

/** 动弹列表 && 动弹详情 使用的Item */
@interface OSCTweetItem : NSObject <NSMutableCopying>

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, assign) AppClientType appClient;

@property (nonatomic, copy) NSString *href;

@property (nonatomic, strong) OSCTweetAuthor *author;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, strong) NSArray<OSCTweetAudio *> *audio;

@property (nonatomic, strong) OSCTweetCode *code;

@property (nonatomic, strong) NSArray<OSCNetImage *> *images;

@property (nonatomic, assign) BOOL liked;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, strong) OSCAbout* about;

@property (nonatomic, strong) OSCStatistics* statistics;

/** 以下是布局信息*/
@property (nonatomic,assign) CGRect userPortraitFrame;

@property (nonatomic,assign) CGRect nameLabelFrame;

@property (nonatomic,assign) CGRect descTextFrame;

@property (nonatomic,assign) CGRect timeLabelFrame;

@property (nonatomic,assign) CGRect commentLabelFrame;

@property (nonatomic,assign) CGRect commentButtonFrame;

@property (nonatomic,assign) CGRect forwardLabelFrame;

@property (nonatomic,assign) CGRect forwardButtonFrame;

@property (nonatomic,assign) CGRect likeLabelFrame;

@property (nonatomic,assign) CGRect likeButtonFrame;

@property (nonatomic,assign) CGRect imageFrame;///< 单图用到

@property (nonatomic,assign) MultipleImageViewFrame multipleFrame;///< 多图用到

@property (nonatomic,assign) CGFloat rowHeight;


/** 当model解析完成之后调用该方法以获取异步布局信息 */
- (void)calculateLayoutWithCurTweetCellWidth:(CGFloat)curWidth
                         forwardViewCurWidth:(CGFloat)forwardViewCurWidth;

@end

#pragma mark -
#pragma mark --- 动弹作者
@interface OSCTweetAuthor : NSObject<NSMutableCopying>

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *portrait;

@property (nonatomic, strong) OSCUserIdentity *identity;

@end


#pragma mark -
#pragma mark --- 动弹Code
@interface OSCTweetCode : NSObject<NSMutableCopying>

@property (nonatomic, copy) NSString *brush;

@property (nonatomic, copy) NSString *content;

@end

#pragma mark -
#pragma mark --- 动弹音频 && 视频
@interface OSCTweetAudio : NSObject

@property (nonatomic, copy) NSString *href;

@property (nonatomic, assign) NSInteger timeSpan;

@end




#pragma mark - 推荐话题
/** 推荐话题列表使用到Item */
@interface OSCTweetTopicItem : NSObject

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* title;

@property (nonatomic,strong) NSString* desc;

@property (nonatomic,strong) NSString* href;

@property (nonatomic,strong) NSString* pubDate;

@property (nonatomic,assign) NSInteger joinCount;

@property (nonatomic,strong) NSArray<OSCTweetItem* >* items;

@end







