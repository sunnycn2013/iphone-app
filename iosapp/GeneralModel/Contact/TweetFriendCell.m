//
//  TweetFriendCell.m
//  iosapp
//
//  Created by 王晨 on 15/8/25.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "TweetFriendCell.h"
#import "UIColor+Util.h"
#import "UIView+Util.h"
#import "Utils.h"

#import <objc/runtime.h>
#import <Masonry.h>

@interface TweetFriendCell ()

@property (nonatomic, strong) OSCAuthor *User;

@end

@implementation TweetFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.tintColor = [UIColor colorWithHex:0x15A230];
        [self initSubviews];
        [self setLayout];
    }
    return self;
}

- (void)initSubviews
{
    _selectedButton = [UIButton new];
    [_selectedButton setImage:[UIImage imageNamed:@"radiobox_off"] forState:UIControlStateNormal];
    [self.contentView addSubview:_selectedButton];
    
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:18.0];
    [self.contentView addSubview:_portrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.numberOfLines = 0;
    _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _nameLabel.font = [UIFont systemFontOfSize:16];
    _nameLabel.textColor = [UIColor contentTextColor];
    [self.contentView addSubview:_nameLabel];
}

- (void)setLayout
{
    
    [_selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(32));
        make.left.equalTo(self.contentView).offset(16);
        make.top.equalTo(self.contentView).offset(10);
        make.height.equalTo(@(32));
        make.right.equalTo(_portrait.mas_left).offset(-8);
    }];
    
    [_portrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(36));
        make.height.equalTo(@(36));
        make.top.equalTo(self.contentView).offset(8);
        make.right.equalTo(_nameLabel.mas_left).offset(-8);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(36));
        make.top.equalTo(self.contentView).offset(8);
        make.right.equalTo(self.contentView).offset(-8);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setAuthor:(OSCAuthor *)author
{
    self.User = author;
    
    [self.portrait loadPortrait:[NSURL URLWithString:author.portrait] userName:author.name];
    self.nameLabel.text = author.name;
    
    NSString *seleName = author.selected ? @"form_checkbox_checked" : @"form_checkbox_normal";
    [self.selectedButton setImage:[UIImage imageNamed:seleName] forState:UIControlStateNormal];
}

#pragma mark - button action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.contentView.backgroundColor = [self.contentView.backgroundColor colorWithAlphaComponent:1.3];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.contentView.backgroundColor = [self.contentView.backgroundColor colorWithAlphaComponent:1.0];
    if ([_delegate respondsToSelector:@selector(clickedToSelectedAuthor:authorInfo:)]) {
        [_delegate clickedToSelectedAuthor:self authorInfo:self.User];
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.contentView.backgroundColor = [self.contentView.backgroundColor colorWithAlphaComponent:1.0];
}


@end





@implementation OSCAuthor (isSelected)

- (void)setSelected:(BOOL)selected{
    objc_setAssociatedObject(self, _cmd, @(selected), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSelected{
    return [objc_getAssociatedObject(self, @selector(setSelected:)) boolValue];
}

- (BOOL)isEqual:(OSCAuthor* )author{
    if (self.id == author.id) {
        return YES;
    }else{
        return NO;
    }
}

@end








