//
//  PersonCell.m
//  iosapp
//
//  Created by ChanAetern on 1/7/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "PersonCell.h"
#import "Utils.h"

#import <Masonry.h>

@implementation PersonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        self.backgroundColor = [UIColor themeColor];
        
        [self initSubviews];
        [self setLayout];
//        
//        UIView *selectedBackground = [UIView new];
//        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
//        [self setSelectedBackgroundView:selectedBackground];
    }
    
    return self;
}

- (void)initSubviews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    _portrait.clipsToBounds = YES;
    _portrait.layer.cornerRadius = 18;
    [self.contentView addSubview:_portrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.numberOfLines = 1;
    _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _nameLabel.font = [UIFont systemFontOfSize:15];
    _nameLabel.textColor = [UIColor newTitleColor];
    [self.contentView addSubview:_nameLabel];
    
    _idendityLabel = [UILabel new];
    _idendityLabel.font = [UIFont systemFontOfSize:10.0];
    _idendityLabel.text = @"官方人员";
    _idendityLabel.textColor = [UIColor colorWithHex:0x24CF5F];
    _idendityLabel.textAlignment = NSTextAlignmentCenter;
    _idendityLabel.layer.masksToBounds = YES;
    _idendityLabel.layer.cornerRadius = 2;
    _idendityLabel.layer.borderColor = [UIColor colorWithHex:0x24CF5F].CGColor;
    _idendityLabel.layer.borderWidth = 1;
    [self.contentView addSubview:_idendityLabel];
    
    _infoLabel = [UILabel new];
    _infoLabel.numberOfLines = 1;
    _infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _infoLabel.font = [UIFont systemFontOfSize:12];
    _infoLabel.textColor = [UIColor newSecondTextColor];
    [self.contentView addSubview:_infoLabel];
}

- (void)setLayout
{
 
    [_portrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.top.equalTo(self.contentView).offset(16);
        make.width.equalTo(@(36));
        make.height.equalTo(@(36));
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_portrait.mas_right).offset(8);
        make.top.equalTo(self.contentView).offset(16);
        make.height.equalTo(@(16));
    }];
    
    [_idendityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel.mas_right).offset(5);
        make.top.equalTo(_nameLabel);
        make.width.equalTo(@(50));
        make.height.equalTo(@(16));
    }];
    
    [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel);
        make.top.equalTo(_nameLabel.mas_bottom).offset(6);
        make.bottom.equalTo(self.contentView).offset(-14);
        make.right.equalTo(self.contentView).offset(-16);
    }];
    
}


@end
