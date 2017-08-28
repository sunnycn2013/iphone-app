//
//  NSDate+Comment.m
//  iosapp
//
//  Created by Graphic-one on 16/12/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NSDate+Comment.h"
#import "NSDateFormatter+Singleton.h"
#import <NSDate+YYAdd.h>

static NSString * const kKeyYears = @"years";
static NSString * const kKeyMonths = @"months";
static NSString * const kKeyDays = @"days";
static NSString * const kKeyHours = @"hours";
static NSString * const kKeyMinutes = @"minutes";

@implementation NSDate (Comment)

- (NSString* )timeAgoSince
{
    NSDate* curDate = [NSDate date];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour;
    NSDateComponents* components = [calendar components:unitFlags fromDate:self toDate:curDate options:0];
    
    if (components.hour < 24) {
        if (components.hour >= 1) {
            return [self localizedStringForType:ValueTypeOfHourAgo value:components];
        }else if (components.minute) {
            return [self localizedStringForType:ValueTypeOfMinuteAgo value:components];
        }else{
            return [self localizedStringForType:ValueTypeOfSecondAgo value:components];
        }
    }else{
        NSUInteger bigUnit = NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear;
        NSDateComponents *bigComponents = [calendar components:bigUnit fromDate:self toDate:curDate options:0];
        if (bigComponents.year > 0) {
            return [self localizedStringForType:ValueTypeOfYearAgo value:bigComponents];
        }else if (bigComponents.month > 0){
            return [self localizedStringForType:ValueTypeOfMonthAgo value:bigComponents];
        }else if (bigComponents.weekOfYear > 0){
            return [self localizedStringForType:ValueTypeOfWeekAgo value:bigComponents];
        }else{
            return [self localizedStringForType:ValueTypeOfDayAgo value:bigComponents];
        }
    }
}

- (NSString *)localizedStringForType:(NSInteger)type value:(NSDateComponents *)components{
    NSDate* curDate = [NSDate date];
    NSDateFormatter *hourFormatter = [NSDateFormatter new];
    hourFormatter.dateFormat = @"HH";
    float currentHour = [[hourFormatter stringFromDate:curDate] floatValue];
    
    NSString *timeString;
    
    switch (type) {
        case ValueTypeOfSecondAgo:
            timeString = @"刚刚";
            break;
        case ValueTypeOfMinuteAgo:
            timeString = [NSString stringWithFormat:@"%ld分钟前", (long)components.minute];
            break;
        case ValueTypeOfHourAgo:
            timeString = [NSString stringWithFormat:@"%ld小时前", (long)components.hour];
            break;
        case ValueTypeOfDayAgo:{
            if (components.day == 1 && components.hour < currentHour) {
                timeString = [NSString stringWithFormat:@"昨天"];
            }else if(components.day == 1 && components.hour > currentHour){
                timeString = [NSString stringWithFormat:@"2天前"];
            }else{
                if (components.hour <= currentHour) {
                    timeString = [NSString stringWithFormat:@"%ld天前", (long)components.day];
                }else if(components.day != 6){
                    timeString = [NSString stringWithFormat:@"%ld天前", (long)components.day + 1];
                }else{
                    timeString = [NSString stringWithFormat:@"上星期"];
                }
            }
        }
            break;
        case ValueTypeOfWeekAgo:{
            if(components.weekOfYear == 1){
                timeString = [NSString stringWithFormat:@"上星期"];
            }else{
                timeString = [NSString stringWithFormat:@"%ld星期前", (long)components.weekOfYear];
            }
        }
            break;
        case ValueTypeOfMonthAgo:
            timeString = [NSString stringWithFormat:@"%ld个月前", (long)components.month];
            break;
        case ValueTypeOfYearAgo:
            timeString = [NSString stringWithFormat:@"%ld年前", (long)components.year];
            break;
        default:
            break;
    }
    
    return timeString;
}

+ (instancetype)dateFromString:(NSString *)string
{
    return [[NSDateFormatter sharedInstance] dateFromString:string];
}

- (NSString *)weekdayString
{
    switch (self.weekday) {
        case 1: return @"星期天";
        case 2: return @"星期一";
        case 3: return @"星期二";
        case 4: return @"星期三";
        case 5: return @"星期四";
        case 6: return @"星期五";
        case 7: return @"星期六";
        default: return @"";
    }
}

@end
