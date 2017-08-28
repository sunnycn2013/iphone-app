//
//  OSCTweetForwardDetailTableViewCell.m
//  iosapp
//
//  Created by Graphic-one on 16/12/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetForwardDetailTableViewCell.h"
#import "OSCTweetItem.h"
#import "OSCAbout.h"
#import "OSCForwardView.h"
#import "AsyncDisplayTableViewCell.h"
#import "Utils.h"
#import "GAMenuView.h"

#import "UIImageView+Comment.h"
#import "UIColor+Util.h"
#import "NSDate+Comment.h"

#import <Masonry.h>

@interface OSCTweetForwardDetailTableViewCell ()<UITextViewDelegate,OSCForwardViewDelegate>
{
    __weak UIImageView* _userPortrait;
    __weak UILabel* _nameLabel;
    __weak UITextView* _descTextView;
    
    __weak OSCForwardView* _forwardView;
    
    __weak UILabel* _timeAndSourceLabel;
    __weak UIImageView* _likeCountButton;
    __weak UIImageView* _forwardCountButton;
    __weak UIImageView* _commentCountButtn;
    __weak UILabel *_idendityLabel;
}

@end

@implementation OSCTweetForwardDetailTableViewCell
{
    BOOL _trackingTouch_userPortrait;
    BOOL _trackingTouch_forwardBtn;
}

+ (instancetype)forwardDetailCellWith:(OSCTweetItem *)item
                      reuseIdentifier:(NSString *)reuseIdentifier
{
    return [[self alloc] initWithTweetItem:item reuseIdentifier:reuseIdentifier];
}

- (instancetype)initWithTweetItem:(OSCTweetItem *)item
                  reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _item = item;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setSubViews];
        [self setLayout];
    }
    return self;
}


#pragma mark -
#pragma mark --- setting SubViews && Layout
- (void)setSubViews{
    UIImageView* userPortrait = [UIImageView new];
    _userPortrait = userPortrait;
    _userPortrait.contentMode = UIViewContentModeScaleAspectFit;
    [_userPortrait handleCornerRadiusWithRadius:22];
    [self.contentView addSubview:_userPortrait];
    
    UILabel* nameLabel = [UILabel new];
    _nameLabel = nameLabel;
    _nameLabel.font = [UIFont boldSystemFontOfSize:nameLabel_FontSize];
    _nameLabel.numberOfLines = 1;
    _nameLabel.textColor = [UIColor newTitleColor];
    [self.contentView addSubview:_nameLabel];
    
    UILabel *idendityLabel = [UILabel new];
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
    
    UITextView* descTextView = [[UITextView alloc]init];
    descTextView.userInteractionEnabled = YES;
    descTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    descTextView.backgroundColor = [UIColor clearColor];
    descTextView.font = [UIFont systemFontOfSize:14];
    descTextView.textColor = [UIColor newTitleColor];
    descTextView.editable = NO;
    descTextView.scrollEnabled = NO;
    [descTextView setTextContainerInset:UIEdgeInsetsZero];
    descTextView.textContainer.lineFragmentPadding = 0;
    descTextView.delegate = self;
    _descTextView = descTextView;
    [self.contentView addSubview:_descTextView];
    
    OSCForwardView* forwardView = [[OSCForwardView alloc] initWithType:OSCForwardViewSource_detail];
    _forwardView = forwardView;
    _forwardView.canToViewLargerIamge = YES;
    _forwardView.canEnterDetailPage = YES;
    _forwardView.delegate = self;
    [self.contentView addSubview:_forwardView];
    
    UILabel* timeAndSourceLabel = [UILabel new];
    _timeAndSourceLabel = timeAndSourceLabel;
    _timeAndSourceLabel.font = [UIFont systemFontOfSize:12];
    _timeAndSourceLabel.textColor = [UIColor newAssistTextColor];
    [self.contentView addSubview:_timeAndSourceLabel];
    
    UIImageView* commentCountButton = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_comment_30"]];
    _commentCountButtn = commentCountButton;
    _commentCountButtn.contentMode = UIViewContentModeRight;
    [self.contentView addSubview:_commentCountButtn];
    
    UIImageView* forwardCountButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_Forward"]];
    _forwardCountButton = forwardCountButton;
    _forwardCountButton.userInteractionEnabled = YES;
    _forwardCountButton.contentMode = UIViewContentModeRight;
    [self.contentView addSubview:_forwardCountButton];

    UIImageView* likeCountButton = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_thumbup_normal"]];
    _likeCountButton = likeCountButton;
    _likeCountButton.contentMode = UIViewContentModeRight;
    _likeCountButton.userInteractionEnabled = YES;
    [_likeCountButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeBtnDidClickMethod:)]];
    [self.contentView addSubview:_likeCountButton];

}

- (void)setLayout{
    [_userPortrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.contentView).with.offset(16);
        make.width.and.height.equalTo(@45);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_userPortrait.mas_centerY);
        make.left.equalTo(_userPortrait.mas_right).with.offset(8);
        make.height.equalTo(@(16));
    }];
    
    [_idendityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(50));
        make.height.equalTo(@(16));
        make.top.equalTo(_nameLabel);
        make.left.equalTo(_nameLabel.mas_right).offset(5);
    }];
    
    [_descTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.top.equalTo(_userPortrait.mas_bottom).with.offset(8);
        make.right.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_forwardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.top.equalTo(_descTextView.mas_bottom).offset(4);
        make.height.equalTo(@(_item.about.viewHeight));
    }];
    
    [_timeAndSourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.top.equalTo(_forwardView.mas_bottom).with.offset(8);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_forwardCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@15);
        make.right.equalTo(self.contentView).with.offset(-16);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_commentCountButtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@15);
        make.bottom.equalTo(self.contentView).with.offset(-16);
        make.right.equalTo(_forwardCountButton.mas_left).with.offset(-24);
    }];
    
    [_likeCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@15);
        make.bottom.equalTo(self.contentView).with.offset(-16);
        make.right.equalTo(_commentCountButtn.mas_left).with.offset(0);
    }];
}

#pragma mark --- UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([self.delegate respondsToSelector:@selector(shouldInteract:TextView:URL:inRange:)]) {
        [self.delegate shouldInteract:self TextView:textView URL:URL inRange:characterRange];
    }
    return NO;
}

#pragma mark --- setting ViewModel
- (void)setItem:(OSCTweetItem *)item{
    _item = item;
    
    [_userPortrait loadPortrait:[NSURL URLWithString:_item.author.portrait] userName:_item.author.name];
    _nameLabel.text = _item.author.name;
    if (_item.author.identity.officialMember) {
        _idendityLabel.hidden = NO;
    }else{
        _idendityLabel.hidden = YES;
    }
    
    _descTextView.attributedText = [Utils contentStringFromRawString:_item.content];
    
    _forwardView.forwardItem = _item.about;
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:_item.pubDate] timeAgoSince]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)_item.appClient]];
    _timeAndSourceLabel.attributedText = att;
    
    if (_item.liked) {
        [_likeCountButton setImage:[UIImage imageNamed:@"ic_thumbup_actived"]];
    } else {
        [_likeCountButton setImage:[UIImage imageNamed:@"ic_thumbup_normal"]];
    }
    
    [_forwardView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(_item.about.viewHeight));
    }];
}

#pragma mark --- click Method
-(void)likeBtnDidClickMethod:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(likeButtonDidClick:tapGestures:)]) {
        [_delegate likeButtonDidClick:self tapGestures:tap];
    }
}
#pragma mark --- 触摸分发
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *t = touches.anyObject;
    
    _trackingTouch_userPortrait = NO;
    _trackingTouch_forwardBtn = NO;
    CGPoint p1 = [t locationInView:_userPortrait];
    CGPoint p3 = [t locationInView:_forwardCountButton];
    if (CGRectContainsPoint(_userPortrait.bounds, p1)) {
        _trackingTouch_userPortrait = YES;
        return;
    }else if (CGRectContainsPoint(_forwardCountButton.bounds, p3)){
        _trackingTouch_forwardBtn = YES;
        return;
    }else{
        _descTextView.selectedRange = NSMakeRange(0, 0);
        
        NSMutableAttributedString* mAtt = _descTextView.attributedText.mutableCopy;
        [mAtt addAttribute:NSBackgroundColorAttributeName value:[_descTextView.tintColor colorWithAlphaComponent:0.3] range:_descTextView.attributedText.rangeOfAll];
        _descTextView.attributedText = mAtt.copy;
        
        [GAMenuView MenuViewWithTitle:@"复制" block:^{
            NSMutableAttributedString* mAtt = _descTextView.attributedText.mutableCopy;
            [mAtt removeAttribute:NSBackgroundColorAttributeName range:_descTextView.attributedText.rangeOfAll];
            _descTextView.attributedText = mAtt.copy;
            UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:_descTextView.text];
        } cancelBlock:^{
            NSMutableAttributedString* mAtt = _descTextView.attributedText.mutableCopy;
            [mAtt removeAttribute:NSBackgroundColorAttributeName range:_descTextView.attributedText.rangeOfAll];
            _descTextView.attributedText = mAtt.copy;
        } inView:_descTextView];
        
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_trackingTouch_userPortrait) {
        if ([_delegate respondsToSelector:@selector(userPortraitDidClick:)]) {
            [_delegate userPortraitDidClick:self];
        }
    }else if (_trackingTouch_forwardBtn){
        if ([_delegate respondsToSelector:@selector(forwardButtonDidClick:)]) {
            [_delegate forwardButtonDidClick:self];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_trackingTouch_userPortrait || !_trackingTouch_forwardBtn) {
        [super touchesCancelled:touches withEvent:event];
    }
}

#pragma mark --- OSCForwardView delegate
- (void)forwardViewDidClick:(OSCForwardView *)forwardView{
    if ([_delegate respondsToSelector:@selector(forwardViewDidClick:)]) {
        [_delegate forwardViewDidClick:self];
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










