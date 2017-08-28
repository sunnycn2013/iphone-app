//
//  TweetTableViewController.h
//  iosapp
//
//  Created by 李萍 on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"
#import "OSCTweetItem.h"

@class TweetTableViewController;
/** 额外信息回传 用于传递最原始的JSON数据 (传递result节点信息)*/
@protocol TweetTableViewControllerDelegate <NSObject>

@optional
- (void)tweetTableViewController:(TweetTableViewController* )tweetTableViewController
                 passInformation:(NSDictionary* )informationDic;

- (void)tweetClickForwardWithTweetItem:(OSCTweetItem *)tweetItem;

@end

typedef NS_ENUM(NSUInteger, NewTweetsType)
{
    NewTweetsTypeAllTweets = 1,
    NewTweetsTypeHotestTweets,
    NewTweetsTypeOwnTweets,
};

typedef NS_ENUM(NSInteger,TweetListType){
    TweetListTypeAll = 1,
    TweetListTypeFriends = 2,
};
typedef NS_ENUM(NSInteger,TweetListOrder){
    TweetListOrderLatest = 1,
    TweetListOrderHot = 2,
};

@interface TweetTableViewController : UITableViewController

@property (nonatomic,weak) id<TweetTableViewControllerDelegate> delegate;


/** 不带order的旧接口 */
-(instancetype)initTweetListWithType:(NewTweetsType)type;/** 常规init方法 */

-(instancetype)initTweetListWithTopic:(NSString *)topicTag;/** 新接口根据title获取话题动弹 */

- (instancetype)initWithTag:(NSString* )tag
				   withName:(NSString *)name
				  withOrder:(TweetListOrder)order; /**只给软件详情相关的地方使用，其他地方请勿使用此方法 **/


/** tweet init methods  */
- (instancetype)initWithTag:(NSString* )tag
                      order:(TweetListOrder)order;

- (instancetype)initWithAuthorId:(NSString* )authorId
                           order:(TweetListOrder)order;

- (instancetype)initWithTweetListType:(TweetListType)tweetListType
                                order:(TweetListOrder)order;

@end
