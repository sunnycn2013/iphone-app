//
//  OSCActivityCell.m
//  iosapp
//
//  Created by 王恒 on 17/4/11.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCActivityCell.h"

#import "UIColor+Util.h"

#define kPaddingLeft 16
#define kPaddingRight 16
#define kInfoLabelWidth 100
#define kLabelHeight 56
#define kRemarkLabelHeight 30
#define kScreenSize [UIScreen mainScreen].bounds.size
#define kInfoPaddingContent 8

@interface OSCActivityNormalCell ()

@property (nonatomic,strong) UILabel *infoLabel;
@property (nonatomic,strong) UILabel *contentLabel;

@end

@implementation OSCActivityNormalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubView];
    }
    return self;
}

- (void)addSubView{
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeft, 0, kInfoLabelWidth, kLabelHeight)];
    _infoLabel.font = [UIFont systemFontOfSize:15];
    _infoLabel.textColor = [UIColor colorWithHex:0x111111];
    _infoLabel.numberOfLines = 1;
    [self.contentView addSubview:_infoLabel];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_infoLabel.frame) + kInfoPaddingContent, 0, kScreenSize.width - CGRectGetMaxX(_infoLabel.frame) - kInfoPaddingContent - kPaddingRight, kLabelHeight)];
    _contentLabel.textAlignment = NSTextAlignmentRight;
    _contentLabel.font = [UIFont boldSystemFontOfSize:15];
    _contentLabel.textColor = [UIColor colorWithHex:0x111111];
    _contentLabel.numberOfLines = 1;
    _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_contentLabel];
}

- (void)setDetail:(NSString *)detail{
    _detail = detail;
    _contentLabel.text = detail;
}

- (void)setInfo:(NSString *)info{
    _info = info;
    _infoLabel.text = info;
}

- (void)setIsStauts:(BOOL)isStauts{
    if (isStauts) {
        _contentLabel.textColor = [UIColor navigationbarColor];
    }else{
        _contentLabel.textColor = [UIColor colorWithHex:0x111111];
    }
}

@end



@interface OSCActivityRemarkCell ()

@property (nonatomic,strong) UILabel *contentLabel;

@end

@implementation OSCActivityRemarkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubView];
    }
    return self;
}

- (void)addSubView{
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeft, 0, kInfoLabelWidth, kRemarkLabelHeight)];
    infoLabel.font = [UIFont systemFontOfSize:15];
    infoLabel.textColor = [UIColor colorWithHex:0x111111];
    infoLabel.numberOfLines = 1;
    infoLabel.text = @"备注：";
    [self.contentView addSubview:infoLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.textColor = [UIColor colorWithHex:0x111111];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:_contentLabel];
}

- (void)setDetail:(NSString *)detail{
    _detail = detail;
    _contentLabel.text = detail;
}

- (void)setTextHeight:(CGFloat)textHeight{
    _textHeight = textHeight;
    _contentLabel.frame = CGRectMake(kPaddingLeft, kRemarkLabelHeight, kScreenSize.width - 2*kPaddingLeft, textHeight);
}

@end
