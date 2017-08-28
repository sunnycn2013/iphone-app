//
//  OSCTweetItem.m
//  iosapp
//
//  Created by Graphic-one on 16/7/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetItem.h"
#import <UIKit/UIFont.h>
#import <CoreGraphics/CoreGraphics.h>
#import "AsyncDisplayTableViewCell.h"
#import "OSCForwardView.h"
#import "Utils.h"
#import "ThumbnailHadle.h"
#import "OSCModelHandler.h"
#import "OSCExtra.h"
#import "OSCNetImage.h"
#import "OSCAbout.h"
#import "OSCStatistics.h"

@implementation OSCTweetItem

+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"audio" : [OSCTweetAudio class],
             @"images" : [OSCNetImage class],
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"audio" : [OSCTweetAudio class],
             @"images" : [OSCNetImage class],
             };
}


- (MultipleImageViewFrame)multipleImageViewFrameZero{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _multipleImageViewFrameZero.frame = CGRectZero;
        _multipleImageViewFrameZero.line = 0;
        _multipleImageViewFrameZero.row = 0;
    });
    return _multipleImageViewFrameZero;
}

- (void)calculateLayoutWithCurTweetCellWidth:(CGFloat)curWidth
                         forwardViewCurWidth:(CGFloat)forwardViewCurWidth
{
    CGRect userPortraitFrame = (CGRect){{padding_left,padding_top},{userPortrait_W,userPortrait_H}};
    _userPortraitFrame = userPortraitFrame;
    
    float left = padding_left + userPortrait_W + userPortrait_SPACE_nameLabel;//除头像外所有控件的左边距;
    
    //nameLabel Frame
    CGFloat nameLWidth = [self getStringWidthWithFont:[UIFont boldSystemFontOfSize:15] withString:self.author.name withHeight:nameLabel_H];
    CGRect nameLabelFrame = (CGRect){{left,padding_top},{nameLWidth,nameLabel_H}};
    _nameLabelFrame = nameLabelFrame;
    
    //text path layuot
    NSAttributedString* string = [Utils contentStringFromRawString:_content];
    CGSize size = [string boundingRectWithSize:(CGSize){(curWidth - left - padding_right),MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin context:nil].size ;
    CGRect descTextFrame = (CGRect){{left,CGRectGetMaxY(_nameLabelFrame) + nameLabel_space_descTextView},{curWidth - left - padding_right,size.height + 3}};
    _descTextFrame = descTextFrame;
    
    //sourceLabel Frame
    
    float yOfBottom = 0;
    
    //images path layout
    if (_images.count == 0) {//纯文字
        _imageFrame = CGRectZero;
        _multipleFrame = [self multipleImageViewFrameZero];;
        _rowHeight = 0;
        
        yOfBottom = CGRectGetMaxY(_descTextFrame) + descTextView_space_timeAndSourceLabel;
        
    }else if (_images.count == 1){//单图
        OSCNetImage* onceImage = [_images lastObject];
        _imageFrame = (CGRect){{left,CGRectGetMaxY(_descTextFrame) + descTextView_space_imageView},[ThumbnailHadle thumbnailSizeWithOriginalW:onceImage.w originalH:onceImage.h]};
        _multipleFrame = [self multipleImageViewFrameZero];
        _rowHeight = 0;
        
        yOfBottom = CGRectGetMaxY(_imageFrame) + imageView_space_timeAndSourceLabel;
        
    }else{//多图
        _imageFrame = CGRectZero;
        _rowHeight = 0;
        
        int count = (int)_images.count;
        MultipleImageViewFrame multipleImageViewFrame;
        
        /** 全局padding值*/
        CGFloat Multiple_Padding = 69;
        CGFloat ImageItemPadding = 8;
        
        /** 动态值维护*/
        CGFloat multiple_WH = ceil((curWidth - (Multiple_Padding * 2)));
        CGFloat imageItem_WH = ceil(((multiple_WH - (2 * ImageItemPadding)) / 3 ));
        
        if (count <= 3) {
            multipleImageViewFrame.line = 1;
            multipleImageViewFrame.row = count;
            multipleImageViewFrame.frame = (CGRect){{0,0},{imageItem_WH * 3 + ImageItemPadding * 2,imageItem_WH}};
        }else if (count <= 6){
            if (count == 4) {
                multipleImageViewFrame.line = 2;
                multipleImageViewFrame.row = 2;
            }else{
                multipleImageViewFrame.line = 2;
                multipleImageViewFrame.row = 3;
            }
            multipleImageViewFrame.frame = (CGRect){{0,0},{imageItem_WH * 3 + ImageItemPadding * 2,imageItem_WH * 2 + ImageItemPadding}};
        }else{
            multipleImageViewFrame.line = 3;
            multipleImageViewFrame.row = 3;
            multipleImageViewFrame.frame = (CGRect){{0,0},{imageItem_WH * 3 + ImageItemPadding * 2,imageItem_WH * 3 + ImageItemPadding * 2}};
        }
        _multipleFrame = multipleImageViewFrame;
        
        yOfBottom = CGRectGetMaxY(_descTextFrame) + descTextView_space_imageView + multipleImageViewFrame.frame.size.height + imageView_space_timeAndSourceLabel;
    }
    
    //底部控件layout
    _timeLabelFrame = CGRectMake(left, yOfBottom, timeAndSourceLabel_W, timeAndSourceLabel_H);
    _forwardLabelFrame = CGRectMake(curWidth - padding_right - commentCountLabel_W , yOfBottom, commentCountLabel_W, commentCountLabel_H);
    _forwardButtonFrame = CGRectMake(CGRectGetMinX(_forwardLabelFrame) - operationBtn_space_label - operationBtn_W, yOfBottom, operationBtn_W, operationBtn_H);
    _commentLabelFrame = CGRectMake(CGRectGetMinX(_forwardButtonFrame) - like_space_comment - commentCountLabel_W, yOfBottom, commentCountLabel_W, commentCountLabel_H);
    _commentButtonFrame = CGRectMake(CGRectGetMinX(_commentLabelFrame) - operationBtn_space_label - operationBtn_W, yOfBottom, operationBtn_W, operationBtn_H);
    _likeLabelFrame = CGRectMake(CGRectGetMinX(_commentButtonFrame) - like_space_comment - commentCountLabel_W, yOfBottom, commentCountLabel_W, commentCountLabel_H);
    _likeButtonFrame = CGRectMake(CGRectGetMinX(_likeLabelFrame) - operationBtn_space_label - operationBtn_W, yOfBottom, operationBtn_W, operationBtn_H);
    
    float forwardViewHeight = 0;
    if(_about){
        [_about calculateLayoutWithForwardViewWidth:forwardViewCurWidth];
        forwardViewHeight = _about.viewHeight + descTextView_space_forwardView;
    }
    
    _rowHeight = CGRectGetMaxY(_likeButtonFrame) + padding_bottom + forwardViewHeight;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    OSCTweetItem* item = [[OSCTweetItem allocWithZone:zone] init];
    item->_id = _id;
    item->_appClient = _appClient;
    item->_href = [_href mutableCopy];
    item->_author = [_author mutableCopy];
    item->_pubDate = [_pubDate mutableCopy];
    item->_audio = [_audio mutableCopy];
    item->_code = [_code mutableCopy];
    item->_images = [_images mutableCopy];
    item->_liked = _liked;
    item->_content = [_content mutableCopy];
    item->_about = [_about mutableCopy];
    item->_statistics = [_statistics mutableCopy];
    return item;
}

- (CGFloat)getStringWidthWithFont:(UIFont *)font withString:(NSString *)string withHeight:(CGFloat)height{
    CGRect stringRect = [string boundingRectWithSize:CGSizeMake(MAX_CANON, height) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    return stringRect.size.width;
}

@end


#pragma mark -
#pragma mark --- 动弹作者
@implementation OSCTweetAuthor

- (id)mutableCopyWithZone:(NSZone *)zone{
    OSCTweetAuthor* authorCopy = [[OSCTweetAuthor allocWithZone:zone] init];
    authorCopy->_id = _id;
    authorCopy->_name = [_name mutableCopy];
    authorCopy->_portrait = [_portrait mutableCopy];
    return authorCopy;
}

@end


#pragma mark -
#pragma mark --- 动弹Code
@implementation OSCTweetCode

- (id)mutableCopyWithZone:(NSZone *)zone{
    OSCTweetCode* codeCopy = [[OSCTweetCode allocWithZone:zone] init];
    codeCopy->_brush = [_brush mutableCopy];
    codeCopy->_content = [_content mutableCopy];
    return codeCopy;
}

@end


#pragma mark -
#pragma mark --- 动弹音频 && 视频
@implementation OSCTweetAudio

@end


#pragma mark - 推荐话题
/** 推荐话题列表使用到Item */
@implementation OSCTweetTopicItem
+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"items" : [OSCTweetItem class],
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"items" : [OSCTweetItem class],
             };
}

@end







