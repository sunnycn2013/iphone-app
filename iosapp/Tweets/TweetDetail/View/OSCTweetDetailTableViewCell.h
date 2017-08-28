//
//  OSCTweetDetailTableViewCell.h
//  iosapp
//
//  Created by 王恒 on 16/12/5.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetDetailContentCell.h"
#import "OSCTweetItem.h"

@interface OSCTweetDetailTableViewCell : OSCTweetDetailContentCell

@property (nonatomic,strong) OSCTweetItem *item;

@property (nonatomic,assign) id<OSCTweetDetailPageDelegate> delegate;

@end
