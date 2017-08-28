//
//  OSCGitListModel.m
//  iosapp
//
//  Created by 王恒 on 17/3/2.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCGitListModel.h"

#import "UIColor+Util.h"

#import <NSObject+YYModel.h>

#define kTopPadding 16
#define kBottomPadding 16
#define kLeftPadding 16
#define kRightPadding 16
#define kPortraitWH 46
#define kPortrait_padding_Title 8
#define kTitle_padding_Description 4
#define kDescriptionMaxH 38 //最多显示两行
#define kDescription_padding_Info 6
#define kInfoHeight 14

#define kScreenSize [UIScreen mainScreen].bounds.size

#define kRightPaddingLeft kPortrait_padding_Title + kPortraitWH + kLeftPadding
#define kRightW kScreenSize.width - (kRightPaddingLeft) - kRightPadding

@implementation OSCGitListModel

//绑定信息
+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"git_description":@"description",
             @"git_public":@"public",
             @"git_namespace":@"namespace"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"owner":[GitOwner class],
             @"git_namespace":[GitNameSpace class]};
}

//拼接title
- (void)parmerTitleAttribute{
    _titleAttribute = [[NSMutableAttributedString alloc] init];
    [_titleAttribute appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@/%@", self.owner.name, self.name]]];
    [_titleAttribute addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSForegroundColorAttributeName:[UIColor colorWithHex:0x111111]} range:NSMakeRange(0, _titleAttribute.length)];
}

//拼接描述信息
- (void)parmerInfoAttribute{
    if (!_infoAttribute) {
        _infoAttribute = [[NSMutableAttributedString alloc] init];
        
        UIImage *langImag = [UIImage imageNamed:@"ic_view"];
        
        NSTextAttachment *textAttachment3 = [NSTextAttachment new];
        textAttachment3.image = langImag;
        textAttachment3.bounds = CGRectMake(0, -2, langImag.size.width, langImag.size.height);
        NSAttributedString *attachmentStrings = [NSAttributedString attributedStringWithAttachment:textAttachment3];
        [_infoAttribute appendAttributedString:attachmentStrings];
        [_infoAttribute appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %ld   ", _watches_count]]];
        
        NSTextAttachment *textAttachment2 = [NSTextAttachment new];
        langImag = [UIImage imageNamed:@"ic_star"];
        textAttachment2.image = langImag;
        textAttachment2.bounds = CGRectMake(0, -2, langImag.size.width, langImag.size.height);
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment2];
        [_infoAttribute appendAttributedString:attachmentString];
        [_infoAttribute appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %ld   ", _stars_count]]];
        
        NSTextAttachment *textAttachment1 = [NSTextAttachment new];
        langImag = [UIImage imageNamed:@"ic_fork"];
        textAttachment1.image = langImag;
        textAttachment1.bounds = CGRectMake(0, -2, langImag.size.width, langImag.size.height);
        NSAttributedString *attachmentStr = [NSAttributedString attributedStringWithAttachment:textAttachment1];
        [_infoAttribute appendAttributedString:attachmentStr];
        [_infoAttribute appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %ld", _forks_count]]];
        
        [_infoAttribute addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor colorWithHex:0x9D9D9D]} range:NSMakeRange(0, _infoAttribute.length)];
    }
}

- (void)calculateLayoutWithCurTweetCellWidth:(CGFloat)curWidth{
    [self parmerTitleAttribute];
    [self parmerInfoAttribute];
    
    _portraitFrame = CGRectMake(kLeftPadding, kTopPadding, kPortraitWH, kPortraitWH);
    
    CGSize layoutSize = CGSizeMake(kRightW, MAX_CANON);
    float titleHeight = [self getSizeWithAttribute:_titleAttribute withSize:layoutSize].height;
    _titleFrame = CGRectMake(kRightPaddingLeft, kTopPadding, kRightW, titleHeight);
    
    float descriptionY = kTopPadding + titleHeight + kTitle_padding_Description;
    float descriptionHeight = [self getSizeWithString:_git_description withFont:[UIFont systemFontOfSize:14] withSize:layoutSize].height;
    if (descriptionHeight > kDescriptionMaxH) {
        descriptionHeight = kDescriptionMaxH;
    }
    _descriptionFrame = CGRectMake(kRightPaddingLeft, descriptionY, kRightW, descriptionHeight);

    float infoY = descriptionY + descriptionHeight + kDescription_padding_Info;
    CGSize infoLayoutSize = CGSizeMake(MAX_CANON, kInfoHeight);
    float infoWidth = [self getSizeWithAttribute:_infoAttribute withSize:infoLayoutSize].width;
    
    _infoFrame = CGRectMake(kScreenSize.width - infoWidth - kRightPadding, infoY, infoWidth, kInfoHeight);
    
    if (_language.length > 0) {
        float langueWidth = [self getSizeWithString:_language withFont:[UIFont systemFontOfSize:10.0] withSize:infoLayoutSize].width;
        _langueFrame = CGRectMake(kRightPaddingLeft, infoY + 2, langueWidth + 8, kInfoHeight);
    }else{
        _langueFrame = CGRectZero;
    }
    
    _cellHeight = CGRectGetMaxY(_infoFrame) + kBottomPadding;
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

@end




@implementation GitOwner

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"portrait_new":@"new_portrait"};
}

@end




@implementation GitNameSpace

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"git_description":@"description"};
}

@end


