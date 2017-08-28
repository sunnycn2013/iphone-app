//
//  OSCTweetForwardDetailTableViewCell.h
//  iosapp
//
//  Created by Graphic-one on 16/12/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetDetailContentCell.h"

#define OSCTweetForwardDetailTableViewCellReuseIdentifier  @"OSCTweetForwardDetailTableViewCell"

@class OSCTweetItem;
@interface OSCTweetForwardDetailTableViewCell : OSCTweetDetailContentCell

- (instancetype) initWithTweetItem:(OSCTweetItem* )item
                   reuseIdentifier:(NSString* )reuseIdentifier;

+ (instancetype) forwardDetailCellWith:(OSCTweetItem* )item
                       reuseIdentifier:(NSString* )reuseIdentifier;

@property (nonatomic,strong) OSCTweetItem* item;

@property (nonatomic,weak) id<OSCTweetDetailPageDelegate> delegate;

/** Lock initialization routine method */
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end
