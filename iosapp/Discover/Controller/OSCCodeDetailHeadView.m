//
//  OSCCodeDetailHeadView.m
//  iosapp
//
//  Created by wupei on 2017/5/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCCodeDetailHeadView.h"
#import <Masonry.h>
#import "UIColor+Util.h"
#import <YYKit.h>
#import "NSDate+Comment.h"

#define kPaddingLeft 16
#define kPaddingRight 16
#define kPortraitPaddingTop 8
#define kPaddingBottom 12
#define kTitlePaddingTop 12
#define kTitlePaddingLanguage 5
#define kCountPaddingPortrait 9
#define kCountHeight 42
#define kCountPaddingLine 5
#define kDescriptionPaddingLine 2
#define kDescriptionPaddingBtnGroup 12
#define kButtonGroupHeight 40
#define kInfoHeight 14


#define kMarginLeft 16


@interface OSCCodeDetailHeadView ()

@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *descriptionLabel;
@property (nonatomic,weak) UILabel *langueLabel;

@property (nonatomic,weak) UILabel *infoLabel;//

@property (nonatomic,weak) UILabel *timeL;//时间

@property (nonatomic,weak) UIView  *lineView;//下划线

@property (nonatomic,strong) NSMutableAttributedString *infoAttribute;
@property (nonatomic,strong) NSMutableAttributedString *titleAttribute;


@end

@implementation OSCCodeDetailHeadView

- (instancetype)initWithModel:(OSCCodeSnippetListModel *)model{
    self = [super init];
    if (self) {
//        self.backgroundColor = [UIColor redColor];
        _model = model;
        [self addContentView];
    }
    return self;
}

- (void)addContentView {
    
    UILabel *titleLabel = [UILabel new];
    _titleLabel = titleLabel;
    _titleLabel.numberOfLines = 0;//多行
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = [UIFont systemFontOfSize:15.0];
    _titleLabel.text = [NSString stringWithFormat:@"%@/%@",_model.owner.name,_model.name];

    [self addSubview:_titleLabel];
    
    UILabel *descriptionLabel = [UILabel new];
    descriptionLabel.font = [UIFont systemFontOfSize:14.0];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.textColor = [UIColor colorWithHex:0x6A6A6A];
    descriptionLabel.font = [UIFont systemFontOfSize:14.0];

    
    descriptionLabel.text = [NSString stringWithFormat:@"%@",_model.code_description];
    
    
    
    _descriptionLabel = descriptionLabel;
    [self addSubview:_descriptionLabel];
    
    UILabel *langueLabel = [UILabel new];
    langueLabel.backgroundColor = [UIColor colorWithHex:0xECECEC];
    langueLabel.layer.borderWidth = 1;
    langueLabel.font = [UIFont systemFontOfSize:10.0];
    langueLabel.textColor = [UIColor colorWithHex:0x9D9D9D];
    langueLabel.textAlignment = NSTextAlignmentCenter;
    langueLabel.layer.borderColor = [UIColor colorWithHex:0xD2D2D2].CGColor;
    langueLabel.layer.borderWidth = 1;
    langueLabel.text = _model.language;

    _langueLabel = langueLabel;
    [self addSubview:_langueLabel];
    
    
    UILabel *infoLabel = [UILabel new];
    _infoLabel = infoLabel;
    [self addSubview:_infoLabel];
    
    UILabel *timeL = [UILabel new];
    _timeL = timeL;
    timeL.font = [UIFont systemFontOfSize:12.0];
    timeL.textColor = [UIColor colorWithHex:0x9D9D9D];
    timeL.textAlignment = NSTextAlignmentRight;
    _timeL.text = [NSString stringWithFormat:@"最后更新于%@",[[self getDateWithString:_model.updated_at] timeAgoSince]];

    [self addSubview:timeL];
    
    UIView *view = [[UIView alloc] init];
    _lineView = view;
    _lineView.backgroundColor = [UIColor separatorColor];
    [self addSubview:_lineView];
    
    [self parmerInfoAttribute];

    [_langueLabel setSize:_model.langueFrame.size];
    
    [self layoutUI];
    
}

- (void)layoutUI {
    CGSize titleSize = [self getSizeWithString:[NSString stringWithFormat:@"%@ / %@",_model.owner.name,_model.name] withFont:[UIFont boldSystemFontOfSize:15.0] withSize:CGSizeMake(kScreenSize.width*2/3, MAX_CANON)];
    
    _titleLabel.frame = CGRectMake(kPaddingLeft, kTitlePaddingTop, titleSize.width, titleSize.height);
    
    
    CGSize infoLayoutSize = CGSizeMake(MAX_CANON, kInfoHeight);
    float infoWidth = [self getSizeWithAttribute:_infoLabel.attributedText withSize:infoLayoutSize].width;

    _infoLabel.frame = CGRectMake(kScreenSize.width - kPaddingRight - infoWidth, kTitlePaddingTop, infoWidth, kInfoHeight);
    
    if (_model.code_description.length > 0) {
        CGSize detailSize = [self getSizeWithString:_model.code_description withFont:[UIFont systemFontOfSize:14.0] withSize:CGSizeMake(kScreenSize.width - kPaddingLeft - kPaddingRight, MAX_CANON)];
        
        _descriptionLabel.frame = CGRectMake(kPaddingLeft, CGRectGetMaxY(_titleLabel.frame) + kTitlePaddingLanguage, kScreenSize.width - kPaddingLeft - kPaddingRight, detailSize.height);
        
    }else {
        _descriptionLabel.hidden = YES;//没有隐藏
    }
    

    _timeL.text = [NSString stringWithFormat:@"最后更新于%@",[[self getDateWithString:_model.updated_at] timeAgoSince]];

    
    //时间
    
    NSString *timeStr = [NSString stringWithFormat:@"最后更新于%@",[[self getDateWithString:_model.updated_at] timeAgoSince]];
    CGSize timeSize = [timeStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];


    _timeL.frame = CGRectMake( kScreenSize.width - timeSize.width - kPaddingRight, CGRectGetMaxY(_titleLabel.frame) + kTitlePaddingLanguage * 2 + _descriptionLabel.height, timeSize.width, timeSize.height);

    
    if (_model.language.length > 0) {
        CGSize languageSize = [self getSizeWithString:_model.language withFont:[UIFont systemFontOfSize:10] withSize:CGSizeMake(MAX_CANON, 17)];
        _langueLabel.frame = CGRectMake(kPaddingLeft, CGRectGetMaxY(_titleLabel.frame) + kTitlePaddingLanguage * 2 + _descriptionLabel.height , languageSize.width + 8, 17);
    }

    _lineView.frame = CGRectMake(0, CGRectGetMaxY(_timeL.frame) + kTitlePaddingLanguage - 1 , kScreenSize.width, 1);

    
    
    self.frame = CGRectMake(0, 64, kScreenSize.width, CGRectGetMaxY(_timeL.frame) + kTitlePaddingLanguage);
}


//拼接title
- (void)parmerTitleAttribute{
    _titleAttribute = [[NSMutableAttributedString alloc] init];
    [_titleAttribute appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@/%@", _model.owner.name, _model.name]]];
    [_titleAttribute addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSForegroundColorAttributeName:[UIColor colorWithHex:0x111111]} range:NSMakeRange(0, _titleAttribute.length)];
    self.titleLabel.attributedText = _titleAttribute;
    self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
}

//拼接描述信息
- (void)parmerInfoAttribute{
    if (!_infoAttribute) {

        _infoAttribute = [[NSMutableAttributedString alloc] init];
        UIImage *langImag = [[UIImage alloc] init];        
        NSTextAttachment *textAttachment2 = [NSTextAttachment new];
        langImag = [UIImage imageNamed:@"ic_star"];
        textAttachment2.image = langImag;
        textAttachment2.bounds = CGRectMake(0, -2, langImag.size.width, langImag.size.height);
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment2];
        [_infoAttribute appendAttributedString:attachmentString];
        [_infoAttribute appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %ld   ", _model.stars_count]]];
        
        NSTextAttachment *textAttachment1 = [NSTextAttachment new];
        langImag = [UIImage imageNamed:@"ic_fork"];
        textAttachment1.image = langImag;
        textAttachment1.bounds = CGRectMake(0, -2, langImag.size.width, langImag.size.height);
        NSAttributedString *attachmentStr = [NSAttributedString attributedStringWithAttachment:textAttachment1];
        [_infoAttribute appendAttributedString:attachmentStr];
        [_infoAttribute appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %ld", _model.forks_count]]];
        
        [_infoAttribute addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor colorWithHex:0x9D9D9D]} range:NSMakeRange(0, _infoAttribute.length)];
    }
    
    self.infoLabel.attributedText = _infoAttribute;
}

//计算富文本高度
- (CGSize)getSizeWithAttribute:(__kindof NSAttributedString *)attributeString withSize:(CGSize)size{
    CGRect attributeRect = [attributeString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return attributeRect.size;
}

//计算文字高度
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
