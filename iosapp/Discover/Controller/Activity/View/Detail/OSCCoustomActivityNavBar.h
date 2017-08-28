//
//  OSCCoustomActivityNavBar.h
//  iosapp
//
//  Created by 王恒 on 16/12/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCCoustomActivityNavBar;
@protocol OSCCoustomActivityNavBarDelegate <NSObject>

- (void)ClickBackBtn;

- (void)ClickFavoriteBtn;

- (void)ClickShareBtn;

@end

@interface OSCCoustomActivityNavBar : UIView

@property (nonatomic, strong) UIButton *favoriteBtn;
@property (nonatomic, strong) UIButton *shareBtn;

@property (nonatomic,assign) id<OSCCoustomActivityNavBarDelegate> delegate;

- (instancetype)init;

- (void)favoritButtonIsFavorite:(BOOL)isFavorit;

- (void)setColorWithState:(BOOL)isColor;

@end
