//
//  OSCImageTweetCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCImageTweetCell.h"
#import "OSCTweetItem.h"
#import "OSCNetImage.h"
#import "OSCStatistics.h"
#import "ImageDownloadHandle.h"
#import "OSCPhotoGroupView.h"
#import "Utils.h"

#import "UIImageView+Comment.h"
#import "NSDate+Comment.h"
#import "UIColor+Util.h"

#import <UIImage+GIF.h>
#import <UIImageView+WebCache.h>
#import <YYKit.h>

@interface OSCImageTweetCell ()<UITextViewDelegate>{
    __weak UIImageView* _userPortrait;
    __weak YYLabel* _nameLabel;
    __weak UITextView* _descTextView;
    __weak UIImageView* _imageView;
    __weak UIImageView* _imageTypeLogo;
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

@implementation OSCImageTweetCell{
    CGFloat _rowHeight;
    CGSize _imageSize;
    
    BOOL _trackingTouch_userPortrait;
    BOOL _trackingTouch_forwardBtn;
    BOOL _trackingTouch_imageView;
    BOOL _trackingTouch_likeBtn;
}

+(instancetype)returnReuseImageTweetCellWithTableView:(UITableView *)tableView
                                           identifier:(NSString *)reuseIdentifier
{
    OSCImageTweetCell* imageTweetCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!imageTweetCell) {
        imageTweetCell = [[OSCImageTweetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        [imageTweetCell addSubViews];
    }
    return imageTweetCell;
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
    [_descTextView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forwardingEvent:)]];
    _descTextView.delegate = self;
    [self handleTextView:_descTextView];
    [self.contentView addSubview:_descTextView];
    
    UIImageView* imageView = [UIImageView new];
    _imageView = imageView;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.6];
    _imageView.userInteractionEnabled = NO;
    [self.contentView addSubview:_imageView];
//    图片类型标识
    UIImageView* imageTypeLogo = [UIImageView new];
    _imageTypeLogo = imageTypeLogo;
    imageTypeLogo.hidden = YES;
    [_imageView addSubview:imageTypeLogo];
    
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
    
    YYLabel* likeCountLabel = [YYLabel new];
    _likeCountLabel = likeCountLabel;
    _likeCountLabel.textAlignment = NSTextAlignmentCenter;
    _likeCountLabel.font = [UIFont systemFontOfSize:12];
    _likeCountLabel.textColor = [UIColor newAssistTextColor];
    [self.contentView addSubview:_likeCountLabel];
    
    UIImageView* forwardCountButton = [[UIImageView alloc] initWithImage:[self forwardImage]];
    _forwardCountButton = forwardCountButton;
    [self.contentView addSubview:_forwardCountButton];
    
    YYLabel* forwardCountLabel = [YYLabel new];
    _forwardCountLabel = forwardCountLabel;
    _forwardCountLabel.textAlignment = NSTextAlignmentCenter;
    _forwardCountLabel.font = [UIFont systemFontOfSize:12];
    _forwardCountLabel.textColor = [UIColor newAssistTextColor];
    [self.contentView addSubview:_forwardCountLabel];
    
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
        _idendityLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame) + 5, CGRectGetMinY(_nameLabel.frame), 50, 16);
    }else{
        _idendityLabel.hidden = YES;
    }
    
    _descTextView.frame = _tweetItem.descTextFrame;
    
    _imageView.frame = _tweetItem.imageFrame;
    
    _imageTypeLogo.frame = (CGRect){{_imageView.bounds.size.width - 18 - 2,_imageView.bounds.size.height - 11 - 2 },{18,11}};
    
    _timeAndSourceLabel.frame = _tweetItem.timeLabelFrame;
    
    _commentCountLabel.frame = _tweetItem.commentLabelFrame;
    
    _commentCountButton.frame = _tweetItem.commentButtonFrame;
    
    _forwardCountLabel.frame = _tweetItem.forwardLabelFrame;
    
    _forwardCountButton.frame = _tweetItem.forwardButtonFrame;
    
    _likeCountLabel.frame = _tweetItem.likeLabelFrame;
    
    _likeCountButton.frame = _tweetItem.likeButtonFrame;
}

-(void)setTweetItem:(OSCTweetItem *)tweetItem{
    _tweetItem = tweetItem;

    [_userPortrait loadPortrait:[NSURL URLWithString:tweetItem.author.portrait] userName:tweetItem.author.name];
    
    _nameLabel.text = tweetItem.author.name;
    _descTextView.attributedText = [Utils contentStringFromRawString:tweetItem.content];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[[NSDate dateFromString:tweetItem.pubDate] timeAgoSince]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)tweetItem.appClient]];
    att.color = [UIColor newAssistTextColor];
    _timeAndSourceLabel.attributedText = att;
    
    OSCNetImage* imageData = [tweetItem.images lastObject];
    BOOL isGif = [imageData.thumb hasSuffix:@".gif"];
    if (isGif) {
        _imageTypeLogo.image = [self gifImage];
        _imageTypeLogo.hidden = NO;
    }
    
///< 只检索小图 然后再打开大图的回调里面把小图url换成大图url实现回调清晰
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageData.thumb] placeholderImage:[Utils createImageWithColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (isGif) {
            NSData *dataImage = UIImagePNGRepresentation(image);
            image = [UIImage sd_animatedGIFWithData:dataImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_imageView setImage:image];
            });
        }
    }];
        
    if (tweetItem.liked) {
        [_likeCountButton setImage:[self likeImage]];
    } else {
        [_likeCountButton setImage:[self unlikeImage]];
    }
    
    [self operationLabel:_likeCountLabel curCount:tweetItem.statistics.like describeText:@"赞"];
    [self operationLabel:_commentCountLabel curCount:tweetItem.statistics.comment describeText:@"评论"];
    [self operationLabel:_forwardCountLabel curCount:tweetItem.statistics.transmit describeText:@"转发"];
    
    _rowHeight = tweetItem.rowHeight;
    _imageSize = tweetItem.imageFrame.size;
    self.contentView.height = _rowHeight;
}

#pragma mark --- 触摸分发
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _trackingTouch_userPortrait = NO;
    _trackingTouch_likeBtn = NO;
    _trackingTouch_imageView = NO;
    _trackingTouch_forwardBtn = NO;
    UITouch *t = touches.anyObject;
    CGPoint p1 = [t locationInView:_userPortrait];
    CGPoint p2 = [t locationInView:_likeCountButton];
    CGPoint p2_1 = [t locationInView:_likeCountLabel];
    CGPoint p3 = [t locationInView:_forwardCountButton];
    CGPoint p3_1 = [t locationInView:_forwardCountLabel];
    CGPoint p4 = [t locationInView:_imageView];
    if (CGRectContainsPoint(_userPortrait.bounds, p1)) {
        _trackingTouch_userPortrait = YES;
    }else if(CGRectContainsPoint(_likeCountButton.bounds, p2) || CGRectContainsPoint(_likeCountLabel.bounds, p2_1)){
        _trackingTouch_likeBtn = YES;
    }else if (CGRectContainsPoint(_forwardCountButton.bounds, p3) || CGRectContainsPoint(_forwardCountLabel.bounds,p3_1)){
//        _trackingTouch_forwardBtn = YES;///< 开启列表转发面板的呼出
        _trackingTouch_forwardBtn = NO;///< 关闭列表转发面板的呼出
    }else if(CGRectContainsPoint(_imageView.bounds, p4)){
        _trackingTouch_imageView = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_trackingTouch_userPortrait) {
        if ([_delegate respondsToSelector:@selector(userPortraitDidClick:)]) {
            [_delegate userPortraitDidClick:self];
        }
    }else if(_trackingTouch_likeBtn){
        if ([_delegate respondsToSelector:@selector(changeTweetStausButtonDidClick:)]) {
            [_delegate changeTweetStausButtonDidClick:self];
        }
    }else if (_trackingTouch_forwardBtn){
        if ([_delegate respondsToSelector:@selector(forwardTweetButtonDidClick:)]) {
            [_delegate forwardTweetButtonDidClick:self];
        }
    }else if (_trackingTouch_imageView){
        UIImageView* fromView = _imageView;
        OSCNetImage* tweetItem = [self.tweetItem.images lastObject];
        
        OSCPhotoGroupItem* currentPhotoItem = [OSCPhotoGroupItem new];
        currentPhotoItem.largeImageURL = [NSURL URLWithString:tweetItem.href];
        currentPhotoItem.thumbView = fromView;
        currentPhotoItem.largeImageSize = (CGSize){tweetItem.w,tweetItem.h};
        
        OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:@[currentPhotoItem]];
        
        if ([_delegate respondsToSelector:@selector(loadLargeImageDidFinsh:photoGroupView:fromView:)]) {
            [_delegate loadLargeImageDidFinsh:self photoGroupView:photoGroup fromView:fromView];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_trackingTouch_userPortrait || !_trackingTouch_likeBtn || !_trackingTouch_imageView ||!_trackingTouch_forwardBtn) {
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


#pragma mark - prepare for reuse
- (void)prepareForReuse{
    [super prepareForReuse];
    _userPortrait.image = nil;
    _imageView.image = nil;
    _imageTypeLogo.image = nil;
    _imageTypeLogo.hidden = YES;
    _rowHeight = 0 ;
    _imageSize = CGSizeZero;
}
@end
