//
//  OSCInformationTableViewCell.m
//  iosapp
//
//  Created by Graphic-one on 16/11/14.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCInformationTableViewCell.h"
#import "OSCListItem.h"
#import "OSCMenuItem.h"

#import "Utils.h"
#import <YYKit.h>

#import "NSDate+Comment.h"

@interface OSCInformationTableViewCell ()

{
    CGFloat rowHeight ;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) YYLabel *timeLabel;
@property (nonatomic, strong) UIImageView *commentIcon;
@property (nonatomic, strong) YYLabel *commentLabel;
@property (nonatomic, strong) UIImageView *viewIcon;
@property (nonatomic, strong) YYLabel *viewLabel;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation OSCInformationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
        [self addContentView];
    }
    return self;
}

+(instancetype)returnReuseCellFormTableView:(UITableView *)tableView
                                  indexPath:(NSIndexPath *)indexPath
                                 identifier:(NSString *)identifierString
{
    OSCInformationTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierString
                                                        forIndexPath:indexPath];
    
    return cell;
}

- (void)addContentView
{
    _titleLabel = [UILabel new];
    _titleLabel.textColor = [UIColor newTitleColor];
    _titleLabel.font = [UIFont systemFontOfSize:informationCell_titleLB_Font_Size];
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.textColor = [UIColor newSecondTextColor];
    _contentLabel.numberOfLines = 2;
    _contentLabel.font = [UIFont systemFontOfSize:informationCell_descLB_Font_Size];
    [self.contentView addSubview:_contentLabel];
    
    _timeLabel = [YYLabel new];
    _timeLabel.textColor = [UIColor newAssistTextColor];
    _timeLabel.font = [UIFont systemFontOfSize:informationCell_infoBar_Font_Size];
    [self.contentView addSubview:_timeLabel];
    
    _commentIcon = [UIImageView new];
    _commentIcon.contentMode = UIViewContentModeScaleAspectFit;
    _commentIcon.image = [UIImage imageNamed:@"ic_comment"];
    [self.contentView addSubview:_commentIcon];
    
    _commentLabel = [YYLabel new];
    _commentLabel.textColor = [UIColor newAssistTextColor];
    _commentLabel.font = [UIFont systemFontOfSize:informationCell_infoBar_Font_Size];
    [self.contentView addSubview:_commentLabel];
    
    _viewIcon = [UIImageView new];
    _viewIcon.contentMode = UIViewContentModeScaleAspectFit;
    _viewIcon.image = [UIImage imageNamed:@"ic_view"];
    [self.contentView addSubview:_viewIcon];
    
    _viewLabel = [YYLabel new];
    _viewLabel.textColor = [UIColor newAssistTextColor];
    _viewLabel.font = [UIFont systemFontOfSize:informationCell_infoBar_Font_Size];
    [self.contentView addSubview:_viewLabel];
    
    _viewIcon.hidden= YES;
    _viewLabel.hidden= YES;
    
    _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(cell_padding_left, rowHeight-1, CGRectGetWidth(self.contentView.frame), 1)];
    _bottomLine.backgroundColor = [[UIColor colorWithHex:0xC8C7CC] colorWithAlphaComponent:0.7];
    [self.contentView addSubview:_bottomLine];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _titleLabel.frame = _listItem.informationLayoutInfo.titleLbFrame;
    _contentLabel.frame = _listItem.informationLayoutInfo.contentLbFrame;
    
    _timeLabel.frame = _listItem.informationLayoutInfo.timeLbFrame;
    _commentIcon.frame = _listItem.informationLayoutInfo.commentImgFrame;
    _commentLabel.frame = _listItem.informationLayoutInfo.commentCountLbFrame;
    _viewIcon.frame = _listItem.informationLayoutInfo.viewCountImgFrame;
    _viewLabel.frame = _listItem.informationLayoutInfo.viewCountLbFrame;
    
    _bottomLine.frame = CGRectMake(cell_padding_left, rowHeight-1, CGRectGetWidth(self.contentView.frame), 1);
    
    rowHeight = _listItem.rowHeight;
}

- (void)setListItem:(OSCListItem *)listItem{
    _listItem = listItem;
    
    _titleLabel.attributedText = listItem.attributedTitle;
    _contentLabel.text = listItem.body;
    
    NSMutableAttributedString *att ;
    if ([listItem.menuItem.token isEqualToString:@"b4ca1962b3a80823c6138441015d9836"]) {//最新软件（不显示authorName）
        att = [[NSMutableAttributedString alloc] initWithString:[[NSDate dateFromString:listItem.pubDate] timeAgoSince]];
    }else{
        att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@ %@", _listItem.author.name, [[NSDate dateFromString:listItem.pubDate] timeAgoSince]]];
    }
    
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, att.length)];
    att.color = [UIColor newAssistTextColor];
    [_timeLabel setAttributedText:att];
    
    _commentLabel.text = [NSString stringWithFormat:@"%ld",(long)listItem.statistics.comment];
    _viewLabel.text = [NSString stringWithFormat:@"%ld",(long)listItem.statistics.view];
    
    [self layoutSubviews];
}
#pragma mark - 

- (void)setShowCommentCount:(BOOL)showCommentCount
{
    if (showCommentCount) {
        _commentLabel.hidden = NO;
        _commentIcon.hidden = NO;
    } else {
        _commentLabel.hidden = YES;
        _commentIcon.hidden = YES;
    }
}

- (void)setShowViewCount:(BOOL)showViewCount
{
    if (showViewCount) {
        _viewLabel.hidden = NO;
        _viewIcon.hidden = NO;
    } else {
        _viewLabel.hidden = YES;
        _viewIcon.hidden = YES;
    }
}


@end
