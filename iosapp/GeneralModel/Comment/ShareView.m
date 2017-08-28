//
//  ShareView.m
//  iosapp
//
//  Created by wupei on 2017/4/27.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "ShareView.h"
#import "SelectBoardView.h"

@interface ShareView ()

@property (nonatomic, strong) UIView  *contentView;


@end
@implementation ShareView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutAllSubviews];
    }
    return self;
}

- (void)layoutAllSubviews{
    
    /*创建灰色背景*/
    UIView *bgView = [[UIView alloc] initWithFrame:self.frame];
    bgView.alpha = 0.3;
    bgView.backgroundColor = [UIColor blackColor];
    [self addSubview:bgView];
    
    
    /*添加手势事件,移除View*/
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissContactView:)];
    [bgView addGestureRecognizer:tapGesture];
    
    /*创建显示View*/
    
    SelectBoardView *selectV = [[[UINib nibWithNibName:@"SelectBoardView" bundle:nil] instantiateWithOwner:nil options:nil] lastObject];
    selectV.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 32, 75);
    
    selectV.center = self.center;
    selectV.layer.cornerRadius = 10;
    
    self.selV = selectV;
    [self addSubview:selectV];
}
#pragma mark - 手势点击事件,移除View
- (void)dismissContactView:(UITapGestureRecognizer *)tapGesture{
    
    [self dismissContactView];
}

-(void)dismissContactView
{
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
    
}

// 这里加载在了window上
-(void)showView
{
    UIWindow * window = [UIApplication sharedApplication].windows[0];
    [window addSubview:self];
}


@end
