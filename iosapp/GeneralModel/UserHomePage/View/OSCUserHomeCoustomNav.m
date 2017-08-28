//
//  OSCUserHomeCoustomNav.m
//  iosapp
//
//  Created by 王恒 on 16/12/27.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCUserHomeCoustomNav.h"


#define kScreenSize [UIScreen mainScreen].bounds.size
#define rightBtnWH 36
#define stautsH 20
#define favorite_space_superView 12
#define message_space_favorite 12

@interface OSCUserHomeCoustomNav ()

{
    UIButton *_favoriteBtn;
    UILabel *_userNameLabel;
}

@end

@implementation OSCUserHomeCoustomNav

- (instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenSize.width, 64)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:36.0/255 green:207.0/255 blue:95.0/255 alpha:0];
        [self addContentView];
    }
    return self;
}

- (void)addContentView{
    //统一Y
    CGFloat Y = stautsH + (64 - stautsH - rightBtnWH)/2;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, Y, rightBtnWH, rightBtnWH);
    [backButton setImage:[UIImage imageNamed:@"btn_back_normal"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    
    _favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _favoriteBtn.frame = CGRectMake(kScreenSize.width - rightBtnWH - favorite_space_superView, Y, rightBtnWH, rightBtnWH);
    [_favoriteBtn addTarget:self action:@selector(clickFavorite) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_favoriteBtn];
    
    UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    messageBtn.frame = CGRectMake(CGRectGetMinX(_favoriteBtn.frame) - rightBtnWH - message_space_favorite, Y, rightBtnWH, rightBtnWH);
    [messageBtn setImage:[UIImage imageNamed:@"btn_pm_normal"] forState:UIControlStateNormal];
    [messageBtn setBackgroundImage:[UIImage imageNamed:@"btn_pm_pressed"] forState:UIControlStateHighlighted];
    [messageBtn addTarget:self action:@selector(clickMessage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:messageBtn];
    
    CGFloat nameLabelW = (CGRectGetMinX(messageBtn.frame) - 12 - kScreenSize.width/2) * 2;
    CGFloat nameLabelX = CGRectGetMinX(messageBtn.frame) - nameLabelW - 12;
    _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, Y, nameLabelW, rightBtnWH)];
    _userNameLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _userNameLabel.textColor = [UIColor whiteColor];
    _userNameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_userNameLabel];
    _userNameLabel.hidden = YES;
}

#pragma mark --- Method
- (void)backClick{
    if ([self.delegate respondsToSelector:@selector(backToSuperVC)]) {
        [self.delegate backToSuperVC];
    }
}

- (void)clickFavorite{
    if ([self.delegate respondsToSelector:@selector(fansClick)]) {
        [self.delegate fansClick];
    }
}

- (void)clickMessage{
    if ([self.delegate respondsToSelector:@selector(sendMessageVC)]) {
        [self.delegate sendMessageVC];
    }
}

- (void)changeFavoriteBtnStatus:(UIImage *)image
           withHeightLightImage:(UIImage *)image_H{
    [_favoriteBtn setBackgroundImage:image forState:UIControlStateNormal];
    [_favoriteBtn setBackgroundImage:image_H forState:UIControlStateHighlighted];
}

- (void)changeCoustomNavWithAlpha:(CGFloat)alpha{
    self.backgroundColor = [UIColor colorWithRed:36.0/255 green:207.0/255 blue:95.0/255 alpha:alpha];
    if (alpha > 0) {
        _userNameLabel.hidden = NO;
    }else{
        _userNameLabel.hidden = YES;
    }
}

- (void)setUserName:(NSString *)userName{
    _userName = userName;
    _userNameLabel.text = userName;
}

@end
