//
//  OSCActivityTableViewCell.m
//  iosapp
//
//  Created by Graphic-one on 16/5/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCActivityTableViewCell.h"
#import "OSCActivities.h"
#import "OSCListItem.h"
#import "OSCTweetItem.h"
#import "Utils.h"

#import <UIImageView+WebCache.h>

NSString* OSCActivityTableViewCell_IdentifierString = @"OSCActivityTableViewCellReuseIdenfitier";

@interface OSCActivityTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UILabel *activityStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityAreaLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *peopleNumLabel;

@end

@implementation OSCActivityTableViewCell

- (void)prepareForReuse{
    [super prepareForReuse];
    _activityImageView.image = nil;
    _activityImageView.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
    _activityImageView.contentMode = UIViewContentModeCenter;
    _descLabel.textColor = [UIColor newTitleColor];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _descLabel.textColor = [UIColor newTitleColor];
    _activityStatusLabel.backgroundColor = [UIColor titleBarColor];
    _activityAreaLabel.backgroundColor = [UIColor titleBarColor];
    _activityImageView.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
    _activityImageView.contentMode = UIViewContentModeCenter;
}

#pragma mark - public method 
+(instancetype)returnReuseCellFormTableView:(UITableView *)tableView
                                  indexPath:(NSIndexPath *)indexPath
                                 identifier:(NSString *)identifierString
{
    OSCActivityTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierString
                                                                     forIndexPath:indexPath];
    
    
    return cell;

}

#pragma mark - setting VM
-(void)setViewModel:(OSCActivities* )viewModel{
    _viewModel = viewModel;
    
    [_activityImageView sd_setImageWithURL:[NSURL URLWithString:viewModel.img] placeholderImage:[UIImage imageNamed:@"event_cover_default"] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(!error){
            _activityImageView.contentMode = UIViewContentModeScaleToFill;
        }
    }];
    _descLabel.text = viewModel.title;
    
    NSString *statusStr;
    switch (viewModel.status) {
        case ActivityStatusEnd:
            statusStr = @"  活动结束  ";
            [self setSelectedBorderWidth:NO];
            break;
        case ActivityStatusHaveInHand:
            [self setSelectedBorderWidth:YES];
            statusStr = @"  正在报名  ";
            break;
        case ActivityStatusClose:
            [self setSelectedBorderWidth:NO];
            statusStr = @"  报名截止  ";
            break;
            
        default:
            break;
    }
    _activityStatusLabel.text = statusStr;
    
    NSString *areaStr;
    switch (viewModel.type) {
        case ActivityTypeOSChinaMeeting:
            areaStr = @" 源创会 ";
            break;
        case ActivityTypeTechnical:
            areaStr = @" 技术交流 ";
            break;
        case ActivityTypeOther:
            areaStr = @" 其他 ";
            break;
        case ActivityTypeBelow:
            areaStr = @" 站外活动 ";
            break;
        default:
            break;
    }

    _activityAreaLabel.text = areaStr;
    _timeLabel.text = [viewModel.startDate substringToIndex:16];
    //_peopleNumLabel.text = [NSString stringWithFormat:@"%ld人参与", (long)viewModel.applyCount];
}

- (void)setListItem:(OSCListItem *)listItem{
    _listItem = listItem;
    
    if (listItem.images.count > 0) {
        OSCNetImage* imageData = [listItem.images lastObject];
        [_activityImageView sd_setImageWithURL:[NSURL URLWithString:imageData.href] placeholderImage:[UIImage imageNamed:@"event_cover_default"] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(!error){
                _activityImageView.contentMode = UIViewContentModeScaleToFill;
            }
        }];
    }else{
        _activityImageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
    }
    _descLabel.text = listItem.title;
    
    NSString *statusStr;
    switch (listItem.extra.eventStatus) {
        case ActivityStatusEnd:
            statusStr = @"  活动结束  ";
            [self setSelectedBorderWidth:NO];
            break;
        case ActivityStatusHaveInHand:
            [self setSelectedBorderWidth:YES];
            statusStr = @"  正在报名  ";
            break;
        case ActivityStatusClose:
            [self setSelectedBorderWidth:NO];
            statusStr = @"  报名截止  ";
            break;
            
        default:
            break;
    }
    _activityStatusLabel.text = statusStr;
    
    NSString *areaStr;
    switch (listItem.extra.eventType) {
        case ActivityTypeOSChinaMeeting:
            areaStr = @" 源创会 ";
            break;
        case ActivityTypeTechnical:
            areaStr = @" 技术交流 ";
            break;
        case ActivityTypeOther:
            areaStr = @" 其他 ";
            break;
        case ActivityTypeBelow:
            areaStr = @" 站外活动 ";
            break;
        default:
            break;
    }
    
    _activityAreaLabel.text = areaStr;
    _timeLabel.text = [listItem.extra.eventStartDate substringToIndex:16];
    //_peopleNumLabel.text = [NSString stringWithFormat:@"%ld人参与", (long)listItem.extra.eventApplyCount];
}

- (void)setSelectedBorderWidth:(BOOL)isSelected
{
    if (isSelected) {
        _activityStatusLabel.layer.borderWidth = 1.0;
        _activityStatusLabel.layer.borderColor = [UIColor newSectionButtonSelectedColor].CGColor;
        _activityStatusLabel.textColor = [UIColor newSectionButtonSelectedColor];
    } else {
        _activityStatusLabel.layer.borderWidth = 0;
        _activityStatusLabel.textColor = [UIColor colorWithHex:0x9d9d9d];
    }
}

- (void)setCompleteRead{
    _descLabel.textColor = [UIColor lightGrayColor];
}


@end
