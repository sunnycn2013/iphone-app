//
//  OSCForwardTweetCell.h
//  iosapp
//
//  Created by Graphic-one on 16/12/3.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "AsyncDisplayTableViewCell.h"

#define OSCForwardTweetCell_reuseStr_OnPIC        @"OSCForwardTweetCell_reuseIdentifierStr_OnPIC"
#define OSCForwardTweetCell_reuseStr_OnlyPIC      @"OSCForwardTweetCell_reuseIdentifierStr_OnlyPIC"
#define OSCForwardTweetCell_reuseStr_MultiplePIC  @"OSCForwardTweetCell_reuseIdentifierStr_MultiplePIC"


@class OSCTweetItem;
@interface OSCForwardTweetCell : AsyncDisplayTableViewCell

+ (instancetype)returnReuseForwardTweetCellWithTableView:(UITableView* )tableView
                                           identifierStr:(NSString* )identifier
                                               tweetItem:(OSCTweetItem* )tweetItem;

@property (nonatomic,strong) OSCTweetItem* tweetItem;

@property (nonatomic,weak) id<AsyncDisplayTableViewCellDelegate> delegate;

@property (nonatomic,assign,getter=isShowCountLabel) BOOL showCountLabel;///< default is YES

@end
