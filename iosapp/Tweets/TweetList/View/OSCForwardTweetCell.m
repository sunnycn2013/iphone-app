//
//  OSCForwardTweetCell.m
//  iosapp
//
//  Created by Graphic-one on 16/12/3.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCForwardTweetCell.h"
#import "Utils.h"
#import "OSCTweetItem.h"
#import "OSCAbout.h"
#import "OSCNetImage.h"
#import "OSCForwardView.h"
#import "OSCPhotoGroupView.h"
#import "AsyncDisplayTableViewCell.h"

#import "UIImageView+Comment.h"
#import "NSDate+Comment.h"
#import "UIColor+Util.h"

#import <YYKit.h>

@interface OSCForwardTweetCell ()<UITextViewDelegate,UIGestureRecognizerDelegate,OSCForwardViewDelegate>
{
    __weak UIImageView* _userPortrait;
    __weak YYLabel* _nameLabel;
    __weak UITextView* _descTextView;
    
    __weak OSCForwardView* _forwardView;
    
    __weak YYLabel* _timeAndSourceLabel;
    __weak UIImageView* _likeCountButton;
    __weak YYLabel* _likeCountLabel;
    __weak UIImageView* _forwardCountButton;
    __weak YYLabel* _forwardCountLabel;
    __weak UIImageView* _commentCountButtn;
    __weak YYLabel* _commentCountLabel;
    __weak YYLabel *_idendityLabel;
}

@end

@implementation OSCForwardTweetCell
{
    CGSize _descTextViewSize;
    CGFloat _forwardViewHeight;
    
    BOOL _trackingTouch_userPortrait;
    BOOL _trackingTouch_forwardBtn;
    BOOL _trackingTouch_likeBtn;
}

+ (instancetype)returnReuseForwardTweetCellWithTableView:(UITableView *)tableView
                                           identifierStr:(NSString *)identifier
                                               tweetItem:(OSCTweetItem *)tweetItem
{
    OSCForwardTweetCell* forwordCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!forwordCell) {
        forwordCell = [[OSCForwardTweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    forwordCell.tweetItem = tweetItem;
    return forwordCell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self settingUI];
        _showCountLabel = YES;
    }
    return self;
}


#pragma mark --- settingUI
- (void)settingUI{
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
    
    OSCForwardView* forwardView = [[OSCForwardView alloc] initWithType:OSCForwardViewSource_list];
    _forwardView = forwardView;
    _forwardView.delegate = self;
    _forwardView.canToViewLargerIamge = YES;
    _forwardView.canEnterDetailPage = YES;
    [self.contentView addSubview:_forwardView];
    
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
    _commentCountButtn = commentCountButton;
    _commentCountButtn.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_commentCountButtn];
    
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
    
    _userPortrait.size = (CGSize){userPortrait_W,userPortrait_H};
    _userPortrait.left = padding_left;
    _userPortrait.top = padding_top;
    
    _nameLabel.top = padding_top;
    _nameLabel.left = CGRectGetMaxX(_userPortrait.frame) + userPortrait_SPACE_nameLabel;
    _nameLabel.width = _tweetItem.nameLabelFrame.size.width;
    _nameLabel.height = nameLabel_H;
    
    if (_tweetItem.author.identity.officialMember) {
        _idendityLabel.hidden = NO;
        _idendityLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame) + 5, CGRectGetMinY(_nameLabel.frame), 50, 16);
    }else{
        _idendityLabel.hidden = YES;
    }
    
    _descTextView.left = CGRectGetMaxX(_userPortrait.frame) + descTextView_SPACE_userPortrait;
    _descTextView.top = CGRectGetMaxY(_nameLabel.frame) + nameLabel_space_descTextView;
    _descTextView.size = _descTextViewSize;
    
    _forwardView.left = _userPortrait.right;
    _forwardView.top = CGRectGetMaxY(_descTextView.frame) + descTextView_space_forwardView;
    _forwardView.width = forwardView_FullWidth_list;
    _forwardView.height = _forwardViewHeight;
    
    _timeAndSourceLabel.left = _descTextView.left;
    _timeAndSourceLabel.top = CGRectGetMaxY(_forwardView.frame) + forwardView_space_timeAndSourceLabel;
    _timeAndSourceLabel.size = (CGSize){timeAndSourceLabel_W,timeAndSourceLabel_H};
    
    _forwardCountLabel.size = (CGSize){commentCountLabel_W,commentCountLabel_H};
    _forwardCountLabel.left = kScreen_W - _forwardCountLabel.width - padding_right;
    _forwardCountLabel.top = _timeAndSourceLabel.top;
    
    _forwardCountButton.size = (CGSize){operationBtn_W,operationBtn_H};
    _forwardCountButton.top = _timeAndSourceLabel.top;
    _forwardCountButton.left = CGRectGetMinX(_forwardCountLabel.frame) - operationBtn_space_label - _forwardCountButton.width;
    
    _commentCountLabel.size = (CGSize){commentCountLabel_W,commentCountLabel_H};
    _commentCountLabel.left = CGRectGetMinX(_forwardCountButton.frame) - like_space_comment - _commentCountLabel.width;
    _commentCountLabel.top = _timeAndSourceLabel.top;
    
    _commentCountButtn.size = (CGSize){operationBtn_W,operationBtn_H};
    _commentCountButtn.left = CGRectGetMinX(_commentCountLabel.frame) - operationBtn_space_label - _commentCountButtn.width;
    _commentCountButtn.top = _timeAndSourceLabel.top;
    
    _likeCountLabel.size = (CGSize){commentCountLabel_W,commentCountLabel_H };
    _likeCountLabel.top = _timeAndSourceLabel.top;
    _likeCountLabel.left = CGRectGetMinX(_commentCountButtn.frame) - like_space_comment - _likeCountLabel.width;
    
    _likeCountButton.size = (CGSize){operationBtn_W + 10,operationBtn_H + 10};
    _likeCountButton.top = _timeAndSourceLabel.top - 1;
    _likeCountButton.left = CGRectGetMinX(_likeCountLabel.frame) - operationBtn_space_label - _likeCountButton.width;
}

#pragma mark --- setting ViewModel
- (void)setShowCountLabel:(BOOL)showCountLabel{
    _showCountLabel = showCountLabel;
    
    _commentCountLabel.hidden   = !_showCountLabel;
    _likeCountLabel.hidden      = !_showCountLabel;
    _forwardCountLabel.hidden   = !_showCountLabel;
}

- (void)setTweetItem:(OSCTweetItem *)tweetItem{
    if (tweetItem.about.id == 0) {
        tweetItem.about.title = @"不存在或已删除的内容";
        tweetItem.about.content = @"抱歉，该内容不存在或已删除";
    }
    _tweetItem = tweetItem;
    
    [_userPortrait loadPortrait:[NSURL URLWithString:tweetItem.author.portrait] userName:tweetItem.author.name];
    _nameLabel.text = tweetItem.author.name;
    _descTextView.attributedText = [Utils contentStringFromRawString:tweetItem.content];
    
    _forwardView.forwardItem = tweetItem.about;
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:tweetItem.pubDate] timeAgoSince]]];
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
    
    _descTextViewSize = tweetItem.descTextFrame.size;
    _forwardViewHeight = tweetItem.about.viewHeight;
    self.contentView.height = tweetItem.rowHeight;
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
- (void)forwardingEvent:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(textViewTouchPointProcessing:)]) {
        [_delegate textViewTouchPointProcessing:tap];
    }
}

#pragma mark --- OSCForwardView delegate
- (void)forwardViewDidClick:(OSCForwardView *)forwardView{
    if ([_delegate respondsToSelector:@selector(forwardViewDidClick:forwardView:)]) {
        [_delegate forwardViewDidClick:self forwardView:_forwardView];
    }
}
- (void)forwardViewDidLoadLargeImage:(OSCForwardView *)forwardView
                      photoGroupView:(OSCPhotoGroupView *)groupView
                            fromView:(UIImageView *)fromView
{
    if ([_delegate respondsToSelector:@selector(loadLargeImageDidFinsh:photoGroupView:fromView:)]) {
        [_delegate loadLargeImageDidFinsh:self photoGroupView:groupView fromView:fromView];
    }
}
@end





















