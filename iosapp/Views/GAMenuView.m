//
//  GAMenuView.m
//  iosapp
//
//  Created by Graphic-one on 17/2/24.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "GAMenuView.h"
#import "UIImage+Comment.h"

#define menuView_W 50
#define menuView_H 35

@interface GAMenuView ()
@property (nonatomic,copy) void(^oneBlock)();
@property (nonatomic,copy) void(^cancelBlock)();
@end

@implementation GAMenuView

+ (void)MenuViewWithTitle:(NSString* )title
                    block:(void(^)())block
                   inView:(UIView* )view
{
    CGRect targetFrame = [view convertRect:view.bounds toView:[UIApplication sharedApplication].keyWindow];
    GAMenuView* meunView = [[GAMenuView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if (block)  meunView.oneBlock = block;
    meunView.backgroundColor = [UIColor clearColor];
    [meunView addSubview:({
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIImage* image = [UIImage imageNamed:@"bg_popover"];
        image = [image fixOrientation];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
        [btn setBackgroundImage:image forState:UIControlStateNormal];
        [btn addTarget:meunView action:@selector(touchMethod:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = (CGRect){{targetFrame.origin.x + targetFrame.size.width * 0.5 - menuView_W * 0.5 ,targetFrame.origin.y - 5 - menuView_H},{menuView_W,menuView_H}};
        btn;
    })];
    [[UIApplication sharedApplication].keyWindow addSubview:meunView];
}

+ (void)MenuViewWithTitle:(NSString* )title
                    block:(void(^)())block
              cancelBlock:(void(^)())cancelBlock
                   inView:(UIView* )view
{
    CGRect targetFrame = [view convertRect:view.bounds toView:[UIApplication sharedApplication].keyWindow];
    GAMenuView* meunView = [[GAMenuView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if (block)  meunView.oneBlock = block;
    if (cancelBlock) meunView.cancelBlock = cancelBlock;
    meunView.backgroundColor = [UIColor clearColor];
    [meunView addSubview:({
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIImage* image = [UIImage imageNamed:@"bg_popover"];
        image = [image fixOrientation];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
        [btn setBackgroundImage:image forState:UIControlStateNormal];
        [btn addTarget:meunView action:@selector(touchMethod:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = (CGRect){{targetFrame.origin.x + targetFrame.size.width * 0.5 - menuView_W * 0.5 ,targetFrame.origin.y - 5 - menuView_H},{menuView_W,menuView_H}};
        btn;
    })];
    [[UIApplication sharedApplication].keyWindow addSubview:meunView];
}

- (void)touchMethod:(UIButton* )btn{
    if (_oneBlock) {
        _oneBlock();
        [self removeFromSuperview];
    }
}

#pragma mark - touch handle 
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_cancelBlock) {
        _cancelBlock();
    }
    [self removeFromSuperview];
}

@end
