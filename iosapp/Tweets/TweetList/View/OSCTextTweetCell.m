//
//  OSCTextTweetCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTextTweetCell.h"
#import "ImageDownloadHandle.h"
#import "OSCTweetItem.h"
#import "OSCStatistics.h"
#import "OSCNetImage.h"
#import "OSCAbout.h"
#import "Utils.h"

#import "UIImageView+Comment.h"
#import "NSDate+Comment.h"
#import "UIColor+Util.h"
#import "UITextView+DisableCopy.h"//UITextView 禁用系统复制

#import <YYKit.h>

@interface OSCTextTweetCell ()<UITextViewDelegate>{
    __weak UIImageView* _userPortrait;
    __weak YYLabel* _nameLabel;
    __weak UITextView* _descTextView;
    __weak YYLabel* _timeAndSourceLabel;
    __weak UIImageView* _likeCountButton;
    __weak YYLabel* _likeCountLabel;
    __weak UIImageView* _forwardCountButton;
    __weak YYLabel* _forwardCountLabel;
    __weak UIImageView* _commentCountButton;
    __weak YYLabel* _commentCountLabel;
    __weak YYLabel *_idendityLabel;
}
@end

@implementation OSCTextTweetCell{
    CGFloat _rowHeight;
    
    BOOL _trackingTouch_userPortrait;
    BOOL _trackingTouch_forwardBtn;
    BOOL _trackingTouch_likeBtn;
}

+ (instancetype)returnReuseTextTweetCellWithTableView:(UITableView *)tableView
                                          identifier:(NSString *)reuseIdentifier
{
    OSCTextTweetCell* textTweetCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!textTweetCell) {
        textTweetCell = [[OSCTextTweetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        [textTweetCell addSubViews];
    }
    return textTweetCell;
}

- (void)addSubViews{
    UIImageView* userPortrait = [UIImageView new];
    _userPortrait = userPortrait;
    _userPortrait.contentMode = UIViewContentModeScaleAspectFit;
    _userPortrait.userInteractionEnabled = YES;
    [_userPortrait handleCornerRadiusWithRadius:22];
    [self.contentView addSubview:_userPortrait];
    
    YYLabel* nameLabel = [YYLabel new];
    _nameLabel = nameLabel;
    _nameLabel.font = [UIFont boldSystemFontOfSize:nameLabel_FontSize];
    _nameLabel.numberOfLines = 1;
    _nameLabel.textColor = [UIColor newTitleColor];
    _nameLabel.displaysAsynchronously = YES;
    _nameLabel.fadeOnAsynchronouslyDisplay = NO;
    _nameLabel.fadeOnHighlight = NO;
    [self.contentView addSubview:_nameLabel];
    
    YYLabel *idendityLabel = [YYLabel new];
    _idendityLabel = idendityLabel;
    _idendityLabel.font = [UIFont systemFontOfSize:10.0];
    _idendityLabel.text = @"官方人员";
    _idendityLabel.textColor = [UIColor colorWithHex:0x24CF5F];
    _idendityLabel.textAlignment = NSTextAlignmentCenter;
    _idendityLabel.layer.masksToBounds = YES;
    _idendityLabel.layer.cornerRadius = 2;
    _idendityLabel.layer.borderColor = [UIColor colorWithHex:0x24CF5F].CGColor;
    _idendityLabel.layer.borderWidth = 1;
    [self addSubview:_idendityLabel];
    
    UITextView* descTextView = [UITextView new];
    _descTextView = descTextView;
    _descTextView.delegate = self;
    [_descTextView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forwardingEvent:)]];
    
    [self handleTextView:_descTextView];
    [self.contentView addSubview:_descTextView];
    
    YYLabel* timeAndSourceLabel = [YYLabel new];
    _timeAndSourceLabel = timeAndSourceLabel;
    _timeAndSourceLabel.font = [UIFont systemFontOfSize:12];
    _timeAndSourceLabel.displaysAsynchronously = YES;
    _timeAndSourceLabel.fadeOnAsynchronouslyDisplay = NO;
    _timeAndSourceLabel.fadeOnHighlight = NO;
    [self.contentView addSubview:_timeAndSourceLabel];
    
    YYLabel* commentCountLabel = [YYLabel new];
    _commentCountLabel = commentCountLabel;
    _commentCountLabel.textAlignment = NSTextAlignmentCenter;
    _commentCountLabel.font = [UIFont systemFontOfSize:12];
    _commentCountLabel.textColor = [UIColor newAssistTextColor];
    _commentCountLabel.displaysAsynchronously = YES;
    _commentCountLabel.fadeOnAsynchronouslyDisplay = NO;
    _commentCountLabel.fadeOnHighlight = NO;
    [self.contentView addSubview:_commentCountLabel];
    
    UIImageView* commentCountButton = [[UIImageView alloc]initWithImage:[self commentImage]];
    _commentCountButton = commentCountButton;
    _commentCountButton.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_commentCountButton];
    
    YYLabel* forwardCountLabel = [YYLabel new];
    _forwardCountLabel = forwardCountLabel;
    _forwardCountLabel.textAlignment = NSTextAlignmentCenter;
    _forwardCountLabel.font = [UIFont systemFontOfSize:12];
    _forwardCountLabel.textColor = [UIColor newAssistTextColor];
    [self.contentView addSubview:_forwardCountLabel];
    
    UIImageView* forwardCountButton = [[UIImageView alloc] initWithImage:[self forwardImage]];
    _forwardCountButton = forwardCountButton;
    [self.contentView addSubview:_forwardCountButton];
    
    YYLabel* likeCountLabel = [YYLabel new];
    _likeCountLabel = likeCountLabel;
    _likeCountLabel.textAlignment = NSTextAlignmentCenter;
    _likeCountLabel.font = [UIFont systemFontOfSize:12];
    _likeCountLabel.textColor = [UIColor newAssistTextColor];
    _likeCountLabel.displaysAsynchronously = YES;
    _likeCountLabel.fadeOnAsynchronouslyDisplay = NO;
    _likeCountLabel.fadeOnHighlight = NO;
    [self.contentView addSubview:_likeCountLabel];
    
    UIImageView* likeCountButton = [[UIImageView alloc]initWithImage:[self unlikeImage]];
    _likeCountButton = likeCountButton;
    _likeCountButton.contentMode = UIViewContentModeTopRight;
    [self.contentView addSubview:_likeCountButton];

}

- (void)layoutSubviews{
    [super layoutSubviews];

    _userPortrait.frame = _tweetItem.userPortraitFrame;
    
    _nameLabel.frame = _tweetItem.nameLabelFrame;
    
    if (_tweetItem.author.identity.officialMember) {
        _idendityLabel.hidden = NO;
        _idendityLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame) + 5, CGRectGetMinY(_nameLabel.frame), 45, 16);
    }else{
        _idendityLabel.hidden = YES;
    }
    
    _descTextView.frame = _tweetItem.descTextFrame;
    
    _timeAndSourceLabel.frame = _tweetItem.timeLabelFrame;
    
    _commentCountLabel.frame = _tweetItem.commentLabelFrame;
    
    _commentCountButton.frame = _tweetItem.commentButtonFrame;
    
    _forwardCountLabel.frame = _tweetItem.forwardLabelFrame;
    
    _forwardCountButton.frame = _tweetItem.forwardButtonFrame;

    _likeCountLabel.frame = _tweetItem.likeLabelFrame;
    
    _likeCountButton.frame = _tweetItem.likeButtonFrame;
}

- (void)setTweetItem:(OSCTweetItem *)tweetItem{
    _tweetItem = tweetItem;
    
    [_userPortrait loadPortrait:[NSURL URLWithString:tweetItem.author.portrait] userName:tweetItem.author.name];
    
    _nameLabel.text = tweetItem.author.name;
    _descTextView.attributedText = [Utils contentStringFromRawString:tweetItem.content];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[[NSDate dateFromString:tweetItem.pubDate] timeAgoSince]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)tweetItem.appClient]];
    att.color = [UIColor newAssistTextColor];
    _timeAndSourceLabel.attributedText = att;
    
    if (tweetItem.liked) {
        [_likeCountButton setImage:[self likeImage]];
    } else {
        [_likeCountButton setImage:[self unlikeImage]];
    }
    
    [self operationLabel:_likeCountLabel curCount:tweetItem.statistics.like describeText:@"赞"];
    [self operationLabel:_commentCountLabel curCount:tweetItem.statistics.comment describeText:@"评论"];
    [self operationLabel:_forwardCountLabel curCount:tweetItem.statistics.transmit describeText:@"转发"];
    
    _rowHeight = tweetItem.rowHeight;
    self.contentView.height = _rowHeight;
}

#pragma mark --- 重用操作
- (void)prepareForReuse{
    [super prepareForReuse];
    _userPortrait.image = nil;
    _rowHeight = 0 ;
}

#pragma mark --- 触摸分发
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _trackingTouch_userPortrait = NO;
    _trackingTouch_likeBtn = NO;
    _trackingTouch_forwardBtn = NO;
    UITouch *t = touches.anyObject;
    CGPoint p1 = [t locationInView:_userPortrait];
    CGPoint p2 = [t locationInView:_likeCountButton];
    CGPoint p2_1 = [t locationInView:_likeCountLabel];
    CGPoint p3 = [t locationInView:_forwardCountButton];
    CGPoint p3_1 = [t locationInView:_forwardCountLabel];
    if (CGRectContainsPoint(_userPortrait.bounds, p1)) {
        _trackingTouch_userPortrait = YES;
    }else if (CGRectContainsPoint(_forwardCountButton.bounds, p3) || CGRectContainsPoint(_forwardCountLabel.bounds , p3_1)){
//        _trackingTouch_forwardBtn = YES;///< 开启列表转发面板的呼出
        _trackingTouch_forwardBtn = NO;///< 关闭列表转发面板的呼出
    }else if(CGRectContainsPoint(_likeCountButton.bounds, p2) || CGRectContainsPoint(_likeCountLabel.bounds, p2_1)){
        _trackingTouch_likeBtn = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_trackingTouch_userPortrait) {
        if ([_delegate respondsToSelector:@selector(userPortraitDidClick:)]) {
            [_delegate userPortraitDidClick:self];
        }
    }else if (_trackingTouch_forwardBtn){
        if ([_delegate respondsToSelector:@selector(forwardTweetButtonDidClick:)]) {
            [_delegate forwardTweetButtonDidClick:self];
        }
    }else if (_trackingTouch_likeBtn){
        if ([_delegate respondsToSelector:@selector(changeTweetStausButtonDidClick:)]) {
            [_delegate changeTweetStausButtonDidClick:self];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_trackingTouch_userPortrait || !_trackingTouch_likeBtn || !_trackingTouch_forwardBtn) {
        [super touchesCancelled:touches withEvent:event];
    }
}

#pragma mark --- 动画handle
- (void)setLikeStatus:(BOOL)isLike animation:(BOOL)isNeedAnimation{
    UIImage* image = isLike ? [self likeImage] : [self unlikeImage];
    if (isNeedAnimation) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            _likeCountButton.layer.transformScale = 1.7;
        } completion:^(BOOL finished) {
            
            _likeCountButton.image = image;
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                _likeCountButton.layer.transformScale = 0.9;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                    _likeCountButton.layer.transformScale = 1;
                } completion:^(BOOL finished) {
                    [self operationLabel:_likeCountLabel curCount:_tweetItem.statistics.like describeText:@"赞"];
                }];
            }];
        }];
    }else{
       [_likeCountButton setImage:image];
        [self operationLabel:_likeCountLabel curCount:_tweetItem.statistics.like describeText:@"赞"];
    }
}

#pragma mark --- textHandle

- (void)copyText:(id)sender
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:_descTextView.text];
}

#pragma mark --- UITextView delegate
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([_delegate respondsToSelector:@selector(shouldInteractTextView:URL:inRange:)]) {
        [_delegate shouldInteractTextView:textView URL:URL inRange:characterRange];
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder{
    return NO;
}

- (void)forwardingEvent:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(textViewTouchPointProcessing:)]) {
        [_delegate textViewTouchPointProcessing:tap];
    }
}


@end





