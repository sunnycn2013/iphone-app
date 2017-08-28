//
//  OSCCoustomActivityNavBar.m
//  iosapp
//
//  Created by 王恒 on 16/12/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCCoustomActivityNavBar.h"

#import "UIColor+Util.h"

#define kScreenSize [UIScreen mainScreen].bounds.size
#define kPaddingLeft 19
#define kPaddingTop 32
#define kBackBtn_W 8
#define kBackBtn_H 15
#define kButton_space_Button 24

@interface OSCCoustomActivityNavBar ()


@end

@implementation OSCCoustomActivityNavBar

- (instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenSize.width, 64)];
    if(self){
        self.tintColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithRed:36.0/255 green:207.0/255 blue:95.0/255 alpha:0];
        [self addContentView];
    }
    return self;
}

- (void)addContentView{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake( 0, kPaddingTop - 10, 60, 40);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton setImage:[UIImage imageNamed:@"btn_back_normal"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    
    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareBtn.frame = CGRectMake(kScreenSize.width - 40, kPaddingTop - 5, 30, 30);
    [_shareBtn setImage:[[UIImage imageNamed:@"ic_share_black_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_shareBtn addTarget:self action:@selector(clickShare) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_shareBtn];
    
    _favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _favoriteBtn.frame = CGRectMake(kScreenSize.width - 40 - kButton_space_Button - 30 + 10, kPaddingTop - 5, 30, 30);
    [_favoriteBtn setImage:[[UIImage imageNamed:@"ic_fav_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_favoriteBtn addTarget:self action:@selector(clickFavorite) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_favoriteBtn];
}

- (void)favoritButtonIsFavorite:(BOOL)isFavorit{
    if (isFavorit) {
        [_favoriteBtn setImage:[[UIImage imageNamed:@"ic_faved_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
    }else{
        [_favoriteBtn setImage:[[UIImage imageNamed:@"ic_fav_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
}

- (void)setColorWithState:(BOOL)isColor{
    if (isColor) {
        [UIView animateWithDuration:0.4 animations:^{
            self.backgroundColor = [UIColor colorWithRed:36.0/255 green:207.0/255 blue:95.0/255 alpha:1];
        } completion:^(BOOL finished) {
        }];
    }else{
        [UIView animateWithDuration:0.4 animations:^{
            self.backgroundColor = [UIColor colorWithRed:36.0/255 green:207.0/255 blue:95.0/255 alpha:0];
        }];
    }
}
//
#pragma mark --- Method
- (void)clickBack{
    if ([_delegate respondsToSelector:@selector(ClickBackBtn)]) {
        [_delegate ClickBackBtn];
    }
}

- (void)clickFavorite{
    if ([_delegate respondsToSelector:@selector(ClickFavoriteBtn)]) {
        [_delegate ClickFavoriteBtn];
    }
}

- (void)clickShare{
    if ([_delegate respondsToSelector:@selector(ClickShareBtn)]) {
        [_delegate ClickShareBtn];
    }
}

@end
