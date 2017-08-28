//
//  OSCMultipleTweetCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCMultipleTweetCell.h"
#import "OSCTweetItem.h"
#import "OSCStatistics.h"
#import "OSCNetImage.h"
#import "OSCAbout.h"
#import "OSCPhotoGroupView.h"
#import "Utils.h"

#import "UIImageView+Comment.h"
#import "NSDate+Comment.h"
#import "ImageDownloadHandle.h"

#import <UIImage+GIF.h>
#import <UIImageView+WebCache.h>
#import <YYKit.h>

@interface OSCMultipleTweetCell ()<UITextViewDelegate>{
    __weak UIImageView* _userPortrait;
    __weak YYLabel* _nameLabel;
    __weak UITextView* _descTextView;
    
    __weak UIView* _imagesView;
    
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

@implementation OSCMultipleTweetCell{
    NSMutableArray* _imageViewsArray;   //二维数组 _imageViewsArray[line][row]
    NSMutableArray<OSCNetImage* >* _largerImageUrls;   //本地维护的大图数组
    NSMutableArray<UIImageView* >* _visibleImageViews;   //可见的imageView数组
    
    /** 以下是根据屏幕大小进行适配的宽高值 (在 setSubViews 底部进行维护)*/
    /**
     _multiple_WH  为多图容器的宽高
     _imageItem_WH 为每张图片的宽高
     Multiple_Padding 是容器距离屏幕边缘的padding值
     ImageItemPadding 是多图图片之间的padding值
     */
    CGFloat _multiple_WH;
    CGFloat _imageItem_WH;
    CGFloat Multiple_Padding;
    CGFloat ImageItemPadding;
    
    CGFloat _rowHeight;
    CGSize _descTextViewSize;
    CGSize _imagesContainerViewSize;
    
    BOOL _trackingTouch_userPortrait;
    BOOL _trackingTouch_forwardBtn;
    BOOL _trackingTouch_likeBtn;
}
+ (instancetype)returnReuseMultipleTweetCellWithTableView:(UITableView *)tableView
                                              identifier:(NSString *)reuseIdentifier
{
    OSCMultipleTweetCell* multipleTweetCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!multipleTweetCell) {
        multipleTweetCell = [[OSCMultipleTweetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        [multipleTweetCell addSubViews];
    }
    return multipleTweetCell;
}

- (void)addSubViews{
    _largerImageUrls = [NSMutableArray arrayWithCapacity:9];
    _visibleImageViews = [NSMutableArray arrayWithCapacity:9];
    
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
    
    UIView* imagesView = [[UIView alloc]init];
    _imagesView = imagesView;
    [self.contentView addSubview:_imagesView];
    
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
    
#pragma TODO:: 使用宏代替 multiple_WH & imageItem_WH
    /** 全局padding值*/
    Multiple_Padding = 69;
    ImageItemPadding = 8;
    
    /** 动态值维护*/
    CGFloat multiple_WH = ceil(([UIScreen mainScreen].bounds.size.width - (Multiple_Padding * 2)));
    _multiple_WH = multiple_WH;
    CGFloat imageItem_WH = ceil(((multiple_WH - (2 * ImageItemPadding)) / 3 ));
    _imageItem_WH = imageItem_WH;
    
    [self addMultiples];
}

- (void)addMultiples{
    _imageViewsArray = [NSMutableArray arrayWithCapacity:3];
    
    CGFloat originX = 0;
    CGFloat originY = 0;
    for (int i = 0 ; i < 3; i++) {//line
        originY = i * (_imageItem_WH + ImageItemPadding);
        NSMutableArray* lineNodes = [NSMutableArray arrayWithCapacity:3];
        for (int j = 0; j < 3; j++) {//row
            originX = j * (_imageItem_WH + ImageItemPadding);
            UIImageView* imageView = [[UIImageView alloc]init];
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadLargeImageWithTap:)]];
            imageView.backgroundColor = [UIColor newCellColor];
            imageView.hidden = YES;
            imageView.userInteractionEnabled = NO;
            imageView.frame = (CGRect){{originX,originY},{_imageItem_WH,_imageItem_WH}};
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [_imagesView addSubview:imageView];
//            imageTypeLogo
            UIImageView* imageTypeLogo = [UIImageView new];
            imageTypeLogo.userInteractionEnabled = NO;
            imageTypeLogo.hidden = YES;
            [imageView addSubview:imageTypeLogo];
            
            [lineNodes addObject:imageView];
        }
        [_imageViewsArray addObject:lineNodes];
    }
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
    
    _imagesView.left = _descTextView.left;
    _imagesView.top = _descTextView.bottom + descTextView_space_imageView;
    _imagesView.size = _imagesContainerViewSize;
    
    _timeAndSourceLabel.frame = _tweetItem.timeLabelFrame;
    
    _commentCountLabel.frame = _tweetItem.commentLabelFrame;
    
    _commentCountButton.frame = _tweetItem.commentButtonFrame;
    
    _forwardCountLabel.frame = _tweetItem.forwardLabelFrame;
    
    _forwardCountButton.frame = _tweetItem.forwardButtonFrame;
    
    _likeCountLabel.frame = _tweetItem.likeLabelFrame;
    
    _likeCountButton.frame = _tweetItem.likeButtonFrame;
}

#pragma mark --- setting ViewModel 

-(void)setTweetItem:(OSCTweetItem *)tweetItem{
    _tweetItem = tweetItem;
    
    for (OSCNetImage* imageDataSource in tweetItem.images) {
        [_largerImageUrls addObject:imageDataSource];
    }

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
    
    [self operationLabel:_likeCountLabel    curCount:tweetItem.statistics.like describeText:@"赞"];
    [self operationLabel:_commentCountLabel curCount:tweetItem.statistics.comment describeText:@"评论"];
    [self operationLabel:_forwardCountLabel curCount:tweetItem.statistics.transmit describeText:@"转发"];
 
    _rowHeight = tweetItem.rowHeight;
    _descTextViewSize = tweetItem.descTextFrame.size;
    _imagesContainerViewSize = tweetItem.multipleFrame.frame.size;
    self.contentView.height = _rowHeight;
    
    [self loopAssemblyContentWithLine:tweetItem.multipleFrame.line
                                  row:tweetItem.multipleFrame.row
                                count:(int)tweetItem.images.count];
}

#pragma mark --- 为多图容器赋值
- (void)loopAssemblyContentWithLine:(int)line row:(int)row count:(int)count{
    int dataIndex = 0;
    for (int i = 0; i < line; i++) {
        for (int j = 0; j < row; j++) {
            if (dataIndex == count) return;
            OSCNetImage* imageData = _tweetItem.images[dataIndex];
            UIImageView* imageView = (UIImageView* )_imageViewsArray[i][j];
            imageView.tag = dataIndex;
            imageView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.6];
            imageView.hidden = NO;
            [_visibleImageViews addObject:imageView];
            
            BOOL isGif = [imageData.thumb hasSuffix:@".gif"];
            if (isGif){
                UIImageView* imageTypeLogo = (UIImageView* )[[imageView subviews] lastObject];
                imageTypeLogo.frame = (CGRect){{imageView.bounds.size.width - 18 - 2,imageView.bounds.size.height - 11 - 2 },{18,11}};
                imageTypeLogo.image = [self gifImage];
                imageTypeLogo.hidden = NO;
            }

///< 只检索小图 然后再打开大图的回调里面把小图url换成大图url实现回调清晰
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageData.thumb] placeholderImage:[Utils createImageWithColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (isGif) {
                    NSData *dataImage = UIImagePNGRepresentation(image);
                    image = [UIImage sd_animatedGIFWithData:dataImage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [imageView setImage:image];
                    });
                }
                imageView.userInteractionEnabled = YES;
            }];

            dataIndex++;
        }
    }
}

#pragma mark --- 加载大图
- (void)loadLargeImageWithTap:(UITapGestureRecognizer* )tap{
    UIImageView* fromView = (UIImageView* )tap.view;
    int index = (int)fromView.tag;
    //    current touch object
    OSCNetImage* image =  _largerImageUrls[index];
    
    //    all imageItem objects
    NSMutableArray* photoGroupItems = [NSMutableArray arrayWithCapacity:_largerImageUrls.count];
    
    for (int i = 0; i < _largerImageUrls.count; i++) {
        OSCNetImage* iamges =  _largerImageUrls[i];
        OSCPhotoGroupItem* photoItem = [OSCPhotoGroupItem new];
        photoItem.thumbView = _visibleImageViews[i];
        photoItem.largeImageURL = [NSURL URLWithString:iamges.href];
        photoItem.largeImageSize = (CGSize){image.w,image.h};
        [photoGroupItems addObject:photoItem];
    }
    
    OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:photoGroupItems];
    
    if ([_delegate respondsToSelector:@selector(loadLargeImageDidFinsh:photoGroupView:fromView:)]) {
        [_delegate loadLargeImageDidFinsh:self photoGroupView:photoGroup fromView:fromView];
    }
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
    }else if (CGRectContainsPoint(_forwardCountButton.bounds, p3) || CGRectContainsPoint(_forwardCountLabel.bounds, p3_1)){
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

#pragma mark - prepare for reuse
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _userPortrait.image = nil;
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            UIImageView* imageView = (UIImageView* )_imageViewsArray[i][j];
            imageView.backgroundColor = [UIColor newCellColor];
            imageView.userInteractionEnabled = NO;
            imageView.tag = 0;
            imageView.hidden = YES;
            imageView.image = nil;
            [_largerImageUrls removeAllObjects];
            [_visibleImageViews removeAllObjects];
            UIImageView* imageTypeLogo = (UIImageView* )[[imageView subviews] lastObject];
            imageTypeLogo.image = nil;
            imageTypeLogo.hidden = YES;
        }
    }
}

@end
