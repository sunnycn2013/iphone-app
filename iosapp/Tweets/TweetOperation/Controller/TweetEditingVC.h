//
//  TweetEditingVC.h
//  iosapp
//
//  Created by ChanAetern on 12/18/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "enumList.h"

@class OSCAbout;
@protocol OSCTweetEditDelegate <NSObject>

- (void)sendCommentOfForwardWithTextView:(__kindof UIScrollView *)textView;

@end

@interface TweetEditingVC : UIViewController

@property (nonatomic,weak) id<OSCTweetEditDelegate>delegate;

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithTopic:(NSString *)TopicName;

- (instancetype)initWithTeamID:(int)teamID;

- (void)insertString:(NSString *)string andSelect:(BOOL)shouldSelect;

//文章分享转至动弹内容
- (instancetype)initWithAboutID:(NSInteger)aboutID
                      aboutType:(InformationType)aboutType
                    forwardItem:(OSCAbout* )forwardItem;

- (instancetype)initWithAboutID:(NSInteger)aboutID
                    fromTweetID:(NSInteger)fromID
                      aboutType:(InformationType)aboutType
                    forwardItem:(OSCAbout *)forwardItem
                      string:(NSAttributedString *)attribute
                  isShowComment:(BOOL)isShow;

@end
