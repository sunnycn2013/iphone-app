//
//  OSCUserHomeCoustomNav.h
//  iosapp
//
//  Created by 王恒 on 16/12/27.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCUserHomeCoustomNav;
@protocol OSCUserHomeCoustomNavDelegate <NSObject>

- (void)backToSuperVC;

- (void)fansClick;

- (void)sendMessageVC;

@end

@interface OSCUserHomeCoustomNav : UIView

@property (nonatomic,assign) id<OSCUserHomeCoustomNavDelegate> delegate;
@property (nonatomic,strong) NSString *userName;

- (instancetype)init;

- (void)changeFavoriteBtnStatus:(UIImage *)image
           withHeightLightImage:(UIImage *)image_H;

- (void)changeCoustomNavWithAlpha:(CGFloat)alpha;

@end
