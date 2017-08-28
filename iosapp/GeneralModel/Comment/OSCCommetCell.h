//
//  OSCCommetCell.h
//  iosapp
//
//  Created by Graphic-one on 17/1/17.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCBaseCommetView.h"

#define OSCCommetCellIdentifier @"OSCCommetCellIdentifier"

@class OSCCommentItem , OSCCommetCell;

@protocol OSCCommetCellDelegate <NSObject>

@optional
- (void)commetCellDidClickUserPortrait:(OSCCommetCell* )commetCell;

- (void)commetCellDidClickLikeButton:(OSCCommetCell* )commetCell;

- (void)commetCellDidClickCommentButton:(OSCCommetCell* )commetCell;

- (void)commetCellDidClickCustomView:(OSCCommetCell* )commetCell;

@end


@interface OSCCommetCell : UITableViewCell

+ (instancetype)commetCellWithTableView:(UITableView* )tableView
                             identifier:(NSString* )identifier
                              indexPath:(NSIndexPath* )indexPath
                            commentItem:(OSCCommentItem* )commentItem
                    commentUxiliaryNode:(CommentUxiliaryNode)commentUxiliaryNode
                        isNeedReference:(BOOL)isNeedShowReference;

@property (nonatomic,strong,readonly) OSCCommentItem* commentItem;

@property (nonatomic,weak) id<OSCCommetCellDelegate> delegate;

- (void)setVoteStatus:(OSCCommentItem* )commentItem animation:(BOOL)isNeedAnimation;

@end
