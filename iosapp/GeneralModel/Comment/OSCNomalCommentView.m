//
//  OSCNomalCommentView.m
//  iosapp
//
//  Created by Graphic-one on 17/1/17.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCNomalCommentView.h"
#import "UIImage+Comment.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utils.h"

#import <YYKit.h>

@interface OSCNomalCommentView () <UITextViewDelegate>
{
    __weak UIImageView *_userPortraitView;
    __weak YYLabel *_nameLabel;
    __weak YYLabel *_timeLabel;
    __weak UIImageView *_commentIconView;
    __weak UITextView *_contentTextView;
    __weak YYLabel *_identityLabel;
}

@property (nonatomic, strong) OSCCommentItem *commentItem;

@end

@implementation OSCNomalCommentView
{
    BOOL _trackingTouch_portrait;
}

 - (instancetype)initWithViewModel:(OSCCommentItem *)commentItem
                 uxiliaryNodeStyle:(CommentUxiliaryNode)uxiliaryNode
 {
     self = [super initWithViewModel:commentItem uxiliaryNodeStyle:uxiliaryNode];
     if (self) {
         self.commentItem = commentItem;
         
         [self addSubviews];
         [self setCommentUxiliaryNodeStyle:uxiliaryNode];
     }
     
     return self;
 }

- (void)addSubviews
{
    UIImageView *userPortrait = [UIImageView new];
    _userPortraitView = userPortrait;
    _userPortraitView.contentMode = UIViewContentModeScaleAspectFit;
    _userPortraitView.userInteractionEnabled = YES;
    [_userPortraitView handleCornerRadiusWithRadius:16];
    [self addSubview:_userPortraitView];
    
    YYLabel *nameLabel = [YYLabel new];
    _nameLabel = nameLabel;
    _nameLabel.font = [UIFont boldSystemFontOfSize:15];
    _nameLabel.numberOfLines = 1;
    _nameLabel.textColor = [UIColor newTitleColor];
    _nameLabel.displaysAsynchronously = YES;
    _nameLabel.fadeOnAsynchronouslyDisplay = NO;
    _nameLabel.fadeOnHighlight = NO;
	_nameLabel.text = @"火星网友";
    [self addSubview:_nameLabel];
    
    YYLabel *timeLabel = [YYLabel new];
    _timeLabel = timeLabel;
    _timeLabel.font = [UIFont boldSystemFontOfSize:10.0];
    _timeLabel.numberOfLines = 1;
    _timeLabel.textColor = [UIColor newAssistTextColor];
    _timeLabel.displaysAsynchronously = YES;
    _timeLabel.fadeOnAsynchronouslyDisplay = NO;
    _timeLabel.fadeOnHighlight = NO;
    [self addSubview:_timeLabel];
    
    if (_commentItem.author.identity.officialMember) {
        YYLabel *identityLabel = [YYLabel new];
        identityLabel.font = [UIFont systemFontOfSize:10.0];
        identityLabel.text = @"官方人员";
        identityLabel.textColor = [UIColor colorWithHex:0x24CF5F];
        identityLabel.textAlignment = NSTextAlignmentCenter;
        identityLabel.layer.masksToBounds = YES;
        identityLabel.layer.cornerRadius = 2;
        identityLabel.layer.borderColor = [UIColor colorWithHex:0x24CF5F].CGColor;
        identityLabel.layer.borderWidth = 1;
        _identityLabel = identityLabel;
        [self addSubview:_identityLabel];
    }
    
    UIImageView *commentIconView = [UIImageView new];
    _commentIconView = commentIconView;
    _commentIconView.contentMode = UIViewContentModeScaleAspectFit;
    _commentIconView.userInteractionEnabled = YES;
    [self addSubview:_commentIconView];
    
    
    UITextView *descTextView = [UITextView new];
    _contentTextView = descTextView;
    _contentTextView.delegate = self;
    _contentTextView.userInteractionEnabled = NO;
    [self handleTextView:_contentTextView];
    
    [self addSubview:_contentTextView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _userPortraitView.frame = _commentItem.layoutInfo.userPortraitFrame;
    _nameLabel.frame = _commentItem.layoutInfo.userNameLbFrame;
    if (_commentItem) {
        _identityLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame) + 5, _nameLabel.frame.origin.y, 50, 16);
    }
    _timeLabel.frame = _commentItem.layoutInfo.timeLbFrame;
    _commentIconView.frame = _commentItem.layoutInfo.commentBtnFrame;
    _contentTextView.frame = _commentItem.layoutInfo.contentTextViewFrame;
}

- (void)setCommentUxiliaryNodeStyle:(CommentUxiliaryNode)uxiliaryNode
{
    [_userPortraitView loadPortrait:[NSURL URLWithString:_commentItem.author.portrait] userName:_commentItem.author.name];
    _nameLabel.text = _commentItem.author.name != nil ? _commentItem.author.name : @"火星网友";
    _timeLabel.text = [NSString stringWithFormat:@"%@", [[NSDate dateFromString:_commentItem.pubDate] timeAgoSince]];
    _contentTextView.attributedText = [OSCBaseCommetView contentStringFromRawString:_commentItem.content withFont:14];
    
    switch (uxiliaryNode) {
        case CommentUxiliaryNode_like:
        {
            [_commentIconView setImage:[[super class] unlikeImage]];
            break;
        }
        case CommentUxiliaryNode_comment:
        {
            [_commentIconView setImage:[[super class] commentImage]];
            break;
        }
        case CommentUxiliaryNode_none:
        {
            break;
        }
        case CommentUxiliaryNode_customView:
        {
            [_commentIconView setImage:[UIImage imageNamed:@"label_best_answer"]];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark --- Event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _trackingTouch_portrait = NO;
    
    UITouch *touch = touches.anyObject;
    
    CGPoint portraitPoint  = [touch locationInView:_userPortraitView];
    
    if (CGRectContainsPoint(_userPortraitView.bounds, portraitPoint)) {
        _trackingTouch_portrait = YES;
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_trackingTouch_portrait) {
        if ([self.delegate respondsToSelector:@selector(commentViewDidClickUserPortrait:)]) {
            [self.delegate commentViewDidClickUserPortrait:self];
        }
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!_trackingTouch_portrait) {
        [super touchesMoved:touches withEvent:event];
    }
}

#pragma mark - textview click

- (void)handleTextView:(UITextView *)textView{
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:14];
    textView.textColor = [UIColor newTitleColor];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    [textView setTextContainerInset:UIEdgeInsetsZero];
    textView.textContainer.lineFragmentPadding = 0;
    [textView setContentInset:UIEdgeInsetsMake(0, -1, 0, 1)];
    textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    [textView setTextAlignment:NSTextAlignmentLeft];
    textView.text = @" ";
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:textView.text];
}


//-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
//    if ([_delegate respondsToSelector:@selector(shouldInteractTextView:URL:inRange:)]) {
//        [_delegate shouldInteractTextView:textView URL:URL inRange:characterRange];
//    }
//    return NO;
//}

@end
