//
//  OSCGitDetailHeader.m
//  iosapp
//
//  Created by 王恒 on 17/3/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCGitDetailHeader.h"

#import "UIColor+Util.h"
#import "NSDate+Comment.h"
#import "UIImage+Comment.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry.h>

#define kPaddingLeft 16
#define kPaddingRight 16
#define kPortraitPaddingTop 8
#define kPaddingBottom 12
#define kTitlePaddingTop 13
#define kTitlePaddingLanguage 5
#define kLanguagePaddingTime 8
#define kCountPaddingPortrait 9
#define kCountHeight 42
#define kCountPaddingLine 5
#define kDescriptionPaddingLine 12
#define kDescriptionPaddingBtnGroup 12
#define kButtonGroupHeight 40
#define kScreenSize [UIScreen mainScreen].bounds.size

@interface OSCGitDetailHeader ()

{
    UIView *_backView;
    UILabel *_titleLabel;
    UILabel *_langueLabel;
    UILabel *_timeLabel;
    UILabel *_starLabel;
    UILabel *_watchLabel;
    UILabel *_forkLabel;
    UIView *_lineView;
    UILabel *_detailLabel;
    UIButton *_buttonGroupView;
    
    UIView *_bottomLine;
}

@property (nonatomic,strong) OSCGitDetailModel *model;

@end

@implementation OSCGitDetailHeader

- (instancetype)initWithModel:(OSCGitDetailModel *)model{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _model = model;
        [self addContentView];
    }
    return self;
}

- (void)addContentView{
    _backView = [UIView new];
    _backView.backgroundColor = [UIColor colorWithHex:0xF9F9F9];
    [self addSubview:_backView];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    _titleLabel.textColor = [UIColor colorWithHex:0x111111];
    _titleLabel.text = [NSString stringWithFormat:@"%@/%@",_model.owner.name,_model.name];
    _titleLabel.numberOfLines = 0;
    [_backView addSubview:_titleLabel];
    
    _langueLabel = [UILabel new];
    _langueLabel.font = [UIFont systemFontOfSize:10];
    _langueLabel.textColor = [UIColor colorWithHex:0x9D9D9D];
    _langueLabel.textAlignment = NSTextAlignmentCenter;
    _langueLabel.backgroundColor = [UIColor colorWithHex:0xECECEC];
    _langueLabel.layer.borderColor = [UIColor colorWithHex:0xD2D2D2].CGColor;
    _langueLabel.layer.borderWidth = 1;
    _langueLabel.text = _model.language;
    [_backView addSubview:_langueLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor colorWithHex:0x6A6A6A];
    _timeLabel.text = [NSString stringWithFormat:@"上次更新 %@",[[self getDateWithString:_model.last_push_at] timeAgoSince]];
    [_backView addSubview:_timeLabel];
    
    _starLabel = [UILabel new];
    _starLabel.numberOfLines = 2;
    _starLabel.textAlignment = NSTextAlignmentCenter;
    NSString *numberString = [self getNumberStringWithNumber:_model.stars_count];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nStars",numberString]];
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor colorWithHex:0x111111]} range:NSMakeRange(0, numberString.length)];
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithHex:0x6A6A6A]} range:NSMakeRange(numberString.length, attributeString.length - numberString.length)];
    _starLabel.attributedText = attributeString;
    [_backView addSubview:_starLabel];
    
    _watchLabel = [UILabel new];
    _watchLabel.numberOfLines = 2;
    _watchLabel.textAlignment = NSTextAlignmentCenter;
    numberString = [self getNumberStringWithNumber:_model.watches_count];
    attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nWatches",numberString]];
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor colorWithHex:0x111111]} range:NSMakeRange(0, numberString.length)];
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithHex:0x6A6A6A]} range:NSMakeRange(numberString.length, attributeString.length - numberString.length)];
    _watchLabel.attributedText = attributeString;
    [_backView addSubview:_watchLabel];
    
    _forkLabel = [UILabel new];
    _forkLabel.numberOfLines = 2;
    _forkLabel.textAlignment = NSTextAlignmentCenter;
    numberString = [self getNumberStringWithNumber:_model.forks_count];
    attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nForks",numberString]];
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor colorWithHex:0x111111]} range:NSMakeRange(0, numberString.length)];
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithHex:0x6A6A6A]} range:NSMakeRange(numberString.length, attributeString.length - numberString.length)];
    _forkLabel.attributedText = attributeString;
    [_backView addSubview:_forkLabel];
    
    _lineView = [UIView new];
    _lineView.backgroundColor = [UIColor separatorColor];
    [_backView addSubview:_lineView];
    
    _detailLabel = [UILabel new];
    _detailLabel.numberOfLines = 0;
    _detailLabel.font = [UIFont systemFontOfSize:16];
    _detailLabel.textColor = [UIColor colorWithHex:0x111111];
    _detailLabel.text = _model.git_description;
    [self addSubview:_detailLabel];
    
    [self addButtonGroup];
    
    _bottomLine = [UIView new];
    _bottomLine.backgroundColor = [UIColor separatorColor];
    [self addSubview:_bottomLine];
    
    [self layoutUI];
}

- (void)addButtonGroup{
    _buttonGroupView = [UIButton new];
    _buttonGroupView.layer.borderColor = [UIColor colorWithHex:0xB6B6B6].CGColor;
    _buttonGroupView.layer.borderWidth = 1;
    _buttonGroupView.layer.masksToBounds = YES;
    _buttonGroupView.layer.cornerRadius = 2;
    [_buttonGroupView setTitle:@"查看源代码" forState:UIControlStateNormal];
    [_buttonGroupView setTitleColor:[UIColor colorWithHex:0x111111] forState:UIControlStateNormal];
    _buttonGroupView.titleLabel.font = [UIFont systemFontOfSize:14];
    [_buttonGroupView addTarget:self action:@selector(codeClick) forControlEvents:UIControlEventTouchUpInside];
    [_buttonGroupView addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:_buttonGroupView];
}

- (void)codeClick{
    _buttonGroupView.backgroundColor = [UIColor whiteColor];
    if ([_delegate respondsToSelector:@selector(codeClickWithModel:)]) {
        [_delegate codeClickWithModel:_model];
    }
}

- (void)touchUpOutSide:(UIButton *)button{
    _buttonGroupView.backgroundColor = [UIColor themeColor];
}

- (void)layoutUI{
    
    CGSize titleSize = [self getSizeWithString:[NSString stringWithFormat:@"%@ / %@",_model.owner.name,_model.name] withFont:[UIFont boldSystemFontOfSize:15.0] withSize:CGSizeMake(kScreenSize.width - kPaddingRight - kPaddingLeft, MAX_CANON)];
    _titleLabel.frame = CGRectMake(kPaddingLeft, kTitlePaddingTop, kScreenSize.width - kPaddingRight - kPaddingLeft, titleSize.height);
    
    float timeLabelPaddingLeft;
    if (_model.language.length > 0) {
        CGSize languageSize = [self getSizeWithString:_model.language withFont:[UIFont systemFontOfSize:10] withSize:CGSizeMake(MAX_CANON, 17)];
        _langueLabel.frame = CGRectMake(kPaddingLeft, CGRectGetMaxY(_titleLabel.frame) + kTitlePaddingLanguage, languageSize.width + 8, 17);
        timeLabelPaddingLeft = CGRectGetWidth(_langueLabel.frame) + kLanguagePaddingTime;
    } 
    
    _timeLabel.frame = CGRectMake( kPaddingLeft + timeLabelPaddingLeft, CGRectGetMaxY(_titleLabel.frame) + kTitlePaddingLanguage, kScreenSize.width -(kPaddingLeft + timeLabelPaddingLeft), 17);
    
    _starLabel.frame = CGRectMake(0, CGRectGetMaxY(_timeLabel.frame) + kCountPaddingPortrait, kScreenSize.width / 3, kCountHeight);
    _watchLabel.frame = CGRectMake(CGRectGetMaxX(_starLabel.frame), CGRectGetMaxY(_timeLabel.frame) + kCountPaddingPortrait, kScreenSize.width / 3, kCountHeight);
    _forkLabel.frame = CGRectMake(CGRectGetMaxX(_watchLabel.frame), CGRectGetMaxY(_timeLabel.frame) + kCountPaddingPortrait, kScreenSize.width / 3, kCountHeight);
    
    _lineView.frame = CGRectMake(0, CGRectGetMaxY(_forkLabel.frame) + kCountPaddingLine, kScreenSize.width, 1);
    
    _backView.frame = CGRectMake(0, 0, kScreenSize.width, CGRectGetMaxY(_lineView.frame));
    
    CGSize detailSize = [self getSizeWithString:_model.git_description withFont:[UIFont systemFontOfSize:16] withSize:CGSizeMake(kScreenSize.width - kPaddingLeft - kPaddingRight, MAX_CANON)];
    _detailLabel.frame = CGRectMake(kPaddingLeft, CGRectGetHeight(_backView.frame) + kDescriptionPaddingLine, kScreenSize.width - kPaddingLeft - kPaddingRight, detailSize.height);
    
    _buttonGroupView.frame = CGRectMake(kPaddingLeft, CGRectGetMaxY(_detailLabel.frame) + kDescriptionPaddingBtnGroup, kScreenSize.width - kPaddingLeft - kPaddingRight, kButtonGroupHeight);
    
    _bottomLine.frame = CGRectMake(0, CGRectGetMaxY(_buttonGroupView.frame) + kPaddingBottom, kScreenSize.width, 1);
    
    self.frame = CGRectMake(0, 0, kScreenSize.width, CGRectGetMaxY(_bottomLine.frame));
}

- (NSString *)getNumberStringWithNumber:(NSInteger)number{
    if (number <= 999) {
        return [NSString stringWithFormat:@"%ld",(long)number];
    }else{
        float number_f = (float)number;
        return [NSString stringWithFormat:@"%0.1fk",number_f / 1000];
    }
}

- (CGSize)getSizeWithString:(__kindof NSString *)string
                   withFont:(UIFont *)font
                   withSize:(CGSize)size{
    CGRect stringRect = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return stringRect.size;
}

- (NSDate *)getDateWithString:(NSString *)string{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *timeString = [string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    timeString = [timeString substringWithRange:NSMakeRange( 0, timeString.length - 6)];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSTimeZone *zone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    formatter.timeZone = zone;
    return [formatter dateFromString:timeString];
}

@end
