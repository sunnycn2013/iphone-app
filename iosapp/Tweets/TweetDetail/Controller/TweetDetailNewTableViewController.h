//
//  TweetDetailNewTableViewController.h
//  iosapp
//
//  Created by Holden on 16/6/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCCommentItem.h"
#import "OSCTweetItem.h"

@protocol TweetDetailDelegate <NSObject>

- (void)clickForwardWithTweetItem:(OSCTweetItem *)tweetItem;

@end

@class OSCTweetItem;
@interface TweetDetailNewTableViewController : UITableViewController
@property (nonatomic, assign) int64_t tweetID;
@property (nonatomic, strong) OSCTweetItem *item;
@property (nonatomic, assign) id<TweetDetailDelegate> detailDelegate;

@property (nonatomic, copy) void (^didTweetCommentSelected)(OSCCommentItem *comment);
@property (nonatomic, copy) void (^didScroll)();
@property (nonatomic, copy) void (^didActivatedInputBar)();
@property (nonatomic, copy) void (^refreshContent)();

-(void)reloadCommentList;
-(void)reloadCommentListWithLocationData:(OSCCommentItem *)newCommentItem isSuccess:(BOOL)isSuccessful;

@end
