//
//  OSCCommentItem.m
//  iosapp
//
//  Created by Holden on 16/7/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCCommentItem.h"
#import "Utils.h"

#define kScreen_bound_width [UIScreen mainScreen].bounds.size.width
#define cell_padding_left 16
#define cell_padding_top 16
#define cell_padding_right 16
#define cell_padding_bottom 16

#define portrait_width_equle_height 32
#define portrait_name_padding 8
#define portrait_content_padding 7
#define comment_width_equle_height 14
#define answer_height 18
#define bestAnswer_width_padding 67

#define cell_nameLB_Font_Size 15
#define cell_timeLB_Font_Size 10
#define cell_contentLB_Font_Size 14
#define cell_timeLB_Font__Height 14

#define referLeftLine_W 0.5
#define referBottomLine_H referLeftLine_W
#define referLine_padding_textView 8
#define portrait_padding_leftLine 7
#define referLeftLineTop_padding_TextView 5

#define kScreenSize [UIScreen mainScreen].bounds.size

@implementation OSCCommentItem

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"refer" : [OSCCommentItemRefer class],
             @"reply" : [OSCCommentItemReply class],
             
             @"references"  : [OSCCommentItemRefer class],
             @"replies"     : [OSCCommentItemReply class],
             };
}

- (void)calculateLayout:(BOOL)isNeedRefer
{
    if (isNeedRefer) {
        [self calaculateLayoutForRefer];
    }else{
        [self calaculateLayoutForUnRefer];
    }
    _layoutHeight = CGRectGetMaxY(_layoutInfo.contentTextViewFrame) + cell_padding_bottom;
}

- (void)calaculateLayoutForRefer{
    CGRect portraitFrame = (CGRect){{cell_padding_left, cell_padding_top}, {portrait_width_equle_height, portrait_width_equle_height}};
    _layoutInfo.userPortraitFrame = portraitFrame;
    
    float nameWidth = [self getStringWidthWithFont:[UIFont boldSystemFontOfSize:15.0] withHeight:40 withString:self.author.name];
    CGRect userNameLabelFrame = CGRectMake(CGRectGetMaxX(portraitFrame) + portrait_name_padding, cell_padding_top, nameWidth, portrait_width_equle_height/2);
    _layoutInfo.userNameLbFrame = userNameLabelFrame;
    
    CGRect timeLabelFrame = CGRectMake(CGRectGetMaxX(portraitFrame) + portrait_name_padding, CGRectGetMaxY(userNameLabelFrame), kScreenSize.width - CGRectGetMaxX(portraitFrame) - portrait_name_padding - 50, portrait_width_equle_height/2);
    _layoutInfo.timeLbFrame = timeLabelFrame;
    
    CGFloat referY =  CGRectGetMaxY(portraitFrame) + portrait_padding_leftLine;
    NSMutableArray *referFrames = [NSMutableArray array];
    for(OSCCommentItemRefer *referModel in _refer){
        NSInteger index = [_refer indexOfObject:referModel];
        CGFloat textViewWidth = kScreenSize.width - cell_padding_left - cell_padding_right - (_refer.count - index) * (referLeftLine_W + referLine_padding_textView);
        
        NSMutableAttributedString *replyContent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:\n", referModel.author]];
        [replyContent appendAttributedString:[Utils emojiStringFromRawString:[referModel.content deleteHTMLTag]]];
        [replyContent addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:cell_contentLB_Font_Size]} range:NSMakeRange(0, replyContent.length)];
        CGFloat textViewHeight = [replyContent boundingRectWithSize:(CGSize){textViewWidth, MAX_CANON}
                                                                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                                    context:nil].size.height;
        
        CGRect textViewFrame = CGRectMake(cell_padding_left + (_refer.count - index) * (referLeftLine_W + referLine_padding_textView), referY + referLeftLineTop_padding_TextView, textViewWidth, textViewHeight);
        CGRect bottomLineFrame = CGRectMake(CGRectGetMinX(textViewFrame), CGRectGetMaxY(textViewFrame) + referLeftLineTop_padding_TextView, textViewWidth, referBottomLine_H);
        CGRect leftLineFrame = CGRectMake(CGRectGetMinX(textViewFrame) - referLine_padding_textView - referLeftLine_W, CGRectGetMaxY(portraitFrame) + portrait_padding_leftLine, referLeftLine_W, CGRectGetMaxY(bottomLineFrame) - CGRectGetMaxY(portraitFrame) - portrait_padding_leftLine);
        referY = CGRectGetMaxY(bottomLineFrame);
        CommentReplyLayoutInfo referInfo = (CommentReplyLayoutInfo){bottomLineFrame,leftLineFrame,textViewFrame};
        [referFrames addObject:@(referInfo)];
    }
    _replysInfo = [referFrames copy];
    
    CGFloat contetViewHeight = [[OSCCommentItem contentStringFromRawString:_content] boundingRectWithSize:(CGSize){(kScreen_bound_width - cell_padding_left - cell_padding_right), MAX_CANON}
                                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                       context:nil].size.height;
    
    CGRect contentViewFrame = CGRectMake(cell_padding_left,referY + referLeftLineTop_padding_TextView, kScreenSize.width - cell_padding_left - cell_padding_right, contetViewHeight);
    _layoutInfo.contentTextViewFrame = contentViewFrame;
}

- (void)calaculateLayoutForUnRefer
{
    CGRect portraitFrame = (CGRect){{cell_padding_left, cell_padding_top}, {portrait_width_equle_height, portrait_width_equle_height}};
    _layoutInfo.userPortraitFrame = portraitFrame;
    
    CGRect commentFrame;
    if (_best) {
        commentFrame = (CGRect){{kScreen_bound_width - cell_padding_right - bestAnswer_width_padding, cell_padding_top}, {bestAnswer_width_padding, answer_height}};
    } else {
        commentFrame = (CGRect){{kScreen_bound_width - cell_padding_right - comment_width_equle_height, cell_padding_top}, {comment_width_equle_height, comment_width_equle_height}};
    }
    
    _layoutInfo.commentBtnFrame = commentFrame;
    
    
   float nameWidth = [self getStringWidthWithFont:[UIFont boldSystemFontOfSize:15.0] withHeight:40 withString:self.author.name];
    CGRect userNameLabelFrame = CGRectMake(CGRectGetMaxX(portraitFrame) + portrait_name_padding, cell_padding_top, nameWidth, portrait_width_equle_height/2);
    _layoutInfo.userNameLbFrame = userNameLabelFrame;
    
    CGRect timeFrame = (CGRect){{cell_padding_left + portrait_width_equle_height + portrait_name_padding, cell_padding_top + userNameLabelFrame.size.height},
                                {kScreen_bound_width - (cell_padding_left + portrait_width_equle_height + portrait_name_padding) - cell_padding_right, cell_timeLB_Font__Height}};
    _layoutInfo.timeLbFrame = timeFrame;
    
    CGSize contentSize = [[OSCCommentItem contentStringFromRawString:_content] boundingRectWithSize:(CGSize){(kScreen_bound_width - cell_padding_left - cell_padding_right), MAX_CANON} options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            context:nil].size;
    
    CGRect contentFrame = (CGRect){{cell_padding_left, cell_padding_top + portrait_width_equle_height + portrait_content_padding}, {kScreen_bound_width - cell_padding_left - cell_padding_right, contentSize.height}};
    _layoutInfo.contentTextViewFrame = contentFrame;
}

#pragma mark - 处理字符串
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString
{
    if (!rawString || rawString.length == 0) return [[NSAttributedString alloc] initWithString:@""];
    
    NSAttributedString *attrString = [Utils attributedStringFromHTML:rawString];
    //    [Utils emojiStringFromAttrString:attrString]
    NSMutableAttributedString *mutableAttrString = [attrString mutableCopy];
    [mutableAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14   ] range:NSMakeRange(0, mutableAttrString.length)];
    
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


+ (NSAttributedString *)attributedTextFromReplies:(NSArray *)replies
{
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\n--共有%lu条评论--\n", (unsigned long)replies.count]
                                                                                       attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    
    [replies enumerateObjectsUsingBlock:^(OSCReply *reply, NSUInteger idx, BOOL *stop) {
        NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：", reply.author]
                                                                                          attributes:@{
                                                                                                       NSForegroundColorAttributeName:[UIColor nameColor],
                                                                                                       NSFontAttributeName:[UIFont systemFontOfSize:13]
                                                                                                       }];
        NSMutableAttributedString *replyContent = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:reply.content]];
        [replyContent addAttributes:@{
                                      NSForegroundColorAttributeName:[UIColor grayColor],
                                      NSFontAttributeName:[UIFont systemFontOfSize:13]
                                      } range:NSMakeRange(0, replyContent.length)];
        [commentString appendAttributedString:replyContent];
        
        [attributedText appendAttributedString:commentString];
        
        if (idx != replies.count-1) {
            [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        } else {
            *stop = YES;
        }
    }];
    
    return [attributedText copy];
}

- (BOOL)isEqualTo:(OSCCommentItem* )commentItem
{
    if (_id         != commentItem.id ||
        
        _appClient  != commentItem.appClient ||
        _vote       != commentItem.vote   ||
        _voteState  != commentItem.voteState ||
        _best       != commentItem.best  ||
        ![_content isEqualToString:commentItem.content] ||
        ![_pubDate isEqualToString:commentItem.pubDate] )
    {
        return NO;
    }else{
        return YES;
    }
}

- (CGFloat)getStringHeightWithFont:(UIFont *)font
                         withWidth:(CGFloat)width
                        withString:(NSString *)targetString{
    CGRect stringRect = [targetString boundingRectWithSize:CGSizeMake(width, MAX_CANON) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return stringRect.size.height;
}

- (CGFloat)getStringWidthWithFont:(UIFont *)font
                       withHeight:(CGFloat)height
                       withString:(NSString *)targetString{
    CGRect stringRect = [targetString boundingRectWithSize:CGSizeMake(MAX_CANON, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return stringRect.size.width;
}

@end

//引用
@implementation OSCCommentItemRefer

@end


//回复
@implementation OSCCommentItemReply

@end

///< 用作CommentReplyLayoutInfo 装箱 拆箱
@implementation NSValue (boxable_CommentReplyLayoutInfo)
+ (instancetype)boxing:(CommentReplyLayoutInfo)replyLayoutInfo///< 手动装箱
{
    NSValue* value = [NSValue value:&replyLayoutInfo withObjCType:@encode(CommentReplyLayoutInfo)];
    return value;
}

- (CommentReplyLayoutInfo)openBoxCase
{
    CommentReplyLayoutInfo layoutInfo = (CommentReplyLayoutInfo){CGRectZero,CGRectZero,CGRectZero};
    [self getValue:&layoutInfo];
    return layoutInfo;
}
@end


