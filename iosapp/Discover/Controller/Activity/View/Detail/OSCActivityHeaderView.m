//
//  OSCActivityHeaderView.m
//  iosapp
//
//  Created by 王恒 on 16/12/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCActivityHeaderView.h"

#import "UIImageView+Comment.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <YYKit.h>

@interface OSCActivityHeaderView ()

@property (nonatomic,weak) UIImageView *headerImageView;
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UIImageView *userImageView;
@property (nonatomic,weak) UILabel *userNameLabel;
@property (nonatomic,weak) UILabel *peopleLabel;

//布局信息
@property (nonatomic,assign) float peopleLabelWidth;
@property (nonatomic,assign) float titleLabelHeight;
@property (nonatomic,assign) float viewHeight;

@end

@implementation OSCActivityHeaderView

- (instancetype)init{
    self = [super init];
    if(self){
        [self addContentView];
    }
    return self;
}

- (void)addContentView{
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.width / kHeaderImageW_H)];
    _headerImageView = headerImageView;
    [self addSubview:_headerImageView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.numberOfLines = 0;
    _titleLabel = titleLabel;
    [self addSubview:_titleLabel];
    
    UIImageView *userImageView = [[UIImageView alloc] init];
    [userImageView handleCornerRadiusWithRadius:kUserImage_W/2];
    _userImageView = userImageView;
    [self addSubview:_userImageView];
    
    UILabel *userNameLabel = [[UILabel alloc] init];
    userNameLabel.font = [UIFont systemFontOfSize:14.0];
    _userNameLabel = userNameLabel;
    [self addSubview:_userNameLabel];
    
    UILabel *peopleLabel = [[UILabel alloc] init];
    peopleLabel.font = [UIFont systemFontOfSize:14.0];
    peopleLabel.textAlignment = NSTextAlignmentRight;
    _peopleLabel = peopleLabel;
    [self addSubview:_peopleLabel];
}

- (void)layoutUI{
    _titleLabel.frame = CGRectMake( kPaddindLeft, CGRectGetMaxY(_headerImageView.frame) + kHeaderImage_space_titleLabel, kScreenSize.width - kPaddindLeft - kPaddingRight, _titleLabelHeight);
    
    _userImageView.frame = CGRectMake( kPaddindLeft, CGRectGetMaxY(_titleLabel.frame) + kTitleLabel_space_userImageView, kUserImage_W, kUserImage_W);
    
    _peopleLabel.frame = CGRectMake(kScreenSize.width - kPaddingRight - _peopleLabelWidth, CGRectGetMaxY(_titleLabel.frame) + kTitleLabel_space_userImageView, _peopleLabelWidth, kUserImage_W);
    
    _userNameLabel.frame = CGRectMake( CGRectGetMaxX(_userImageView.frame) + kUserImage_space_nameLabel, CGRectGetMaxY(_titleLabel.frame) + kTitleLabel_space_userImageView, kScreenSize.width - CGRectGetMaxX(_userImageView.frame) - kUserImage_space_nameLabel - _peopleLabelWidth - kPaddingRight - kUserImage_space_nameLabel, kUserImage_W);
    
    _viewHeight = CGRectGetMaxY(_userImageView.frame) + kPaddingBottom;
}

- (void)setModel:(OSCListItem *)model{
    _model = model;
    OSCNetImage *netImage = model.images[0];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:netImage.href]];
    
    _titleLabel.text = model.title;
    _titleLabelHeight = [[self class] getHeightOfString:model.title font:[UIFont systemFontOfSize:18.0]];
    
    [_userImageView loadPortrait:[NSURL URLWithString:model.author.portrait] userName:model.author.name];
    
    _userNameLabel.text = model.author.name;
    
    //NSString *applyers = [NSString stringWithFormat:@"已报名%ld人", model.extra.eventApplyCount];//500人/
    //_peopleLabel.text = applyers;//@"500人/已报名124人";
    //_peopleLabelWidth = [[self class] getWidthOfString:applyers font:[UIFont systemFontOfSize:14.0]];
    
    [self layoutUI];
}

- (float)getHeaderViewHeight{
    return _viewHeight;
}

+ (float)getWidthOfString:(NSString *)string font:(UIFont *)font{
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAX_CANON, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return size.width;
}

+ (float)getHeightOfString:(NSString *)string font:(UIFont *)font{
    CGSize size = [string boundingRectWithSize:CGSizeMake(kScreenSize.width - kPaddindLeft - kPaddingRight, MAX_CANON) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return size.height;
}

@end
