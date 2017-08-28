//
//  ActivityDetailCell.m
//  iosapp
//
//  Created by 李萍 on 16/5/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ActivityDetailCell.h"
#import "Utils.h"
#import "GAMenuView.h"

@implementation ActivityDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor themeColor];
    
    _label.hidden = NO;
    _iconImageView.hidden = NO;
    
    _activityBodyView.hidden = YES;
    
    _activityBodyView.scrollView.bounces = NO;
    _activityBodyView.scrollView.scrollEnabled = NO;
    _activityBodyView.opaque = NO;
    _activityBodyView.backgroundColor = [UIColor themeColor];
}

- (void)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString:@"priceType"]) {
        _label.hidden = NO;
        _iconImageView.hidden = NO;
        
        _activityBodyView.hidden = YES;
        
        _iconImageView.image = [UIImage imageNamed:@"ic_ticket"];
    } else if ([identifier isEqualToString:@"timeType"]) {
        _label.hidden = NO;
        _iconImageView.hidden = NO;
        
        _activityBodyView.hidden = YES;
        
        _iconImageView.image = [UIImage imageNamed:@"ic_calendar"];
    } else if ([identifier isEqualToString:@"addressType"]) {
        _label.hidden = NO;
        _iconImageView.hidden = NO;
        
        _activityBodyView.hidden = YES;
        
        _iconImageView.image = [UIImage imageNamed:@"ic_location"];
    } else if ([identifier isEqualToString:@"descType"]) {
        _label.hidden = YES;
        _iconImageView.hidden = YES;
        
        _activityBodyView.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - CONTENT

- (void)setActivity:(OSCListItem *)activity
{
    [self dequeueReusableCellWithIdentifier:_cellType];
    
    if ([_cellType isEqualToString:@"priceType"]) {
        _label.text = activity.extra.eventCostDesc;
        
    } else if ([_cellType isEqualToString:@"timeType"]) {
        _label.text = [self componentsSeparatedEventStartDate:activity.extra.eventStartDate];
        
    } else if ([_cellType isEqualToString:@"addressType"]) {
        NSString *address = [NSString stringWithFormat:@"%@ %@ %@", activity.extra.eventProvince, activity.extra.eventCity, activity.extra.eventSpot];
        _label.text = address;
        
    }
}

//时间去除秒数
- (NSString *)componentsSeparatedEventStartDate:(NSString *)eventStartDate
{
    NSArray *array = [eventStartDate componentsSeparatedByString:@":"];
    NSString *timeStr = [NSString stringWithFormat:@"%@:%@", array[0], array[1]];
    
    return timeStr;
}

#pragma mark - copy handle

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([_cellType isEqualToString:@"addressType"]) {
        [GAMenuView MenuViewWithTitle:@"复制" block:^{
            UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:_label.text];
        } inView:_label];
    }
}

@end
