//
//  NewCommentCell.m
//  iosapp
//
//  Created by 李萍 on 16/6/2.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewCommentCell.h"
#import "Utils.h"
#import <Masonry.h>

#import <YYKit.h>
#import "UIImageView+Comment.h"
#import "NSDate+Comment.h"

@interface NewCommentCell (){
    __weak UIView* _colorView;
    BOOL _isOngoingAnimation;
}

@end

@implementation NewCommentCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setLayOutForSubView];
    }
    return self;
}

- (void)setLayOutForSubView
{
    _commentPortrait = [UIImageView new];
    _commentPortrait.backgroundColor = [UIColor clearColor];
    [_commentPortrait handleCornerRadiusWithRadius:16];
    [self.contentView addSubview:_commentPortrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    _nameLabel.textColor = [UIColor colorWithHex:0x111111];
    [self.contentView addSubview:_nameLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:10];
    _timeLabel.textColor = [UIColor colorWithHex:0x9d9d9d];
    [self.contentView addSubview:_timeLabel];
    
    _contentTextView = [UITextView new];
    _contentTextView.userInteractionEnabled = NO;
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:_contentTextView.text];
    [self setUpContetTextView:_contentTextView];
    [self.contentView addSubview:_contentTextView];
    
    _referCommentView = [UIView new];
    [self.contentView addSubview:_referCommentView];
    
    _voteLabel = [UILabel new];
    _voteLabel.font = [UIFont systemFontOfSize:14];
    _voteLabel.textColor = [UIColor colorWithHex:0x979797];
    [self.contentView addSubview:_voteLabel];
    
    _voteImageView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_voteImageView setImage: [UIImage imageNamed:@"ic_thumbup_normal"] forState:UIControlStateNormal];
    [_voteImageView addTarget:self action:@selector(voteForComment:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_voteImageView];
    
    _commentButton = [UIButton new];
    [_commentButton setImage:[UIImage imageNamed:@"ic_comment_30"] forState:UIControlStateNormal];
    [self.contentView addSubview:_commentButton];
    
    _bestImageView = [UIImageView new];
    _bestImageView.image = [UIImage imageNamed:@"label_best_answer"];
    [self.contentView addSubview:_bestImageView];
    
    UIView* colorView = [[UIView alloc]init];
    colorView.backgroundColor = [UIColor newSeparatorColor];
    [self.contentView addSubview:colorView];
    _colorView = colorView;
    
    //masonry
    [_commentPortrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.contentView).with.offset(16);
        make.width.and.height.equalTo(@32);
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(15);
        make.left.equalTo(_commentPortrait.mas_right).offset(8);
    }];
    
    [_voteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(16);
        make.width.and.height.equalTo(@14);
        make.right.equalTo(_voteLabel.mas_left).with.offset(-5);
    }];
    
    [_voteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLabel.mas_top).with.offset(0);
        make.bottom.equalTo(_nameLabel.mas_bottom).with.offset(0);
        make.right.equalTo(_commentButton.mas_left).with.offset(-16);
    }];
    
    [_commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_nameLabel);
        make.right.equalTo(self.contentView).offset(-16);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLabel.mas_bottom);
        make.left.equalTo(_nameLabel);
    }];
    [_referCommentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_commentPortrait.mas_bottom).offset(7);
        make.left.equalTo(_commentPortrait);
        make.right.equalTo(self.contentView).offset(-16);
    }];
    [_contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_referCommentView.mas_bottom).offset(7);
        make.left.equalTo(_commentPortrait);
        make.right.equalTo(self.contentView).offset(-16);
        make.bottom.equalTo(self.contentView).offset(-16);
    }];
    [_colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.right.and.bottom.equalTo(self.contentView);
        make.height.equalTo(@0.5);
    }];
}

- (void)voteForComment:(UIButton* )btn{
    btn.selected = NO;
    btn.highlighted = NO;
    
    if ([_delegate respondsToSelector:@selector(setVoteStatusClickAction:sourceComment:)]) {
        [_delegate setVoteStatusClickAction:self sourceComment:_comment];
    }
}

#pragma mark - contentData

- (void)setSourceType:(NSInteger)sourceType
{
    _sourceType = sourceType;
}

- (void)setComment:(OSCCommentItem *)comment {
    
    _comment = comment;
    
    [_commentPortrait loadPortrait:[NSURL URLWithString:comment.author.portrait] userName:comment.author.name];
    _nameLabel.text = comment.author.name.length > 0 ? comment.author.name : @"火星网友";
    
    _timeLabel.text = [[NSDate dateFromString:comment.pubDate] timeAgoSince];
    
    _bestImageView.hidden = YES;
    
    if (_sourceType == 6) {
        if (comment.voteState == CommentStatusType_Like) {
            [_voteImageView setImage:[UIImage imageNamed:@"ic_thumbup_actived"] forState:UIControlStateNormal];
        } else if (_comment.voteState == CommentStatusType_Unlike) {
            [_voteImageView setImage:[UIImage imageNamed:@"ic_thumbup_normal"] forState:UIControlStateNormal];
        } else {
            [_voteImageView setImage:[UIImage imageNamed:@"ic_thumbup_normal"] forState:UIControlStateNormal];
        }
        _voteLabel.text = [NSString stringWithFormat:@"%ld", (long)comment.vote];
    } else {
        _voteImageView.hidden = YES;
        _voteLabel.hidden = YES;
    }

    _contentTextView.attributedText = [NewCommentCell contentStringFromRawString:comment.content];
    
    if (comment.refer.count > 0) {
        _referCommentView.hidden = NO;
        [self setLayOutForRefer:comment.refer];
    } else {
        _referCommentView.hidden = YES;
    }
}

- (void)setDataForQuestionComment:(OSCCommentItem *)questComment {
    [_commentPortrait loadPortrait:[NSURL URLWithString:questComment.author.portrait] userName:questComment.author.name];
    _nameLabel.text = questComment.author.name;
    _timeLabel.text = [[NSDate dateFromString:questComment.pubDate] timeAgoSince];
    
    _contentTextView.attributedText = [NewCommentCell contentStringFromRawString:questComment.content];
    
    _voteLabel.hidden = YES;
    _voteImageView.hidden = YES;
    
    if (questComment.best) {
        
        _commentButton.hidden = YES;
        _bestImageView.hidden = NO;
        
    } else {
        _commentButton.hidden = NO;
        _bestImageView.hidden = YES;
        
    }
}

- (void)setDataForQuestionCommentReply:(OSCCommentItemReply *)commentReply {
    [_commentPortrait loadPortrait:[NSURL URLWithString:commentReply.author.portrait] userName:commentReply.author.name];
    _nameLabel.text = commentReply.author.name;
    _timeLabel.text = [[NSDate dateFromString:commentReply.pubDate] timeAgoSince];
    _bestImageView.hidden = YES;
    /* 隐藏 */
    _voteImageView.hidden = YES;
    _voteLabel.hidden = YES;
    /* */
    
    _contentTextView.attributedText = [NewCommentCell contentStringFromRawString:commentReply.content];
}


- (void)setUpContetTextView:(UITextView*)textView {
    textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    textView.font = [UIFont systemFontOfSize:14];
    textView.textColor = [UIColor colorWithHex:0x111111];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    [textView setTextContainerInset:UIEdgeInsetsZero];
    textView.textContainer.lineFragmentPadding = 0;
    textView.linkTextAttributes = @{
                                    NSForegroundColorAttributeName: [UIColor nameColor],
                                    NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)
                                    };
    
}

#pragma mark - 处理字符串
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString {
    if (!rawString || rawString.length == 0) return [[NSAttributedString alloc] initWithString:@""];
    
    NSAttributedString *attrString = [Utils attributedStringFromHTML:rawString];
    //    [Utils emojiStringFromAttrString:attrString]
    NSMutableAttributedString *mutableAttrString = [attrString mutableCopy];
    [mutableAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14   ] range:NSMakeRange(0, mutableAttrString.length)];
    
    // remove under line style
    [mutableAttrString beginEditing];
    [mutableAttrString enumerateAttribute:NSUnderlineStyleAttributeName
                                  inRange:NSMakeRange(0, mutableAttrString.length)
                                  options:0
                               usingBlock:^(id value, NSRange range, BOOL *stop) {
                                   if (value) {
                                       [mutableAttrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
                                   }
                               }];
    [mutableAttrString endEditing];
    
    return mutableAttrString;
}

#pragma mark - refer
- (void)setLayOutForRefer:(NSArray *)refers
{
    if (refers.count <= 0) {
        return;
    }
    
    NSInteger referNum = refers.count;
    
    while (referNum > 0) {
        UIView *subContainer = [UIView new];
        [_referCommentView addSubview:subContainer];
        
        UILabel *contentLabel = [UILabel new];
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
        contentLabel.numberOfLines = 0;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_referCommentView addSubview:contentLabel];
        
        
        OSCCommentItemRefer *refer = refers[referNum-1];
        
        NSMutableAttributedString *replyContent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:\n", refer.author]];
        [replyContent appendAttributedString:[Utils emojiStringFromRawString:[refer.content deleteHTMLTag]]];
        contentLabel.attributedText = replyContent;
        
        UIView *leftLine = [UIView new];
        leftLine.backgroundColor = [UIColor separatorColor];
        [_referCommentView addSubview:leftLine];
        
        UIView *bottomLine = [UIView new];
        bottomLine.backgroundColor = [UIColor separatorColor];
        [_referCommentView addSubview:bottomLine];
        
        for (UIView *view in _referCommentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
        NSDictionary *views = NSDictionaryOfVariableBindings(subContainer, contentLabel, leftLine, bottomLine);
        
        referNum --;
        
        if(referNum > 0) {
            subContainer.hidden = NO;
            [_referCommentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftLine]|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:views]];
            
            [_referCommentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subContainer]-6-[contentLabel]-5-[bottomLine(0.5)]|"
                                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                                      metrics:nil
                                                                                        views:views]];
            
            
            
            
            [_referCommentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[leftLine(1)]-8-[subContainer]|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:views]];
        } else {
            subContainer.hidden = YES;
            [_referCommentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftLine]|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:views]];
            
            [_referCommentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[contentLabel]-5-[bottomLine(0.5)]|"
                                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                                      metrics:nil
                                                                                        views:views]];
            
            
            [_referCommentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[leftLine(1)]-8-[contentLabel]|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:views]];
        }
        
        _referCommentView = subContainer;
        
    }
    
}

#pragma mark - vote animation

- (void)setVoteStatus:(OSCCommentItem* )commentItem animation:(BOOL)isNeedAnimation{
    UIImage* image = commentItem.voteState == CommentStatusType_Like ? [UIImage imageNamed:@"ic_thumbup_actived"] : [UIImage imageNamed:@"ic_thumbup_normal"];

    _isOngoingAnimation = NO;

    if (isNeedAnimation) {
        _isOngoingAnimation = YES;
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
            _voteImageView.layer.transformScale = 1.7;
        } completion:^(BOOL finished) {
            [_voteImageView setImage:image forState:UIControlStateNormal];
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                _voteImageView.layer.transformScale = 0.9;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                    _voteImageView.layer.transformScale = 1;
                } completion:^(BOOL finished) {
                    _isOngoingAnimation = NO;
                    _voteLabel.text = [NSString stringWithFormat:@"%ld", (long)commentItem.vote];
                }];
            }];
        }];
    } else {
        if (_isOngoingAnimation) {
            [_voteImageView.layer removeAllAnimations];
        }
        [_voteImageView setImage:image forState:UIControlStateNormal];
        _voteLabel.text = [NSString stringWithFormat:@"%ld", (long)commentItem.vote];
    }
}


#pragma mark --- UITextView delegate


@end
