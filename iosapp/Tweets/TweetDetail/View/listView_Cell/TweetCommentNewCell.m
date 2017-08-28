//
//  TweetCommentNewCell.m
//  iosapp
//
//  Created by Holden on 16/6/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetCommentNewCell.h"
#import "UIImageView+Comment.h"
#import "Utils.h"
#import "UIColor+Util.h"
#import "NSDate+Comment.h"

#import <YYKit.h>

@implementation TweetCommentNewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_portraitIv setCornerRadius:16];
    _commentTagIv.userInteractionEnabled = YES;
    _portraitIv.userInteractionEnabled = YES;
    _idendityLabel.textColor = [UIColor colorWithHex:0x24CF5F];
    _idendityLabel.layer.masksToBounds = YES;
    _idendityLabel.layer.cornerRadius = 2;
    _idendityLabel.layer.borderColor = [UIColor colorWithHex:0x24CF5F].CGColor;
    _idendityLabel.layer.borderWidth = 1;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
}

-(void)setCommentModel:(OSCCommentItem *)commentModel {
    
    [self.portraitIv loadPortrait:[NSURL URLWithString:commentModel.author.portrait] userName:commentModel.author.name];
    [self.nameLabel setText:commentModel.author.name];
    
    if (commentModel.author.identity.officialMember) {
        _idendityLabel.hidden = NO;
    }else{
        _idendityLabel.hidden = YES;
    }
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[[NSDate dateFromString:commentModel.pubDate] timeAgoSince]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
//    [att appendAttributedString:[Utils getAppclientName:(int)commentModel.appClient]];
    att.color = [UIColor newAssistTextColor];
    self.interalTimeLabel.attributedText = att;
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:commentModel.content]];
    if (commentModel.replies.count > 0) {
        [contentString appendAttributedString:[OSCCommentItem attributedTextFromReplies:commentModel.replies]];
    }
    [self.contentLabel setAttributedText:contentString];
}

#pragma mark - 处理长按操作

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return _canPerformAction(self, action);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)copyText:(id)sender {
    self.backgroundColor = [UIColor whiteColor];
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:_contentLabel.text];
}

- (void)deleteObject:(id)sender {
    self.backgroundColor = [UIColor whiteColor];
    _deleteObject(self);
}


@end
