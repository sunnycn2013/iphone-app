//
//  OSCTweetDetailTableViewCell.m
//  iosapp
//
//  Created by 王恒 on 16/12/5.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetDetailTableViewCell.h"
#import "Utils.h"
#import "ThumbnailHadle.h"
#import "OSCNetImage.h"
#import "ImageDownloadHandle.h"
#import "OSCPhotoGroupView.h"
#import "GAMenuView.h"

#import "NSDate+Comment.h"
#import "UIImageView+Comment.h"

#import <SDWebImage/UIImage+GIF.h>
#import <Masonry.h>

@interface OSCTweetDetailTableViewCell ()<UITextViewDelegate>

//控件
@property (nonatomic,weak) UIImageView *userPortrait;
@property (nonatomic,weak) UILabel *nameLabel;
@property (nonatomic,weak) UITextView *descTextView;
@property (nonatomic,weak) UIImageView *tweetImageView;

@property (nonatomic,weak) UILabel *timeLabel;
@property (nonatomic,weak) UIImageView *likeButton;
@property (nonatomic,weak) UIImageView* forwardButton;
@property (nonatomic,weak) UIImageView *commentButton;

@property (nonatomic,weak) UIImageView *imageTypeLogo;

@property (nonatomic,weak) UILabel *idendityLabel;

@end

@implementation OSCTweetDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        [self addContentView];
        [self layoutUI];
    }
    return self;
}

#pragma mark --- UI
- (void)addContentView{
    UIImageView *userPortrait = [UIImageView new];
    userPortrait.contentMode = UIViewContentModeScaleAspectFit;
    userPortrait.userInteractionEnabled = YES;
    [userPortrait setCornerRadius:22];
    [userPortrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserPortrait:)]];
    [self.contentView addSubview:userPortrait];
    _userPortrait = userPortrait;
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.font = [UIFont boldSystemFontOfSize:15];
    nameLabel.numberOfLines = 1;
    nameLabel.textColor = [UIColor newTitleColor];
    [self.contentView addSubview:nameLabel];
    _nameLabel = nameLabel;
    
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
    
    UITextView *descTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    descTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    descTextView.backgroundColor = [UIColor clearColor];
    descTextView.font = [UIFont systemFontOfSize:14];
    descTextView.textColor = [UIColor newTitleColor];
    descTextView.editable = NO;
    descTextView.scrollEnabled = NO;
    [descTextView setTextContainerInset:UIEdgeInsetsZero];
    descTextView.textContainer.lineFragmentPadding = 0;
    descTextView.delegate = self;
    [self.contentView addSubview:descTextView];
    _descTextView = descTextView;
    
    UIImageView *tweetImageView = [UIImageView new];
    tweetImageView.contentMode = UIViewContentModeScaleAspectFill;
    tweetImageView.clipsToBounds = YES;
    tweetImageView.userInteractionEnabled = YES;
    tweetImageView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
    [tweetImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)]];
    [self.contentView addSubview:tweetImageView];
    _tweetImageView = tweetImageView;
    
    UILabel *timeLabel = [UILabel new];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor newAssistTextColor];
    [self.contentView addSubview:timeLabel];
    _timeLabel = timeLabel;
    
    UIImageView *likeButton = [UIImageView new];
    likeButton.userInteractionEnabled = YES;
    [likeButton setImage:[UIImage imageNamed:@"ic_thumbup_normal"]];
    likeButton.contentMode = UIViewContentModeRight;
    [likeButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLikeWithtapGestures:)]];
    [self.contentView addSubview:likeButton];
    _likeButton = likeButton;
    
    UIImageView *forwardButton = [UIImageView new];
    forwardButton.userInteractionEnabled = YES;
    forwardButton.image = [UIImage imageNamed:@"ic_Forward"];
    forwardButton.contentMode = UIViewContentModeRight;
    [forwardButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickForward)]];
    [self.contentView addSubview:forwardButton];
    _forwardButton = forwardButton;
    
    UIImageView *commentButton = [UIImageView new];
    commentButton.contentMode = UIViewContentModeRight;
    commentButton.image = [UIImage imageNamed:@"ic_comment_30"];
    commentButton.userInteractionEnabled = YES;
    [commentButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickComment)]];
    [self.contentView addSubview:commentButton];
    _commentButton = commentButton;
    
    //    imageTypeLogo
    UIImageView* imageTypeLogo = [[UIImageView alloc]init];
    imageTypeLogo.userInteractionEnabled = NO;
    imageTypeLogo.hidden = YES;
    [_tweetImageView addSubview:imageTypeLogo];
    _imageTypeLogo = imageTypeLogo;
}

- (void)layoutUI{
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
    
    [_tweetImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.top.equalTo(_descTextView.mas_bottom).with.offset(8);
    }];
    
    [_imageTypeLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.equalTo(_tweetImageView).with.offset(-2);
        make.width.equalTo(@18);
        make.height.equalTo(@11);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.top.equalTo(_tweetImageView.mas_bottom).with.offset(8);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_forwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@15);
        make.right.equalTo(self.contentView).with.offset(-16);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@15);
        make.bottom.equalTo(self.contentView).with.offset(-16);
        make.right.equalTo(_forwardButton.mas_left).with.offset(-24);
    }];
    
    [_likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@15);
        make.bottom.equalTo(self.contentView).with.offset(-16);
        make.right.equalTo(_commentButton.mas_left).with.offset(-1);
    }];
}

- (void)setItem:(OSCTweetItem *)item{
    _item = item;
    
    [_userPortrait loadPortrait:[NSURL URLWithString:item.author.portrait] userName:item.author.name];
    
    _nameLabel.text = item.author.name;
    
    if (item.author.identity.officialMember) {
        _idendityLabel.hidden = NO;
    }else{
        _idendityLabel.hidden = YES;
    }
    
    _descTextView.attributedText = [Utils contentStringFromRawString:item.content];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:item.pubDate] timeAgoSince]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)item.appClient]];
    _timeLabel.attributedText = att;
    
    OSCNetImage* onceImage = [_item.images lastObject];
    CGSize imageSize = [ThumbnailHadle thumbnailSizeWithOriginalW:onceImage.w originalH:onceImage.h];
    
    if (item.images.count == 1) {
        OSCNetImage* imageData = [item.images lastObject];
        
        BOOL isGif = NO;
        if ([imageData.thumb hasSuffix:@".gif"]) {
            _imageTypeLogo.image = [UIImage imageNamed:@"gif"];
            _imageTypeLogo.hidden = NO;
            isGif = YES;
        }
        
        UIImage* largerImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageData.href];
        
        if (!largerImage) {
            UIImage* image = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageData.thumb];
            if (!image) {
                [ImageDownloadHandle downloadImageWithUrlString:imageData.thumb SaveToDisk:NO completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _tweetImageView.userInteractionEnabled = YES;
                        if ([imageData.thumb hasSuffix:@".gif"]) {
                            UIImageView* imageTypeLogo = (UIImageView* )[[_tweetImageView subviews] lastObject];
                            imageTypeLogo.image = [UIImage imageNamed:@"gif"];
                            imageTypeLogo.hidden = NO;
                            NSData *dataImage = UIImagePNGRepresentation(image);
                            UIImage* gifImage = [UIImage sd_animatedGIFWithData:dataImage];
                            [_tweetImageView setImage:gifImage];
                        }else{
                            [_tweetImageView setImage:image];
                        }
                    });
                }];
            }else{
                _tweetImageView.userInteractionEnabled = YES;
                if ([imageData.thumb hasSuffix:@".gif"]) {
                    UIImageView* imageTypeLogo = (UIImageView* )[[_tweetImageView subviews] lastObject];
                    imageTypeLogo.image = [UIImage imageNamed:@"gif"];
                    imageTypeLogo.hidden = NO;
                    NSData *dataImage = UIImagePNGRepresentation(image);
                    image = [UIImage sd_animatedGIFWithData:dataImage];
                }
                [_tweetImageView setImage:image];
            }
        }else{
            _tweetImageView.userInteractionEnabled = YES;
            if ([imageData.thumb hasSuffix:@".gif"]) {
                UIImageView* imageTypeLogo = (UIImageView* )[[_tweetImageView subviews] lastObject];
                imageTypeLogo.image = [UIImage imageNamed:@"gif"];
                imageTypeLogo.hidden = NO;
                NSData *dataImage = UIImagePNGRepresentation(largerImage);
                largerImage = [UIImage sd_animatedGIFWithData:dataImage];
            }
            [_tweetImageView setImage:largerImage];
        }
        
        [_tweetImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_descTextView.mas_bottom).with.offset(8);
            make.width.equalTo(@(imageSize.width));
            make.height.equalTo(@(imageSize.height));
        }];
        
    } else {
        [_tweetImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_descTextView.mas_bottom).with.offset(0);
        }];
    }
    
    if (item.liked) {
        [_likeButton setImage:[UIImage imageNamed:@"ic_thumbup_actived"]];
    } else {
        [_likeButton setImage:[UIImage imageNamed:@"ic_thumbup_normal"]];
    }
}

#pragma mark --- Method
- (void)clickUserPortrait:(UITapGestureRecognizer* )tap{
    if ([self.delegate respondsToSelector:@selector(userPortraitDidClick:)]) {
        [self.delegate userPortraitDidClick:self];
    }
}

- (void)clickComment{
    if ([self.delegate respondsToSelector:@selector(commentButtonDidClick:)]) {
        [self.delegate commentButtonDidClick:self];
    }
}

- (void)clickLikeWithtapGestures:(UITapGestureRecognizer* )tap{
    if ([self.delegate respondsToSelector:@selector(likeButtonDidClick:tapGestures:)]) {
        [self.delegate likeButtonDidClick:self tapGestures:tap];
    }
}

- (void)clickForward{
    if ([self.delegate respondsToSelector:@selector(forwardButtonDidClick:)]) {
        [self.delegate forwardButtonDidClick:self];
    }
}

- (void)clickImageView:(UITapGestureRecognizer *)tapGR{
    UIImageView *fromView = (UIImageView *)tapGR.view;
    
    NSMutableArray* photoGroupItems = [NSMutableArray arrayWithCapacity:_item.images.count];
    for (int i = 0; i < _item.images.count; i++) {
        OSCPhotoGroupItem* photoItem = [OSCPhotoGroupItem new];
        photoItem.thumbView = _tweetImageView;
        OSCNetImage *item = [_item.images lastObject];
        photoItem.largeImageURL = [NSURL URLWithString:item.href];
        [photoGroupItems addObject:photoItem];
    }
    
    OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:photoGroupItems];
    
    if ([self.delegate respondsToSelector:@selector(loadLargeImageDidFinsh:photoGroupView:fromView:)]) {
        [self.delegate loadLargeImageDidFinsh:self photoGroupView:photoGroup fromView:fromView];
    }
}

#pragma mark --- UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([self.delegate respondsToSelector:@selector(shouldInteract:TextView:URL:inRange:)]) {
        [self.delegate shouldInteract:self TextView:textView URL:URL inRange:characterRange];
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
