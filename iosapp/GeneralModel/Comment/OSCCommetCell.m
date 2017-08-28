//
//  OSCCommetCell.m
//  iosapp
//
//  Created by Graphic-one on 17/1/17.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCCommetCell.h"
#import "OSCTopCommentView.h"
#import "OSCNomalCommentView.h"

#import "OSCCommentItem.h"


@interface OSCCommetCell () <OSCCommetViewDelegate>
{
    CommentUxiliaryNode _commentUxiliaryNode;
    BOOL _isNeedShowReference;
    __weak OSCTopCommentView*   _Nullable  _topCommentView;
    __weak OSCNomalCommentView* _Nullable  _nomalCommentView;
}

@property (nonatomic,strong,readwrite) OSCCommentItem* commentItem;

@end

@implementation OSCCommetCell

+ (instancetype)commetCellWithTableView:(UITableView* )tableView
                             identifier:(NSString* )identifier
                              indexPath:(NSIndexPath* )indexPath
                            commentItem:(OSCCommentItem* )commentItem
                    commentUxiliaryNode:(CommentUxiliaryNode)commentUxiliaryNode
                        isNeedReference:(BOOL)isNeedShowReference
{
    OSCCommetCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (cell) {
        for (UIView* view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    cell->_isNeedShowReference = isNeedShowReference;
    cell->_commentUxiliaryNode = commentUxiliaryNode;
    cell.commentItem = commentItem;
    
    [cell configurationContentView];
    
    return cell;
}

- (void)configurationContentView{
    if (_isNeedShowReference) {
        [self.contentView addSubview:({
            OSCTopCommentView* commentView = [[OSCTopCommentView alloc] initWithViewModel:_commentItem uxiliaryNodeStyle:_commentUxiliaryNode];
            commentView.frame = self.contentView.frame;
            _topCommentView = commentView;
            _topCommentView.userInteractionEnabled = YES;
            _topCommentView;
        })];
        _topCommentView.delegate = self;
        _nomalCommentView = nil;
    }else{
        [self.contentView addSubview:({
            OSCNomalCommentView* commentView = [[OSCNomalCommentView alloc] initWithViewModel:_commentItem uxiliaryNodeStyle:_commentUxiliaryNode];
            commentView.frame = self.contentView.frame;
            _nomalCommentView = commentView;
            _nomalCommentView.userInteractionEnabled = YES;
            _nomalCommentView;
        })];
        _nomalCommentView.delegate = self;
        _topCommentView = nil;
    }
}

///< 防KVO修改readonly属性
- (OSCCommentItem *)commentItem
{
    if (!_commentItem || [_commentItem isEqual:[NSNull null]]) return nil;
    
    if (_isNeedShowReference) {
        return [_topCommentView.commnetItem isEqualTo:_commentItem] ? _commentItem : nil;
    }else{
        return [_nomalCommentView.commnetItem isEqualTo:_commentItem] ? _commentItem : nil;
    }
}

#pragma mark --- delegate handle
- (void)commentViewDidClickUserPortrait:(__kindof OSCBaseCommetView* )commentView
{
    if ([_delegate respondsToSelector:@selector(commetCellDidClickUserPortrait:)]) {
        [_delegate commetCellDidClickUserPortrait:self];
    }
}
- (void)commentViewDidClickLikeButton:(__kindof OSCBaseCommetView* )commentView
{
    if ([_delegate respondsToSelector:@selector(commetCellDidClickLikeButton:)]) {
        [_delegate commetCellDidClickLikeButton:self];
    }
}
- (void)commentViewDidClickCommentButton:(__kindof OSCBaseCommetView* )commentView
{
    if ([_delegate respondsToSelector:@selector(commetCellDidClickCommentButton:)]) {
        [_delegate commetCellDidClickCommentButton:self];
    }
}
- (void)commentViewDidClickCustomView:(__kindof OSCBaseCommetView* )commentView
{
    if ([_delegate respondsToSelector:@selector(commetCellDidClickCustomView:)]) {
        [_delegate commetCellDidClickCustomView:self];
    }
}

#pragma mark - animation action
- (void)setVoteStatus:(OSCCommentItem* )commentItem animation:(BOOL)isNeedAnimation
{
    [_topCommentView setVoteStatus:commentItem animation:isNeedAnimation];
}

@end







