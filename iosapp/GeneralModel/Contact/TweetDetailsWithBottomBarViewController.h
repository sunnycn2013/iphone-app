//
//  TweetDetailsWithBottomBarViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 1/14/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomBarViewController.h"

@class OSCTweetItem;
@interface TweetDetailsWithBottomBarViewController : UIViewController

- (instancetype)initWithTweetID:(NSInteger)tweetID;

- (instancetype)initWithTweetItem:(OSCTweetItem *)tweetItem ;

@end
