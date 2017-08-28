//
//  OSCStatistics.m
//  iosapp
//
//  Created by Graphic-one on 16/12/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCStatistics.h"

@implementation OSCStatistics

- (id)mutableCopyWithZone:(NSZone *)zone{
    OSCStatistics* copy = [[OSCStatistics allocWithZone:zone] init];
    copy.comment = _comment;
    copy.view = _view;
    copy.like = _like;
    copy.transmit = _transmit;
    return copy;
}

@end
