//
//  OSCAttendantCell.m
//  iosapp
//
//  Created by 李萍 on 2016/12/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCAttendantCell.h"
#import "OSCUserItem.h"

#import "Utils.h"
#import "UIButtonColorHF.h"

@interface OSCAttendantCell ()

@property (nonatomic, assign) NSInteger loIndexPathRow;

@end

@implementation OSCAttendantCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _genderIcon.layer.borderWidth = 1.0;
    _genderIcon.layer.borderColor = [UIColor colorWithHex:0xffffff].CGColor;
    
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    _portrait.clipsToBounds = YES;
    _portrait.layer.cornerRadius = 22.5;
    
    _idendityLabel.textColor = [UIColor colorWithHex:0x24CF5F];
    _idendityLabel.layer.masksToBounds = YES;
    _idendityLabel.layer.cornerRadius = 2;
    _idendityLabel.layer.borderColor = [UIColor colorWithHex:0x24CF5F].CGColor;
    _idendityLabel.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setIndexPathRow:(NSInteger)indexPathRow
{
    self.loIndexPathRow = indexPathRow;
}

- (void)setUserItem:(OSCUserItem *)userItem
{
    self.loUserItem = userItem;
    
    [_portrait loadPortrait:[NSURL URLWithString:userItem.portrait] userName:userItem.name];
    _nameLabel.text = userItem.name.length ? userItem.name : @"匿名用户";
    NSString *desc = [NSString stringWithFormat:@"%@ %@ %@", userItem.eventInfo.name, userItem.eventInfo.company, userItem.eventInfo.job];
    _descLabel.text = desc.length ? desc : @" ";

    _followButton.tag = (self.loIndexPathRow == NSNotFound ? 0 : self.loIndexPathRow)+1;
    
    [self relationLayoutWithItem:userItem button:_followButton];
    
    [_followButton addTarget:self action:@selector(relationAction:) forControlEvents:UIControlEventTouchUpInside];
    _portrait.userInteractionEnabled = YES;
	_nameLabel.userInteractionEnabled = YES;
	_descLabel.userInteractionEnabled = YES;
    [_portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserPortrait:)]];
	[_nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserPortrait:)]];
	[_descLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserPortrait:)]];
    
    _idendityLabel.hidden = !userItem.identity.officialMember;
	
    switch (userItem.gender) {
        case UserGenderTypeMan:
        {
            _genderIcon.hidden = NO;
            [_genderIcon setImage:[UIImage imageNamed:@"ic_male"]];
            break;
        }
        case UserGenderTypeWoman:
        {
            _genderIcon.hidden = NO;
            [_genderIcon setImage:[UIImage imageNamed:@"ic_female"]];
            break;
        }
        default:
        {
            _genderIcon.hidden = YES;
            break;
        }
            break;
    }
}

- (void)relationLayoutWithItem:(OSCUserItem *)userItem button:(UIButton *)button
{
    button.backgroundColor = ButtonNormalBackgroundColor;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.enabled = YES;
    switch (userItem.relation) {
        case UserRelationStatusMutual://双方互为粉丝
        case UserRelationStatusSelf://你单方面关注他
            [_followButton setTitle:@"已关注" forState:UIControlStateNormal];
            break;
        case UserRelationStatusOther://他单方面关注我
        case UserRelationStatusNone: //互不关注
            [_followButton setTitle:@"关注" forState:UIControlStateNormal];
            break;
        default:
        {
            _followButton.backgroundColor = ButtonDissableBackgroundColor;
            [_followButton setTitle:@"关注" forState:UIControlStateNormal];
            [_followButton setTitleColor:ButtonDissableTextColor forState:UIControlStateNormal];
            _followButton.enabled = NO;
            break;
        }
    }
}

#pragma mark - relationAction 
- (void)relationAction:(UIButton *)button
{
    NSInteger tags = button.tag - 1;
    
    if ([_delegate respondsToSelector:@selector(clickActionForAttendantCell:relationAction:indexforRow:)]) {
        [_delegate clickActionForAttendantCell:self relationAction:self.loUserItem.relation indexforRow:tags];
    }
}

- (void)clickUserPortrait:(UITapGestureRecognizer *)tap
{
    if ([_delegate respondsToSelector:@selector(clickActionForAttendantCellUserPortrait:)]) {
        [_delegate clickActionForAttendantCellUserPortrait:self];
    }
}

@end
