//
//  UINavigationController+PushWithAnimation.h
//  iosapp
//
//  Created by 王恒 on 16/11/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , OSCPushAnimationType){
    OSCPushAnimationTypeDefault = 0,
    OSCPushAnimationTypeNews,
};

@interface UINavigationController (PushWithAnimation)

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)PushViewController:(__kindof UIViewController *)targetVC
         WithAnimationType:(OSCPushAnimationType)animationType;

@end






@interface OSCCoustomNavigationDelegate : NSObject <UINavigationControllerDelegate>

- (void)PushWithAnimation:(OSCPushAnimationType)animationType
           WithNavigation:(__kindof UINavigationController *)navigation
 WithTargetViewController:(__kindof UIViewController *)targetVC;

@end
