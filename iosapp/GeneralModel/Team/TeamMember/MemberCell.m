//
//  MemberCell.m
//  iosapp
//
//  Created by chenhaoxiang on 3/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "MemberCell.h"
#import "TeamMember.h"
#import "Utils.h"

#import <Masonry.h>

@implementation MemberCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setLayout];
    }
    
    return self;
}

- (void)setLayout
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:30];
    [self.contentView addSubview:_portrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont systemFontOfSize:14];
    _nameLabel.textColor = [UIColor contentTextColor];
    [self.contentView addSubview:_nameLabel];
    
    [_portrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.height.equalTo(@(60));
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(@(60));
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_portrait.mas_bottom).offset(8);
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];
}

- (void)setContentWithMember:(TeamMember *)member
{
    [_portrait loadPortrait:member.portraitURL userName:member.name];
    _nameLabel.text = member.name;
}

@end
