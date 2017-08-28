//
//  UINavigationController+PushWithAnimation.m
//  iosapp
//
//  Created by 王恒 on 16/11/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "UINavigationController+PushWithAnimation.h"

@implementation UINavigationController (PushWithAnimation)

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    OSCCoustomNavigationDelegate *navigationDelegate = (OSCCoustomNavigationDelegate *)self.delegate;
//    [navigationDelegate PushWithAnimation:OSCPushAnimationTypeDefault WithNavigation:self WithTargetViewController:viewController];
//}

- (void)PushViewController:(UIViewController *)targetVC WithAnimationType:(OSCPushAnimationType)animationType{
    OSCCoustomNavigationDelegate *navigationDelegate = (OSCCoustomNavigationDelegate *)self.delegate;
    [navigationDelegate PushWithAnimation:animationType WithNavigation:self WithTargetViewController:targetVC];
}

@end




@interface OSCCoustomNavigationDelegate ()

@property (nonatomic,assign) OSCPushAnimationType animationType;

@end

@implementation OSCCoustomNavigationDelegate

- (void)PushWithAnimation:(OSCPushAnimationType)animationType
           WithNavigation:(__kindof UINavigationController *)navigation
 WithTargetViewController:(__kindof UIViewController *)targetVC{
    _animationType = animationType;
    [navigation pushViewController:targetVC animated:YES];
}

#pragma --mark UINavigationControllerDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC{
    switch (_animationType) {
        case OSCPushAnimationTypeDefault:
        {
            return nil;
            break;
        }
        case OSCPushAnimationTypeNews:
        {
            return nil;
            break;
        }
        default:
            return nil;
            break;
    }
}


@end
