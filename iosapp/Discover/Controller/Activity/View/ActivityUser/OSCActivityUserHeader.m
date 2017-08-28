//
//  OSCActivityUserHeader.m
//  iosapp
//
//  Created by 王恒 on 17/4/12.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCActivityUserHeader.h"

#import <Masonry.h>

#import "UIColor+Util.h"

#define kPaddingLeftRight 16
#define kPaddingTopBottom 16
#define kFontSize 18
#define kScreenSize [UIScreen mainScreen].bounds.size

@implementation OSCActivityUserHeader

- (instancetype)initWithTitle:(NSString *)title{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:0XF6F6F6];
        [self addContentViewWithTitle:title];
    }
    return self;
}

- (void)addContentViewWithTitle:(NSString *)title{
    CGFloat titleHeight = [self getHeightWithString:title WithWidth:kScreenSize.width - 2*kPaddingLeftRight];
    self.frame = CGRectMake(0, 0, kScreenSize.width, titleHeight + 2 * kPaddingTopBottom);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftRight, kPaddingTopBottom, kScreenSize.width - 2*kPaddingLeftRight, titleHeight)];
    label.font = [UIFont systemFontOfSize:kFontSize];
    label.numberOfLines = 0;
    label.textColor = [UIColor colorWithHex:0x111111];
    label.text = title;
    [self addSubview:label];
}

- (CGFloat)getHeightWithString:(NSString *)string WithWidth:(CGFloat)width{
    CGRect stringRect = [string boundingRectWithSize:CGSizeMake(width, MAX_CANON) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kFontSize]} context:nil];
    return stringRect.size.height;
}

@end
