//
//  NSDate+Comment.h
//  iosapp
//
//  Created by Graphic-one on 16/12/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DateTools.h>

NS_ENUM(NSInteger,TimeValueType){
    ValueTypeOfSecondAgo = 0,
    ValueTypeOfMinuteAgo,
    ValueTypeOfHourAgo,
    ValueTypeOfDayAgo,
    ValueTypeOfWeekAgo,
    ValueTypeOfMonthAgo,
    ValueTypeOfYearAgo
};

@interface NSDate (Comment)

+ (instancetype)dateFromString:(NSString *)string;
- (NSString *)weekdayString;

- (NSString* )timeAgoSince;

@end
