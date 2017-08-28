//
//  OSCTweetAtMeCell.m
//  iosapp
//
//  Created by 王恒 on 16/12/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetAtMeCell.h"
#import "ImageDownloadHandle.h"
#import "Utils.h"

#import "UIView+Util.h"
#import "UIColor+Util.h"
#import "NSDate+Comment.h"

#import <Masonry.h>
#import <UIImageView+WebCache.h>

#define padding_left 16
#define padding_right padding_left
#define padding_top padding_left
#define padding_bottom padding_left
#define userPortraitImageView_W 44
#define userPortraitImageView_space_nameLabel 8 
#define nameLabel_H 18
#define nameLabel_space_desTextView 8
#define descTextView_space_timeAndSourceLabel 8
#define timeAndSourceLabel_H 15
#define commentCountLabel_W 24
#define commentCountLabel_H 15
#define commentBtn_W 15
#define commentBtn_space_commentCountLabel 8
#define kScreenSize [UIScreen mainScreen].bounds.size

@interface OSCTweetAtMeCell ()<UITextViewDelegate>

@property (nonatomic,weak) UIImageView *userPortraitImageView;
@property (nonatomic,weak) UILabel *nameLabel;
@property (nonatomic,weak) UITextView *descTextView;
@property (nonatomic,weak) UILabel *timeAndSourceLabel;
@property (nonatomic,weak) UILabel *commentCountLabel;
@property (nonatomic,weak) UIImageView *commentBtn;

@end

@implementation OSCTweetAtMeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initContentView];
        [self LayoutUI];
    }
    return self;
}

- (void)initContentView{
    UIImageView *userPortraitImageView = [UIImageView new];
    [userPortraitImageView setCornerRadius:22.0];
    userPortraitImageView.userInteractionEnabled = YES;
    [userPortraitImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserPortraitImageView)]];
    _userPortraitImageView = userPortraitImageView;
    [self.contentView addSubview:_userPortraitImageView];
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.font = [UIFont systemFontOfSize:15.0];
    nameLabel.textColor = [UIColor blackColor];
    _nameLabel = nameLabel;
    [self.contentView addSubview:_nameLabel];
    
    UITextView *descTextView = [UITextView new];
    descTextView.backgroundColor = [UIColor clearColor];
    descTextView.font = [UIFont systemFontOfSize:14];
    descTextView.textColor = [UIColor newTitleColor];
    descTextView.editable = NO;
    descTextView.scrollEnabled = NO;
    [descTextView setTextContainerInset:UIEdgeInsetsZero];
    descTextView.textContainer.lineFragmentPadding = 0;
    [descTextView setContentInset:UIEdgeInsetsMake(0, -1, 0, 1)];
    descTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    [descTextView setTextAlignment:NSTextAlignmentLeft];
    descTextView.delegate = self;
    _descTextView = descTextView;
    [self.contentView addSubview:_descTextView];
    
    UILabel *timeAndSourceLabel = [UILabel new];
    timeAndSourceLabel.font = [UIFont systemFontOfSize:12.0];
    timeAndSourceLabel.textColor = [UIColor newAssistTextColor];
    _timeAndSourceLabel = timeAndSourceLabel;
    [self.contentView addSubview:_timeAndSourceLabel];
    
    UILabel *commentCountLabel = [UILabel new];
    commentCountLabel.font = [UIFont systemFontOfSize:12];
    commentCountLabel.textColor = [UIColor newAssistTextColor];
    _commentCountLabel = commentCountLabel;
    [self.contentView addSubview:_commentCountLabel];
    
    UIImageView *commentBtn = [UIImageView new];
    [commentBtn setImage:[UIImage imageNamed:@"ic_comment_30"]];
    _commentBtn = commentBtn;
    [self.contentView addSubview:_commentBtn];
}

- (void)LayoutUI{
    [_userPortraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(userPortraitImageView_W));
        make.width.equalTo(@(userPortraitImageView_W));
        make.top.equalTo(self.contentView).offset(padding_top);
        make.left.equalTo(self.contentView).offset(padding_left);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(nameLabel_H));
        make.left.equalTo(_userPortraitImageView.mas_right).offset(userPortraitImageView_space_nameLabel);
        make.top.equalTo(self.contentView).offset(padding_top);
        make.right.equalTo(self.contentView).offset(padding_right);
    }];
    
    [_descTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kScreenSize.width - padding_left - userPortraitImageView_W - userPortraitImageView_space_nameLabel - padding_right));
        make.top.equalTo(_nameLabel.mas_bottom).offset(8);
        make.left.equalTo(self.contentView).offset(padding_left + userPortraitImageView_W + userPortraitImageView_space_nameLabel);
    }];
    
    [_timeAndSourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(padding_left + userPortraitImageView_W + userPortraitImageView_space_nameLabel);
        make.top.equalTo(_descTextView.mas_bottom).offset(descTextView_space_timeAndSourceLabel);
        make.height.equalTo(@(timeAndSourceLabel_H));
    }];
    
    [_commentCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-padding_right);
        make.height.equalTo(@(commentCountLabel_H));
        make.top.equalTo(_descTextView.mas_bottom).offset(descTextView_space_timeAndSourceLabel);
    }];
    
    [_commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_commentCountLabel.mas_left).offset(-commentBtn_space_commentCountLabel);
        make.height.equalTo(@(commentBtn_W));
        make.width.equalTo(@(commentBtn_W));
        make.top.equalTo(_descTextView.mas_bottom).offset(descTextView_space_timeAndSourceLabel);
        make.bottom.equalTo(self.contentView).offset(-padding_bottom);
    }];
}

- (void)setItem:(AtMeItem *)item{
    _item = item;
    
    [_userPortraitImageView loadPortrait:[NSURL URLWithString:item.author.portrait] userName:item.author.name];
    
    _nameLabel.text = item.author.name;
    
    _descTextView.attributedText = [Utils contentStringFromRawString:item.content];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:item.pubDate] timeAgoSince]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)item.appClient]];
    _timeAndSourceLabel.attributedText = att;
    
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)item.commentCount];
}

#pragma mark --- Method
- (void)clickUserPortraitImageView{
    if ([_delegate respondsToSelector:@selector(atMeCellDidClickUserPortrait:)]) {
        [_delegate atMeCellDidClickUserPortrait:self];
    }
}

#pragma mark --- textViewDelegate
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([_delegate respondsToSelector:@selector(shouldInteractTextView:URL:inRange:)]) {
        [_delegate shouldInteractTextView:textView URL:URL inRange:characterRange];
    }
    return NO;
}

@end
