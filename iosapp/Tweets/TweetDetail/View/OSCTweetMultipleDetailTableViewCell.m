//
//  NewMultipleDetailCell.m
//  iosapp
//
//  Created by Graphic-one on 16/7/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetMultipleDetailTableViewCell.h"
#import "OSCTweetItem.h"
#import "OSCNetImage.h"
#import "Utils.h"
#import "OSCPhotoGroupView.h"
#import "ImageDownloadHandle.h"
#import "GAMenuView.h"

#import "UIColor+Util.h"
#import "UIView+Util.h"
#import "NSDate+Comment.h"
#import "UIImageView+Comment.h"
#import "NSDate+Comment.h"

#import <SDWebImage/SDImageCache.h>
#import <SDWebImageDownloaderOperation.h>
#import <UIImage+GIF.h>
#import <Masonry.h>

@interface OSCTweetMultipleDetailTableViewCell ()<UITextViewDelegate>{
    NSMutableArray* _imageViewsArray;   //二维数组 _imageViewsArray[line][row]
    
    NSMutableArray<NSString* >* _largerImageUrls;   //本地维护的大图数组
    NSMutableArray<UIImageView* >* _visibleImageViews;   //可见的imageView数组
    
    OSCPhotoGroupView* _photoGroup;
    
    CGFloat _multiple_WH;
    CGFloat _imageItem_WH;
    CGFloat Multiple_Padding;
    CGFloat ImageItemPadding;
}

@end

@implementation OSCTweetMultipleDetailTableViewCell
{
    __weak UIImageView* _userPortrait;
    __weak UILabel* _nameLabel;
    __weak UITextView* _descTextView;
    
    __weak UIView* _imagesView; //container view
    
    __weak UILabel* _timeLabel;
    __weak UIImageView* _commentImage;
    __weak UIImageView* _forwardImage;
    __weak UIImageView* _likeImage;
    __weak UILabel *_idendityLabel;
}

#pragma mark -
#pragma mark --- init Method
+ (instancetype) multipleDetailCellWith:(OSCTweetItem *)item
                        reuseIdentifier:(NSString *)reuseIdentifier
{
    return [[self alloc] initWithTweetItem:item reuseIdentifier:reuseIdentifier];
}
- (instancetype) initWithTweetItem:(OSCTweetItem *)item
                   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _item = item;
    }
    return self;
}
- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _largerImageUrls = [NSMutableArray arrayWithCapacity:9];
        _visibleImageViews = [NSMutableArray arrayWithCapacity:9];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setSubViews];
        [self setLayout];
    }
    return self;
}

#pragma mark - 
#pragma mark --- setting SubViews && Layout
-(void)setSubViews{
    UIImageView* userPortrait = [[UIImageView alloc]init];
    userPortrait.userInteractionEnabled = YES;
    userPortrait.contentMode = UIViewContentModeScaleAspectFit;
    [userPortrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userPortraitDidClickMethod:)]];
    _userPortrait = userPortrait;
    [_userPortrait handleCornerRadiusWithRadius:22];
    [self.contentView addSubview:_userPortrait];
    
    UILabel* nameLabel = [[UILabel alloc]init];
    nameLabel.font = [UIFont boldSystemFontOfSize:15];
    nameLabel.numberOfLines = 1;
    nameLabel.textColor = [UIColor newTitleColor];
    _nameLabel = nameLabel;
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
    
    UIView* imagesView = [[UIView alloc]init];
    _imagesView = imagesView;
    [self.contentView addSubview:_imagesView];
    
    UILabel* timeLabel = [[UILabel alloc]init];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor newAssistTextColor];
    _timeLabel = timeLabel;
    [self.contentView addSubview:_timeLabel];
    
    UIImageView* likeImage = [[UIImageView alloc] init];
    likeImage.userInteractionEnabled = YES;
    likeImage.contentMode = UIViewContentModeRight;
    likeImage.image = [UIImage imageNamed:@"ic_thumbup_normal"];
    [likeImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeBtnDidClickMethod:)]];
    _likeImage = likeImage;
    [self.contentView addSubview:_likeImage];
    
    UIImageView* forwardImage = [[UIImageView alloc] init];
    forwardImage.userInteractionEnabled = YES;
    forwardImage.contentMode = UIViewContentModeRight;
    forwardImage.image = [UIImage imageNamed:@"ic_Forward"];
    [forwardImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forwardBtnDidClickMethod:)]];
    _forwardImage = forwardImage;
    [self.contentView addSubview:_forwardImage];
    
    UIImageView* commentImage = [[UIImageView alloc]init];
    commentImage.contentMode = UIViewContentModeRight;
    commentImage.userInteractionEnabled = YES;
    commentImage.image = [UIImage imageNamed:@"ic_comment_30"];
    [commentImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentBtnDidClickMethod:)]];
    _commentImage = commentImage;
    [self.contentView addSubview:_commentImage];
    
    /** 全局padding值*/
    Multiple_Padding = 16;
    ImageItemPadding = 8;
    
    /** 动态值维护*/
    CGFloat multiple_WH = ceil(([UIScreen mainScreen].bounds.size.width - (Multiple_Padding * 2)));
    _multiple_WH = multiple_WH;
    CGFloat imageItem_WH = ceil(((multiple_WH - (2 * ImageItemPadding)) / 3 ));
    _imageItem_WH = imageItem_WH;
    
    [self addMultiples];
}
-(void)setLayout{
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
    
    [_imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(Multiple_Padding);
        make.top.equalTo(_descTextView.mas_bottom).with.offset(8);
        make.width.equalTo(@(_multiple_WH));
        make.height.equalTo(@(_multiple_WH));
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.top.equalTo(_imagesView.mas_bottom).with.offset(8);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_forwardImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@15);
        make.right.equalTo(self.contentView).with.offset(-16);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_commentImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@15);
        make.bottom.equalTo(self.contentView).with.offset(-16);
        make.right.equalTo(_forwardImage.mas_left).with.offset(-24);
    }];
    
    [_likeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@15);
        make.bottom.equalTo(self.contentView).with.offset(-16);
        make.right.equalTo(_commentImage.mas_left).with.offset(0);
    }];
}

#pragma mark -
#pragma mark --- setting Model
-(void)setItem:(OSCTweetItem *)item{
    _item = item;
    
    [_largerImageUrls removeAllObjects];
    for (OSCNetImage* imageDataSource in item.images) {
        [_largerImageUrls addObject:imageDataSource.href];
    }
    
    [self settingContentForSubViews:item];
}
#pragma mrak --- 设置内容给子视图
-(void)settingContentForSubViews:(OSCTweetItem* )model{
    [_userPortrait loadPortrait:[NSURL URLWithString:model.author.portrait] userName:model.author.name];
    
    _nameLabel.text = model.author.name;
    
    if (model.author.identity.officialMember) {
        _idendityLabel.hidden = NO;
    }else{
        _idendityLabel.hidden = YES;
    }

    _descTextView.attributedText = [Utils contentStringFromRawString:model.content];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:model.pubDate] timeAgoSince]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)model.appClient]];
    _timeLabel.attributedText = att;
    
    if (model.liked) {
        [_likeImage setImage:[UIImage imageNamed:@"ic_thumbup_actived"]];
    } else {
        [_likeImage setImage:[UIImage imageNamed:@"ic_thumbup_normal"]];
    }
    
    //    Assignment and update the layout
    [self assemblyContentToImageViewsWithImagesCount:model.images.count];
}


#pragma mark -
#pragma mark --- Using a for loop
-(void)addMultiples{
    _imageViewsArray = [NSMutableArray arrayWithCapacity:3];
    
    CGFloat originX = 0;
    CGFloat originY = 0;
    for (int i = 0 ; i < 3; i++) {//line
        originY = i * (_imageItem_WH + ImageItemPadding);
        NSMutableArray* lineNodes = [NSMutableArray arrayWithCapacity:3];
        for (int j = 0; j < 3; j++) {//row
            originX = j * (_imageItem_WH + ImageItemPadding);
            UIImageView* imageView = [[UIImageView alloc]init];
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadLargeImageWithTapGes:)]];
            imageView.backgroundColor = [UIColor newCellColor];
            imageView.hidden = YES;
            imageView.userInteractionEnabled = NO;
            imageView.frame = (CGRect){{originX,originY},{_imageItem_WH,_imageItem_WH}};
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [_imagesView addSubview:imageView];
//            imageTypeLogo
#pragma TODO
            UIImageView* imageTypeLogo = [UIImageView new];
            imageTypeLogo.frame = (CGRect){{imageView.bounds.size.width - 18 - 2,imageView.bounds.size.height - 11 - 2 },{18,11}};
            imageTypeLogo.userInteractionEnabled = NO;
            imageTypeLogo.hidden = YES;
            [imageView addSubview:imageTypeLogo];
            
            [lineNodes addObject:imageView];
        }
        [_imageViewsArray addObject:lineNodes];
    }
}
//assembly NewMultipleTweetCell
-(void)assemblyContentToImageViewsWithImagesCount:(NSInteger)count{
    if (count <= 3) {   //Single line layout
        [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(_imageItem_WH));
        }];
        [self loopAssemblyContentWithLine:1 row:(int)count count:(int)count];
    }else if (count <= 6){  //Double row layout
        [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@((_imageItem_WH * 2) + ImageItemPadding));
        }];
        if (count == 4) {
            [self loopAssemblyContentWithLine:2 row:2 count:(int)count];
        }else{
            [self loopAssemblyContentWithLine:2 row:3 count:(int)count];
        }
    }else{  //Three lines layout
        [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(_multiple_WH));
        }];
        [self loopAssemblyContentWithLine:3 row:3 count:(int)count];
    }
}
-(void)loopAssemblyContentWithLine:(int)line row:(int)row count:(int)count{
    int dataIndex = 0;
    for (int i = 0; i < line; i++) {
        for (int j = 0; j < row; j++) {
            if (dataIndex == count) return;
            OSCNetImage* imageData = _item.images[dataIndex];
            UIImageView* imageView = (UIImageView* )_imageViewsArray[i][j];
            imageView.tag = dataIndex;
            imageView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.6];
            imageView.hidden = NO;
            [_visibleImageViews addObject:imageView];
            
            UIImage* largerImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageData.href];
            
            if (!largerImage) {
                UIImage* image = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageData.thumb];
                if (!image) {
                    [ImageDownloadHandle downloadImageWithUrlString:imageData.thumb SaveToDisk:NO completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imageView.userInteractionEnabled = YES;
                            if ([imageData.thumb hasSuffix:@".gif"]) {
                                UIImageView* imageTypeLogo = (UIImageView* )[[imageView subviews] lastObject];
                                imageTypeLogo.image = [UIImage imageNamed:@"gif"];
                                imageTypeLogo.hidden = NO;
                                NSData *dataImage = UIImagePNGRepresentation(image);
                                UIImage* gifImage = [UIImage sd_animatedGIFWithData:dataImage];
                                [imageView setImage:gifImage];
                            }else{
                                [imageView setImage:image];
                            }
                        });
                    }];
                }else{
                    imageView.userInteractionEnabled = YES;
                    if ([imageData.thumb hasSuffix:@".gif"]) {
                        UIImageView* imageTypeLogo = (UIImageView* )[[imageView subviews] lastObject];
                        imageTypeLogo.image = [UIImage imageNamed:@"gif"];
                        imageTypeLogo.hidden = NO;
                        NSData *dataImage = UIImagePNGRepresentation(image);
                        image = [UIImage sd_animatedGIFWithData:dataImage];
                    }
                    [imageView setImage:image];
                }
            }else{
                imageView.userInteractionEnabled = YES;
                if ([imageData.thumb hasSuffix:@".gif"]) {
                    UIImageView* imageTypeLogo = (UIImageView* )[[imageView subviews] lastObject];
                    imageTypeLogo.image = [UIImage imageNamed:@"gif"];
                    imageTypeLogo.hidden = NO;
                    NSData *dataImage = UIImagePNGRepresentation(largerImage);
                    largerImage = [UIImage sd_animatedGIFWithData:dataImage];
                }
                [imageView setImage:largerImage];
            }
            
            dataIndex++;
            
        }
    }
}

#pragma mark --- click Method
-(void)userPortraitDidClickMethod:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(userPortraitDidClick:)]) {
        [_delegate userPortraitDidClick:self];
    }
}
-(void)commentBtnDidClickMethod:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(commentButtonDidClick:)]) {
        [_delegate commentButtonDidClick:self];
    }
}
-(void)likeBtnDidClickMethod:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(likeButtonDidClick:tapGestures:)]) {
        [_delegate likeButtonDidClick:self tapGestures:tap];
    }
}
- (void)forwardBtnDidClickMethod:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(forwardButtonDidClick:)]) {
        [_delegate forwardButtonDidClick:self];
    }
}

#pragma mark --- 加载大图
-(void)loadLargeImageWithTapGes:(UITapGestureRecognizer* )tap{
    UIImageView* fromView = (UIImageView* )tap.view;
    int index = (int)fromView.tag;
//        current touch object
    OSCPhotoGroupItem* currentPhotoItem = [OSCPhotoGroupItem new];
    currentPhotoItem.thumbView = fromView;
    currentPhotoItem.largeImageURL = [NSURL URLWithString:_largerImageUrls[index]];
    
//        all imageItem objects
    NSMutableArray* photoGroupItems = [NSMutableArray arrayWithCapacity:_largerImageUrls.count];
    
    for (int i = 0; i < _largerImageUrls.count; i++) {
        OSCPhotoGroupItem* photoItem = [OSCPhotoGroupItem new];
        photoItem.thumbView = _visibleImageViews[i];
        photoItem.largeImageURL = [NSURL URLWithString:_largerImageUrls[i]];
        [photoGroupItems addObject:photoItem];
    }
    
    OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:photoGroupItems];

    if ([_delegate respondsToSelector:@selector(loadLargeImageDidFinsh:photoGroupView:fromView:)]) {
        [_delegate loadLargeImageDidFinsh:self photoGroupView:photoGroup fromView:fromView];
    }
}
#pragma mark --- UITextView delegate 
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([_delegate respondsToSelector:@selector(shouldInteract:TextView:URL:inRange:)]) {
        [_delegate shouldInteract:self TextView:textView URL:URL inRange:characterRange];
    }
    return NO;
}

#pragma mark - copy handle

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
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
}

@end
