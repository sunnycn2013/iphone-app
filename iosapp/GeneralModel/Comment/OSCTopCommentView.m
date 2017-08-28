//
//  OSCTopCommentView.m
//  iosapp
//
//  Created by Graphic-one on 17/1/17.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCTopCommentView.h"
#import "OSCCommentItem.h"
#import "Utils.h"

#import "UIColor+Util.h"
#import "UIImage+Comment.h"
#import "NSDate+Comment.h"
#import "UIImageView+Comment.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <YYKit/YYKit.h>
#import <YYTextAttribute.h>

#define kPaddingRight 16
#define kImageView_WH 14
#define kFavoriteLabel_W 21
#define kFavoriteLabel_padding_FavoriteBtn 5
#define kPaddingTop 16

@interface OSCTopCommentView ()
{
    
    BOOL _isOngoingAnimation;
    UIImageView *userPortrait;
    UILabel *likeLabel;
    UIImageView *likeImageView;
    UIImageView *commentImageView;
    UITextView  *commentTextView;//评论文本，非引用区
    //UILabel *shareL; //用于生产图片分享的
    YYLabel *shareL; //用于生产图片分享的
    
}

@end

@implementation OSCTopCommentView
{
    BOOL _trackingTouch_portrait;
    BOOL _trackingTouch_likeBtn;
    BOOL _trackingTouch_commentBtn;
}

- (instancetype)initWithViewModel:(OSCCommentItem *)commentItem
                uxiliaryNodeStyle:(CommentUxiliaryNode)uxiliaryNode
{
    self = [super initWithViewModel:commentItem uxiliaryNodeStyle:uxiliaryNode];
    if (self) {
        [self addContentViewWithModel:commentItem];
        [self addRightButtonsViewWithUxiliaryNodeStyle:uxiliaryNode isFavorite:commentItem.voteState likeCount:commentItem.vote];
    }
    return self;
}

- (instancetype)initWithViewModel:(OSCCommentItem *)commentItem
                uxiliaryNodeStyle:(CommentUxiliaryNode)uxiliaryNode
                          isShare:(BOOL)isShare{
    self = [super initWithViewModel:commentItem uxiliaryNodeStyle:uxiliaryNode];
    if (self) {
        [self addContentViewWithModel:commentItem isShare:YES];
    }
    return self;
}

- (void)addContentViewWithModel:(OSCCommentItem *)commentItem{
    userPortrait = [UIImageView new];
    [userPortrait loadPortrait:[NSURL URLWithString:commentItem.author.portrait] userName:commentItem.author.name];
    userPortrait.frame = commentItem.layoutInfo.userPortraitFrame;
    userPortrait.userInteractionEnabled = YES;
    [userPortrait handleCornerRadiusWithRadius:commentItem.layoutInfo.userPortraitFrame.size.height/2];
    [self addSubview:userPortrait];
    
    YYLabel *nameLabel = [YYLabel new];
    nameLabel.frame = commentItem.layoutInfo.userNameLbFrame;
    nameLabel.font = [UIFont boldSystemFontOfSize:15.0];
    nameLabel.numberOfLines = 1;
    nameLabel.textColor = [UIColor newTitleColor];
    nameLabel.displaysAsynchronously = YES;
    nameLabel.fadeOnAsynchronouslyDisplay = NO;
    nameLabel.fadeOnHighlight = NO;
    nameLabel.text = commentItem.author.name != nil ? commentItem.author.name : @"火星网友";
    [self addSubview:nameLabel];
    
    if (commentItem.author.identity.officialMember) {
        YYLabel *identityLabel = [YYLabel new];
        identityLabel.frame = CGRectMake(CGRectGetMaxX(nameLabel.frame)  + 5, nameLabel.frame.origin.y, 50, 16);
        identityLabel.font = [UIFont systemFontOfSize:10.0];
        identityLabel.text = @"官方人员";
        identityLabel.textColor = [UIColor colorWithHex:0x24CF5F];
        identityLabel.textAlignment = NSTextAlignmentCenter;
        identityLabel.layer.masksToBounds = YES;
        identityLabel.layer.cornerRadius = 2;
        identityLabel.layer.borderColor = [UIColor colorWithHex:0x24CF5F].CGColor;
        identityLabel.layer.borderWidth = 1;
        [self addSubview:identityLabel];
    }
    
    YYLabel *timeLabel = [YYLabel new];
    timeLabel.frame = commentItem.layoutInfo.timeLbFrame;
    timeLabel.font = [UIFont systemFontOfSize:10.0];
    timeLabel.numberOfLines = 1;
    timeLabel.textColor = [UIColor newAssistTextColor];
    timeLabel.displaysAsynchronously = YES;
    timeLabel.fadeOnAsynchronouslyDisplay = NO;
    timeLabel.fadeOnHighlight = NO;
    timeLabel.text = [[NSDate dateFromString:commentItem.pubDate] timeAgoSince];
    [self addSubview:timeLabel];
    
    [self addReplySubViewsWithArray:commentItem.refer withLayout:commentItem.replysInfo];
    
    commentTextView = [UITextView new];
    commentTextView.frame = commentItem.layoutInfo.contentTextViewFrame;
    commentTextView.textColor = [UIColor newTitleColor];
    commentTextView.scrollEnabled = NO;
    commentTextView.editable = NO;
    commentTextView.font = [UIFont systemFontOfSize:14.0];
    commentTextView.attributedText = [OSCBaseCommetView contentStringFromRawString:commentItem.content withFont:14.0];
    commentTextView.userInteractionEnabled = NO;
    commentTextView.textContainerInset = UIEdgeInsetsMake(0, -5, 0, 0);
    [self addSubview:commentTextView];
}

- (void)addReplySubViewsWithArray:(NSArray<OSCCommentItemRefer *> *)referArray
                       withLayout:(NSArray<NSValue *> *)layoutArray{
    for (OSCCommentItemRefer *referItem in referArray) {
        NSInteger index = [referArray indexOfObject:referItem];
        CommentReplyLayoutInfo layoutInfo = [layoutArray[index] openBoxCase];
        
        CALayer *leftLine = [CALayer layer];
        leftLine.backgroundColor = [[UIColor separatorColor] CGColor];
        leftLine.frame = layoutInfo.leftLineFrame;
        [self.layer addSublayer:leftLine];
        
        CALayer *bottomLine = [CALayer layer];
        bottomLine.backgroundColor = [[UIColor separatorColor] CGColor];
        bottomLine.frame = layoutInfo.bottomLineFrame;
        [self.layer addSublayer:bottomLine];
        
        UITextView *textView = [UITextView new];
        textView.frame = layoutInfo.contentTextViewFrame;
        textView.font = [UIFont systemFontOfSize:14.0];
        textView.textColor = [UIColor colorWithHex:0x6a6a6a];
        
        NSMutableAttributedString *replyContent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:\n", referItem.author]];
        [replyContent appendAttributedString:[Utils emojiStringFromRawString:[referItem.content deleteHTMLTag]]];
        [replyContent addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0],NSForegroundColorAttributeName:[UIColor colorWithHex:0x6a6a6a]} range:NSMakeRange(0, replyContent.length)];
        textView.attributedText = replyContent;
        textView.scrollEnabled = NO;
        textView.textContainerInset = UIEdgeInsetsMake(0, -5, 0, 0);
        textView.editable = NO;
        textView.userInteractionEnabled = NO;
        [self addSubview:textView];
    }
}

- (void)addRightButtonsViewWithUxiliaryNodeStyle:(CommentUxiliaryNode)uxiliaryNode
                                      isFavorite:(BOOL)isFavorite
                                       likeCount:(NSInteger)likeCount{
    if (uxiliaryNode & CommentUxiliaryNode_none) {
        return;
    }
    
    if (uxiliaryNode & CommentUxiliaryNode_comment) {
        commentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenSize.width - kPaddingRight - kImageView_WH, kPaddingTop, kImageView_WH + 4, kImageView_WH + 4)];
        commentImageView.image = [[super class] commentImage];
        commentImageView.userInteractionEnabled = YES;
        [self addSubview:commentImageView];
    }
    
    if (uxiliaryNode & CommentUxiliaryNode_like) {
        likeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenSize.width - kPaddingRight - kImageView_WH - kFavoriteLabel_W, kPaddingTop, kFavoriteLabel_W, kImageView_WH)];
        likeLabel.font = [UIFont systemFontOfSize:14.0];
        likeLabel.textColor = [UIColor colorWithHex:0x979797];
        likeLabel.text = [NSString stringWithFormat:@"%ld",likeCount];
        likeLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:likeLabel];
        
//  likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(likeLabel.frame) - kFavoriteLabel_padding_FavoriteBtn - kImageView_WH, kPaddingTop, kImageView_WH, kImageView_WH)];
        
        likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenSize.width - kPaddingRight - kImageView_WH, kPaddingTop, kImageView_WH, kImageView_WH)];
        
        likeImageView.image = isFavorite == CommentStatusType_Like? [[super class] likeImage] : [[super class] unlikeImage];
        likeImageView.userInteractionEnabled = YES;
        [self addSubview:likeImageView];
    }
    
    if (uxiliaryNode & CommentUxiliaryNode_customView) {
        return;
    }
}


#pragma mark --- Event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _trackingTouch_portrait = NO;
    _trackingTouch_likeBtn = NO;
    _trackingTouch_commentBtn = NO;
    
    UITouch *touch = touches.anyObject;
    
    CGPoint portraitPoint  = [touch locationInView:userPortrait];
    CGPoint likePoint = [touch locationInView:likeImageView];
    CGPoint commentPoint = [touch locationInView:commentImageView];
    

    
    if (CGRectContainsPoint(userPortrait.bounds, portraitPoint)) {
        _trackingTouch_portrait = YES;
    } else if (CGRectContainsPoint(likeImageView.bounds, likePoint)) {
        _trackingTouch_likeBtn = YES;
    } else if (CGRectContainsPoint(commentImageView.bounds, commentPoint)) {
        _trackingTouch_commentBtn = YES;
    }else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_trackingTouch_portrait) {
        if ([self.delegate respondsToSelector:@selector(commentViewDidClickUserPortrait:)]) {
            [self.delegate commentViewDidClickUserPortrait:self];
        }
    } else if (_trackingTouch_likeBtn) {
        if ([self.delegate respondsToSelector:@selector(commentViewDidClickLikeButton:)]) {
            [self.delegate commentViewDidClickLikeButton:self];
        }
    } else if (_trackingTouch_commentBtn) {
        if ([self.delegate respondsToSelector:@selector(commentViewDidClickCommentButton:)]) {
            [self.delegate commentViewDidClickCommentButton:self];
        }
    }else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!_trackingTouch_portrait || !_trackingTouch_likeBtn || !_trackingTouch_commentBtn) {
        [super touchesMoved:touches withEvent:event];
    }
}

#pragma mark - vote animation

- (void)setVoteStatus:(OSCCommentItem* )commentItem animation:(BOOL)isNeedAnimation{
    UIImage* image = commentItem.voteState == CommentStatusType_Like ? [UIImage imageNamed:@"ic_thumbup_actived"] : [UIImage imageNamed:@"ic_thumbup_normal"];
    
    _isOngoingAnimation = NO;
    
    if (isNeedAnimation) {
        _isOngoingAnimation = YES;
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             likeImageView.layer.transformScale = 1.7;
                         } completion:^(BOOL finished) {
                             [likeImageView setImage:image];
                             [UIView animateWithDuration:0.2
                                                   delay:0
                                                 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  likeImageView.layer.transformScale = 0.9;
                                              } completion:^(BOOL finished) {
                                                  [UIView animateWithDuration:0.2
                                                                        delay:0
                                                                      options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                                                                   animations:^{
                                                                       likeImageView.layer.transformScale = 1;
                                                                   } completion:^(BOOL finished) {
                                                                       _isOngoingAnimation = NO;
                                                                       likeLabel.text = [NSString stringWithFormat:@"%ld", (long)commentItem.vote];
                                                                   }];
                                              }];
                         }];
    } else {
        if (_isOngoingAnimation) {
            [likeImageView.layer removeAllAnimations];
        }
        [likeImageView setImage:image];
        likeLabel.text = [NSString stringWithFormat:@"%ld", (long)commentItem.vote];
    }
}

# pragma 用于生成分享图片

- (void)addContentViewWithModel:(OSCCommentItem *)commentItem isShare:(BOOL)isShare{
    userPortrait = [UIImageView new];
    [userPortrait loadPortrait:[NSURL URLWithString:commentItem.author.portrait] userName:commentItem.author.name];
    userPortrait.frame = commentItem.layoutInfo.userPortraitFrame;
    userPortrait.userInteractionEnabled = YES;
    [userPortrait handleCornerRadiusWithRadius:commentItem.layoutInfo.userPortraitFrame.size.height/2];
    [self addSubview:userPortrait];
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.frame = commentItem.layoutInfo.userNameLbFrame;
    nameLabel.font = [UIFont boldSystemFontOfSize:15.0];
    nameLabel.numberOfLines = 1;
    nameLabel.textColor = [UIColor newTitleColor];
    nameLabel.text = commentItem.author.name.length > 0 ? commentItem.author.name : @"火星网友";
    [self addSubview:nameLabel];
    
//    if (commentItem.author.identity.officialMember) {
//        YYLabel *identityLabel = [YYLabel new];
//        identityLabel.frame = CGRectMake(CGRectGetMaxX(nameLabel.frame)  + 5, nameLabel.frame.origin.y, 50, 16);
//        identityLabel.font = [UIFont systemFontOfSize:10.0];
//        identityLabel.text = @"官方人员";
//        identityLabel.textColor = [UIColor colorWithHex:0x24CF5F];
//        identityLabel.textAlignment = NSTextAlignmentCenter;
//        identityLabel.layer.masksToBounds = YES;
//        identityLabel.layer.cornerRadius = 2;
//        identityLabel.layer.borderColor = [UIColor colorWithHex:0x24CF5F].CGColor;
//        identityLabel.layer.borderWidth = 1;
//        [self addSubview:identityLabel];
//    }
    
    UILabel  *timeLabel = [UILabel new];
    timeLabel.frame = commentItem.layoutInfo.timeLbFrame;
    timeLabel.font = [UIFont systemFontOfSize:10.0];
    timeLabel.numberOfLines = 1;
    timeLabel.textColor = [UIColor newAssistTextColor];
    
    //字符串截取
    NSArray *dateArr = [commentItem.pubDate componentsSeparatedByString:@" "];
    timeLabel.text =  dateArr[0];

    [self addSubview:timeLabel];
    
    [self addReplySubViewsWithArray:commentItem.refer withLayout:commentItem.replysInfo];
    
    //判断是否有 引用评论
    if (commentItem.refer.count <=0) {
        
     //使用YYText 处理富文本行高

        YYLabel *contentL = [[YYLabel alloc] init];
        contentL.numberOfLines = 0;
        contentL.preferredMaxLayoutWidth = kScreenWidth -32;
        
         NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithAttributedString:[OSCBaseCommetView contentStringFromRawString:commentItem.content withFont:24.0]];
        
        //NSTextAttachment可以将要插入的图片作为特殊字符处理
        
        YYAnimatedImageView *imageView1= [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"ic_quote_left"]];
        imageView1.frame = CGRectMake(0, 0, 20, 20);
        
//        imageView1.contentEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);

        
        YYAnimatedImageView *imageView2= [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"ic_quote_right"]];
        imageView2.frame = CGRectMake(0, 0, 20, 20);
        
        //为了有一点空隙，所以增加宽度
        CGSize size1 = CGSizeMake(40, 20);
        CGSize size2 = CGSizeMake(40, 20);

        
        NSMutableAttributedString *attachText1= [NSMutableAttributedString attachmentStringWithContent:imageView1 contentMode:UIViewContentModeScaleAspectFit attachmentSize:size1 alignToFont:[UIFont systemFontOfSize:24] alignment:YYTextVerticalAlignmentCenter];
       
        NSMutableAttributedString *attachText2= [NSMutableAttributedString attachmentStringWithContent:imageView2 contentMode:UIViewContentModeScaleAspectFit attachmentSize:size2 alignToFont:[UIFont systemFontOfSize:24] alignment:YYTextVerticalAlignmentCenter];
 

        [attri insertAttributedString:attachText1 atIndex:0];

        [attri appendAttributedString:attachText2];
        
        //用label的attributedText属性来使用富文本
        contentL.attributedText = attri;

        CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 32, MAXFLOAT);
        
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:maxSize text:attri];
        contentL.textLayout = layout;
        CGFloat introHeight = layout.textBoundingSize.height;
        
        
        contentL.frame =  commentItem.layoutInfo.contentTextViewFrame;
        contentL.width = maxSize.width;
        //        lab.height = ceil(size.height) + 50;
        contentL.height = introHeight + 50;
       
        [self addSubview:contentL];
        self->shareL = contentL;
        
    }else{
    
    commentTextView = [UITextView new];
    commentTextView.textColor = [UIColor newTitleColor];
    commentTextView.scrollEnabled = NO;
    commentTextView.editable = NO;
    commentTextView.attributedText = [OSCBaseCommetView contentStringFromRawString:commentItem.content withFont:14.0];
    
    commentTextView.textContainerInset = UIEdgeInsetsMake(0, -5, 0, 0);
    commentTextView.frame = commentItem.layoutInfo.contentTextViewFrame;

//    CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 32, MAXFLOAT);
//    // 计算文字占据的高度
//    CGSize size = [commentTextView.attributedText boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
//    commentTextView.width = size.width;
//    commentTextView.height = size.height + 25 ;
        
    [self addSubview:commentTextView];
    }
}

- (CGFloat)getShareLHeight {
    return self->shareL.height;
}

@end
