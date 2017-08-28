//
//  TweetFriendCell.h
//  iosapp
//
//  Created by 王晨 on 15/8/25.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCListItem.h"

@class TweetFriendCell;
@protocol TweetFriendCellDelegate <NSObject>

- (void)clickedToSelectedAuthor:(TweetFriendCell *)cell authorInfo:(OSCAuthor *)author;

@end

@interface TweetFriendCell : UITableViewCell

@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) OSCAuthor *author;

@property (nonatomic, weak) id <TweetFriendCellDelegate> delegate;

@end



/** 拓展属性记录是否选中 */
@interface OSCAuthor (isSelected)

@property (nonatomic,assign,getter=isSelected) BOOL selected;

- (BOOL)isEqual:(OSCAuthor* )author;

@end

