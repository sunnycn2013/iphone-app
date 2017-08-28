//
//  OSCGitListTableViewCell.m
//  iosapp
//
//  Created by 王恒 on 17/3/3.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCGitListTableViewCell.h"

#import "UIColor+Util.h"
#import "UIImage+Comment.h"
#import "UIImageView+Comment.h"

#import <UIImageView+WebCache.h>

@interface OSCGitListTableViewCell ()

@property (nonatomic,weak) UIImageView *portraitImageView;
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *descriptionLabel;
@property (nonatomic,weak) UILabel *infoLabel;
@property (nonatomic,weak) UILabel *langueLabel;

@end

@implementation OSCGitListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor themeColor];
        [self setSelectedBackgroundView:selectedBackground];
        [self addContentView];
    }
    return self;
}

- (void)addContentView{
    self.contentView.backgroundColor = [UIColor cellsColor];
    
    UIImageView *portraitImageView = [UIImageView new];
    portraitImageView.layer.masksToBounds = YES;
    _portraitImageView = portraitImageView;
    [self.contentView addSubview:_portraitImageView];
    
    UILabel *titleLabel = [UILabel new];
    _titleLabel = titleLabel;
    _titleLabel.numberOfLines = 0;
    [self.contentView addSubview:_titleLabel];
    
    UILabel *descriptionLabel = [UILabel new];
    descriptionLabel.font = [UIFont systemFontOfSize:13];
    descriptionLabel.numberOfLines = 4;
    descriptionLabel.textColor = [UIColor colorWithHex:0x6A6A6A];
    _descriptionLabel = descriptionLabel;
    [self.contentView addSubview:_descriptionLabel];
    
    UILabel *infoLabel = [UILabel new];
    _infoLabel = infoLabel;
    [self.contentView addSubview:_infoLabel];
    
    UILabel *langueLabel = [UILabel new];
    langueLabel.backgroundColor = [UIColor colorWithHex:0xECECEC];
    langueLabel.layer.borderWidth = 1;
    langueLabel.font = [UIFont systemFontOfSize:10.0];
    langueLabel.textColor = [UIColor colorWithHex:0x9D9D9D];
    langueLabel.textAlignment = NSTextAlignmentCenter;
    langueLabel.layer.borderColor = [UIColor colorWithHex:0xD2D2D2].CGColor;
    _langueLabel = langueLabel;
    [self. contentView addSubview:_langueLabel];
}

- (void)setModel:(OSCGitListModel *)model{
    _model = model;
    [self layoutUI:_model];
    //赋值
    [_portraitImageView loadPortrait:[NSURL URLWithString:model.owner.portrait_new] userName:model.owner.name];
    [_titleLabel setAttributedText:model.titleAttribute];
    _descriptionLabel.text = model.git_description;
    [_infoLabel setAttributedText:model.infoAttribute];
    _langueLabel.text = model.language;
}

- (void)layoutUI:(OSCGitListModel *)model{
    _portraitImageView.frame = model.portraitFrame;
    _portraitImageView.layer.cornerRadius = model.portraitFrame.size.width / 2;
    _titleLabel.frame = model.titleFrame;
    _descriptionLabel.frame = model.descriptionFrame;
    _infoLabel.frame = model.infoFrame;
    _langueLabel.frame = model.langueFrame;
}

@end
