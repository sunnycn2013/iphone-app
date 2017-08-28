//
//  OSCAttendantCell.h
//  iosapp
//
//  Created by 李萍 on 2016/12/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "enumList.h"

@class OSCUserItem, OSCAttendantCell;

@protocol OSCAttendantCellDelegate <NSObject>

- (void)clickActionForAttendantCell:(OSCAttendantCell *)attendantCell relationAction:(UserRelationStatus)relationStatus indexforRow:(NSInteger)row;

- (void)clickActionForAttendantCellUserPortrait:(OSCAttendantCell *)attendantCell;

@end

@interface OSCAttendantCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *portrait;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *genderIcon;
@property (weak, nonatomic) IBOutlet UILabel *idendityLabel;

@property (nonatomic, assign) NSInteger indexPathRow;

@property (nonatomic, strong) OSCUserItem *userItem;
@property (nonatomic, strong) OSCUserItem *loUserItem;

@property (nonatomic, weak) id <OSCAttendantCellDelegate> delegate;
- (void)relationLayoutWithItem:(OSCUserItem *)userItem button:(UIButton *)button;

@end
