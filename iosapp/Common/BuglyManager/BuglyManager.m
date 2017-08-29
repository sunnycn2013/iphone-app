//
//  BuglyManager
//  CaibeiMarket
//
//  Created by icaibei on 2017/8/19.
//  Copyright © 2017年 qianji. All rights reserved.
//

#import "BuglyManager.h"
#import <Bugly/Bugly.h>

#define CMBuglyKey @"eb0ecba716"

@implementation BuglyManager

+ (void)initBugly
{
    BuglyConfig * config = [[BuglyConfig alloc] init];
    config.blockMonitorEnable = YES;
    [Bugly startWithAppId:CMBuglyKey config:config];
}

@end
