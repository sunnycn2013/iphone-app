//
//  OSCAbout.m
//  iosapp
//
//  Created by Graphic-one on 16/12/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCAbout.h"

#import "Utils.h"

#import "OSCForwardView.h"
#import "AsyncDisplayTableViewCell.h"

@implementation OSCAbout
+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"images" : [OSCNetImage class],
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"images" : [OSCNetImage class],
             };
}

#define maxHeightOfContentView 50

- (void)calculateLayoutWithForwardViewWidth:(CGFloat)curForwardViewWidth
{
    CGFloat fullWidth = curForwardViewWidth - forwardView_padding_left - forwardView_padding_right;
    _viewHeight = 0;
    if (_type == InformationTypeTweet) {
        _titleLabelFrame = CGRectZero;
        
        NSString* contentText = [NSString stringWithFormat:@"%@：%@",_title,_content];
        _content = contentText;
        NSMutableAttributedString* string = [[Utils contentStringFromRawString:_content] mutableCopy];
        [string addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:contectLb_font_size]} range:NSMakeRange(0, string.length)];
        CGSize strSize = [string boundingRectWithSize:(CGSize){fullWidth,MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        float height = strSize.height;
        _contectTextViewFrame = (CGRect){{forwardView_padding_left,forwardView_padding_top},{fullWidth,height}};
        
        if (_images.count > 1) {
            _forwardingMultipleFrame = [self calculateMultipleImageViewFrameWithCount:(int)_images.count curForwardViewWidth:curForwardViewWidth];
            
            _imageFrame = CGRectZero;
            _viewHeight += forwardView_padding_top + _contectTextViewFrame.size.height + forwardView_content_SPACE_picture + _forwardingMultipleFrame.frame.size.height + _imageFrame.size.height + forwardView_padding_bottom;
        }else if (_images.count == 1){
            _imageFrame = (CGRect){{forwardView_padding_left,CGRectGetMaxY(_contectTextViewFrame) + forwardView_content_SPACE_picture},{fullWidth,forwardView_PieceImageView_Height}};
            
            _forwardingMultipleFrame = _multipleImageViewFrameZero;
            _viewHeight += forwardView_padding_top + _contectTextViewFrame.size.height + forwardView_content_SPACE_picture + _forwardingMultipleFrame.frame.size.height + _imageFrame.size.height + forwardView_padding_bottom;
        }else{
            _imageFrame = CGRectZero;
            _forwardingMultipleFrame = _multipleImageViewFrameZero;
            _viewHeight += forwardView_padding_top + _contectTextViewFrame.size.height + forwardView_padding_bottom;
        }
    }else{
        CGSize titleSize = [_title boundingRectWithSize:(CGSize){fullWidth,[UIFont systemFontOfSize:titleLb_font_size].lineHeight * 2 + 4} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:titleLb_font_size]} context:nil].size;
        _titleLabelFrame = (CGRect){{forwardView_padding_left,forwardView_padding_top},{fullWidth,titleSize.height}};
        CGSize contentSize = [_content boundingRectWithSize:(CGSize){fullWidth,MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:contectLb_font_size]} context:nil].size;
        float height = contentSize.height;
        if(height > maxHeightOfContentView){
            height = maxHeightOfContentView;
        }
        _contectTextViewFrame = (CGRect){{forwardView_padding_left,CGRectGetMaxY(_titleLabelFrame) + forwardView_title_SPACE_content},{fullWidth,height}};
        
        _viewHeight += forwardView_padding_top + _titleLabelFrame.size.height + forwardView_title_SPACE_content + _contectTextViewFrame.size.height + forwardView_padding_bottom;
        
    }
}

- (MultipleImageViewFrame)calculateMultipleImageViewFrameWithCount:(int)count
                                               curForwardViewWidth:(CGFloat)curForwardViewWidth
{
#pragma TODO:: 使用宏代替 multiple_WH & imageItem_WH
    /** 全局padding值*/
    CGFloat Multiple_Padding = forwardView_padding_left;
    CGFloat ImageItemPadding = 8;
    
    /** 动态值维护*/
    CGFloat multiple_WH = ceil((curForwardViewWidth - (Multiple_Padding * 2)));
    CGFloat imageItem_WH = ceil(((multiple_WH - (2 * ImageItemPadding)) / 3 ));
    
    MultipleImageViewFrame multiple;
    if (count <= 3) {
        multiple.line = 1;
        multiple.row = count;
        multiple.frame = (CGRect){{forwardView_padding_left,CGRectGetMaxY(_contectTextViewFrame) + forwardView_content_SPACE_picture},{imageItem_WH * 3 + ImageItemPadding * 2,imageItem_WH}};
    }else if (count <= 6){
        if (count == 4) {
            multiple.line = 2;
            multiple.row = 2;
        }else{
            multiple.line = 2;
            multiple.row = 3;
        }
        multiple.frame = (CGRect){{forwardView_padding_left,CGRectGetMaxY(_contectTextViewFrame) + forwardView_content_SPACE_picture},{imageItem_WH * 3 + ImageItemPadding * 2,imageItem_WH * 2 + ImageItemPadding}};
    }else{
        multiple.line = 3;
        multiple.row = 3;
        multiple.frame = (CGRect){{forwardView_padding_left,CGRectGetMaxY(_contectTextViewFrame) + forwardView_content_SPACE_picture},{imageItem_WH * 3 + ImageItemPadding * 2,imageItem_WH * 3 + ImageItemPadding * 2}};
    }
    return multiple;
}

+ (instancetype)forwardInfoModelWithTitle:(NSString* )title
                                  content:(NSString* )content
                                     type:(InformationType)type
                                fullWidth:(CGFloat)fullWidth
{
    OSCAbout* forwardInfo = [OSCAbout new];
    forwardInfo.title = title;
    forwardInfo.content = content;
    forwardInfo.type = type;
    [forwardInfo calculateLayoutWithForwardViewWidth:fullWidth];
    return forwardInfo;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    OSCAbout* aboutInfo = [[OSCAbout allocWithZone:zone] init];
    aboutInfo.id = _id;
    aboutInfo.title = [_title mutableCopy];
    aboutInfo.content = [_content mutableCopy];
    aboutInfo.type = _type;
    aboutInfo.statistics = [_statistics mutableCopy];
    aboutInfo.href = [_href mutableCopy];
    aboutInfo.images = [_images mutableCopy];
    return aboutInfo;
}

@end
