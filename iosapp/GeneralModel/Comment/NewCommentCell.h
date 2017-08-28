//
//  NewCommentCell.h
//  iosapp
//
//  Created by 李萍 on 16/6/2.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCBlogDetail.h"
#import "OSCCommentItem.h"

@class NewCommentCell;
@protocol NewCommentCellDelegate <NSObject>

- (void)setVoteStatusClickAction:(NewCommentCell *)cell sourceComment:(OSCCommentItem *)comment;

@end

@interface NewCommentCell : UITableViewCell

@property (strong, nonatomic) UIImageView *commentPortrait;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UITextView *contentTextView;
@property (strong, nonatomic) UILabel *voteLabel;
@property (strong, nonatomic) UIButton *voteImageView;
@property (strong, nonatomic) UIButton *commentButton;
@property (nonatomic, strong) UIImageView *bestImageView;

@property (nonatomic, strong) UIView *referCommentView;

@property (nonatomic, assign) NSInteger sourceType;
@property (nonatomic, strong) OSCCommentItem *comment;

@property (nonatomic, weak) id <NewCommentCellDelegate> delegate;

@property (nonatomic, copy) BOOL (^canPerformAction)(UITableViewCell *cell, SEL action);


- (void)setDataForQuestionComment:(OSCCommentItem *)questComment;

- (void)setDataForQuestionCommentReply:(OSCCommentItemReply *)commentReply;
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString;

- (void)setVoteStatus:(OSCCommentItem* )commentItem animation:(BOOL)isNeedAnimation;

@end

