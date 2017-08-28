//
//  TweetLikeUserCell.m
//  iosapp
//
//  Created by 李萍 on 15/4/3.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TweetLikeUserCell.h"
#import "Utils.h"
#import "UIImageView+Comment.h"

#import <Masonry.h>

@implementation TweetLikeUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        
        [self initSubviews];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
    }
    return self;
}

- (void)initSubviews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    _portrait.userInteractionEnabled = YES;
//    [_portrait setCornerRadius:5.0];
    _portrait.layer.cornerRadius = 5;
    [_portrait zy_cornerRadiusRoundingRect];
    [self.contentView addSubview:_portrait];
    
    _userNameLabel = [UILabel new];
    _userNameLabel.font = [UIFont boldSystemFontOfSize:14];
    _userNameLabel.userInteractionEnabled = YES;
    _userNameLabel.textColor = [UIColor nameColor];
    [self.contentView addSubview:_userNameLabel];
}

- (void)setLayout
{
    [_portrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.left.equalTo(self.contentView).offset(8);
        make.width.equalTo(@(36));
        make.height.equalTo(@(36));
    }];
    
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_portrait);
        make.left.equalTo(_portrait.mas_right).offset(8);
        make.height.equalTo(_portrait);
    }];
    
}

@end
