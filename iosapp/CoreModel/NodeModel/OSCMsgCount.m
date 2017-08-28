//
//  OSCMsgCount.m
//  iosapp
//
//  Created by Graphic-one on 16/12/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCMsgCount.h"
#import "Config.h"

#import <YYKit.h>

@implementation OSCMsgCount

static NSLock* _lock;
+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lock = [[NSLock alloc] init];
        _lock.name = @"Gra_MsgCountLock";
    });
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    _totalCount = _mention + _review + _letter;
    return YES;
}

- (NSInteger)totalCount{
    if (_totalCount == NSNotFound || _totalCount == 0) {
        _totalCount = _mention + _review + _letter;
    }
    return _totalCount;
}

+ (instancetype)currentMsgCount{
    return [Config getCurMsgCount];
}

+ (void)updateCurMsgCount:(OSCMsgCount* )curMsgCount
{
    [_lock lock];
    
    [Config saveMsgCount:curMsgCount];
    
    [_lock unlock];
}

- (BOOL)isEqualTo:(OSCMsgCount* )msgCount{
    if (_mention == msgCount.mention &&
        _review  == msgCount.review  &&
        _fans    == msgCount.fans &&
        _like    == msgCount.like &&
        _letter  == msgCount.letter)
    {
        return YES;
    }else{
        return NO;
    }
}

- (id)copyWithZone:(nullable NSZone *)zone{
    typeof(self) one = [self.class new];
    one.mention = self.mention;
    one.review = self.review;
    one.fans = self.fans;
    one.like = self.like;
    one.letter = self.letter;
    return one;
}

@end
