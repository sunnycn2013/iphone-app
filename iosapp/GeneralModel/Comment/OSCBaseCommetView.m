//
//  OSCBaseCommetView.m
//  iosapp
//
//  Created by Graphic-one on 17/1/17.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCBaseCommetView.h"
#import "Utils.h"

@interface OSCBaseCommetView ()

@property (nonatomic,readwrite,strong) OSCCommentItem* commnetItem;

@end

@implementation OSCBaseCommetView

- (instancetype)initWithViewModel:(OSCCommentItem *)commentItem
                uxiliaryNodeStyle:(CommentUxiliaryNode)uxiliaryNode
{
    self = [super init];
    if (self) {
        _commnetItem = commentItem;
        
        //subClass cover ....
    }
    return self;
}

static UIImage* _likeImage;
+ (UIImage *)likeImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _likeImage = [UIImage imageNamed:@"ic_thumbup_actived"];
    });
    return _likeImage;
}

static UIImage* _unlikeImage;
+ (UIImage* )unlikeImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _unlikeImage = [UIImage imageNamed:@"ic_thumbup_normal"];
    });
    return _unlikeImage;
}

static UIImage* _commentImage;
+ (UIImage *)commentImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _commentImage = [UIImage imageNamed:@"ic_comment_30"];
    });
    return _commentImage;
}

#pragma mark - 处理字符串
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString withFont:(CGFloat)fontSize;
{
    if (!rawString || rawString.length == 0) return [[NSAttributedString alloc] initWithString:@""];
    
    NSAttributedString *attrString = [Utils attributedStringFromHTML:rawString];
    //    [Utils emojiStringFromAttrString:attrString]
    NSMutableAttributedString *mutableAttrString = [attrString mutableCopy];
    [mutableAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize   ] range:NSMakeRange(0, mutableAttrString.length)];
    
    // remove under line style
    [mutableAttrString beginEditing];
    [mutableAttrString enumerateAttribute:NSUnderlineStyleAttributeName
                                  inRange:NSMakeRange(0, mutableAttrString.length)
                                  options:0
                               usingBlock:^(id value, NSRange range, BOOL *stop) {
                                   if (value) {
                                       [mutableAttrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
                                   }
                               }];
    [mutableAttrString endEditing];
    
    return mutableAttrString;
}

#pragma mark - vote animation

- (void)setVoteStatus:(OSCCommentItem* )commentItem animation:(BOOL)isNeedAnimation{
    //
}


@end
